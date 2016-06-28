parser = require "parser"

local noopfunction = function() end
local mockprocessors = {
	inlinemath = noopfunction,
	section = noopfunction,
	plaintext = noopfunction
}

local function test(definition, text, expected)
	mockprocessors[definition] = function(t) return {definition, t} end
	result = parser.parse(text, mockprocessors)
	assert.are.same(expected, result)
end

describe("An #inlinemath definition", function()
	local tag = "inlinemath"

	it("should find the formulas", function()
		local text = [[$\sum_{k=1}^10 k^2 = 17$]]
		local expected = {
			{tag, text}
		}
		test(tag, text, expected)
	end)

	it("should match only the two dollar signs", function()
		local expected = {
			{tag, "$$"}
		}
		test(tag, [[$$\sum_{k=1}^10 k^2$]], expected)
	end)

	it("should find only spaces", function()
		local expected = {
			{tag, "$ $"}
		}
		test(tag, [[$ $\sum_{k=1}^10 k^2$]], expected)
	end)

	it("should find two inline math expressions", function()
		local firstpart = [[$\sum_{k=1}^10$]]
		local secondpart = [[$ k^2$]]
		local expected = {
			{tag, firstpart},
			{tag, secondpart}
		}
		test(tag, firstpart .. [[ algo no meio ]] .. secondpart, expected)
	end)
end)

describe("A #section definition", function()
	local tag = "section"

	it("should find a simple section", function()
		local title = "Título da seção"
		local expected = {
			{tag, title}
		}
		test(tag, "# " .. title, expected)
	end)

	it("should find two sections", function()
		local text = [[
Dois poemas do João Cabral

# Habitar o tempo

Para não matar seu tempo, imaginou:
vivê-lo enquanto ele ocorre, ao vivo;
no instante finíssimo em que ocorre,
em ponta de agulha e porém acessível;

# O relógio

Ao redor da vida do homem
há certas caixas de vidro,
dentro das quais, como em jaula,
se ouve palpitar um bicho.
		]]

		local expected = {
			{tag, "Habitar o tempo"},
			{tag, "O relógio"}
		}
		test(tag, text, expected)
	end)
end)
