local discordia = require('discordia')

return {
    name = "ping",
    description = "Ping the bot",
    command = function(_, message)
        message.channel:send('pong')
    end
}