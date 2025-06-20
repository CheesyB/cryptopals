package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")
local score = require("lib.score")
local padding = require("lib.padding")
local log = require("lib.thirdparty.log")
local misc = require("lib.misc")
local parsing = require("lib.parsing")
log.level = "info"

-- function TestParsing()
-- 	local input_string = "foo=bar&baz=qux&zap=zazzle"
-- 	local result = parsing.parse_profile(input_string, true)
-- 	luaunit.assertEquals(result, { foo = "bar", baz = "qux", zap = "zazzle" })
-- end

function TestHammingDistance()
	luaunit.assertEquals(score.hammingDistance("a", "b"), 2)
	luaunit.assertEquals(score.hammingDistance("this is a test\n", "wokka wokka!!!\n"), 37)
end

function TestscoreChiSquare()
	local well_crafted_text = "This is a well crafted pice of asthonishing English Text"
	local giberish = [[()*)AE*G()U*gh08 08yesg08y2h30o8h?m+/"?o3n:IE?i<.n3!+'n;!6e >!iDt==
  csnEr& gt<-em'$,s2,>(i:)1o4l:g %=gy1$) D's 6&,:7a=!rt 3*%go2h(enE6)e&%(:f'o?yX^JB,=/a
  -h&u:; =bT$>!i:)1"rZ_i h :3i:oeh/=-s$!r9!+a3& lsB5&')'t+7a46""']]
	local good_score = score.scoreChiSquare(well_crafted_text)
	local bad_score = score.scoreChiSquare(giberish)
	assert(good_score < bad_score)
end

function TestSwapByte()
	local text = "Here is X swaped with Y, or is it?"
	local result = parsing.swap_bytes(text, 9, 23)
	luaunit.assertEquals(result, "Here is Y swaped with X, or is it?")

	local text = "Here is X swaped with Y"
	local result = parsing.swap_bytes(text, 9, 23)
	luaunit.assertEquals(result, "Here is Y swaped with X")
end

function TestPkcs7Validation()
	local good = "HalloIchTest\x04\x04\x04\x04"
	luaunit.assertEquals(padding.pkcs7_validation(good), true)
	local edge = "HalloIchBinTest!\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
	luaunit.assertEquals(padding.pkcs7_validation(edge), true)
	edge = "HalloIchBinTest\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
	luaunit.assertEquals(padding.pkcs7_validation(edge), true)
	local bad = "HalloIchTest\x03\x04\x04\x04"
	luaunit.assertEquals(padding.pkcs7_validation(bad), false)
	local bad_edge = "HalloIchBinTest!!\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
	luaunit.assertEquals(padding.pkcs7_validation(bad_edge), false)
	bad = "HalloIchTest\x05\x05\x05\x05"
	luaunit.assertEquals(padding.pkcs7_validation(bad), false)
end

function TestPkcsRemove()
	local input = "HalloIchTest\x04\x04\x04\x04"
  luaunit.assertEquals("HalloIchTest", padding.pkcs7_remove(input))
	input = "HalloIchBinTest\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
  luaunit.assertEquals("HalloIchBinTest", padding.pkcs7_remove(input))

end

os.exit(luaunit.LuaUnit.run())
