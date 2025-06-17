local M = {}

local misc = require("lib.misc")
local heavy = require("lib.heavy")

function M.pkcs7_remove(input)
	if M.pkcs7_validation(input) then
		local last_byte = string.byte(input:sub(-1))
		return input:sub(1, #input - last_byte)
	end
end

function M.pkcs7(input, block_length)
	local remainder = block_length - #input % block_length
	if remainder == block_length then
		input = input .. string.rep(string.char(block_length), block_length)
	else
		input = input .. string.rep(string.char(remainder), remainder)
	end
	return input
end

function M.pkcs7_validation(input, block_length)
	if block_length == nil then
		block_length = 16
	end
	local blocks = heavy.blockDivide(input, block_length)
	local last = blocks[#blocks]

	local padding_byte = string.byte(string.sub(last, -1))
  if padding_byte == 0 then
    error("invalid padding")
  end
	
  for i = 1, padding_byte do
		if string.byte(last:sub(-i, -i)) ~= padding_byte then
      error("invalid padding")
		end
	end
	return true
end

return M
