local M = {}

local ecb = require("lib.ecb")
local padding = require("lib.padding")

local key = "YELLOW SUBMARINE"

function M.parse_profile(encrypted_profile)
	local decrypted_profile = ecb.decrypt(encrypted_profile, key, true)

	-- Create an empty table to hold the parsed key-value pairs
	local parsed_table = {}

	-- Iterate through each key=value pair separated by '&'
	for pair in string.gmatch(decrypted_profile, "[^&]+") do
		-- Find the key and value in each pair
		local key, value = string.match(pair, "([^=]+)=([^=]+)")

		-- Add the key-value pair to the table
		if key and value then
			parsed_table[key] = value
		end
	end

	return parsed_table
end

local function url_encode(str)
	if str then
		-- Replace special characters with URL encoded equivalents
		str = string.gsub(str, "([&=])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
	end
	return str
end

function M.profile_for(email)
	local sanitized_email = url_encode(email)
	local encoded_profile = "email=" .. sanitized_email .. "&uid=100" .. "&role=user"
	return ecb.encrypt(encoded_profile, key, true)
end

function M.swap_bytes(cipher, pos1, pos2)
	assert(pos1 <= pos2, "pos2 must be bigger than pos1")
	assert(pos2 <= #cipher, "pos2 must be less than #cipher")
  local b1 = string.sub(cipher, pos1, pos1)
  local b2 = string.sub(cipher, pos2, pos2)
  return cipher:sub(1, pos1 - 1) .. b2 .. cipher:sub(pos1 + 1, pos2 -1 ) .. b1 .. cipher:sub(pos2 + 1)
end

return M
