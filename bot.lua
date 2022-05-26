local discordia = require('discordia')
local settings = require('settings')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

function runcommand(message)
	local args = string.split(msg.content, ' ')
end

client:on('messageCreate', function(message)

	-- if (not string) then
	-- 	return
	-- end

    if message.author.Bot then
		return
	end

	local succes, error = pcall(function()
		runcommand(message)
	end)

	if (not succes) then
		print(error)
	end
end)

client:run("Bot " ..settings.Token)