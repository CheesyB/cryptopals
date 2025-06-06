local M = {}

local openssl = require("openssl")

function M.decrypt(cipher, key)
	local evp = openssl.cipher.get("aes-128-ecb")
	local e = evp:decrypt_new()
	assert(e:init(key))
	e:padding(false)

	local tmp = assert(e:update(cipher))
	tmp = tmp .. assert(e:final(cipher))
  return tmp
end

function M.encrypt(plaintext, key)
	local evp = openssl.cipher.get("aes-128-ecb")
	local e = evp:encrypt_new()
	assert(e:init(key))
	e:padding(false)

	local tmp = (assert(e:update(plaintext)))
	tmp = tmp .. (assert(e:final()))
	return tmp 
end

return M
