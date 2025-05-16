-- score.lua
local M = {}

local log = require("log")
local misc = require("misc")

function M.ASC(a, b)
	return a.score > b.score
end

function M.DSC(a, b)
	return a.score < b.score
end

function M.scoreSimple(input_str)
	local good = 0
	for char in input_str:gmatch(".") do
		local ascii_num = string.byte(char)
		if (ascii_num >= 65 and ascii_num < 90) or (ascii_num >= 97 and ascii_num < 122) or ascii_num == 32 then
			good = good + 1
		end
	end
	return good / #input_str
end

local asciiFreq = {}

function M.scoreChiSquare(input_str)
	local letters = {}
	for c in input_str:gmatch(".") do
		if letters[c] == nil then
			letters[c] = 1
		else
			letters[c] = letters[c] + 1
		end
	end

	local score = 0
	for toTest, prob in pairs(asciiFreq()) do
		local expected_count = prob / 100 * #input_str
		local observed_count = letters[toTest] or 0
		score = score + ((observed_count - expected_count) ^ 2 / expected_count)
		log.debug(score, observed_count, expected_count)
	end
	return score
end

function M.bitCount(number, divisor)
	if divisor == 1 then
		return number
	end
	return M.bitCount(number % divisor, divisor // 2) + number // divisor
end

function M.hammingDistance(x, y)
	if #x ~= #y then
		error("input buffers must be equal")
	end
	local distance = {}
	for i = 1, #x do
		local xord = string.byte(x, i, #x) ~ string.byte(y, i, #y)
		table.insert(distance, M.bitCount(xord, 128))
	end
	local sum = 0
	for _, value in ipairs(distance) do
		sum = sum + value
	end
	return sum
end

return M
