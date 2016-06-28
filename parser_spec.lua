parser = require "parser"

local noopfunction = function() end
local mockprocessors = {
	inlinemath = noopfunction,
	plaintext = noopfunction
}

describe("An #inlinemath definition", function()
	local mathtag = "inlinemath"

	local test = function(text, expected)
		mockprocessors.inlinemath = function(t) return {mathtag, t} end
		result = parser.parse(text, mockprocessors)
		assert.are.same(expected, result)
	end

	it("should find the formulas", function()
		local text = [[$\sum_{k=1}^10 k^2 = 17$]]
		local expected = {
			{mathtag, text}
		}
		test(text, expected)
	end)

	it("should match only the two dollar signs", function()
		local expected = {
			{mathtag, "$$"}
		}
		test([[$$\sum_{k=1}^10 k^2$]], expected)
	end)

	it("should find only spaces", function()
		local expected = {
			{mathtag, "$ $"}
		}
		test([[$ $\sum_{k=1}^10 k^2$]], expected)
	end)

	it("should find two inline math expressions", function()
		local firstpart = [[$\sum_{k=1}^10$]]
		local secondpart = [[$ k^2$]]
		local expected = {
			{mathtag, firstpart},
			{mathtag, secondpart}
		}
		test(firstpart .. [[ algo no meio ]] .. secondpart, expected)
	end)
end)
