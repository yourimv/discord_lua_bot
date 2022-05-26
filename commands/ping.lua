local discordia = require('discordia')

return {
    name = "ping",
    descrption = "Ping the bot",
    command = function(_, msg)
        msg.channel:send('pong')
    end
}