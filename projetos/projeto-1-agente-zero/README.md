# Projeto 1 — Agente do Zero

![Status](https://img.shields.io/badge/status-estável-brightgreen)
![Python](https://img.shields.io/badge/python-3.11%2B-blue)
![License](https://img.shields.io/badge/licença-MIT-lightgrey)
![Anthropic](https://img.shields.io/badge/Anthropic-API-orange)

> **Agente Python sem frameworks — demonstração do loop agentic puro**

Implementação do zero de um agente de IA utilizando diretamente a API da Anthropic, sem nenhum framework de alto nível como LangChain ou LlamaIndex. O objetivo é entender o mecanismo fundamental por trás de qualquer agente: o loop **Pensar → Agir → Observar**.

---

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Como usar](#como-usar)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Como adicionar novas ferramentas](#como-adicionar-novas-ferramentas)
- [Testes](#testes)
- [Licença](#licença)

---

## Pré-requisitos

- **Python 3.11 ou superior** — o projeto usa recursos de tipagem e sintaxe disponíveis a partir desta versão
- **Conta Anthropic** com acesso à API — crie sua conta em [console.anthropic.com](https://console.anthropic.com)
- **Chave de API Anthropic** (`ANTHROPIC_API_KEY`) — gerada no painel da sua conta
- `pip` atualizado (`pip install --upgrade pip`)

---

## Instalação

Siga os passos abaixo na ordem apresentada:

```bash
# 1. Clone o repositório principal
git clone https://github.com/seu-usuario/agentic-masterclass.git

# 2. Entre na pasta do projeto
cd agentic-masterclass/projetos/projeto-1-agente-zero

# 3. (Recomendado) Crie e ative um ambiente virtual
python -m venv .venv
source .venv/bin/activate       # Linux / macOS
# .venv\Scripts\activate        # Windows

# 4. Instale as dependências
pip install -r requirements.txt

# 5. Copie o arquivo de variáveis de ambiente
cp .env.example .env

# 6. Abra o arquivo .env e preencha sua chave de API
# ANTHROPIC_API_KEY=sk-ant-...
```

> **Atenção:** nunca commite o arquivo `.env` com sua chave real. Ele já está listado no `.gitignore`.

---

## Como usar

### Modo interativo

```bash
python agent.py
```

O agente iniciará no modo de conversa interativa. Digite sua mensagem e pressione Enter:

```
Agente do Zero — INEMA.CLUB
Pressione Ctrl+C para sair

Você: Quanto é 15% de 2400?
============================================================
AGENTE INICIADO
============================================================

[Iteração 1] Pensando...
  → Usando ferramenta: calcular({"expressao": "2400 * 0.15"})
  ← Resultado: Resultado: 360...

============================================================
RESPOSTA FINAL:
============================================================
15% de 2400 é igual a 360.
```

### Exemplos de prompts para testar

| Categoria | Exemplo de prompt |
|-----------|------------------|
| Matemática | `"Calcule a raiz quadrada de 144"` |
| Matemática | `"Qual é o resultado de (500 * 1.1) ** 2?"` |
| Memória | `"Salve uma nota chamada 'reunião' com o conteúdo 'dia 10 às 14h'"` |
| Busca | `"Busque informações sobre inteligência artificial generativa"` |
| Combinado | `"Calcule 12 * 8 e salve o resultado como nota 'multiplicação'"` |

### Saindo do agente

Digite `sair`, `exit` ou `quit`, ou pressione `Ctrl+C`.

### Usando via código

```python
from agent import executar_agente

resultado = executar_agente("Quanto é 2 + 2?")
print(resultado)  # "2 + 2 é igual a 4."
```

---

## Estrutura do projeto

```
projeto-1-agente-zero/
│
├── agent.py               # Código principal — loop agentic completo
├── requirements.txt       # Dependências Python (anthropic, python-dotenv)
├── .env.example           # Modelo de variáveis de ambiente
├── .env                   # Suas variáveis locais (não commitado)
├── Makefile               # Atalhos de comandos (install, run, test, lint)
│
├── tools/                 # Ferramentas extras (plug-and-play)
│   ├── __init__.py        # Exporta schemas e funções das ferramentas
│   └── weather_tool.py    # Exemplo: consulta de clima (OpenWeatherMap)
│
├── tests/                 # Testes unitários
│   └── test_agent.py      # Testes com unittest e mocks
│
├── README.md              # Este arquivo
├── CONTRIBUTING.md        # Guia de contribuição
└── ROTEIRO.md             # Roteiro de estudo passo a passo
```

### Descrição de cada arquivo

- **`agent.py`** — coração do projeto. Define as ferramentas (`tools`), o dispatcher (`executar_ferramenta`) e o loop agentic (`executar_agente`). Leia este arquivo para entender tudo.
- **`requirements.txt`** — apenas duas dependências: `anthropic` (SDK oficial) e `python-dotenv` (carrega o `.env`).
- **`tools/weather_tool.py`** — ferramenta de exemplo que demonstra como estender o agente com novas capacidades sem alterar o `agent.py`.
- **`tests/test_agent.py`** — testes unitários que validam o dispatcher e o loop agentic com mocks, sem consumir sua cota da API.

---

## Como adicionar novas ferramentas

O agente foi projetado para ser facilmente extensível. Siga os 4 passos abaixo:

### Passo 1 — Crie o módulo da ferramenta em `tools/`

```python
# tools/minha_ferramenta.py

def get_minha_ferramenta_schema() -> dict:
    """Retorna o schema JSON que a API Anthropic espera."""
    return {
        "name": "minha_ferramenta",
        "description": "Descreva o que esta ferramenta faz.",
        "input_schema": {
            "type": "object",
            "properties": {
                "parametro": {
                    "type": "string",
                    "description": "Descreva o parâmetro."
                }
            },
            "required": ["parametro"]
        }
    }

def minha_ferramenta(parametro: str) -> str:
    """Implementação da ferramenta."""
    return f"Resultado para: {parametro}"
```

### Passo 2 — Exporte em `tools/__init__.py`

```python
from .minha_ferramenta import get_minha_ferramenta_schema, minha_ferramenta
__all__ = [..., "get_minha_ferramenta_schema", "minha_ferramenta"]
```

### Passo 3 — Registre a ferramenta em `agent.py`

```python
from tools import get_minha_ferramenta_schema, minha_ferramenta

tools = [
    # ... ferramentas existentes ...
    get_minha_ferramenta_schema(),  # adicione aqui
]
```

### Passo 4 — Adicione o case no dispatcher

```python
def executar_ferramenta(nome: str, inputs: dict) -> str:
    # ... cases existentes ...
    elif nome == "minha_ferramenta":
        return minha_ferramenta(inputs["parametro"])
```

Pronto. O agente já saberá usar a nova ferramenta automaticamente.

---

## Testes

```bash
# Rodar todos os testes
python -m unittest tests/test_agent.py -v

# Ou via Makefile
make test
```

Os testes **não consomem sua cota da API** — o cliente Anthropic é mockado com `unittest.mock`.

---

## Licença

Este projeto está licenciado sob a **Licença MIT**.

```
MIT License

Copyright (c) 2025 INEMA.CLUB

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
