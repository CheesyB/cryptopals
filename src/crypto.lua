-- crypto.lua
local crypto = {}

function crypto.dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. crypto.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end
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
local function getOct2bin(a)
	return oct2bin[a]
end
local function convertBin(n)
	local s = string.format("%o", n)
	s = s:gsub(".", getOct2bin)
	return s
end

function crypto.encodeHex(bytes)
	local hexstr = {}
	for i = 1, #bytes do
		local hex = string.format("%x", string.byte(bytes, i))
		table.insert(hexstr, hex)
	end
	return table.concat(hexstr)
end

function crypto.decodeHex(hexString)
	if #hexString % 2 ~= 0 then
		error("Hex string must have an even number of digits.")
	end

	local bytes = {}
	for i = 1, #hexString, 2 do
		local pair = hexString:sub(i, i + 1)
		local byte = (tonumber(pair, 16))
		table.insert(bytes, byte)
	end
	return string.char(table.unpack(bytes))
end

function crypto.base64(input)
	local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local result = ""
	local padding = ((3 - (#input % 3)) % 3) -- Determine padding
	input = input .. string.rep("\0", padding) -- Add padding
	for i = 1, #input, 3 do
		local bytes = { string.byte(input, i, i + 2) }
		local bitPattern = bytes[1] << 16 | bytes[2] << 8 | bytes[3]
		for j = 18, 0, -6 do
			local index = bitPattern >> j & 0x3f
			result = result .. base64chars:sub(index + 1, index + 1)
		end
	end
	return result:sub(1, #result - padding) .. string.rep("=", padding) --- @type string
end

function crypto.scoreEnglishString(input_str)
	local frequency = "ETAONRISHDLFCMUGYPWBVKJXZQ"
	local letters = {}
	for c in input_str:gmatch(".") do
		if letters[c] == nil then
			letters[c] = 1
		else
			letters[c] = letters[c] + 1
		end
	end

	local score = 0
	for k, v in pairs(letters) do
		if k:match("l") then
			k = string.upper(k)
		end
		local index = string.find(frequency, k, nil, true)
		if index ~= nil then
			score = score + (v / #input_str * (26 - index))
		end
	end
	return score
end

function crypto.xorByte(input, against)
	local bytes = {}
	for i = 1, #input do
		local byte = string.byte(input, i, i) ~ string.byte(against)
		table.insert(bytes, byte)
	end
	return string.char(table.unpack(bytes))
end

function crypto.xorBuff(input, against)
	if #input ~= #against then
		error("buffer sizes must match")
	end
	local bytes = {}
	for i = 1, #input do
		local byte = string.byte(input, i, i) ~ string.byte(against, i, i)
		table.insert(bytes, byte)
	end
	return string.char(table.unpack(bytes))
end

return crypto
