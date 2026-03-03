# Guia de Contribuição

Obrigado pelo interesse em contribuir com o **Projeto 1 — Agente do Zero**! Este guia descreve o processo para reportar problemas, propor melhorias e adicionar novas funcionalidades.

---

## Sumário

- [Como fazer fork e abrir um PR](#como-fazer-fork-e-abrir-um-pr)
- [Como adicionar uma nova ferramenta](#como-adicionar-uma-nova-ferramenta)
- [Padrão de commit messages](#padrão-de-commit-messages)
- [Como rodar os testes](#como-rodar-os-testes)
- [Boas práticas gerais](#boas-práticas-gerais)

---

## Como fazer fork e abrir um PR

### 1. Faça o fork do repositório

Clique no botão **Fork** no GitHub para criar uma cópia do repositório na sua conta.

### 2. Clone o seu fork localmente

```bash
git clone https://github.com/SEU-USUARIO/agentic-masterclass.git
cd agentic-masterclass/projetos/projeto-1-agente-zero
```

### 3. Configure o remote upstream (repositório original)

```bash
git remote add upstream https://github.com/INEMA-CLUB/agentic-masterclass.git
```

### 4. Mantenha seu fork atualizado antes de começar

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

### 5. Crie uma branch com nome descritivo

Use o padrão `tipo/descricao-curta`:

```bash
git checkout -b feat/ferramenta-traducao
# ou
git checkout -b fix/calcular-divisao-por-zero
# ou
git checkout -b docs/melhorar-readme
```

### 6. Faça suas alterações

- Siga os padrões de código descritos neste guia
- Adicione testes para qualquer nova funcionalidade
- Verifique a sintaxe antes de commitar:
  ```bash
  make lint
  ```

### 7. Commite seguindo o padrão de mensagens

Veja a seção [Padrão de commit messages](#padrão-de-commit-messages) abaixo.

### 8. Suba a branch para o seu fork

```bash
git push origin feat/ferramenta-traducao
```

### 9. Abra o Pull Request

No GitHub, clique em **Compare & pull request**. Preencha:
- **Título** claro e objetivo (siga o padrão de commits)
- **Descrição** explicando o que foi feito, por que e como testar
- Marque se o PR resolve alguma issue com `Closes #123`

---

## Como adicionar uma nova ferramenta

Adicionar uma ferramenta ao agente segue um processo estruturado. Use o template abaixo como ponto de partida.

### Template de ferramenta

Crie um arquivo em `tools/nome_da_ferramenta.py`:

```python
"""
tools/nome_da_ferramenta.py
Breve descrição do que esta ferramenta faz.

Dependências externas (se houver):
    pip install nome-do-pacote

Configuração (se houver):
    Adicione ao .env:
    NOME_DA_FERRAMENTA_API_KEY=sua_chave
"""

import os


def get_nome_da_ferramenta_schema() -> dict:
    """
    Retorna o schema JSON da ferramenta no formato Anthropic.

    Returns:
        dict: Schema completo com name, description e input_schema.
    """
    return {
        "name": "nome_da_ferramenta",
        "description": "Descreva claramente o que a ferramenta faz e quando usá-la.",
        "input_schema": {
            "type": "object",
            "properties": {
                "parametro_obrigatorio": {
                    "type": "string",
                    "description": "Descreva o que este parâmetro representa."
                },
                "parametro_opcional": {
                    "type": "integer",
                    "description": "Parâmetro opcional com valor padrão."
                }
            },
            "required": ["parametro_obrigatorio"]
        }
    }


def nome_da_ferramenta(parametro_obrigatorio: str, parametro_opcional: int = 10) -> str:
    """
    Implementa a lógica da ferramenta.

    Args:
        parametro_obrigatorio (str): Descrição do parâmetro.
        parametro_opcional (int): Descrição. Padrão: 10.

    Returns:
        str: Resultado formatado como string legível.
    """
    # TODO: implementar a lógica real aqui
    return f"Resultado para '{parametro_obrigatorio}' com opcao={parametro_opcional}"
```

### Passo a passo de integração

**1. Registre a exportação em `tools/__init__.py`:**

```python
from .weather_tool import get_weather_tool_schema, get_weather
from .nome_da_ferramenta import get_nome_da_ferramenta_schema, nome_da_ferramenta  # adicione

__all__ = [
    "get_weather_tool_schema", "get_weather",
    "get_nome_da_ferramenta_schema", "nome_da_ferramenta",  # adicione
]
```

**2. Importe e registre o schema em `agent.py`:**

```python
from tools import get_weather_tool_schema, get_weather
from tools import get_nome_da_ferramenta_schema, nome_da_ferramenta  # adicione

tools = [
    # ... ferramentas existentes ...
    get_nome_da_ferramenta_schema(),  # adicione
]
```

**3. Adicione o case no dispatcher de `agent.py`:**

```python
def executar_ferramenta(nome: str, inputs: dict) -> str:
    # ... cases existentes ...

    elif nome == "nome_da_ferramenta":
        return nome_da_ferramenta(
            inputs["parametro_obrigatorio"],
            inputs.get("parametro_opcional", 10)
        )

    return f"Ferramenta '{nome}' não encontrada."
```

**4. Adicione testes em `tests/test_agent.py`:**

```python
def test_dispatch_nome_da_ferramenta(self):
    """Ferramenta 'nome_da_ferramenta': deve retornar resultado esperado."""
    resultado = agent.executar_ferramenta(
        "nome_da_ferramenta",
        {"parametro_obrigatorio": "valor de teste"}
    )
    self.assertIn("valor de teste", resultado)
```

**5. Documente no README.md** adicionando a ferramenta à árvore de arquivos e à seção de extensão.

---

## Padrão de commit messages

Seguimos o padrão [Conventional Commits](https://www.conventionalcommits.org/). Cada mensagem deve ter o formato:

```
tipo(escopo): descrição curta em minúsculo
```

### Tipos permitidos

| Tipo | Quando usar |
|------|-------------|
| `feat` | Nova funcionalidade ou ferramenta |
| `fix` | Correção de bug |
| `docs` | Alterações apenas em documentação |
| `test` | Adição ou correção de testes |
| `refactor` | Refatoração sem mudança de comportamento |
| `chore` | Tarefas de manutenção (deps, CI, etc.) |
| `style` | Formatação de código sem mudança lógica |

### Exemplos

```bash
# Boa mensagem — clara, no padrão
git commit -m "feat(tools): adicionar ferramenta de consulta de CEP"
git commit -m "fix(dispatcher): tratar divisao por zero em calcular"
git commit -m "docs(readme): atualizar secao de instalacao com venv"
git commit -m "test(agent): adicionar teste para max_iteracoes"
git commit -m "refactor(loop): extrair logica de impressao para funcao separada"

# Mensagens que devem ser evitadas
git commit -m "fix"          # muito vago
git commit -m "wip"          # nunca commite WIP na main
git commit -m "Alterações"   # sem contexto
```

### Commits com breaking change

Se sua alteração quebra a compatibilidade com versões anteriores, adicione `!` após o tipo e explique no corpo da mensagem:

```bash
git commit -m "feat(agent)!: renomear executar_ferramenta para dispatch_tool

BREAKING CHANGE: a funcao executar_ferramenta foi renomeada para dispatch_tool.
Atualize todas as importacoes diretas."
```

---

## Como rodar os testes

### Rodar todos os testes

```bash
python -m unittest tests/test_agent.py -v
```

### Rodar um teste específico

```bash
python -m unittest tests.test_agent.TestDispatcher.test_dispatch_calcular -v
```

### Rodar todos os testes de uma classe

```bash
python -m unittest tests.test_agent.TestDispatcher -v
```

### Via Makefile

```bash
make test
```

### Verificar sintaxe

```bash
make lint
```

### O que esperar

Todos os testes devem passar sem necessidade de chave de API configurada:

```
test_dispatch_buscar_na_web ... ok
test_dispatch_calcular ... ok
test_dispatch_calcular_erro_sintaxe ... ok
test_dispatch_calcular_expressao_complexa ... ok
test_dispatch_ferramenta_invalida ... ok
test_dispatch_ferramenta_invalida_nome_no_retorno ... ok
test_dispatch_salvar_multiplas_notas ... ok
test_dispatch_salvar_nota ... ok
test_dispatch_salvar_nota_persistencia ... ok
test_agente_max_iteracoes ... ok
test_agente_resposta_final ... ok
test_agente_retorna_string ... ok
test_agente_usa_ferramenta_e_responde ... ok

----------------------------------------------------------------------
Ran 13 tests in 0.003s

OK
```

---

## Boas práticas gerais

- **Não commite o arquivo `.env`** — ele contém segredos e já está no `.gitignore`.
- **Escreva docstrings** para todas as funções públicas. Siga o formato Google Style.
- **Comentários em inglês** — padrão Python, facilita contribuições internacionais.
- **Texto para o usuário em português** — mensagens exibidas no terminal e docstrings de alto nível.
- **Uma ferramenta por arquivo** — mantenha cada ferramenta em seu próprio módulo em `tools/`.
- **Não quebre a interface pública** — `executar_agente(mensagem, max_iteracoes)` é a interface estável. Ao refatorar, mantenha a assinatura compatível.
- **Prefira `str` como retorno das ferramentas** — o agente insere o retorno diretamente no contexto da conversa; sempre retorne strings legíveis.
