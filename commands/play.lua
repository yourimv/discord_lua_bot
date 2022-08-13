local helpers = require('helpers')
local json = require('../json')
local spawn = require('coro-spawn')
local parse = require('url').parse
local isActive = {}
local songQueue = {}
local streamObj = {}
local songObj = {}

local function setStreamObject (ytobj, message)
    streamObj[message.channel.guild.id] = nil
    if ytobj == nil then return end
    local oldUrl = ytobj.url
    if string.sub(ytobj.url, 1, #"https:") ~= "https:" then
        ytobj.url = "ytsearch:" .. ytobj.url
    end
    local res = spawn('youtube-dl', {
        args = { '-g', ytobj.url },
        stdio = { nil, true, 2 }
    })
    if not res then return message.channel:send('Error sourcing youtube-dl') end
    local msg = message.channel:send('Fetching '..oldUrl..'... :fishing_pole_and_fish:')
    local stream
    for chunk in res.stdout.read do
        local urls = chunk:split('\n')
        for _, yturl in pairs(urls) do
            local mime = parse(yturl, true).query.mime
            if mime and mime:find('audio') == 1 then
                stream = yturl
            end
        end
    end
    streamObj[message.channel.guild.id] = stream
    msg:setContent('Now playing: '..ytobj.title..' :ok_hand:')
end

local function getYoutubeVideoInfo(url, message)
    if string.sub(url, 1, #"https:") ~= "https:" then
        url = "ytsearch:" .. url
    end
    local res = spawn("youtube-dl", {
        args = { "-j", "--rm-cache-dir", "--skip-download", url },
        stdio = {nil, true, nil}
    })
    if not res then return message.channel:send('Error sourcing youtube-dl') end
    local info = {}
    local json_string=""
    for i in res.stdout.read do
        json_string = json_string .. i
    end
    local decodedJson = json.decode(json_string)
    for _, formats in pairs(decodedJson.formats) do
        if formats["protocol"] == "https" and formats["container"] == "m4a_dash" then
            info["stream_url"] = formats["url"]
            break
        end
    end
    info["title"] = decodedJson["title"]
    info["thumbnail"] = decodedJson["thumbnail"]
    info["fulltitle"] = decodedJson["fulltitle"]
    info["view_count"] = decodedJson["view_count"]
    info["duration"] = decodedJson["duration"]
    info["channel_url"] = decodedJson["channel_url"]
    info["uploader"] = decodedJson["uploader"]
    info["video_url"] = "https://www.youtube.com/watch?v="..decodedJson["id"]
    return info
end

local play
play = function(vc, connection, message)
    if streamObj[message.channel.guild.id] == nil then
        connection:close()
        isActive[message.channel.guild.id] = false
        return
    end
    local conn = vc:join()
    local song = streamObj[message.channel.guild.id]
    conn:playFFmpeg(song)
    songObj[message.channel.guild.id] = table.remove(songQueue[message.channel.guild.id], 1)
    setStreamObject(songObj[message.channel.guild.id], message)
    play(vc, conn, message)
end

return {
	name = 'play',
	description = 'Plays a song from a youtube. If no URL is provided, the bot will search for a song!',
    aliases = { "skip", "queue" },
    command = function(args, message, client, rest)
        if args[1] == nil then return message.channel:send('You must enter an additional argument') end
        local requester = message.guild:getMember(message.author)
        local vc = requester.voiceChannel
        if vc == nil then return message.channel:send('You must be connected to a voice channel in order to use this command') end
        -- Sub commands
        if args[1] == 'skip' and args[2] == nil then
            if songObj[message.channel.guild.id] ~= nil then vc:join():stopStream() end
            return
        end
        if args[1] == 'queue' and args[2] == nil then
            if songObj[message.channel.guild.id] == nil then return message.channel:send("No song is currently playing!") end
            local embedFields = {}
            table.insert(embedFields, { name = "Now playing: ".. songObj[message.channel.guild.id].title, value = songObj[message.channel.guild.id].url, inline = false })
            for i, v in pairs(songQueue[message.channel.guild.id]) do
                table.insert(embedFields, { name = ""..i..": ".. v.title, value = v.url, inline = false })
            end
            return helpers.GET_EMBED("Song queue", "​", embedFields, message, songObj[message.channel.guild.id].thumbnail)
        end
        local url = ""
        if string.match(args[1], "v=(...........)") == nil then
            for _, v in pairs(args) do
                url = url .. v
            end
        else
            url = helpers.string.split(args[1], '&')[1]
        end
        local vidInfo = getYoutubeVideoInfo(url)

        if not songQueue[message.channel.guild.id] then
            songQueue[message.channel.guild.id] = {}
        end
        if not songObj[message.channel.guild.id] then
            songObj[message.channel.guild.id] = nil
        end

        table.insert(songQueue[message.channel.guild.id], { query = url, url = vidInfo["video_url"], title = vidInfo["title"], thumbnail = vidInfo["thumbnail"]})
        if not isActive[message.channel.guild.id] then
            isActive[message.channel.guild.id] = true
            coroutine.wrap(function()
                songObj[message.channel.guild.id] = table.remove(songQueue[message.channel.guild.id], 1)
                setStreamObject(songObj[message.channel.guild.id], message)
                play(vc, nil, message)
            end)()
        else
            message.channel:send {
                content = 'Added '..vidInfo["title"]..' to the song queue :pencil:',
                reference = {
                    message = message,
                    mention = false,
                }
            }
        end
	end
};