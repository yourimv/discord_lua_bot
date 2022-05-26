function code(str)
    return string.format('```\n%s```', str)
end

function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

return {
	name = 'lua',
	description = 'Executes lua code',
    command = function(args, message, client, rest)

        local sandbox = {
            math = math,
            string = string,
        }

        args[1] = args[1]:gsub('```\n?', '')
        args[#args] = args[#args]:gsub('```\n?', '')

        local str = ''
        for i,v in pairs(args) do
            str = str ..'\n'.. v
        end

        local lines = {}
        sandbox.message = message
        sandbox.print = function(...)
            table.insert(lines, printLine(...))
        end

        local fn, syntaxError = load(str, 'LuaQT', 't', sandbox)
        if not fn then return message:reply(code(syntaxError)) end

        local success, runtimeError = pcall(fn)
        if not success then return message:reply(code(runtimeError)) end

        lines = table.concat(lines, '\n')

        if #lines > 1990 then
            lines = lines:sub(1, 1990)
        end

        return message:reply(code(lines))
	end
};