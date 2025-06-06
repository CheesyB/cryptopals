package.path = package.path .. ";./src/?.lua"
local luaunit = require("luaunit")

local crypto = require("lib.crypto")
local coding = require("lib.coding")
local misc = require("lib.misc")
local heavy = require("lib.heavy")
local score = require("lib.score")
local base64 = require("base64")
local log = require("lib.thirdparty.log")
log.level = "info"

function TestSet1Challenge1()
	misc.heading(1, 1)
	local input_hex = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
	local expected = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
	local result = coding.encodeBase64(coding.decodeHex(input_hex))
	luaunit.assertEquals(result, expected)
	log.info("\n" .. result .. "==\n" .. expected)
end

function TestSet1Challenge2()
	misc.heading(1,2)
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
	local keySizes = heavy.detectKeysize(input, 1, 40)
	local size = keySizes[1]["size"]
  log.info("key size " .. size)

	local transposed = heavy.transposeInput(input, size)
	local key = ""
	for _, block in ipairs(transposed) do
		local res = crypto.searchKey(block, score.scoreChiSquare, score.DSC)
		key = key .. res["key"]
	end
	print("Key: " .. key .. " -> " .. crypto.xorKey(input, key):sub(1, 200))
end

function TestSet1Challenge7()
	print("\nSet 1 Challenge 7")
	io.input("src/cyphers/challenge7.txt")
	local raw = io.read("*all")
	local input = base64.decode(raw)
	local openssl = require("openssl")
	local evp = openssl.cipher.get("aes-128-ecb")
	local key = "YELLOW SUBMARINE"

	local e = evp:decrypt_new()
	assert(e:init(key))
	e:padding(false)

	local decypher = assert(e:update(input))
	decypher = decypher .. assert(e:final())
	print(decypher:sub(1, 20))
end

function TestSet1Challenge8()
	print("\nSet 1 Challenge 8")
	io.input("src/cyphers/challenge8.txt")
	local raw = io.read("*all"):gsub("\n", "")

	local input = coding.decodeHex(raw)

	local bytes = heavy.blockDivide(input, 16)

	local buckets = {}
	for _, byte in ipairs(bytes) do
		if buckets[byte] == nil then
			buckets[byte] = 1
		else
			buckets[byte] = buckets[byte] + 1
		end
	end

	local singel_entropy = {}
	for byte, count in pairs(buckets) do
		local p = count / #input
		singel_entropy[byte] = -p * math.log(p, 256)
	end

	-- local block_entropy = {}
	-- for i = 1, #input - 16, 16 do
	-- 	local summed_entropy = 0
	-- 	for j = 1, 16 do
	-- 		summed_entropy = summed_entropy + singel_entropy[bytes[i + j]]
	-- 	end
	-- 	table.insert(block_entropy, summed_entropy / 16)
	-- end

	for i, byte in ipairs(bytes) do
		-- print(buckets[byte])
		if buckets[byte] > 1 then
			io.write("X", i)
		else
			io.write("_")
		end
	end
end

os.exit(luaunit.LuaUnit.run())
