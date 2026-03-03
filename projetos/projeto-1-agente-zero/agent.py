"""
Agente do Zero — Agentic Engineering Masterclass
INEMA.CLUB — Projeto 1: Agente sem framework

Demonstra o loop agentic manual com Anthropic API:
- Tools (function calling)
- Loop Pensar → Agir → Observar
- Sem frameworks externos
"""
import os
import json
import anthropic
from dotenv import load_dotenv

load_dotenv()
client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

# ─── FERRAMENTAS ──────────────────────────────────────────────────────────────

tools = [
    {
        "name": "buscar_na_web",
        "description": "Busca informações na web sobre qualquer tema",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "O que buscar. Seja específico."
                }
            },
            "required": ["query"]
        }
    },
    {
        "name": "calcular",
        "description": "Executa cálculos matemáticos. Recebe expressão Python válida.",
        "input_schema": {
            "type": "object",
            "properties": {
                "expressao": {
                    "type": "string",
                    "description": "Expressão matemática. Ex: '2 + 2' ou '100 * 0.15'"
                }
            },
            "required": ["expressao"]
        }
    },
    {
        "name": "salvar_nota",
        "description": "Salva uma nota ou resultado importante em memória",
        "input_schema": {
            "type": "object",
            "properties": {
                "titulo": {"type": "string"},
                "conteudo": {"type": "string"}
            },
            "required": ["titulo", "conteudo"]
        }
    }
]

# ─── DISPATCHER ───────────────────────────────────────────────────────────────

notas = {}  # Memória simples em dicionário

def executar_ferramenta(nome: str, inputs: dict) -> str:
    """Despacha a ferramenta correta e retorna o resultado."""

    if nome == "buscar_na_web":
        # Simulação de busca (substitua por requests + BeautifulSoup em produção)
        query = inputs["query"]
        return f"[Resultado de busca para '{query}']: Encontrado 3 resultados relevantes. Artigo principal: informações sobre {query} publicadas em 2025. Fonte: web simulada."

    elif nome == "calcular":
        try:
            resultado = eval(inputs["expressao"], {"__builtins__": {}})
            return f"Resultado: {resultado}"
        except Exception as e:
            return f"Erro no cálculo: {str(e)}"

    elif nome == "salvar_nota":
        notas[inputs["titulo"]] = inputs["conteudo"]
        return f"Nota '{inputs['titulo']}' salva com sucesso."

    return f"Ferramenta '{nome}' não encontrada."

# ─── LOOP AGENTIC ─────────────────────────────────────────────────────────────

def executar_agente(mensagem_usuario: str, max_iteracoes: int = 10) -> str:
    """
    Loop agentic principal:
    1. Envia mensagem ao LLM
    2. Se o LLM chamar ferramentas → executa e retorna resultados
    3. Repete até o LLM responder sem ferramentas (stop_reason = end_turn)
    """
    mensagens = [{"role": "user", "content": mensagem_usuario}]
    iteracao = 0

    print(f"\n{'='*60}")
    print(f"AGENTE INICIADO")
    print(f"{'='*60}")

    while iteracao < max_iteracoes:
        iteracao += 1
        print(f"\n[Iteração {iteracao}] Pensando...")

        # LLM pensa
        resposta = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=4096,
            system="Você é um assistente inteligente com acesso a ferramentas. Use-as quando necessário para fornecer respostas precisas e úteis.",
            tools=tools,
            messages=mensagens
        )

        # Sem uso de ferramentas = resposta final
        if resposta.stop_reason == "end_turn":
            resposta_final = next(
                (b.text for b in resposta.content if hasattr(b, "text")),
                "Sem resposta."
            )
            print(f"\n{'='*60}")
            print(f"RESPOSTA FINAL:")
            print(f"{'='*60}")
            print(resposta_final)
            return resposta_final

        # Processa chamadas de ferramentas
        resultados_ferramentas = []
        for bloco in resposta.content:
            if bloco.type == "tool_use":
                print(f"  → Usando ferramenta: {bloco.name}({json.dumps(bloco.input, ensure_ascii=False)})")
                resultado = executar_ferramenta(bloco.name, bloco.input)
                print(f"  ← Resultado: {resultado[:100]}...")
                resultados_ferramentas.append({
                    "type": "tool_result",
                    "tool_use_id": bloco.id,
                    "content": resultado
                })

        # Adiciona ao histórico e continua o loop
        mensagens.append({"role": "assistant", "content": resposta.content})
        mensagens.append({"role": "user", "content": resultados_ferramentas})

    return "Máximo de iterações atingido."

# ─── MAIN ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Agente do Zero — INEMA.CLUB")
    print("Pressione Ctrl+C para sair\n")

    while True:
        try:
            mensagem = input("Você: ").strip()
            if not mensagem:
                continue
            if mensagem.lower() in ["sair", "exit", "quit"]:
                break
            executar_agente(mensagem)
        except KeyboardInterrupt:
            print("\nAté logo!")
            break
        except Exception as e:
            print(f"Erro: {e}")
