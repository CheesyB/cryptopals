local M = {}

local heavy = require("lib.heavy")
local crypto = require("lib.crypto")
local coding = require("lib.coding")
local misc = require("lib.misc")
local cbc = require("lib.cbc")
local ecb = require("lib.ecb")
local padding = require("lib.padding")
local base64 = require("base64")

function M.cbc_text_decryption()
	local raw = misc.read_file("src/assets/cbc_oracle_texts.txt")
	local input = {}
	for line in string.gmatch(raw, "(.-)\n") do
		local cipher = cbc.encrypt(padding.pkcs7(base64.decode(line), 16), misc.IV, misc.KEY)
		local plaintext = base64.encode(padding.pkcs7_remove(cbc.decrypt(cipher, misc.IV, misc.KEY, false)))
		assert(line == plaintext)
		table.insert(input, cipher)
	end
	return input[math.random(#input)], misc.IV, misc.KEY
end

function M.cbc_padding_check(cipher)
	local plaintext = cbc.decrypt(cipher, misc.IV, misc.KEY, false)
	return padding.pkcs7_validation(plaintext)
end

function M.smack_cbc_oracle(cipher, IV, padding_checker)
	local blocks = heavy.blockDivide(cipher)
	local plaintext = ""
	for k = 1, #blocks do
		local extention = ""
		local key = ""
		for j = 1, 16 do
			for i = 0, 255, 1 do
				local mod_block = string.rep("\x00", 16 - j) .. string.char(i) .. extention .. blocks[k] 
				if pcall(padding_checker, mod_block) then
					key = string.char(j ~ i) .. key
					extention = crypto.xorBuff(string.rep(string.char((j + 1)), j), key)
					break
				end
			end
		end
		plaintext = plaintext .. crypto.xorBuff(blocks[k-1] or IV , key)
	end
  return plaintext
end

return M
