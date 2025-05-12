package.path = package.path .. ";./src/?.lua"

local crypto = require("crypto")

print("Set 1 Challenge 1")
local input_hex = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
local bytes = crypto.decodeHex(input_hex)
print("Result: " .. crypto.base64(bytes))

print("\nSet 1 Challenge 2")
local input_str = "1c0111001f010100061a024b53535009181c"
local against = "686974207468652062756c6c277320657965"

local input_bytes = crypto.decodeHex(input_str)
local against_bytes = crypto.decodeHex(against)

print(input_bytes)
print(against_bytes)

local xord = crypto.xorBuff(input_bytes, against_bytes)
print(xord)
print("Result: " .. crypto.encodeHex(xord))



print("\nSet 1 Challenge 3")

local hex_str = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
local input_bytes = crypto.decodeHex(hex_str)
print(input_bytes)

local asciiChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- Uppercase letters (A to Z)
	.. "abcdefghijklmnopqrstuvwxyz" -- Lowercase letters (a to z)
	.. "0123456789" -- Digits (0 to 9)
	.. " !\"#$%&'()*+,-./" -- Printable punctuation (SP to /)
	.. ":;<=>?@"

local attempts = {}
for c in asciiChars:gmatch(".") do
  local tmp =  crypto.xorByte(input_bytes, c)
	table.insert(attempts, {key=c, value=crypto.scoreEnglishString(tmp)})
end
table.sort(attempts, function(a, b) return a.value > b.value end)
print(crypto.dump(attempts[1]))
print("Result: " .. crypto.xorByte(input_bytes, attempts[1]["key"]))


