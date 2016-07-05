local mockcontext = {}

function mockcontext.new()
	local t = { calls = {} }
	return setmetatable(t, mockcontext)
end

function mockcontext:__index(key)
	return function(text)
		self.calls[#self.calls + 1] = {
			"context." .. key,
			text
		}
	end
end

function mockcontext:__call(text)
	self.calls[#self.calls + 1] = {"context", text}
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

	it("should use the ConTeXt API correctly", function()
		local env = buildenv("", function(_)
			return loadfile("spec/text.lua")()
		end)

		loadfile("compiler.cld", "t", env)()

		local expected = {
			{"context.starttext"},

			{"context.section", "(hrtf) Auralização e o emprego de HRTFs"},

			{"context", [=[
Além dessas alterações na própria estrutura da onda sonora, o ouvinte capta um
outro tipo de informação decorrente do deslocamento do sinal sonoro através do
espaço de propagação: as diferenças de fase (chamadas ITD, do inglês
{\em Interaural Time Difference}) e de intensidade (chamadas ILD, do inglês
{\em Interaural Level Difference}) dos sinais que chegam a seu ouvido
direito e esquerdo. A inserção artificial desses efeitos em um sinal sonoro,
com o intuito de reconstruir ou modelar uma cena sonora real, é chamada
auralização [@alton2000master @michael2007auralization].]=]},

			{"context", [=[
Pensando em termos de processamento de sinais, uma HRTF é, idealmente, um
filtro %--- cuja função de transferência é, digamos, $H(z)$ --- 
que modifica um sinal de entrada $x(n)$ incutindo-lhe as mesmas transformações
supracitadas, de modo a tornar a saída $y(n)$ igual ao
sinal sonoro que chega ao ouvido.
Sendo $h(n)$ a resposta impulsiva desse filtro, a saída desejada será, então,
calculada através da convolução do sinal de entrada com $h(n)$, definida por:]=]},

			{"context", [=[
$$$ (convolução)
y(n) = (x*h)(n) = \sum_k x(k)h(n-k).
$$$]=]},

			{"context.section", "(cipic) O banco de dados CIPIC"},

			{"context", [=[
As HRTFs foram medidas tendo os indivíduos se posicionado no centro de uma
esfera de 1~m de raio com diâmetro alinhado com o eixo interauricular do
indivíduo (cf. figura #esfera-do-cipic). Alto-falantes de 5,8~cm de raio
foram colocados em diversas posições ao longo da esfera (aproximadamente nos
pontos exibidos na figura #esfera-do-cipic). Os canais auditivos dos
indivíduos foram bloqueados e microfones foram utilizados para captar o sinal
emitido pelos alto-falantes.]=]},

			{"context.section", "(resultados) Resultados"},

			{"context", [=[
Nenhum dos métodos encontrados na literatura para se obterem filtros IIR a
partir de filtros FIR impõe restrições ao número de pólos e zeros reais que
produz. Assim, não se pode garantir que todos os filtros IIR do banco de
dados terão o mesmo número de pólos reais e de zeros reais, qualquer que seja a
ténica usada para gerar esses filtros IIR. E o que se observou, ao implementar
o método de Kalman, é que, de fato, os números de pólos e de zeros reais
variam filtro a filtro. A tabela #tab:pzreais mostra a distribuição de
cada configuração entre os filtros do banco obtidos pelo método de Kalman, e a
figura #fig:pzreais apresenta graficamente a distribuição espacial dos
filtros com configuração mais comum.]=]},

			{"context", [=[
%{
%	{
%		| polos reais | zeros reais | total de filtros |
%		|-------------|-------------|------------------|
%		| 0           | 0           | 177              |
%		| 0           | 2           | 826              |
%
%		(tab:pzreais-6) Filtros com 6 polos e 6 zeros
%	},
%	{
%		| polos reais | zeros reais | total de filtros |
%		|-------------|-------------|------------------|
%		| 0           | 0           | 49               |
%		| 0           | 2           | 306              |
%
%		(tab:pzreais-8) Filtros com 8 polos e 8 zeros
%	};
%	{
%		| polos reais | zeros reais | total de filtros |
%		|-------------|-------------|------------------|
%		| 0           | 0           | 2                |
%		| 0           | 4           | 174              |
%
%		(tab:pzreais-10) Filtros com 10 polos e 10 zeros
%	},
%	{
%		| polos reais | zeros reais | total de filtros |
%		|-------------|-------------|------------------|
%		| 0           | 2           | 53               |
%		| 0           | 4           | 52               |
%
%		(tab:pzreais-12) Filtros com 12 polos e 12 zeros
%	}
%
%	(tab:pzreais) Distribuição dos filtros segundo número de polos e de zeros reais, para
%	filtros de algumas ordens diferentes.
%}
%
%$$$
%{
%	| f(x) = { | 1, x < 3; |
%    |          | 0, c.c.   |
%}
%$$$
]=]},

			{"context.stoptext"},
		}

		assert.are.same(expected, env.context.calls)
	end)
end)
