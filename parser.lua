local lpeg = require "lpeg"

local P, S, V = lpeg.P, lpeg.S, lpeg.V
local C, Ct = lpeg.C, lpeg.Ct

local function buildgrammar(processors)
	local dollar = P"$"
	local any = P(1)
	local emptyline = P"\n\n"

	return P {
		"document",
		document = V"paragraph" * -1,
		paragraph = V"text" ^0 * (emptyline^1 + -1),
		text = V"inline" + (V"plaintext" * V"text" ^0),
		inline = V"inlinemath",
		inlinemath = C(dollar * (any - dollar)^0 * dollar) / processors.inlinemath,
		plaintext = C((any - V"inline")^1) / processors.plaintext
	}
end

local M = {}

function M.parse(text, processors)
	local grammar = buildgrammar(processors)
	return Ct(grammar):match(text)
end

return M
