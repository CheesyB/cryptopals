local M = {}

local openssl = require("openssl")

function M.ebc_decrypt(cipher, iv, key)
	local evp = openssl.cipher.get("aes-128-ecb")
	local e = evp:decrypt_new()
	assert(e:init(key, iv))
	e:padding(false)

	assert(e:update(cipher))
	return assert(e:final(cipher))
end

function M.ebc_encrypt(plaintext, iv, key)
	local evp = openssl.cipher.get("aes-128-ecb")
	local e = evp:encrypt_new()
	assert(e:init(key, iv))
	e:padding(false)

	assert(e:update(plaintext))
	return  assert(e:final())
end


return M
