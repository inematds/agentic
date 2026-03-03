# Skill: fix-issue

## Descrição

A skill `fix-issue` automatiza o processo completo de corrigir uma issue do GitHub. Ao receber o número de uma issue, o Claude busca os detalhes no repositório, analisa o código relacionado, cria uma branch dedicada, implementa a correção, roda os testes e commita as mudanças — tudo de forma autônoma.

Esta skill é ideal para bugs bem descritos, melhorias de código, ajustes de documentação e refatorações pontuais.

---

## Como Usar

```
/fix-issue <numero-da-issue>
```

### Exemplos

```bash
# Corrigir a issue #123
/fix-issue 123

# Corrigir a issue #45 (bug report)
/fix-issue 45

# Corrigir a issue #200 (feature request simples)
/fix-issue 200
```

---

## Passos de Execução

O Claude seguirá **obrigatoriamente** esta sequência ao executar a skill:

### Passo 1 — Ler a Issue

Buscar os detalhes completos da issue no GitHub usando a CLI `gh`:

```bash
gh issue view <numero> --json title,body,labels,assignees,comments
```

Analisar:
- Título e descrição do problema
- Labels (bug, enhancement, documentation, etc.)
- Comentários com informações adicionais
- Arquivos ou funções mencionados

### Passo 2 — Analisar o Código Relacionado

Identificar os arquivos relevantes para a issue:

- Buscar por funções, classes ou variáveis mencionadas na issue
- Ler os arquivos identificados completamente antes de qualquer edição
- Entender o contexto: como o código é usado, quais dependências existem
- Verificar os testes existentes para a área afetada

Ferramentas usadas neste passo: `Grep`, `Glob`, `Read`

### Passo 3 — Criar Branch Dedicada

Criar uma branch com nomenclatura padronizada antes de qualquer modificação:

```bash
# Para bugs
git checkout -b fix/issue-<numero>-descricao-curta

# Para melhorias
git checkout -b feat/issue-<numero>-descricao-curta

# Para documentação
git checkout -b docs/issue-<numero>-descricao-curta
```

Nunca fazer alterações diretamente em `main` ou `develop`.

### Passo 4 — Implementar o Fix

Aplicar as correções necessárias seguindo as convenções do projeto definidas no `CLAUDE.md`:

- Editar apenas os arquivos necessários
- Manter o estilo de código existente
- Adicionar type hints onde estiverem faltando
- Atualizar docstrings se a assinatura da função mudou
- Não introduzir dependências novas sem necessidade

Ferramentas usadas neste passo: `Edit`, `Write`

### Passo 5 — Rodar os Testes

Verificar que a correção não quebrou nada e, idealmente, adicionar testes para o caso corrigido:

```bash
# Rodar todos os testes
pytest

# Rodar apenas os testes relacionados ao fix
pytest tests/test_<modulo>.py -v

# Verificar cobertura na área modificada
pytest --cov=app/<modulo> --cov-report=term-missing
```

Se algum teste falhar:
1. Analisar o erro
2. Corrigir o problema
3. Rodar os testes novamente
4. Repetir até todos passarem

### Passo 6 — Commitar as Mudanças

Após todos os testes passarem, fazer o commit com mensagem clara e referência à issue:

```bash
# Adicionar arquivos modificados
git add <arquivos-modificados>

# Commitar com referência à issue
git commit -m "Fix: corrige <descricao-do-problema>

Resolve #<numero-da-issue>

- <detalhe 1 do que foi feito>
- <detalhe 2 do que foi feito>"
```

Não usar `git add .` — adicionar apenas os arquivos realmente modificados para o fix.

---

## Ferramentas Disponíveis

| Ferramenta | Uso na Skill                                              |
|------------|-----------------------------------------------------------|
| `Bash`     | Executar `gh issue view`, `git`, `pytest`, `ruff`         |
| `Read`     | Ler arquivos de código antes de editar                    |
| `Edit`     | Aplicar correções nos arquivos identificados              |
| `Write`    | Criar novos arquivos de teste quando necessário           |
| `Grep`     | Buscar funções, classes e padrões no código               |
| `Glob`     | Encontrar arquivos relacionados à issue                   |

---

## Comportamento em Casos Especiais

### Issue muito ampla ou ambígua

Se a issue não tiver detalhes suficientes para implementar uma solução clara, o Claude deve:
1. Listar o que foi entendido
2. Apresentar as possíveis abordagens
3. Perguntar ao usuário qual caminho seguir antes de modificar qualquer arquivo

### Testes falhando antes do fix

Se os testes já estiverem falhando antes da modificação, o Claude deve:
1. Informar ao usuário sobre os testes falhos pré-existentes
2. Perguntar se deve corrigir apenas a issue ou também os testes quebrados
3. Documentar os testes que estavam falhos no commit

### Fix requer mudanças em múltiplos módulos

Se a correção impactar mais de 3 arquivos distintos, o Claude deve:
1. Apresentar um plano detalhado antes de executar
2. Aguardar confirmação do usuário
3. Executar as mudanças de forma incremental, testando a cada etapa

---

## Saída Esperada

Ao finalizar, o Claude deve apresentar um resumo:

```
Fix concluído para a issue #<numero>

Branch criada: fix/issue-<numero>-<descricao>
Arquivos modificados:
  - app/routers/tasks.py (linha 45: corrigido filtro de data)
  - tests/test_tasks.py (adicionado teste para o caso de data inválida)

Testes: 42 passed, 0 failed
Commit: "Fix: corrige filtro de data inválida no endpoint de tarefas"

Próximos passos:
  git push origin fix/issue-<numero>-<descricao>
  gh pr create --title "Fix #<numero>: <descricao>"
```
