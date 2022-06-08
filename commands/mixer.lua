local settings = require('settings')
local helpers = require('helpers')
local requester
local vc
local conn
local loopIndex

local function play(sound)
	conn:playFFmpeg('commands\\mixer_sounds\\'..sound..'.mp3')
end

local function loop(args)
	local amt = args[loopIndex]:match("%((.-)%)")
	local loopArgs = {}
	if amt == "" then amt = 1 else amt = tonumber(amt) end
	for _,arg in pairs(args) do
		if arg == "end" then
			break
		end
		if not string.find(arg,"loop") then
			table.insert(loopArgs,arg)
		end
		loopIndex = loopIndex + 1
	end
	if amt > 1 then
		local loopArgsCopy = helpers.table.shallowCopy(loopArgs)
		for _=2,amt do
			helpers.table.concatinate(loopArgs, loopArgsCopy)
		end
	end
	for _,v in pairs(loopArgs) do
		play(v)
	end
end

local operations = {
	["loop"] = loop,
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
		for i=1,#args do
			for k,v in pairs(operations) do
				if string.find(args[loopIndex],k) then
					v(args)
				elseif not string.find(args[loopIndex],"end") then
					play(args[loopIndex])
				end
			end
			loopIndex = loopIndex + 1
		end
		conn:close()
	end
};