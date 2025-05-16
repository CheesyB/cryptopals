-- code.lua
local M = {}

function M.encodeHex(bytes)
	local hexstr = {}
	for i = 1, #bytes do
		local hex = string.format("%02x", string.byte(bytes, i))
		table.insert(hexstr, hex)
	end
	return table.concat(hexstr)
end

function M.decodeHex(hexString)
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

local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function M.encodeBase64(input)
  input =  input:gsub("\r?\n", "")
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

local function createDecodingMap()
	local map = {}
	for i = 1, #base64chars do
		map[base64chars:sub(i, i)] = i - 1
	end
	return map
end

local base64map = createDecodingMap()

function M.decodeBase64(input)
	input = input:gsub("=", "") -- Remove padding
	local result = ""
	local len = #input
	for i = 1, len, 4 do
		local bitPattern = 0
		for j = 0, 3 do
      local mapping =  base64map[input:sub(i + j, i + j)] or 0
			bitPattern = bitPattern << 6  | mapping
		end
		for j = 16, 0, -8 do
			local byte = (bitPattern >> j) & 0xFF
			result = result .. string.char(byte)
		end
	end
	return result:gsub("\0", "") -- Strip padding bytes
end

return M
