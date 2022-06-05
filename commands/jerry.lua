return {
	name = 'jerry',
	description = 'This command mocks Nodelet Jerry (from Tom and Jerry)',
    command = function(args, message, client, rest)
		local mention = '<@824233879991877632>'
		local list = {
			'U a bitch ' ..mention.. ' bitch',
			mention.. ' https://external-preview.redd.it/JngpvU1O1WVW7kpDL0U4OaCqbviSIE7Rr5JVF0sU3_M.png?auto=webp&s=bb965288fe8a943a9495d5a3639f242088863376',
			mention.. ' https://preview.redd.it/5w8tp1t1nrb51.jpg?width=640&crop=smart&auto=webp&s=567990aa183bcd3ee21cece386b071b2b116b644',
		}
		message.channel:send(list[math.random(#list)])
	end
};