local M = {}

local openssl = require("openssl")
local crypto = require("lib.crypto")
local misc = require("lib.misc")
local heavy = require("lib.heavy")

function M.cbc_decrypt(cipher, iv, key)
	local evp = openssl.cipher.get("aes-128-ecb")

	local e = evp:decrypt_new()
	assert(e:init(key, iv))
	e:padding(false)

	local blocks = heavy.blockDivide(cipher, #key)
	local previouse_block = iv

	local plaintext = ""
	for _, block in ipairs(blocks) do
		local plain = assert(e:update(block))
		plain = plain .. assert(e:final())
		plaintext = plaintext .. crypto.xorBuff(plain, previouse_block)
		previouse_block = block
	end
	return plaintext
end

function M.cbc_encrypt(plaintext, iv, key)
	local evp = openssl.cipher.get("aes-128-ecb")

	local e = evp:encrypt_new()
	assert(e:init(key, iv))
	e:padding(false)

	local blocks = heavy.blockDivide(plaintext, #key)
	local previouse_block = iv

	local cipher = ""

	for _, block in ipairs(blocks) do
		local xored = crypto.xorBuff(block, previouse_block)
		local c = assert(e:update(xored))
		cipher = cipher .. c .. assert(e:final())
		previouse_block = c
	end
	return cipher
end

return M
