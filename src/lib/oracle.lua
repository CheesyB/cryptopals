local M = {}

local heavy = require("lib.heavy")
local crypto = require("lib.crypto")
local coding = require("lib.coding")
local misc = require("lib.misc")
local cbc = require("lib.cbc")
local ecb = require("lib.ecb")
local padding = require("lib.padding")

function M.randb(len)
	key = {}
	for _ = 1, len do
		table.insert(key, string.char(math.random(0, 255)))
	end
	return table.concat(key)
end

local function rand16b()
	return M.randb(16)
end

function M.append_oracle_ecb(unknown_string, key)
	return function(my_string)
		local combined = my_string .. coding.decodeBase64(unknown_string:gsub("\n", ""))
		local input = padding.pkcs7(combined, 16)
		return ecb.encrypt(input, key)
	end
end

function M.encryption_oracle(input)
	local key = rand16b()
	input = padding.pkcs7(M.randb(math.random(5, 10)) .. input .. M.randb(math.random(5, 10)), 16)
	if math.random(1, 2) == 1 then
		-- ecb
		return ecb.encrypt(input, key), "ecb"
	else
		-- cbc
		local iv = rand16b()
		return cbc.encrypt(input, iv, key), "cbc"
	end
end

function M.detect_mode(input)
	local bytes = heavy.blockDivide(input, 16)

	local buckets = {}
	for _, byte in ipairs(bytes) do
		if buckets[byte] == nil then
			buckets[byte] = 1
		else
			return "ecb"
		end
	end
	return "cbc"
end

function M.print_duplicate_blocks(bytes)
	local buckets = {}
	for i, byte in ipairs(bytes) do
		if buckets[byte] > 1 then
			io.write("X", i)
		else
			io.write("_")
		end
	end
end

--- single entroy for the time I need that
-- local singel_entropy = {}
-- for byte, count in pairs(buckets) do
--   local p = count / #input
--   singel_entropy[byte] = -p * math.log(p, 256)
-- end

-- local block_entropy = {}
-- for i = 1, #input - 16, 16 do
-- 	local summed_entropy = 0
-- 	for j = 1, 16 do
-- 		summed_entropy = summed_entropy + singel_entropy[bytes[i + j]]
-- 	end
-- 	table.insert(block_entropy, summed_entropy / 16)

local asciiChars = " !\"#$%&'()*+,-./\n" -- Printable punctuation (SP to /)
	.. "0123456789" -- Digits (0 to 9)
	.. ":;<=>?@"
	.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- Uppercase letters (A to Z)
	.. "abcdefghijklmnopqrstuvwxyz" -- Lowercase letters (a to z)

function M.smack_ecb(oracle)
	local plain_oracle = oracle("")
	local block_size = #plain_oracle
	for i = 1, 40 do
		local repeated = string.rep("A", i)
		local current_len = #oracle(repeated)
		if current_len > block_size then
			block_size = current_len - block_size
			break
		end
	end
	-- let's make sure that we have a block_size * 2 byte duplicate code block
	assert(M.detect_mode(oracle(string.rep("A", block_size * 2))) == "ecb")

	local plaintext = string.rep("A", block_size - 1)

	for i = 1, #plain_oracle -1 do
		for j = 1, block_size do
			local padding = string.rep("A", block_size - j)
			local cipher_bytes = heavy.blockDivide(oracle(padding), 16)[(i // block_size) + 1]
			for c in asciiChars:gmatch(".") do
				local p = plaintext:sub(-(block_size - 1)) .. c
				local test_cipher = oracle(p):sub(1, block_size)
				assert(#test_cipher == #cipher_bytes)
				if test_cipher == cipher_bytes then
					plaintext = plaintext .. c
					break
				end
			end
		end
    if i % 10 == 0 then
      io.write('.')
      io.flush()
    end
	end
  print()

	return plaintext:sub(16,#plaintext)
end

return M
