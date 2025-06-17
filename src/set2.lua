package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")

local json = require("lib.thirdparty.json")
local parsing = require("lib.parsing")
local misc = require("lib.misc")
local heavy = require("lib.heavy")
local oracle = require("lib.ecb_oracle")
local padding = require("lib.padding")
local cbc = require("lib.cbc")
local base64 = require("base64")
local log = require("lib.thirdparty.log")
log.level = "info"

function TestSet2Challenge1()
	misc.heading(2, 1)
	local input = "YELLOW SUBMARINE"
	local block_length = 16
	local padded = padding.pkcs7(input, block_length)
	misc.hexPrint(padded)

	block_length = 15
	padded = padding.pkcs7(input, block_length)
	print(#padded)
	assert(#padded % block_length == 0)
end

function TestSet2Challenge2()
	misc.heading(2, 2)
	io.input("src/cyphers/set2challenge2.txt")
	local raw = io.read("*all")
	local input = base64.decode(raw)
	local key = "YELLOW SUBMARINE"
	local IV = string.rep("\x00", #key)
	local plain = cbc.decrypt(input, IV, key)
	print(plain:sub(1, 20))
end

function TestSet2Challenge3()
	misc.heading(2, 3)
	for _ = 1, 100 do
		local input = oracle.randb(50)
		local cipher, mode = oracle.encryption_oracle(input)
		assert(oracle.detect_mode(cipher), mode)
	end
end

function TestSet2Challenge4()
	misc.heading(2, 4)
	io.input("src/cyphers/set2challenge4.txt")
	local unkown = io.read("*all")
	local key = "YELLOW SUBMARINE"
	local new_oracle = oracle.append_oracle_ecb(unkown, key)
	local cipher = new_oracle("")
	local key_size = heavy.detectKeysize(cipher, 1, 40)[1]["size"]
	log.info("Key size: ", misc.dump(key_size))

	-- oracle.smack_ecb(new_oracle)
end

function TestSet2Challenge5()
	misc.heading(2, 5)
  local attack_block = "admin" .. string.rep(string.char(11), 11)
  local attack_email = string.rep('A', 10) .. attack_block .. string.rep('A', 18)
	local current_cipher = parsing.profile_for(attack_email)
  local blocks = heavy.blockDivide(current_cipher, 16)
  blocks[5] = blocks[2]
  local tmp = table.concat(blocks)
  local pwnd = parsing.parse_profile(tmp)
  print(json.encode(pwnd))
end

function TestSet2Challenge6()
	misc.heading(2, 6)
	io.input("src/cyphers/set2challenge4.txt")
	local unkown = io.read("*all")
	local key = "YELLOW SUBMARINE"
	local new_oracle = oracle.append_oracle_ecb(unkown, key, "randomBytes")
	local cipher = new_oracle("")
	local key_size = heavy.detectKeysize(cipher, 1, 40)[1]["size"]
  local test = oracle.smack_ecb_harder(new_oracle)
  
end

os.exit(luaunit.LuaUnit.run())
