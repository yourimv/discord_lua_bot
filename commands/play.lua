local spawn = require('coro-spawn')
local parse = require('url').parse


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

        local connection = vc:join()
        local child = spawn('youtube-dl', {
            args = {'-g', args[1]},
            stdio = { nil, true, 2 }
        })

        local stream
        for chunk in child.stdout.read do
            local urls = chunk:split('\n')

            for _, yturl in pairs(urls) do
                local mime = parse(yturl, true).query.mime

                if mime and mime:find('audio') == 1 then
                    stream = yturl
                end
            end
        end
        message.channel:send('Playing '..args[1]..' :musical_note:')
        connection:playFFmpeg(stream)
        connection:close()
	end
};