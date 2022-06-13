local settings = require('settings')
local helpers = require('helpers')
local spawn = require('coro-spawn')
local requester
local vc
local conn
local loopIndex
local mixerFile
local joinCache

local function write(sound)
	mixerFile:write("file \'"..settings.mixerSoundsPath.."\\"..sound..".mp3\'\n")
end

local function getOperationParameters(args)
	local argument = args[loopIndex]:match("%((.-)%)")
	local parameters = helpers.string.split(argument, ",")
	return parameters
end

local function clearCache()
	os.remove(settings.mixerSoundsPath.."\\mixer_temp\\mixerInputs.txt")
	os.remove(settings.mixerSoundsPath.."\\mixer_temp\\mixerFile.mp3")
	for _,v in pairs(joinCache) do os.remove(v) end
end

local function play()
	local res = spawn('ffmpeg', {
        args = {
			"-loglevel", "error",
			"-f", "concat", "-safe", "0", "-i", settings.mixerSoundsPath.."\\mixer_temp\\mixerInputs.txt",
			"-c", "copy", settings.mixerSoundsPath.."\\mixer_temp\\mixerFile.mp3"
		},
        stdio = { nil, true, 2 }
    })
	res.waitExit()
	conn:playFFmpeg(settings.mixerSoundsPath.."\\mixer_temp\\mixerFile.mp3")
end

local function join(args)
	local parameters = getOperationParameters(args)
	local argTable = {}
	table.insert(argTable, "-loglevel")
	table.insert(argTable, "error")
	for i=1,#parameters do
		table.insert(argTable, "-i")
		table.insert(argTable, settings.mixerSoundsPath.."\\"..parameters[i]..".mp3")
	end
	table.insert(argTable, "-filter_complex")
	table.insert(argTable, "amix=inputs="..helpers.table.getLength(parameters)..":duration=first:dropout_transition=3")
	table.insert(argTable, settings.mixerSoundsPath.."\\"..helpers.table.toString(parameters)..".mp3")
    local res = spawn('ffmpeg', {
        args = argTable,
        stdio = { nil, true, 2 }
    })
	res.waitExit()
	write(helpers.table.toString(parameters))
	table.insert(joinCache, settings.mixerSoundsPath.."\\"..helpers.table.toString(parameters)..".mp3")
end

local function loop(args)
	local amt = tonumber(args[loopIndex]:match("%((.-)%)"))
	local loopArgs = {}
	for i=1,#args do
		if args[loopIndex] == "end" then
			break
		end
		if not string.find(args[loopIndex], "loop") then
			table.insert(loopArgs,args[loopIndex])
		end
		loopIndex = loopIndex + 1
	end
	if amt > 1 then
		local loopArgsCopy = helpers.table.shallowCopy(loopArgs)
		for _=2,amt do
			helpers.table.concatinate(loopArgs, loopArgsCopy)
		end
	end
	for _,v in pairs(loopArgs) do write(v) end
end

local function pitch(args)
	local parameters = getOperationParameters(args)
	local file = parameters[1]
	local pitch = parameters[2]
	local tempfile = "\\mixer_temp\\"..file.."_"..pitch
	-- ffmpeg -i bruh.mp3 -af asetrate=44100*0.9,aresample=44100,atempo=1/0.9 output.mp3
	local res = spawn('ffmpeg', {
        args = {
			"-loglevel", "error",
			"-i", settings.mixerSoundsPath.."\\"..file..".mp3", "-af",
			"asetrate="..pitch.."*0.9,aresample="..pitch..",atempo=1/0.9",
			settings.mixerSoundsPath..tempfile..".mp3"
		},
        stdio = { nil, true, 2 }
    })
	res.waitExit()
	write(tempfile)
	table.insert(joinCache, settings.mixerSoundsPath..tempfile..".mp3")

end

local operations = {
	["loop"] = loop,
	["join"] = join,
	["pitch"] = pitch,
}

local function getHelpEmbed(message)
	local embedFields = {}
	table.insert(embedFields, {
		name = "Mixer commands",
		value = "These commands can be used. All commands accept ONE argument. \n i.e. FUNC(arg)",
		inline = false
	})
	for k,_ in pairs(operations) do
		table.insert(embedFields, { name = k, value = '​', inline = true })
	end
	table.insert(embedFields, {
		name = "Mixer sounds",
		value = "These sounds can be used and played by the mixer.",
		inline = false
	})
	for _, v in pairs(helpers.io.scanDir(settings.mixerSoundsPath)) do
		table.insert(embedFields, { name = ""..v, value = '​', inline = true })
	end
	return helpers.GET_EMBED("Mixer command options", "These options are available in the mixer command", embedFields, message)
end

return {
	name = 'mixer',
	description = 'WIP - make your own \'music\' with specific sounds. Type ;mixer help for help',
    command = function(args, message, client, rest)
		if args[1] == nil then return message.channel:send('You must enter an additional argument') end
		if args[1] == 'help' then return getHelpEmbed(message) end
		loopIndex = 1
		requester = message.guild:getMember(message.author)
        vc = requester.voiceChannel
		conn = vc:join()
		local done = false
		local operationPerformed = false
		mixerFile = io.open(settings.mixerSoundsPath.."\\mixer_temp\\mixerInputs.txt", "w")
		joinCache = {}
		for i=1,#args do
			for k,v in pairs(operations) do
				if args[loopIndex] == nil then
					done = true
					break
				end
				if string.find(args[loopIndex],k) then
					v(args)
					operationPerformed = true
				end
			end
			if done then break end
			if not operationPerformed then write(args[loopIndex]) else operationPerformed = false end
			loopIndex = loopIndex + 1
		end
		mixerFile:close()
		if conn == nil then clearCache() return message.channel:send("Cannot connect to the voice channel") end
		play()
		conn:close()
		clearCache()
	end
};