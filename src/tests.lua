package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")
local score = require("lib.score")
local log = require("lib.thirdparty.log")
local misc = require("lib.misc")
log.level = "info"

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
	print(good_score)
	print(bad_score)
end

os.exit(luaunit.LuaUnit.run())
