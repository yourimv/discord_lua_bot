module("helpers", package.seeall)

-- String Helpers
function string.startswith(text, prefix)
    return text:find(prefix, 1, true) == 1
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Table Helpers
function table.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end
    return sliced
end

function table.arrayToString(tbl)
    local str = "["
    for _,v in pairs(tbl) do
        str = str .." ".. v
    end
    str = str .. " ]"
    return str
end

function table.concatinate(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function table.shallowCopy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

-- IO
function io.scanDir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    return t
end

-- LuaQT utils
function GET_EMBED(title, description, embedFields, message, thumbnail)
	return message.channel:send {
		embed = {
			title = title,
			description = description,
			author = {
				name = 'LuaQT',
				icon_url = 'https://i.imgur.com/d8sRPMv.png'
			},
            thumbnail = { url = thumbnail },
			fields = embedFields,
			footer = {
				text = "Created in LUA because the author is retarded"
			},
			color = 0x333FFF
		}
	}
end