local discordia = require('discordia')

return {
    name = "help",
    description = "Get the commands of the bot",
    command = function(args, message, _, rest)
        local embedfields = {}
        local embedTitle
        local embedDescription
        local validArgs = true
        if (args[1]) then
            local matchcommand
            for _, v in pairs(rest.commands) do
                if string.lower(v.name) == string.lower(args[1]) then
                    matchcommand = v
                end
            end

            if not matchcommand then
                message.channel:send('No command/category found')
                validArgs = false
            else
                embedTitle = matchcommand.name
                embedDescription = matchcommand.description
            end
        else
            for _, v in pairs(rest.commands) do
                table.insert(embedfields, {
                    name = v.name,
                    value = v.description,
                    inline = false
                })
            end
            embedTitle = 'Help'
            embedDescription = 'For more information use ' .. rest.prefix ..'help {{command_name}}'
        end
        if validArgs then
            message.channel:send{
                embed = {
                    title = embedTitle,
                    description = embedDescription,
                    author = {
                        name = 'LuaQT',
                        icon_url = 'https://i.imgur.com/d8sRPMv.png'
                    },
                    fields = embedfields,
                    footer = {
                        text = "Created in LUA because the author is retarded"
                    },
                    color = 0x333FFF
                }
            }
        end
    end
}