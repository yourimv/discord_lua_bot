local discordia = require('discordia')

return {
    name = "help",
    description = "Get the commands of the bot",
    command = function(args, message, _, rest)
        local embedfields
        if (args[1]) then
            print(args[1])
            for _, v in pairs(rest.commands) do
                if string.lower(v.name) == string.lower(args[1]) then
                    command = v
                end
            end

            if (not command) then
                message.channel:send('No command/category found')
            else
                embedfields = 'Name: ' .. command.name .. '\nDescription: ' .. command.description
            end
        else
            embedfields = {}
            for _, v in pairs(rest.commands) do
                table.insert(embedfields, {
                    name = v.name,
                    value = v.description,
                    inline = false
                })
            end
        end
        message.channel:send{
            embed = {
                title = 'Help',
                description = 'For more information use ' .. rest.prefix ..'help {{command_name}}',
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
}