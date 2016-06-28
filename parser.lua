local lpeg = require "lpeg"

local P, V = lpeg.P, lpeg.V
local C, Ct = lpeg.C, lpeg.Ct

local function buildgrammar(processors)
	local dollar = P"$"
	local any = P(1)
	local emptyline = P"\n\n"

	return P {
		"document",
		document = (V"section" + V"paragraph")^1 + -1,
		section = P"# " * C(V"text") * emptyline^-1 / processors.section,
		paragraph = V"text" * emptyline^-1,
		text = V"inline" + (V"plaintext" * V"text" ^0),
		inline = V"inlinemath",
		inlinemath = C(dollar * (any - dollar)^0 * dollar) / processors.inlinemath,
		plaintext = C((any - V"inline" - emptyline)^1) / processors.plaintext
	}
end

local M = {}

function M.parse(text, processors)
	local grammar = buildgrammar(processors)
	return Ct(grammar):match(text)
end

return M
