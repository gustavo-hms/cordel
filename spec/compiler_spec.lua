local mockcontext = {}

function mockcontext.new()
	local t = { methods = {}, calls = {} }
	return setmetatable(t, mockcontext)
end

function mockcontext:__index(table, key)
	return function(text)
		self.methods[#self.methods + 1] = { name = key, arg = text }
	end
end

function mockcontext:__call(f, text)
	self.calls[#self.calls + 1] = text
end

local function mockenvironment(doc)
	return {arguments = {arguments = "doc=" .. doc}}
end

local function mockio(loaddata)
	return {loaddata = loaddata}
end

describe("The #compiler", function()
	local buildenv = function(corfile, loaddata)
		return {
			require = require,
			string = string,
			context = mockcontext.new(),
			environment = mockenvironment(corfile),
			io = mockio(loaddata)
		}
	end

	it("should read the right file", function()
		local corfile = "meu livro.cor"
		local loaddata_called = false

		local env = buildenv(corfile, function(doc)
			loaddata_called = true
			assert.are.equal(corfile, doc)
			return ""
		end)

		loadfile("compiler.cld", "t", env)()
		assert.True(loaddata_called)
	end)
end)
