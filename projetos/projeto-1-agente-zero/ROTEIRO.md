# Roteiro de Estudo — Projeto 1: Agente do Zero

Este roteiro guia você do zero até a criação de um agente de pesquisa completo. Siga os passos em ordem — cada etapa constrói sobre a anterior.

**Tempo total estimado: ~3h30min**

---

## Passo 1 — Entender o que é um loop agentic

**Tempo estimado: 5 minutos de leitura**

Antes de tocar em código, entenda o conceito fundamental.

### O que é um agente de IA?

Um agente é um programa que usa um modelo de linguagem (LLM) para **tomar decisões e executar ações** de forma autônoma, repetindo o ciclo até completar uma tarefa.

### O loop agentic (Pensar → Agir → Observar)

```
┌─────────────────────────────────────────────────────┐
│                   LOOP AGENTIC                      │
│                                                     │
│   Usuário pergunta                                  │
│         ↓                                           │
│   LLM PENSA ──── Tenho informação suficiente? ──── SIM → Responde ao usuário
│         │                                           │
│        NÃO                                          │
│         ↓                                           │
│   LLM AGE ──── Escolhe e chama uma ferramenta       │
│         ↓                                           │
│   OBSERVA ──── Recebe o resultado da ferramenta     │
│         ↓                                           │
│   Volta para PENSA (com o novo contexto)            │
└─────────────────────────────────────────────────────┘
```

### Por que isso importa?

Sem o loop agentic, o LLM só pode usar o que está em seu treinamento. Com ele, o LLM pode:
- Fazer cálculos em tempo real
- Buscar informações atualizadas
- Salvar e recuperar dados
- Interagir com sistemas externos (APIs, bancos de dados, arquivos)

### Leitura complementar (opcional)

- [Documentação oficial da Anthropic — Tool Use](https://docs.anthropic.com/en/docs/build-with-claude/tool-use)
- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629) (artigo original do conceito)

---

## Passo 2 — Instalar dependências e configurar o ambiente

**Tempo estimado: 10 minutos**

### 2.1 — Crie e ative um ambiente virtual

```bash
cd projetos/projeto-1-agente-zero

# Criar o ambiente virtual
python -m venv .venv

# Ativar (Linux/macOS)
source .venv/bin/activate

# Ativar (Windows)
.venv\Scripts\activate
```

Você saberá que deu certo quando o prompt do terminal mostrar `(.venv)` no início.

### 2.2 — Instale as dependências

```bash
pip install -r requirements.txt
```

Deve instalar apenas dois pacotes: `anthropic` e `python-dotenv`.

### 2.3 — Configure o arquivo .env

```bash
cp .env.example .env
```

Abra o arquivo `.env` em qualquer editor de texto e preencha:

```
ANTHROPIC_API_KEY=sk-ant-api03-...
```

> Como obter sua chave: acesse [console.anthropic.com](https://console.anthropic.com) → API Keys → Create Key.

### 2.4 — Verifique a instalação

```bash
python -c "import anthropic; print('Tudo certo!')"
```

---

## Passo 3 — Ler o agent.py completo e entender cada função

**Tempo estimado: 20 minutos**

Abra o `agent.py` e leia **cada seção** prestando atenção nos comentários.

### O que observar em cada seção

**Seção `tools` (linhas ~20–61):**
- Cada ferramenta é um dicionário com `name`, `description` e `input_schema`
- O `input_schema` segue o padrão JSON Schema
- O `description` é lido pelo modelo para decidir quando usar a ferramenta

**Seção `executar_ferramenta` (linhas ~67–86):**
- É o dispatcher: recebe o nome e os inputs, executa a função certa
- `eval()` é usado para calcular expressões matemáticas (cuidado em produção!)
- `notas` é um dicionário global — memória simples em RAM

**Seção `executar_agente` (linhas ~90–146):**
- Mantém a lista `mensagens` que cresce a cada iteração
- `stop_reason == "end_turn"` significa que o modelo terminou
- `stop_reason == "tool_use"` significa que o modelo quer usar uma ferramenta
- Os resultados das ferramentas são adicionados de volta ao histórico

### Perguntas para reflexão

1. O que acontece se o modelo chamar uma ferramenta que não existe no dispatcher?
2. Por que `mensagens` precisa crescer a cada iteração e não apenas a última resposta é enviada?
3. O que a propriedade `tool_use_id` representa e por que ela é necessária?

---

## Passo 4 — Executar o agente e fazer 3 perguntas diferentes

**Tempo estimado: 15 minutos**

```bash
python agent.py
```

### Perguntas sugeridas para testar cada ferramenta

**Testando `calcular`:**
```
Você: Qual é o resultado de 1234 * 5678?
```

**Testando `salvar_nota` e `buscar_na_web`:**
```
Você: Busque informações sobre Python e salve um resumo como nota chamada "python"
```

**Testando raciocínio multi-passo:**
```
Você: Calcule quanto é 15% de 4800 e salve o resultado como "desconto"
```

### O que observar durante a execução

- Quantas iterações o agente usou para responder cada pergunta?
- O modelo sempre escolheu a ferramenta certa?
- O que aparece entre `[Iteração N]` e `RESPOSTA FINAL`?

---

## Passo 5 — Adicionar a ferramenta `get_weather`

**Tempo estimado: 30 minutos**

A ferramenta `get_weather` já está implementada em `tools/weather_tool.py`. Sua tarefa é integrá-la ao agente principal.

### 5.1 — Examine a ferramenta existente

```bash
cat tools/weather_tool.py
```

Entenda:
- O que `get_weather_tool_schema()` retorna?
- O que `get_weather(cidade)` faz quando não há API key?

### 5.2 — Integre ao agent.py

Abra `agent.py` e faça as seguintes alterações:

**No início do arquivo, adicione o import:**
```python
from tools import get_weather_tool_schema, get_weather
```

**Na lista `tools`, adicione o schema:**
```python
tools = [
    # ... ferramentas existentes ...
    get_weather_tool_schema(),
]
```

**No dispatcher `executar_ferramenta`, adicione o case:**
```python
elif nome == "consultar_clima":
    return get_weather(inputs["cidade"])
```

### 5.3 — Teste a nova ferramenta

```bash
python agent.py
```

```
Você: Como está o clima em São Paulo hoje?
Você: Compara o clima de Curitiba com o de Manaus
```

### 5.4 — (Opcional) Configure a API real

Crie uma conta grátis no [OpenWeatherMap](https://openweathermap.org/api) e adicione ao `.env`:

```
OPENWEATHER_API_KEY=sua_chave_aqui
```

Também instale o `requests`:
```bash
pip install requests
```

---

## Passo 6 — Adicionar memória persistente com arquivo JSON

**Tempo estimado: 45 minutos**

Atualmente, as notas do agente são perdidas quando o programa fecha (estão em um dicionário na memória RAM). Neste passo, você vai persistir as notas em um arquivo JSON.

### 6.1 — Entenda o problema

Execute o agente, salve uma nota, feche com Ctrl+C, e abra novamente. A nota sumiu. Por quê?

### 6.2 — Implemente a persistência

Substitua o dicionário `notas = {}` por funções que leem e escrevem em disco:

```python
import pathlib

ARQUIVO_NOTAS = pathlib.Path("notas.json")

def carregar_notas() -> dict:
    """Load notes from disk, returning empty dict if file doesn't exist."""
    if ARQUIVO_NOTAS.exists():
        import json
        return json.loads(ARQUIVO_NOTAS.read_text(encoding="utf-8"))
    return {}

def salvar_notas_em_disco(notas: dict) -> None:
    """Persist the notes dictionary to disk as JSON."""
    import json
    ARQUIVO_NOTAS.write_text(
        json.dumps(notas, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )

# Inicializa carregando do disco
notas = carregar_notas()
```

### 6.3 — Atualize o dispatcher

Modifique o case `salvar_nota` para persistir em disco:

```python
elif nome == "salvar_nota":
    notas[inputs["titulo"]] = inputs["conteudo"]
    salvar_notas_em_disco(notas)
    return f"Nota '{inputs['titulo']}' salva com sucesso."
```

### 6.4 — Adicione a ferramenta `listar_notas`

Adicione ao `tools`:

```python
{
    "name": "listar_notas",
    "description": "Lista todas as notas salvas anteriormente",
    "input_schema": {
        "type": "object",
        "properties": {},
        "required": []
    }
}
```

E ao dispatcher:

```python
elif nome == "listar_notas":
    if not notas:
        return "Nenhuma nota salva ainda."
    return "\n".join(f"- {titulo}: {conteudo}" for titulo, conteudo in notas.items())
```

### 6.5 — Teste a persistência

```bash
python agent.py
# Salve uma nota, feche com Ctrl+C
python agent.py
# Pergunte: "Quais notas eu tenho salvas?"
```

---

## Passo 7 — Desafio final: criar um agente de pesquisa completo

**Tempo estimado: 2 horas**

Este é o desafio final. Você vai construir um agente capaz de pesquisar, sintetizar e reportar informações sobre qualquer tema.

### Objetivo

Criar um agente que, dado um tema de pesquisa, seja capaz de:
1. Quebrar o tema em subtópicos
2. Buscar informações para cada subtópico
3. Fazer cálculos relevantes (ex: estatísticas)
4. Salvar o relatório final em arquivo Markdown

### Ferramentas a implementar

**`buscar_wikipedia(termo)` — busca real na Wikipedia:**
```python
# Instale: pip install wikipedia-api
import wikipediaapi

def buscar_wikipedia(termo: str, idioma: str = "pt") -> str:
    wiki = wikipediaapi.Wikipedia(
        user_agent="agente-pesquisa/1.0",
        language=idioma
    )
    pagina = wiki.page(termo)
    if not pagina.exists():
        return f"Artigo '{termo}' não encontrado na Wikipedia."
    # Return first 1000 chars to avoid overwhelming the context
    return pagina.summary[:1000]
```

**`salvar_relatorio(nome_arquivo, conteudo)` — salva arquivo Markdown:**
```python
def salvar_relatorio(nome_arquivo: str, conteudo: str) -> str:
    import pathlib
    caminho = pathlib.Path(nome_arquivo)
    if not nome_arquivo.endswith(".md"):
        caminho = pathlib.Path(nome_arquivo + ".md")
    caminho.write_text(conteudo, encoding="utf-8")
    return f"Relatório salvo em '{caminho}'."
```

### System prompt especializado

Substitua o `system` do `client.messages.create` por:

```python
system = """Você é um agente de pesquisa especializado. Quando receber um tema:
1. Identifique 3-5 subtópicos relevantes
2. Use buscar_wikipedia para pesquisar cada subtópico
3. Use calcular para qualquer estatística ou comparação numérica relevante
4. Sintetize as informações em um relatório estruturado
5. Salve o relatório final com salvar_relatorio
Seja metódico, cite as fontes e organize o relatório com títulos Markdown."""
```

### Exemplo de uso esperado

```
Você: Pesquise sobre energia solar no Brasil e gere um relatório
```

O agente deve:
- Buscar "energia solar Brasil", "matriz energética Brasil", "capacidade instalada solar"
- Calcular comparações (ex: crescimento percentual)
- Gerar e salvar um arquivo `relatorio-energia-solar.md`

### Critérios de sucesso

- [ ] O agente completa a pesquisa sem intervenção humana
- [ ] O relatório salvo tem pelo menos 3 seções com conteúdo real
- [ ] O agente usou pelo menos 3 chamadas de ferramentas diferentes
- [ ] O arquivo Markdown gerado é legível e bem formatado

### Dicas

- Aumente `max_iteracoes` para 20 neste desafio
- Adicione `print` extras para entender o raciocínio do agente
- Se a pesquisa travar, tente um tema mais específico

---

## Parabéns!

Se você chegou até aqui, você:

- Entendeu o funcionamento interno de um loop agentic
- Implementou e integrou novas ferramentas
- Adicionou persistência de dados
- Construiu um agente de pesquisa funcional

**Próximo projeto:** Projeto 2 — Agente com LangChain, onde veremos como frameworks de alto nível abstraem exatamente o que você acabou de construir na mão.
