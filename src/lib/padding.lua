local M = {}

local misc = require("lib.misc")

function M.pkcs7(input, block_lenght)
	local remainder = block_lenght % #input
	if remainder == 0 then
		input = input .. string.rep(string.char(block_lenght), block_lenght)
	else
		input = input .. string.rep(string.char(remainder), remainder)
	end
	return input
end

return M
