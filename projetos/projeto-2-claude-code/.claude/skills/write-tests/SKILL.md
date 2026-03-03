# Skill: write-tests

## Descrição

A skill `write-tests` gera testes unitários automaticamente para um arquivo de código existente. Ao receber o caminho do arquivo, o Claude lê o código, identifica todas as funções e métodos públicos que ainda não têm testes, cria um arquivo de testes completo com cobertura adequada e valida os testes rodando o pytest — tudo de forma autônoma.

Esta skill é ideal para aumentar a cobertura de testes em código legado, garantir que novas funcionalidades tenham testes desde o início e manter a qualidade do projeto.

---

## Como Usar

```
/write-tests <caminho/do/arquivo>
```

### Exemplos

```bash
# Gerar testes para um service
/write-tests app/services/task_service.py

# Gerar testes para um router
/write-tests app/routers/tasks.py

# Gerar testes para um módulo utilitário
/write-tests app/utils/validators.py
```

---

## Passos de Execução

O Claude seguirá **obrigatoriamente** esta sequência ao executar a skill:

### Passo 1 — Ler o arquivo alvo

Ler o arquivo completo para entender todo o código:

Ferramenta usada: `Read`

Ao ler o arquivo, identificar e documentar:
- Todas as funções públicas (não começam com `_`)
- Todos os métodos públicos de classes
- Os parâmetros de entrada: tipos esperados, valores opcionais, defaults
- Os valores de retorno: tipo e possíveis valores
- As exceções que podem ser levantadas
- As dependências externas: banco de dados, APIs, services

### Passo 2 — Verificar testes existentes

Antes de criar qualquer teste, verificar se já existem testes para o arquivo:

Ferramenta usada: `Glob`, `Grep`

```python
# Padrões de arquivos de teste a procurar:
# tests/test_<modulo>.py
# tests/<modulo>_test.py
# <mesmo_diretorio>/test_<modulo>.py
```

Para cada função identificada no Passo 1, verificar se já há um teste correspondente:

```bash
# Buscar por nome da função nos arquivos de teste
grep -r "def test_<nome_da_funcao>" tests/
```

Gerar a lista de:
- Funções já testadas (pular ou complementar se a cobertura for fraca)
- Funções sem nenhum teste (prioridade máxima)

### Passo 3 — Analisar os fixtures e conftest existentes

Ler o `conftest.py` para entender os fixtures disponíveis:

Ferramenta usada: `Glob`, `Read`

```bash
# Buscar conftest.py nos diretórios de teste
find tests/ -name "conftest.py"
```

Identificar:
- Fixtures de banco de dados disponíveis (`db`, `session`, `client`)
- Fixtures de usuário autenticado (`auth_headers`, `user`)
- Mocks e patches já configurados
- Configurações de ambiente de teste

### Passo 4 — Planejar os casos de teste

Para cada função sem teste, planejar os cenários:

**Para cada função, criar testes para:**

1. **Caminho feliz (happy path)** — entrada válida, saída esperada
2. **Valores de borda** — zero, vazio, None, string vazia, lista vazia
3. **Entradas inválidas** — tipo errado, formato inválido
4. **Exceções esperadas** — verificar que a exceção correta é levantada
5. **Estados extremos** — valor máximo, mínimo, lista muito grande

**Exemplos de casos por tipo de função:**

Para funções de criação (create):
```python
def test_create_task_sucesso()          # dados válidos → task criada
def test_create_task_titulo_vazio()     # título vazio → ValidationError
def test_create_task_usuario_invalido() # user_id inválido → HTTPException 404
```

Para funções de busca (get/list):
```python
def test_get_task_existente()           # ID válido → task retornada
def test_get_task_nao_encontrada()      # ID inválido → HTTPException 404
def test_list_tasks_pagina_vazia()      # sem tasks → lista vazia
def test_list_tasks_paginacao()         # muitas tasks → respeita limit/offset
```

Para funções de atualização (update):
```python
def test_update_task_sucesso()          # dados parciais → task atualizada
def test_update_task_sem_permissao()    # outro usuário → HTTPException 403
```

### Passo 5 — Criar o arquivo de testes

Criar o arquivo de testes seguindo as convenções do projeto:

Ferramenta usada: `Write`

**Estrutura padrão do arquivo de testes:**

```python
"""Testes para <nome_do_modulo>.

Cobre as funções: <lista_de_funcoes>
"""
import pytest
from unittest.mock import MagicMock, patch

# Imports do módulo sendo testado
from app.services.task_service import create_task, get_task, list_tasks


# =============================================================================
# Fixtures específicas para este módulo
# =============================================================================

@pytest.fixture
def task_data_valida():
    """Dados mínimos válidos para criar uma task."""
    return {
        "title": "Tarefa de teste",
        "description": "Descrição da tarefa",
        "priority": "medium"
    }


# =============================================================================
# Testes: create_task
# =============================================================================

class TestCreateTask:
    """Testes para a função create_task."""

    def test_sucesso_dados_validos(self, db, task_data_valida):
        """Deve criar a task quando os dados são válidos."""
        ...

    def test_falha_titulo_vazio(self, db):
        """Deve levantar ValidationError quando o título está vazio."""
        ...


# =============================================================================
# Testes: get_task
# =============================================================================

class TestGetTask:
    """Testes para a função get_task."""
    ...
```

**Convenções obrigatórias:**
- Agrupar testes por função em classes `TestNomeDaFuncao`
- Nomes de testes descritivos: `test_<cenario>_<resultado_esperado>`
- Docstring em cada teste explicando o que está sendo testado
- Usar `pytest.raises()` para testar exceções
- Não duplicar lógica de setup — usar fixtures

### Passo 6 — Validar os testes

Após criar o arquivo, rodar os testes para garantir que passam:

Ferramenta usada: `Bash`

```bash
# Rodar apenas os testes recém-criados
pytest tests/test_<modulo>.py -v

# Se falhar, ver o traceback completo
pytest tests/test_<modulo>.py -v --tb=long

# Verificar cobertura do módulo
pytest tests/test_<modulo>.py --cov=app/<modulo> --cov-report=term-missing
```

Se algum teste falhar:
1. Analisar o erro: é um problema no teste ou no código?
2. Se for problema no teste: corrigir a lógica do teste
3. Se for problema no código: informar ao usuário antes de alterar o código de produção
4. Rodar novamente até todos passarem
5. Se o código de produção tiver bugs expostos pelos testes, reportar sem corrigir automaticamente

---

## Ferramentas Disponíveis

| Ferramenta | Uso na Skill                                                         |
|------------|----------------------------------------------------------------------|
| `Read`     | Ler o arquivo alvo e o conftest.py                                   |
| `Write`    | Criar o arquivo de testes gerado                                     |
| `Bash`     | Rodar pytest para validar, buscar arquivos com find                  |
| `Grep`     | Verificar testes existentes, buscar imports e fixtures               |
| `Glob`     | Localizar arquivos de teste e conftest.py                            |
| `Edit`     | Ajustar testes que precisam de correção após a primeira execução     |

---

## Comportamento em Casos Especiais

### Arquivo com muitas funções (>10 funções públicas)

Se o arquivo tiver muitas funções:
1. Informar ao usuário quantas funções foram encontradas
2. Perguntar se deve gerar testes para todas ou para um subconjunto
3. Priorizar funções críticas de negócio sobre funções utilitárias simples

### Funções com dependências externas difíceis de mockar

Se a função acessa banco de dados, APIs externas ou sistema de arquivos:
1. Identificar as dependências
2. Usar mocks/patches adequados
3. Documentar no comentário do teste o que está sendo mockado e por quê

### Testes existentes com baixa cobertura

Se já existir um arquivo de testes mas a cobertura for baixa:
1. Não sobrescrever o arquivo existente
2. Identificar os casos de teste faltando
3. Criar um arquivo `test_<modulo>_adicional.py` com os novos testes
4. Ou perguntar ao usuário se deseja mesclar com o arquivo existente

### Código sem type hints

Se o arquivo não tiver type hints:
1. Inferir os tipos a partir do código
2. Avisar no resumo final que a falta de type hints dificultou a geração de testes precisos
3. Sugerir adicionar type hints ao arquivo de produção

---

## Saída Esperada

Ao finalizar, o Claude deve apresentar um resumo:

```
Testes gerados para: app/services/task_service.py

Arquivo criado: tests/test_task_service.py

Funcoes cobertas:
  - create_task     → 4 testes (happy path, titulo vazio, usuario invalido, duplicado)
  - get_task        → 3 testes (existente, nao encontrada, sem permissao)
  - list_tasks      → 4 testes (vazia, com dados, paginacao, filtro por status)
  - update_task     → 3 testes (sucesso, nao encontrada, sem permissao)
  - delete_task     → 2 testes (sucesso, sem permissao)

Total: 16 testes gerados

Resultado do pytest:
  16 passed em 2.34s

Cobertura de app/services/task_service.py: 94%
Linhas nao cobertas: 45, 67 (tratamento de erro de conexao com o banco)

Funcoes nao cobertas (fora do escopo ou muito simples):
  - _validate_internal  (privada, testada indiretamente)
```
