# Skill: review-pr

## Descrição

A skill `review-pr` realiza um review estruturado e completo de um Pull Request do GitHub. Ao receber o número do PR, o Claude busca as mudanças, analisa a qualidade do código, verifica a cobertura de testes, confere as convenções do projeto e produz um comentário de review organizado e acionável — pronto para ser postado ou usado como referência.

Esta skill é ideal para garantir consistência nos reviews, acelerar o processo de code review e manter a qualidade do código em equipe.

---

## Como Usar

```
/review-pr <numero-do-pr>
```

### Exemplos

```bash
# Fazer review do PR #78
/review-pr 78

# Fazer review do PR #12
/review-pr 12

# Fazer review do PR #200 antes de aprovar
/review-pr 200
```

---

## Passos de Execução

O Claude seguirá **obrigatoriamente** esta sequência ao executar a skill:

### Passo 1 — Buscar informações do PR

Coletar todos os metadados relevantes do Pull Request:

```bash
gh pr view <numero> --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,reviews,comments,labels,isDraft,mergeable
```

Analisar:
- Título e descrição: o PR explica claramente o que faz e por quê?
- Autor e contexto
- Branch de origem e destino
- Tamanho: número de arquivos e linhas alteradas
- Status: draft, mergeable, ou bloqueado por checks
- Labels e reviews já existentes

Se o PR estiver como draft (`isDraft: true`), informar ao usuário antes de continuar — PRs draft geralmente não estão prontos para review.

### Passo 2 — Obter as mudanças em detalhes

Buscar o diff completo do PR:

```bash
gh pr diff <numero>
```

Analisar linha a linha:
- Quais arquivos foram adicionados, modificados ou removidos
- Se as mudanças são coesas (um PR deve fazer uma coisa só)
- Se há código comentado ou debugs esquecidos (console.log, print, pdb, etc.)
- Se há hardcoded secrets, URLs ou configurações de ambiente

Ferramentas usadas neste passo: `Bash`

### Passo 3 — Analisar os arquivos modificados

Para cada arquivo relevante modificado, ler o contexto completo (não apenas o diff):

Ferramentas usadas neste passo: `Read`, `Glob`, `Grep`

Para cada arquivo analisado, verificar:

**Qualidade do código:**
- O código é legível e autoexplicativo?
- Há funções ou métodos muito longos que deveriam ser quebrados?
- Há duplicação de código que poderia ser extraída?
- O tratamento de erros é adequado?
- Há edge cases não tratados?

**Convenções do projeto (conforme CLAUDE.md):**
- Nomenclatura de variáveis, funções e classes está correta?
- Type hints presentes onde obrigatório?
- Docstrings seguindo o formato padrão?
- Imports organizados na ordem correta?
- Estilo de código consistente com o restante do projeto?

**Segurança:**
- Inputs de usuário estão sendo validados?
- Há operações que deveriam ter verificação de autorização?
- Dados sensíveis sendo logados ou expostos?

### Passo 4 — Verificar cobertura de testes

Identificar se os arquivos modificados têm testes correspondentes:

```bash
# Listar arquivos de teste existentes
gh pr diff <numero> --name-only
```

Ferramentas usadas neste passo: `Glob`, `Grep`, `Read`

Para cada arquivo de código modificado:
- Verificar se existe um arquivo de teste correspondente
- Ler os testes existentes: cobrem os casos do PR?
- O PR adicionou novos testes para as novas funcionalidades?
- Há testes para os edge cases identificados?

```bash
# Verificar se os testes passam localmente (se possível)
pytest tests/ -v --tb=short 2>&1 | tail -20
```

### Passo 5 — Verificar checks do PR

Ver o status dos checks automatizados:

```bash
gh pr checks <numero>
```

Identificar:
- Quais checks estão falhando
- Quais checks estão passando
- Há checks de lint, tipo ou segurança falhando?

### Passo 6 — Produzir o review estruturado

Gerar um comentário de review completo, organizado nas seguintes seções:

```
## Review do PR #<numero>: <titulo>

### Resumo
[2-3 frases sobre o objetivo do PR e impressão geral]

### Pontos Positivos
- [O que está bem feito — seja específico]
- [Boa prática adotada]

### Problemas Críticos (bloqueiam merge)
- **[arquivo:linha]** — [descrição do problema] | Sugestão: [como corrigir]

### Melhorias Sugeridas (não bloqueiam)
- **[arquivo:linha]** — [sugestão de melhoria]
- [Consideração de design]

### Testes
- [ ] [Caso de teste faltando] em `tests/test_<modulo>.py`
- [x] [Caso coberto adequadamente]

### Checklist Final
- [ ] Testes passando
- [ ] Lint sem erros
- [ ] Sem código de debug
- [ ] Documentação atualizada (se necessário)
- [ ] Variáveis de ambiente documentadas (se necessário)

### Decisão
**[APROVADO / APROVADO COM RESSALVAS / MUDANÇAS NECESSÁRIAS]**

[Justificativa da decisão em 1-2 frases]
```

---

## Ferramentas Disponíveis

| Ferramenta | Uso na Skill                                                       |
|------------|--------------------------------------------------------------------|
| `Bash`     | Executar `gh pr view`, `gh pr diff`, `gh pr checks`, `pytest`      |
| `Read`     | Ler os arquivos modificados no contexto completo                   |
| `Grep`     | Buscar padrões problemáticos (debug, secrets, TODOs)               |
| `Glob`     | Encontrar arquivos de teste correspondentes aos arquivos mudados   |

---

## Comportamento em Casos Especiais

### PR muito grande (>500 linhas alteradas)

Se o diff for muito extenso:
1. Informar ao usuário o tamanho do PR
2. Focar nos arquivos de maior risco (lógica de negócio, autenticação, dados)
3. Mencionar no review que o PR poderia ser quebrado em partes menores

### PR sem descrição

Se o PR não tiver descrição ou a descrição for muito vaga:
1. Incluir no review que a falta de contexto dificulta o review
2. Sugerir o que a descrição deveria incluir
3. Continuar o review mesmo assim

### Checks falhando

Se os checks automatizados estiverem falhando:
1. Listar os checks que estão falhando no review
2. Classificar como problema crítico se for lint, tipos ou testes
3. Não aprovar o PR enquanto houver checks críticos falhando

### PR é do próprio usuário

Se o PR foi criado pelo usuário que invocou a skill:
1. Avisar sobre o conflito de interesse em auto-review
2. Continuar o review de forma objetiva como pair review
3. Focar em melhorias de qualidade, não em aprovação

---

## Saída Esperada

Ao finalizar, o Claude deve apresentar o review formatado e perguntar:

```
Review concluido para PR #<numero>: "<titulo>"

[Review completo formatado acima]

---
Deseja que eu:
  1. Poste este review como comentario no PR: gh pr review <numero> --comment -b "..."
  2. Aprove o PR: gh pr review <numero> --approve
  3. Solicite mudancas: gh pr review <numero> --request-changes -b "..."
  4. Apenas usar como referencia (nao postar)
```

Aguardar a decisão do usuário antes de executar qualquer ação no GitHub.
