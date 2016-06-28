parser = require "parser"

describe("A #section definition", function()
	local test = function(text, expected)
		local processor = function(t) return "[" .. t .. "]" end
		result = parser.section(processor):match(text)
		assert.are.equal(expected, result)
	end

	it("should find the right text for section title", function()
		test("# Título da seção", "[Título da seção]")
	end)

	it("should ignore hashes not at the begining of line", function()
		test("Título da # seção", nil)
	end)

	it("should ignore subsections", function()
		test("## Título da subseção", nil)
	end)
end)
