local lpeg = require "lpeg"

local export = {}

local section = lpeg.P "# " * lpeg.C(lpeg.P(1)^1)
local subsection = lpeg.P "## " * lpeg.C(lpeg.P(1)^1)

function export.parse(text)
	local document = lpeg.Ct(section) + lpeg.Ct(subsection)
	return document:match(text)
end

return export
