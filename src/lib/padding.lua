local M = {}

local misc = require("lib.misc")

function M.pkcs7(input, block_length)
	local remainder =  block_length - #input % block_length
	if remainder == block_length then
		input = input .. string.rep(string.char(block_length), block_length)
	else
		input = input .. string.rep(string.char(remainder), remainder)
	end
	return input
end

return M
