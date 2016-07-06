parser = require "parser"

local mockprocessors = {}
mockprocessors.__index = function() return 0 end

function mockprocessors.new()
	return setmetatable({}, mockprocessors)
end

local function test(text, expected, processors)
	result = parser.parse(text, processors)
	assert.are.same(expected, result)
end

describe("An #inlinemath definition", function()
	local processors = mockprocessors.new()
	processors.inlinemath = 1
	processors.paragraph = function(...) return ... end

	it("should find the formulas", function()
		local text = [[$\sum_{k=1}^10 k^2 = 17$]]
		local expected = {[[\sum_{k=1}^10 k^2 = 17]]}
		test(text, expected, processors)
	end)

	it("should ignore the first dollar sign", function()
		test([[$$\sum_{k=1}^10 k^2$]], {[[\sum_{k=1}^10 k^2]]}, processors)
	end)

	it("shouldn't match if there's a space between text and $", function()
		test([[$ \sum_{k=1}^10 k^2$]], {[[$ \sum_{k=1}^10 k^2$]]}, processors)
	end)

	it("should find two inline math expressions", function()
		local input = [[$\sum_{k=1}^10$ algo no meio $k^2$]]
		local expected = {[[\sum_{k=1}^10]], "k^2"}
		test(input, expected, processors)
	end)
end)

describe("An #emphasize definition", function()
	local processors = mockprocessors.new()
	processors.emphasize = 1
	processors.paragraph = function(...) return ... end

	it("should find the emphasized text", function()
		test([[*com sentimento!*]], {"com sentimento!"}, processors)
	end)

	it("should match inside a phrase", function()
		test([[É preciso tocar *com sentimento*!]], {"com sentimento"}, processors)
	end)

	it("should find two emphasized expressions", function()
		local input = [[Em ia contente, levava um *brio*, levava *destino*]]
		local expected = {"brio", "destino"}
		test(input, expected, processors)
	end)

	it("shouldn't match if there's a space between text and asterisk", function()
		local input = [[Em ia contente, levava um *brio *, levava *destino*]]
		local expected = {"destino"}
		test(input, expected, processors)
	end)
end)

describe("A #section definition", function()
	local processors = mockprocessors.new()
	processors.section = function(...) return ... end

	it("should find a simple section", function()
		local title = "Título da seção"
		local expected = {title}
		test("# " .. title, expected, processors)
	end)

	it("should find two sections", function()
		local text = [[
Dois poemas do João Cabral

# Habitar o tempo

Para não matar seu tempo, imaginou:
vivê-lo enquanto ele ocorre, ao vivo;
no instante finíssimo em que ocorre,
em ponta de agulha e porém acessível;

# O relógio

Ao redor da vida do homem
há certas caixas de vidro,
dentro das quais, como em jaula,
se ouve palpitar um bicho.
		]]

		local expected = {"Habitar o tempo", "O relógio"}
		test(text, expected, processors)
	end)
end)

describe("A #complete definition", function()
	local doc = loadfile("spec/text.lua")()

	it("should generate the right structure", function()
		local expected = {
			{"section",
				{"plaintext", "(hrtf) Auralização e o emprego de HRTFs"}
			},

			{"paragraph",
				{"plaintext", [=[
Além dessas alterações na própria estrutura da onda sonora, o ouvinte capta um
outro tipo de informação decorrente do deslocamento do sinal sonoro através do
espaço de propagação: as diferenças de fase (chamadas ITD, do inglês
]=]},

				{"emphasize", "Interaural Time Difference"},

				{"plaintext", [=[) e de intensidade (chamadas ILD, do inglês
]=]},
				{"emphasize", "Interaural Level Difference"},
				
				{"plaintext", [=[) dos sinais que chegam a seu ouvido
direito e esquerdo. A inserção artificial desses efeitos em um sinal sonoro,
com o intuito de reconstruir ou modelar uma cena sonora real, é chamada
auralização [@alton2000master @michael2007auralization].]=]}
			},

			{"paragraph",
				{"plaintext", [=[
Pensando em termos de processamento de sinais, uma HRTF é, idealmente, um
filtro %--- cuja função de transferência é, digamos, ]=]},

				{"inlinemath", "H(z)"},

				{"plaintext", [=[ --- 
que modifica um sinal de entrada ]=]},

				{"inlinemath", "x(n)"},

				{"plaintext", [=[ incutindo-lhe as mesmas transformações
supracitadas, de modo a tornar a saída ]=]},

				{"inlinemath", "y(n)"},

				{"plaintext", [=[ igual ao
sinal sonoro que chega ao ouvido.
Sendo ]=]},

				{"inlinemath", "h(n)"},

				{"plaintext", [=[ a resposta impulsiva desse filtro, a saída desejada será, então,
calculada através da convolução do sinal de entrada com ]=]},

				{"inlinemath", "h(n)"},

				{"plaintext", ", definida por:"}
			},

			{"paragraph",
				{"plaintext",[=[
$$$ (convolução)
y(n) = (x*h)(n) = \sum_k x(k)h(n-k).
$$$]=]}
			},

			{"section", {"plaintext", "(cipic) O banco de dados CIPIC"}},

			{"paragraph",
				{"plaintext", [=[
As HRTFs foram medidas tendo os indivíduos se posicionado no centro de uma
esfera de 1~m de raio com diâmetro alinhado com o eixo interauricular do
indivíduo (cf. figura #esfera-do-cipic). Alto-falantes de 5,8~cm de raio
foram colocados em diversas posições ao longo da esfera (aproximadamente nos
pontos exibidos na figura #esfera-do-cipic). Os canais auditivos dos
indivíduos foram bloqueados e microfones foram utilizados para captar o sinal
emitido pelos alto-falantes.]=]}
			},

			{"section", {"plaintext", "(resultados) Resultados"}},

			{"paragraph",
				{"plaintext", [=[
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
			},

			{"paragraph", {"plaintext", [=[
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
			}
		}

		local processors = {}
		processors.inlinemath = function(text) return {"inlinemath", text} end
		processors.strong = function(text) return {"strong", text} end
		processors.emphasize = function(text) return {"emphasize", text} end
		processors.plaintext = function(text) return {"plaintext", text} end
		processors.paragraph = function(...) return {"paragraph", ...} end
		processors.section = function(...) return {"section", ...} end

		local result = parser.parse(doc, processors)
		assert.are.same(expected, result)
	end)
end)
