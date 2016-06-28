local lpeg = require "lpeg"

local function buildgrammar(processors)
	local dollar = lpeg.P "$"
	local any = lpeg.P(1)

	return lpeg.P {
		"document",
		document = lpeg.V("text")^0 * -1,
		text = lpeg.V "inline" + (lpeg.V "plaintext" * lpeg.V("text")^0),
		inline = lpeg.V "inlinemath",
		inlinemath = lpeg.C(dollar * (any - dollar)^0 * dollar) / processors.inlinemath,
		plaintext = lpeg.C((any - lpeg.V "inline")^1) / processors.plaintext
	}
end

local M = {}

function M.parse(text, processors)
	local grammar = buildgrammar(processors)
	return lpeg.Ct(grammar):match(text)
end

return M
