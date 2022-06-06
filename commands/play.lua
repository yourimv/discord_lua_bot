local json = require('../json')
local spawn = require('coro-spawn')
local parse = require('url').parse
local isActive = false
local songQueue = {}
local streamObj = nil
local songObj = nil

local function setStreamObject (ytobj, message)
    streamObj = nil
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
    streamObj = stream
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
    if streamObj == nil then
        connection:close()
        isActive = false
        return
    end
    local conn = vc:join()
    songObj = table.remove(songQueue, 1)
    conn:playFFmpeg(streamObj)
    setStreamObject(songObj, message)
    play(vc, conn, message)
end

return {
	name = 'play',
	description = 'plays a song from a youtube url',
    command = function(args, message, client, rest)
        local requester = message.guild:getMember(message.author)
        local vc = requester.voiceChannel
        if vc == nil then
            message.channel:send('You must be connected to a voice channel in order to use this command')
            return
        end
        if args[1] == 'queue' and songObj ~= nil then
            local embedFields = {}
            table.insert(embedFields, {
                name = "Now playing: ".. songObj.title,
                value = songObj.url,
                inline = false
            })
            for i, v in pairs(songQueue) do
                table.insert(embedFields, {
                    name = ""..i..": ".. v.title,
                    value = v.url,
                    inline = false
                })
            end
            message.channel:send{
                embed = {
                    title = "Queue",
                    description = "",
                    author = {
                        name = 'LuaQT',
                        icon_url = 'https://i.imgur.com/d8sRPMv.png'
                    },
                    fields = embedFields,
                    footer = {
                        text = "Created in LUA because the author is retarded"
                    },
                    color = 0x333FFF
                }
            }
            return
        end
        local url = ""
        if string.match(args[1], "v=(...........)") == nil then
            for _, v in pairs(args) do
                url = url .. v
            end
        else
            url = args[1]
        end
        local vidInfo = getYoutubeVideoInfo(url)
        table.insert(songQueue, { query = url, url = vidInfo["video_url"], title = vidInfo["title"]})
        if not isActive then
            isActive = true
            setStreamObject({ url = url, title = vidInfo["title"]}, message)
            songObj = table.remove(songQueue, 1)
            play(vc, nil, message)
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