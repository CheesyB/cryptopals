package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")

local crypto = require("lib.crypto")
local coding = require("lib.coding")
local misc = require("lib.misc")
local heavy = require("lib.heavy")
local score = require("lib.score")
local padding = require("lib.padding")
local cbc = require("lib.cbc")
local base64 = require("base64")
local log = require("lib.log")
log.level = "info"

function TestSet2Challenge1()
	misc.heading(2, 1)
	local input = "YELLOW SUBMARINE"
	local block_length = 16
	local padded = padding.pkcs7(input, block_length)
	misc.hexPrint(padded)
end

function TestSet2Challenge2()
	misc.heading(2, 2)
	io.input("src/cyphers/set2challenge2.txt")
	local raw = io.read("*all")
	local input = base64.decode(raw)
	local key = "YELLOW SUBMARINE"
	local IV = string.rep("\x00", #key)
	local plain = cbc.cbc_decrypt(input, IV, key)
  print(plain)
end

function TestSet2Challenge3()
	misc.heading(2, 3)
	-- local cipher = cbc.cbc_encrypt("AAAAAAABBBBBBBCBCCIAJOIJO{IHOIHO", IV, key)
	local plain = cbc.cbc_decrypt(input, IV, key)
  print(plain)
end

os.exit(luaunit.LuaUnit.run())
