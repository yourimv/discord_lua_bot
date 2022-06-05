return {
	name = 'gigabot',
	description = 'This command mocks Rustlet GigaBot',
    command = function(args, message, client, rest)
		local mention = '<@903698381254311937>'
		local list = {
			'Nice socks ' ..mention.. ' where\'d you get those??? https://i.imgur.com/qy8LdM5.jpg',
			'U a bitch ' ..mention.. ' bitch',
			mention.. ' https://cdn.discordapp.com/attachments/650532824952078411/979772296430518332/unknown.png',
			mention.. ' https://c.tenor.com/i_-satjXa0cAAAAC/crab-is-gone-smash.gif',
		}
		message.channel:send(list[math.random(#list)])
	end
};