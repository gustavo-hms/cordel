local lpeg = require "lpeg"

local M = {}; _ENV = M

local P, V = lpeg.P, lpeg.V
local C, Ct, Cg = lpeg.C, lpeg.Ct, lpeg.Cg

local function buildgrammar(processors)
	local dollar = P"$"
	local any = P(1)
	local emptyline = P"\n\n"

	return P {
		"document",
		document = (V"section" + V"paragraph")^1 * -1,
		section = P"# " * Cg(V"text"^1) * emptyline^-1 / processors.section,
		paragraph = Cg(V"text"^1 * emptyline^-1) / processors.paragraph,
		text = V"inline" + V"plaintext",
		inline = V"inlinemath",
		inlinemath = C(dollar * (any - dollar)^0 * dollar) / processors.inlinemath,
		plaintext = C((any - V"inline" - emptyline)^1) / processors.plaintext
	}
end

function parse(text, processors)
	local grammar = buildgrammar(processors)
	return Ct(grammar):match(text)
end

return M
