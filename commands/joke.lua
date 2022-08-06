local http = require("coro-http")
local helpers = require('helpers')

return {
	name = 'joke',
	description = 'The bot tells a joke',
    command = function(args, message, client, rest)
		if args[1] == 'help' then
			return message.channel:send('Supported arguments: CATEGORY. Command sends requests to https://sv443.net/jokeapi/v2/')
		end
		local url = 'https://v2.jokeapi.dev/joke/'
		if args[1] then url = url .. args[1]
		else url = url .. 'Any'
		end
		coroutine.wrap(function()
			local res = helpers.HTTP_GET(url, http)
			local joke = res['joke']
			if joke == nil then
				return message.channel:send(res["setup"].."\n\n||"..res["delivery"].."||")
			end
			message.channel:send(joke)
		end)()
	end
};