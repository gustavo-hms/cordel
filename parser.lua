local lpeg = require "lpeg"

_ENV = {}

local P, V, B = lpeg.P, lpeg.V, lpeg.B
local C, Ct, Cg = lpeg.C, lpeg.Ct, lpeg.Cg
local char = lpeg.locale()

local function inline(delimiter)
	delimiter = P(delimiter)
	local not_delimiter = 1 - delimiter
	local notspace = 1 - char.space

	return delimiter * C(notspace * not_delimiter^0) * B(notspace) * delimiter
end

local function buildgrammar(processors)
	local any = P(1)
	local dollar = P"$"
	local emptyline = P"\n\n"

	return P {
		"document",
		document = (V"section" + V"paragraph")^1 * -1,
		section = P"# " * Cg(V"text"^1) * emptyline^-1 / processors.section,
		paragraph = Cg(V"text"^1 * emptyline^-1) / processors.paragraph,
		text = V"inline" + V"plaintext",
		inline = V"inlinemath" + V"emphasize",
		inlinemath = C(dollar * (any - dollar)^0 * dollar) / processors.inlinemath,
		emphasize = inline("*") / processors.emphasize,
		plaintext = C((any - V"inline" - emptyline)^1) / processors.plaintext
	}
end

function parse(text, processors)
	local grammar = buildgrammar(processors)
	return Ct(grammar):match(text)
end

return _ENV
