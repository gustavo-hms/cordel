parser = require "parser"

local noopfunction = function() end
local mockprocessors = {
	inlinemath = noopfunction,
	section = noopfunction,
	plaintext = noopfunction
}

local function copytable(t)
	local tt = {}
	for k,v in pairs(t) do
		tt[k] = v
	end
	return tt
end

local function test(definition, text, expected)
	processors = copytable(mockprocessors)
	processors[definition] = function(t) return {definition, t} end
	result = parser.parse(text, processors)
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

describe("A #complete definition", function()
	it("should generate the right structure", function()
		local doc = [[
# O monstrengo

O monstrengo que está no fim do mar
Na noite de breu ergueu-se a voar;
À roda da nau voou três vezes,
Voou três vezes a chiar,

# Um título de seção com $fórmula = \theta^2$ incluída

A força que um campo magnético aplica a uma carga movendo-se sobre ele é:
$\mathbf{F}=q\left(\mathbf{v}\times\mathbf{B}\right)$.]]

		local expected = {
			{"section", {"plaintext", "O monstrengo"}},
			{"paragraph",
				{"plaintext",
					"O monstrengo que está no fim do mar\n" ..
					"Na noite de breu ergueu-se a voar;\n" ..
					"À roda da nau voou três vezes,\n" ..
					"Voou três vezes a chiar,"
				}
			},
			{"section",
				{"plaintext", "Um título de seção com "},
				{"inlinemath", [[$fórmula = \theta^2$]]},
				{"plaintext", " incluída"}
			},
			{"paragraph",
				{"plaintext", "A força que um campo magnético aplica a uma carga movendo-se sobre ele é:\n"},
				{"inlinemath", [[$\mathbf{F}=q\left(\mathbf{v}\times\mathbf{B}\right)$]]},
				{"plaintext", "."}
			}
		}

		processors = {}
		for k,_ in pairs(mockprocessors) do
			processors[k] = function(t) return {k, t} end
		end

		result = parser.parse(doc, processors)
		assert.are.same(expected, result)
	end)
end)
