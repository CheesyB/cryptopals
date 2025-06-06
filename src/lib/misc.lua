-- misc.lua
local M = {}

local log = require("lib.thirdparty.log")

local oct2bin = {
	["0"] = "000",
	["1"] = "001",
	["2"] = "010",
	["3"] = "011",
	["4"] = "100",
	["5"] = "101",
	["6"] = "110",
	["7"] = "111",
}

function M.getOct2bin(a)
	return oct2bin[a]
end

function M.convertBin(n)
	local s = string.format("%o", n)
	s = s:gsub(".", M.getOct2bin)
	return s
end

function M.dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end
function M.hexPrint(str)
    for i = 1, #str do
        local char = str:sub(i, i)
        local ascii_code = string.byte(char)
        if ascii_code >= 32 and ascii_code <= 126 then
            io.write(char)
        else
            io.write(string.format("\\x%02X", ascii_code))
        end
    end
    io.write("\n")
end
function M.asciiPrint(str)
    for i = 1, #str do
        local char = str:sub(i, i)
        local ascii_code = string.byte(char)
        if ascii_code >= 32 and ascii_code <= 126 then
            io.write(char)
        else
            io.write(string.format("\\%d", ascii_code))
        end
    end
    io.write("\n")
end


function M.read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end


function M.heading(set, challenge)
	log.warn("\nSet " .. set .. " Challenge " .. challenge)

  
end

return M
