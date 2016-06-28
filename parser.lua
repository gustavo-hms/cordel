local lpeg = require "lpeg"

local M = {}

function M.section(processor)
	return lpeg.P "# " * lpeg.C(lpeg.P(1)^1) / processor
end

function M.subsection(processor)
	return lpeg.P "## " * lpeg.C(lpeg.P(1)^1) / processor
end

return M
