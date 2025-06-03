-- M.lua
local log = require("lib.log")
local score = require("lib.score")

local M = {}

local function cycleChars(s)
	local i = 0
	local len = #s
	---@type integer
	return function()
		if len == 0 then
			return nil
		end

		i = (i % len) + 1
		return s:sub(i, i)
	end
end

function M.xorKey(input, key)
	local bytes = {}
	local cycle_key = cycleChars(key)
	for i = 1, #input do
		local key_byte = string.byte(cycle_key())
		local byte = string.byte(input, i, i) ~ key_byte
		log.debug(string.sub(input, i, i) .. " with: " .. string.char(key_byte) .. " is char: " .. string.char(byte))
		table.insert(bytes, byte)
	end
	return string.char(table.unpack(bytes))
end

function M.xorByte(input, against)
	local bytes = {}
	for i = 1, #input do
		local byte = string.byte(input, i, i) ~ string.byte(against)
		table.insert(bytes, byte)
	end
	return string.char(table.unpack(bytes))
end

function M.xorBuff(input, against)
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

function M.searchKey(input_bytes, score_fun, sort_fun)
	local asciiChars = "0123456789" -- Digits (0 to 9)
		.. " !\"#$%&'()*+,-./" -- Printable punctuation (SP to /)
		.. ":;<=>?@"
		.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- Uppercase letters (A to Z)
		.. "abcdefghijklmnopqrstuvwxyz" -- Lowercase letters (a to z)

	local attempts = {}
	for c in asciiChars:gmatch(".") do
		local decoded = M.xorByte(input_bytes, c)
		table.insert(attempts, { key = c, score = score_fun(decoded), decoded = decoded })
	end
	table.sort(attempts, sort_fun)
	return attempts[1]
end

return M
