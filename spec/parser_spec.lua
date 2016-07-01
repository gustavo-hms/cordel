parser = require "parser"

local mockprocessors = {}
mockprocessors.__index = function() return 0 end

function mockprocessors.new()
	return setmetatable({}, mockprocessors)
end

local function test(text, expected, processors)
	result = parser.parse(text, processors)
	assert.are.same(expected, result)
end

describe("An #inlinemath definition", function()
	local processors = mockprocessors.new()
	processors.inlinemath = 1
	processors.paragraph = function(...) return ... end

	it("should find the formulas", function()
		local text = [[$\sum_{k=1}^10 k^2 = 17$]]
		local expected = {text}
		test(text, expected, processors)
	end)

	it("should match only the two dollar signs", function()
		local expected = {"$$"}
		test([[$$\sum_{k=1}^10 k^2$]], expected, processors)
	end)

	it("should find only spaces", function()
		local expected = {"$ $"}
		test([[$ $\sum_{k=1}^10 k^2$]], expected, processors)
	end)

	it("should find two inline math expressions", function()
		local firstpart = [[$\sum_{k=1}^10$]]
		local secondpart = [[$ k^2$]]
		local expected = {firstpart, secondpart}
		test(firstpart .. [[ algo no meio ]] .. secondpart, expected, processors)
	end)
end)

describe("A #section definition", function()
	local processors = mockprocessors.new()
	processors.section = function(...) return ... end

	it("should find a simple section", function()
		local title = "Título da seção"
		local expected = {title}
		test("# " .. title, expected, processors)
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

		local expected = {"Habitar o tempo", "O relógio"}
		test(text, expected, processors)
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
			{"section", {
				{"plaintext", "O monstrengo"}
			}},
			{"paragraph", {
				{"plaintext",
					"O monstrengo que está no fim do mar\n" ..
					"Na noite de breu ergueu-se a voar;\n" ..
					"À roda da nau voou três vezes,\n" ..
					"Voou três vezes a chiar,"
				}
			}},
			{"section", {
				{"plaintext", "Um título de seção com "},
				{"inlinemath", [[$fórmula = \theta^2$]]},
				{"plaintext", " incluída"}
			}},
			{"paragraph", {
				{"plaintext", "A força que um campo magnético aplica a uma carga movendo-se sobre ele é:\n"},
				{"inlinemath", [[$\mathbf{F}=q\left(\mathbf{v}\times\mathbf{B}\right)$]]},
				{"plaintext", "."}
			}}
		}

		local processors = {}
		processors.inlinemath = function(text) return {"inlinemath", text} end
		processors.plaintext = function(text) return {"plaintext", text} end
		processors.paragraph = function(...) return {"paragraph", {...}} end
		processors.section = function(...) return {"section", {...}} end

		local result = parser.parse(doc, processors)
		assert.are.same(expected, result)
	end)
end)
