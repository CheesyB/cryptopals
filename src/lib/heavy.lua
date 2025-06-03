-- heavy
local M = {}

local score = require("lib.score")

function M.blockDivide(input, blockSize)
	local block = {}
	for i = 1, #input, blockSize do
		table.insert(block, string.sub(input, i, i + blockSize - 1))
	end
	return block
end

function M.detectKeysize(input, from, to)
	local hemmingDist = {}
	for i = from, to do
		local blocks = M.blockDivide(input, i)
		local total_score = (
			score.hammingDistance(blocks[1], blocks[2])
			+ score.hammingDistance(blocks[2], blocks[3])
			+ score.hammingDistance(blocks[3], blocks[4])
		)
			/ i
			/ 3

		table.insert(hemmingDist, { size = i, score = total_score })
	end
	table.sort(hemmingDist, score.DSC)
	return hemmingDist
end

function M.transposeInput(input, keySize)
	local blocks = {}
	for i = 1, keySize do
		blocks[i] = ""
		for j = i, #input, keySize do
			blocks[i] = blocks[i] .. string.sub(input, j, j)
		end
	end
	return blocks
end

return M
