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

describe("An #inlinemath definition", function()
	local test = function(text, expected)
		local processor = function(t) return "[" .. t .. "]" end
		result = parser.inlinemath(processor):match(text)
		assert.are.equal(expected, result)
	end

	it("should find the formulas", function()
		test("$\\sum_{k=1}^10 k^2$", "[$\\sum_{k=1}^10 k^2$]")
	end)

	it("shouldn't match an expression preceded by two dollar signs", function()
		test("$$\\sum_{k=1}^10 k^2$", nil)
	end)

	it("should find only spaces", function()
		test("$ $\\sum_{k=1}^10 k^2$", "[$ $]")
	end)
end)
