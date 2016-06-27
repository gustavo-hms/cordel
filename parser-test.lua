test = require "tests/gambiarra"
serpent = require "tests/serpent"
parser = require "parser"

test("Check section definition", function()
	local data = {
		{
			description = "it should find the right text for section title",
			text = [[# Título da seção]],
			expected = {"Título da seção"}
		},
		{
			description = "it should ignore hashes not at the begining of the line",
			text = [[Título da # seção]],
			expected = nil
		},
		{
			description = "it should ignore subsections",
			text = [[## Título da subseção]],
			expected = nil
		}
	}

	for i, item in ipairs(data) do
		result = parser.parse(item.text)
		ok(eq(result, item.expected), item.description)
	end
end)

test("Check subsection definition", function()
	local data = {
		{
			description = "it should find the right text for subsection title",
			text = [[## Título da subseção]],
			expected = {"Título da subseção"}
		},
		{
			description = "it should ignore hashes not at the begining of the line",
			text = [[Título da ## subseção]],
			expected = nil
		},
		{
			description = "it should ignore sections",
			text = [[# Título da seção]],
			expected = nil
		}
	}

	for i, item in ipairs(data) do
		result = parser.parse(item.text)
		ok(eq(result, item.expected), item.description)
	end
end)
