"""
tests/test_agent.py
Testes unitários para o Agente do Zero.

Cobre:
- Dispatcher de ferramentas (executar_ferramenta)
- Loop agentic (executar_agente) com mock do cliente Anthropic

Os testes NÃO consomem cota da API — o cliente é completamente mockado.
Os testes funcionam mesmo sem o pacote 'anthropic' instalado no ambiente,
pois o módulo é injetado via sys.modules antes do import de agent.py.

Executar:
    python -m unittest tests/test_agent.py -v
    # ou, a partir da raiz do projeto:
    python3 -m unittest tests/test_agent.py -v
"""

import sys
import os
import unittest
from unittest.mock import MagicMock, patch

# ---------------------------------------------------------------------------
# Ensure the project root is on sys.path so we can import agent.py directly.
# ---------------------------------------------------------------------------
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

# ---------------------------------------------------------------------------
# Inject stub modules into sys.modules BEFORE importing agent.py.
#
# This allows the tests to run even if the 'anthropic' and 'dotenv' packages
# are not installed in the current environment (e.g. outside a virtualenv).
# The stubs only need to expose what agent.py uses at module-load time.
# ---------------------------------------------------------------------------

def _build_anthropic_stub() -> MagicMock:
    """Build a minimal stub for the 'anthropic' package."""
    stub = MagicMock()
    # anthropic.Anthropic(api_key=...) → returns a mock client instance
    stub.Anthropic.return_value = MagicMock()
    return stub


def _build_dotenv_stub() -> MagicMock:
    """Build a minimal stub for the 'dotenv' package."""
    stub = MagicMock()
    # load_dotenv() does nothing in tests
    stub.load_dotenv.return_value = None
    return stub


# Only inject stubs when the real packages are not available
if "anthropic" not in sys.modules:
    sys.modules["anthropic"] = _build_anthropic_stub()

if "dotenv" not in sys.modules:
    dotenv_stub = _build_dotenv_stub()
    sys.modules["dotenv"] = dotenv_stub
    # agent.py uses "from dotenv import load_dotenv"
    sys.modules["dotenv"].load_dotenv = dotenv_stub.load_dotenv

# Now it is safe to import agent.py
import agent  # noqa: E402


class TestDispatcher(unittest.TestCase):
    """Tests for the executar_ferramenta dispatcher."""

    def setUp(self):
        """Reset shared state before each test."""
        # Clear the in-memory notes dict so tests are fully isolated
        agent.notas.clear()

    # ------------------------------------------------------------------
    # test_dispatch_calcular
    # ------------------------------------------------------------------
    def test_dispatch_calcular(self):
        """Ferramenta 'calcular': 2 + 2 deve retornar 'Resultado: 4'."""
        resultado = agent.executar_ferramenta("calcular", {"expressao": "2 + 2"})
        self.assertEqual(resultado, "Resultado: 4")

    def test_dispatch_calcular_expressao_complexa(self):
        """Ferramenta 'calcular': expressoes compostas devem funcionar."""
        resultado = agent.executar_ferramenta("calcular", {"expressao": "10 * 5 - 3"})
        self.assertEqual(resultado, "Resultado: 47")

    def test_dispatch_calcular_erro_sintaxe(self):
        """Ferramenta 'calcular': expressao invalida deve retornar mensagem de erro."""
        # "import os" is blocked by the empty __builtins__ sandbox in agent.py,
        # so NameError is raised — a genuine error case.
        resultado = agent.executar_ferramenta("calcular", {"expressao": "import os"})
        self.assertIn("Erro", resultado)

    # ------------------------------------------------------------------
    # test_dispatch_salvar_nota
    # ------------------------------------------------------------------
    def test_dispatch_salvar_nota(self):
        """Ferramenta 'salvar_nota': deve salvar e confirmar a nota."""
        resultado = agent.executar_ferramenta(
            "salvar_nota",
            {"titulo": "lembrete", "conteudo": "Reunião às 14h"}
        )
        # Confirm the return message signals success
        self.assertIn("lembrete", resultado)
        self.assertIn("salva", resultado.lower())

    def test_dispatch_salvar_nota_persistencia(self):
        """Ferramenta 'salvar_nota': nota deve estar disponivel no dict de notas."""
        agent.executar_ferramenta(
            "salvar_nota",
            {"titulo": "compras", "conteudo": "leite, pão, ovos"}
        )
        # Verify the note was actually stored in the shared dict
        self.assertIn("compras", agent.notas)
        self.assertEqual(agent.notas["compras"], "leite, pão, ovos")

    def test_dispatch_salvar_multiplas_notas(self):
        """Ferramenta 'salvar_nota': deve suportar multiplas notas distintas."""
        agent.executar_ferramenta("salvar_nota", {"titulo": "nota1", "conteudo": "conteudo1"})
        agent.executar_ferramenta("salvar_nota", {"titulo": "nota2", "conteudo": "conteudo2"})
        self.assertEqual(len(agent.notas), 2)
        self.assertEqual(agent.notas["nota1"], "conteudo1")
        self.assertEqual(agent.notas["nota2"], "conteudo2")

    # ------------------------------------------------------------------
    # test_dispatch_ferramenta_invalida
    # ------------------------------------------------------------------
    def test_dispatch_ferramenta_invalida(self):
        """Ferramenta inexistente deve retornar mensagem indicando 'nao encontrada'."""
        resultado = agent.executar_ferramenta("ferramenta_que_nao_existe", {})
        self.assertIn("não encontrada", resultado)

    def test_dispatch_ferramenta_invalida_nome_no_retorno(self):
        """A mensagem de erro deve incluir o nome da ferramenta desconhecida."""
        nome_invalido = "xyz_ferramenta_fantasma"
        resultado = agent.executar_ferramenta(nome_invalido, {})
        self.assertIn(nome_invalido, resultado)

    # ------------------------------------------------------------------
    # test_dispatch_buscar_na_web
    # ------------------------------------------------------------------
    def test_dispatch_buscar_na_web(self):
        """Ferramenta 'buscar_na_web': deve retornar string com resultado de busca."""
        resultado = agent.executar_ferramenta(
            "buscar_na_web",
            {"query": "inteligencia artificial"}
        )
        self.assertIsInstance(resultado, str)
        self.assertGreater(len(resultado), 0)
        # The simulated result should mention the query term
        self.assertIn("inteligencia artificial", resultado)


class TestExecutarAgente(unittest.TestCase):
    """Tests for the executar_agente loop using a mocked Anthropic client."""

    def setUp(self):
        """Set up a fresh mock client before each test."""
        agent.notas.clear()
        # Replace the module-level client with a fresh MagicMock each time
        self.mock_client = MagicMock()
        agent.client = self.mock_client

    # ------------------------------------------------------------------
    # Helper — build a mock response that simulates end_turn (final answer)
    # ------------------------------------------------------------------
    def _make_end_turn_response(self, text: str) -> MagicMock:
        """
        Build a mock Anthropic response object that simulates a final answer
        (stop_reason = 'end_turn') with the given text.
        """
        mock_response = MagicMock()
        mock_response.stop_reason = "end_turn"

        # Create a content block with a .text attribute
        mock_text_block = MagicMock()
        mock_text_block.text = text
        mock_response.content = [mock_text_block]

        return mock_response

    # ------------------------------------------------------------------
    # Helper — build a tool_use response followed by an end_turn response
    # ------------------------------------------------------------------
    def _make_tool_use_then_end_turn(
        self,
        tool_name: str,
        tool_input: dict,
        tool_use_id: str,
        final_text: str,
    ):
        """
        Build two mock responses:
        1. First call: stop_reason = 'tool_use' with one tool_use block.
        2. Second call: stop_reason = 'end_turn' with the final text.
        """
        # --- First response: tool call ---
        mock_tool_block = MagicMock()
        mock_tool_block.type = "tool_use"
        mock_tool_block.name = tool_name
        mock_tool_block.input = tool_input
        mock_tool_block.id = tool_use_id

        mock_tool_response = MagicMock()
        mock_tool_response.stop_reason = "tool_use"
        mock_tool_response.content = [mock_tool_block]

        # --- Second response: final answer ---
        mock_final_response = self._make_end_turn_response(final_text)

        return mock_tool_response, mock_final_response

    # ------------------------------------------------------------------
    # test_agente_resposta_final
    # ------------------------------------------------------------------
    def test_agente_resposta_final(self):
        """Loop agentic: resposta end_turn imediata deve ser retornada corretamente."""
        texto_esperado = "A resposta é 42."
        self.mock_client.messages.create.return_value = self._make_end_turn_response(
            texto_esperado
        )

        resultado = agent.executar_agente("Qual a resposta para tudo?")

        self.assertEqual(resultado, texto_esperado)
        # The client should have been called exactly once
        self.mock_client.messages.create.assert_called_once()

    def test_agente_usa_ferramenta_e_responde(self):
        """Loop agentic: agente deve usar ferramenta e depois retornar resposta final."""
        tool_response, final_response = self._make_tool_use_then_end_turn(
            tool_name="calcular",
            tool_input={"expressao": "2 + 2"},
            tool_use_id="toolu_test_01",
            final_text="2 + 2 é igual a 4."
        )
        self.mock_client.messages.create.side_effect = [tool_response, final_response]

        resultado = agent.executar_agente("Quanto é 2 + 2?")

        self.assertEqual(resultado, "2 + 2 é igual a 4.")
        # The client should have been called twice: once for tool_use, once for end_turn
        self.assertEqual(self.mock_client.messages.create.call_count, 2)

    def test_agente_max_iteracoes(self):
        """Loop agentic: deve parar e retornar mensagem ao atingir max_iteracoes."""
        # Simulate the model always wanting to use a tool — never finishing
        mock_tool_block = MagicMock()
        mock_tool_block.type = "tool_use"
        mock_tool_block.name = "calcular"
        mock_tool_block.input = {"expressao": "1 + 1"}
        mock_tool_block.id = "toolu_loop"

        mock_infinite = MagicMock()
        mock_infinite.stop_reason = "tool_use"
        mock_infinite.content = [mock_tool_block]

        # Always return the tool_use response (never ends naturally)
        self.mock_client.messages.create.return_value = mock_infinite

        resultado = agent.executar_agente("Pergunta sem fim", max_iteracoes=3)

        self.assertEqual(resultado, "Máximo de iterações atingido.")
        # Exactly max_iteracoes calls should have been made
        self.assertEqual(self.mock_client.messages.create.call_count, 3)

    def test_agente_retorna_string(self):
        """executar_agente deve sempre retornar uma string."""
        self.mock_client.messages.create.return_value = self._make_end_turn_response(
            "Resposta qualquer."
        )
        resultado = agent.executar_agente("Teste")
        self.assertIsInstance(resultado, str)


if __name__ == "__main__":
    unittest.main(verbosity=2)
