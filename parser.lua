local lpeg = require "lpeg"

local M = {}

local any = lpeg.P(1)

function M.inlinemath(processor)
	local dollar = lpeg.P "$"
	return lpeg.C(dollar * (any - dollar)^1 * dollar) / processor
end

function M.section(processor)
	return lpeg.P "# " * lpeg.C(any^1) / processor
end

function M.subsection(processor)
	return lpeg.P "## " * lpeg.C(any^1) / processor
end

return M
