package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")

local crypto = require("crypto")
local coding = require("coding")
local misc = require("misc")
local heavy = require("heavy")
local score = require("score")
local log = require("log")
local base64 = require("base64")
log.level = "info"

function TestSet1Challenge1()
	print("Set 1 Challenge 1")
	local input_hex = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
	local expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
	local result = coding.encodeBase64(coding.decodeHex(input_hex))
	luaunit.assertEquals(result, expected)
	log.info("\n" .. result .. "==\n" .. expected)
end

function TestSet1Challenge2()
	print("\nSet 1 Challenge 2")
	local input_str = coding.decodeHex("1c0111001f010100061a024b53535009181c")
	local against = coding.decodeHex("686974207468652062756c6c277320657965")
	local expected = "746865206b696420646f6e277420706c6179"
	local xord = crypto.xorBuff(input_str, against)
	local result = coding.encodeHex(xord)
	luaunit.assertEquals(result, expected)
	log.info("\n" .. result .. "==\n" .. expected)
end

function TestSet1Challenge3()
	print("\nSet 1 Challenge 3")
	local input_str = coding.decodeHex("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736")
	local expected = "Cooking MC's like a pound of bacon"
	local result = crypto.searchKey(input_str, score.scoreSimple, score.ASC)

	luaunit.assertEquals(result["key"], "X")
	log.info("\n" .. result["key"] .. "==" .. "X")
	luaunit.assertEquals(result["decoded"], expected)
	log.info("\n" .. result["decoded"] .. "==\n" .. expected)
end

function TestSet1Challenge4()
	print("\nSet 1 Challenge 4")

	io.input("src/cyphers/challenge4.txt")
	local expected = "Now that the party is jumping\n"

	local all_score = {}
	for line in io.lines() do
		local result = crypto.searchKey(coding.decodeHex(line), score.scoreSimple, score.ASC)
		table.insert(
			all_score,
			{ key = result["key"], score = result["score"], line = line, decoded = result["decoded"] }
		)
	end
	table.sort(all_score, score.ASC)
	log.info("\n" .. all_score[1]["decoded"] .. "==\n" .. expected)
end

function TestSet1Challenge5()
	print("\nSet 1 Challenge 5")

	local input_str = { "Burning 'em, if you ain't quick and nimble", "\nI go crazy when I hear a cymbal" }
	local key = "ICE"

	local tmp1 = crypto.xorKey(input_str[1], key)
	local tmp2 = crypto.xorKey(input_str[2], key)
	log.info(
		"Result: "
			.. coding.encodeHex(tmp1)
			.. coding.encodeHex(tmp2)
			.. "==\n"
			.. "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272"
			.. "a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
	)
end

function TestSet1Challenge6()
	print("\nSet 1 Challenge 6")
	io.input("src/cyphers/challenge6.txt")
	local raw = io.read("*all")
	local input = base64.decode(raw)
	luaunit.assertEquals(score.hammingDistance("this is a test\n", "wokka wokka!!!\n"), 37)
	local keySizes = heavy.detectKeysize(input, 1, 40)
	local sizes = {
		keySizes[1]["size"],
		keySizes[2]["size"],
		keySizes[3]["size"],
	}
	local keys = {}
	for _, size in ipairs(sizes) do
		local transposed = heavy.transposeInput(input, size)
		local key = ""
		for _, block in ipairs(transposed) do
			local res = crypto.searchKey(block, score.scoreSimple, score.ASC)
			key = key .. res["key"]
		end
		table.insert(keys, key)
	end
	print("Key: " .. keys[3].. " -> " .. crypto.xorKey(input, keys[3]):sub(1,20))

end

function TestSet1Challenge7()
	print("\nSet 1 Challenge 7")
	io.input("src/cyphers/challenge7.txt")
	local raw = io.read("*all")
	local input = base64.decode(raw)
  local result = crypto.xorKey(input, "YELLOW SUBMARINE")
  --print(result)
end

os.exit(luaunit.LuaUnit.run())
