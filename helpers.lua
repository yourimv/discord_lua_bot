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