local spawn = require('coro-spawn')
local split = require('coro-split')
local parse = require('url').parse
local isActive = false
local songQueue = {}

function getStream(url)
    local child = spawn('youtube-dl', {
        args = {'-g', url},
        stdio = {nil, true, true}
    })
    local stream
    function readstdout()
        local stdout = child.stdout
        for chunk in stdout.read do
            local mime = parse(chunk, true).query.mime
            if mime and mime:find('audio') then
                stream = chunk
            end
        end
        return pcall(stdout.handle.close, stdout.handle)
    end
    function readstderr()
        local stderr = child.stderr
        for chunk in stderr.read do
            print(chunk)
        end
        return pcall(stderr.handle.close, stderr.handle)
    end
    split(readstdout, readstderr, child.waitExit)
    return stream and stream:gsub('%c', '')
end

local play
play = function(vc, connection)
    if next(songQueue) == nil then
        connection:close()
        isActive = false
        return
    end
    local conn = vc:join()
    isActive = true
    conn:playFFmpeg(table.remove(songQueue,1))
    play(vc, conn)
end

return {
	name = 'play',
	description = 'description',
    command = function(args, message, client, rest)

        local requester = message.guild:getMember(message.author)
        local vc = requester.voiceChannel

        if vc == nil then
            message.channel:send('You must be connected to a voice channel in order to use this command')
            return
        end

        table.insert(songQueue, getStream(args[1]))
        if not isActive then
            play(vc, nil)
        end
	end
};