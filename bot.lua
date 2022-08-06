local discordia = require('discordia')
local settings = require('settings')
local commands = require('commands')
local helpers = require('helpers')
local enums = discordia.enums
local logger = discordia.Logger(
	enums.logLevel.info,
	"%F %T",
	"./luaqt.log"
)
local client = discordia.Client()

local commandList = {}

for i,v in pairs(commands.commands) do
	local command = require('./commands/'..v)
	table.insert(commandList, {
		name = command.name,
		description = command.description,
		aliases = command.aliases,
		run = command.command
	})
end

client:on('ready', function()
	print(_VERSION)
	print('Logged in as '.. client.user.username)
end)

local function runCommand(message)
	local args = helpers.string.split(message.content, ' ')
	local commandString = string.gsub(args[1], settings.prefix, '')
	commandString = string.lower(commandString)
	args = table.slice(args, 2)

	local commandObject = nil

	for _,v in pairs(commandList) do
		local alias = helpers.table.getByValue(v.aliases, commandString)
		if v.name == commandString then
			commandObject = v
			break
		elseif alias then
			commandObject = v
			args = helpers.table.prepend(args, alias)
			break
		end
	end

	if commandObject then
		logger:log(enums.logLevel.info, commandObject.name .." executed by user ".. message.author.name .. "("..message.author.id..") with args: " ..helpers.table.arrayToString(args))
		commandObject.run(args, message, client, {
			commands = commandList,
			prefix = settings.prefix
		})
	end

end

client:on('messageCreate', function(message)

	if not helpers.string.startswith(message.content, settings.prefix) then
		return
	end

    if message.author.Bot then
		return
	end

	local succes, error = pcall(function()
		runCommand(message)
	end)

	if (not succes) then
		print(error)
	end
end)

client:run("Bot " ..settings.token)