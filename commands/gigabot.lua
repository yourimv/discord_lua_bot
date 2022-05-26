return {
	name = 'gigabot',
	description = 'This command mocks Rustlet GigaBot',
    command = function(args, message, client, rest)
		local mention = '<@903698381254311937>'
		local list = {
			'Nice socks ' ..mention.. ' where\'d you get those??? https://i.imgur.com/qy8LdM5.jpg',
			'You a bitch' ..mention.. ' bitch',
		}
		message.channel:send(list[math.random(#list)])
	end
};