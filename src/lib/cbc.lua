local M = {}

local openssl = require("openssl")
local crypto = require("lib.crypto")
local misc = require("lib.misc")
local ecb = require("lib.ecb")
local heavy = require("lib.heavy")

function M.decrypt(cipher, iv, key, padding)
  padding = padding or false
	local blocks = heavy.blockDivide(cipher, #key)
	local previouse_block = iv

	local plaintext = ""
	for _, block in ipairs(blocks) do
		plain = ecb.decrypt(block, key, padding)
		plaintext = plaintext .. crypto.xorBuff(plain, previouse_block)
		previouse_block = block
	end
	return plaintext
end

function M.encrypt(plaintext, iv, key)
	local evp = openssl.cipher.get("aes-128-ecb")

	local e = evp:encrypt_new()
	assert(e:init(key))
	e:padding(false)

	local blocks = heavy.blockDivide(plaintext, #key)
	local previouse_block = iv

	local cipher = ""

	for _, block in ipairs(blocks) do
		local xored = crypto.xorBuff(block, previouse_block)
    local c = ecb.encrypt(xored, key)
		cipher = cipher ..  c
		previouse_block = c
	end
	return cipher
end

return M
