local helpers = require('helpers')

return {
    name = "help",
    description = "Get the commands of the bot",
    command = function(args, message, _, rest)
        local embedFields = {}
        local embedTitle
        local embedDescription
        if (args[1]) then
            local matchcommand
            for _, v in pairs(rest.commands) do
                if string.lower(v.name) == string.lower(args[1]) then
                    matchcommand = v
                end
            end
            if not matchcommand then return message.channel:send('No command/category found') end
            embedTitle = matchcommand.name
            embedDescription = matchcommand.description
        else
            for _, v in pairs(rest.commands) do
                table.insert(embedFields, {
                    name = v.name,
                    value = v.description,
                    inline = false
                })
            end
            embedTitle = 'Help'
            embedDescription = 'For more information use ' .. rest.prefix ..'help {{command_name}}'
        end
        return helpers.GET_EMBED(embedTitle, embedDescription, embedFields, message)
    end
}