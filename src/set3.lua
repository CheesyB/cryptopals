package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")

local crypto = require("lib.crypto")
local json = require("lib.thirdparty.json")
local parsing = require("lib.parsing")
local coding = require("lib.coding")
local misc = require("lib.misc")
local heavy = require("lib.heavy")
local score = require("lib.score")
local oracle = require("lib.cbc_oracle")
local padding = require("lib.padding")
local cbc = require("lib.cbc")
local ecb = require("lib.ecb")
local base64 = require("base64")
local log = require("lib.thirdparty.log")
log.level = "info"

function TestCBCPaddingOracle()
	local cipher, IV, _ = oracle.cbc_text_decryption()
	local plain_text = oracle.smack_cbc_oracle(cipher, IV, oracle.cbc_padding_check)
	print(plain_text)
end

function TestCTRMode()
  local raw = "L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ=="
  local input = base64.decode(raw)
  local key = misc.KEY
  local nonce = 0
  
end

os.exit(luaunit.LuaUnit.run())
