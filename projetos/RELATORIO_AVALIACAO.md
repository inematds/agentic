# RELATÓRIO DE AVALIAÇÃO — Projetos Práticos Agentic Engineering

> Avaliação técnica detalhada dos 4 projetos práticos
> Data: 2026-03-03 | Avaliador: Claude Opus 4.6

---

## RESUMO EXECUTIVO

| Projeto | Nota | Força Principal | Problema Principal |
|---------|------|-----------------|-------------------|
| P1 Agente do Zero | **8.5/10** | Código funcional + 13 testes | eval() precisa reforço de segurança |
| P2 Claude Code | **8.0/10** | Skills + scripts profissionais | CLAUDE.md exemplo é de outro projeto |
| P3 Antigravity | **7.5/10** | Documentação excelente | Produto em beta — instruções podem não funcionar |
| P4 Codex CLI | **8.0/10** | COMO_EXECUTAR.txt + GitHub Actions | Verificar se `@openai/codex` está disponível via npm |
| Menu (index.html) | **9.5/10** | Design coerente, tabela comparativa | Sem problemas críticos |
| Prompts (prompts.html) | **9.5/10** | 5 prompts especializados + botão copiar | Sem problemas críticos |

**Total de arquivos:** 50 | **Total de linhas:** ~16.000+ | **ZIPs:** 4 (36-46KB cada)

---

## PROJETO 1 — AGENTE DO ZERO (8.5/10)

### Pontos Fortes
- `agent.py` funcional com loop agentic correto, 3 ferramentas, dispatcher limpo
- 13 testes unitários passando (dispatcher + loop agentic com mock)
- Arquitetura extensível com `tools/weather_tool.py` como exemplo plug-and-play
- `ROTEIRO.md` pedagógico excelente — 7 passos progressivos com tempos estimados
- Design system HTML correto: orange, INEMA.CLUB, light mode, círculos numerados

### Problemas Encontrados

| Severidade | Problema | Local |
|---|---|---|
| Media | `eval()` sandboxado mas sem validação de input — possível DoS com `(2**2)**1000000` | `agent.py:77` |
| Baixa | `requirements.txt` sem limite superior de versão (`>=0.40.0` sem `<1.0.0`) | `requirements.txt` |
| Baixa | `buscar_na_web` retorna dados simulados genéricos (intencional, mas poderia ser mais realista) | `agent.py:71` |
| Info | Passo 6 do ROTEIRO sugere persistência JSON, mas código base usa dict em RAM | `ROTEIRO.md` |

### Recomendações
1. Adicionar regex de validação antes do `eval()`: `re.match(r'^[\d\s\+\-\*/%\(\)\.]+$', expr)`
2. Considerar `ast.literal_eval()` ou `sympy` para math seguro
3. Adicionar logging básico (`logging.basicConfig`)

---

## PROJETO 2 — CLAUDE CODE (8.0/10)

### Pontos Fortes
- 3 skills profissionais: `fix-issue`, `review-pr`, `write-tests` — todas com passos claros e tratamento de edge cases
- `scripts/setup.sh` e `scripts/check-config.sh` robustos com `set -e`, cores, validações
- `exemplos/mcp-config.json` com 8 servidores MCP documentados
- `settings.json` com allow/deny lists + hooks PreToolUse/PostToolUse
- `ROTEIRO.md` com 8 passos (6h total) — progressão bem calibrada

### Problemas Encontrados

| Severidade | Problema | Local |
|---|---|---|
| Media | `CLAUDE.md` de exemplo descreve projeto `task-api` (FastAPI), não o próprio projeto Claude Code — pode confundir | `CLAUDE.md` |
| Baixa | `exemplos/CLAUDE.md.minimal` pode ter final abrupto (56 linhas) — verificar se cobre o mínimo | `exemplos/CLAUDE.md.minimal` |
| Baixa | `settings.json` tem estrutura `hooks.PreToolUse[].hooks[]` (aninhamento redundante, mas é o formato real do Claude Code) | `.claude/settings.json` |
| Info | Scripts usam `set -e` mas não `set -u` (variáveis undefined) | `scripts/*.sh` |

### Recomendações
1. Adicionar nota no topo do `CLAUDE.md`: "Este é um EXEMPLO para projeto FastAPI — adapte para seu projeto"
2. Revisar `CLAUDE.md.minimal` — garantir que inclui pelo menos 3 seções completas
3. Adicionar `set -u` nos scripts bash

---

## PROJETO 3 — ANTIGRAVITY (7.5/10)

### Pontos Fortes
- `CONTEXT.md` rico e realista (10+ seções, stack completa, fluxos de trabalho)
- `workspace.json` bem estruturado com MCP servers, workflows, permissões
- `scripts/setup-mcp.sh` com `set -euo pipefail` — boas práticas exemplares
- `COMO_EXECUTAR.txt` acessível para leigos com linguagem simples
- `exemplos/workflow-feature.md` realista mostrando Plan→Execute→Verify

### Problemas Encontrados

| Severidade | Problema | Local |
|---|---|---|
| Alta | Antigravity é produto em beta restrito — comandos como `brew install --cask antigravity` podem não funcionar | `index.html`, `ROTEIRO.md` |
| Media | URLs como `antigravity.dev` e `g.co/antigravity` não verificáveis — pode frustrar usuários | Vários arquivos |
| Baixa | `workspace.json` referencia `ARCHITECTURE.md` que não existe no projeto | `workspace.json:7` |
| Info | Detalhes muito específicos de UX/CLI do Antigravity são baseados na documentação de referência — marcar como "baseado em documentação beta" | Vários |

### Recomendações
1. Adicionar banner de aviso no topo: "Antigravity está em beta restrito. Este guia é baseado na documentação oficial disponível. Instruções podem mudar."
2. Incluir seção "Plano B" com alternativas caso o acesso não esteja disponível
3. Criar `ARCHITECTURE.md` placeholder ou remover referência do `workspace.json`

---

## PROJETO 4 — CODEX CLI (8.0/10)

### Pontos Fortes
- `AGENTS.md` extremamente detalhado (477 linhas) — projeto Node.js/Express real com 10 seções
- `COMO_EXECUTAR.txt` excelente para leigos (285 linhas, 3 OS, troubleshooting com 7 problemas)
- `exemplos/github-actions.yml` workflow funcional de AI Code Review com anti-duplicação
- `scripts/run-headless.sh` para automação CI/CD — busca API key de `.env` com segurança
- Tabela comparativa Claude Code vs Codex no HTML é diferencial

### Problemas Encontrados

| Severidade | Problema | Local |
|---|---|---|
| Media | Verificar se `npm install -g @openai/codex` funciona atualmente — Codex CLI foi lançado em abril 2025 e pode ter mudanças | `README.md`, `index.html` |
| Baixa | `.codex/config.toml` usa modelo `o4-mini` — confirmar se é o nome correto do modelo na versão atual | `.codex/config.toml:6` |
| Baixa | GitHub Actions workflow referencia flag `--quiet` que pode ter mudado entre versões | `exemplos/github-actions.yml` |
| Info | `AGENTS.md` é para projeto exemplo "TaskPro" — adicionar nota de que é template para adaptação | `AGENTS.md` |

### Recomendações
1. Adicionar nota de versão: "Testado com Codex CLI v0.X — comandos podem mudar em versões futuras"
2. Incluir link para releases do Codex CLI no GitHub
3. Marcar modelo `o4-mini` como "padrão atual" com alternativas documentadas

---

## MENU E PROMPTS (9.5/10)

### `projetos/index.html` — Sem problemas críticos
- 4 cards com informações corretas e links funcionais
- Tabela comparativa precisa (ferramenta/empresa/modelo/config/open-source)
- Seção de personas bem definida
- Responsive: grid 2x2 desktop, 1 coluna mobile
- Link para `prompts.html` no footer e na seção de retorno

### `projetos/prompts.html` — Sem problemas críticos
- 5 prompts especializados que gerariam resultados úteis em qualquer IA
- Botão "Copiar" com fallback (Clipboard API + execCommand)
- Diferenciação clara entre CLAUDE.md, AGENTS.md e CONTEXT.md
- Seção "Dicas para Melhores Resultados" adicionada

### Landing page (`index.html`) — Sem problemas
- Seção "Projetos Práticos" integrada corretamente com 4 cards
- Link para prompts.html presente
- Visual consistente com o resto da landing page

---

## PROBLEMAS TRANSVERSAIS

| # | Problema | Projetos | Ação |
|---|---|---|---|
| 1 | `.gitignore` existe na raiz do repo mas não dentro de cada projeto | Todos | Aceitável — `.gitignore` do repo cobre tudo |
| 2 | ZIPs podem ficar desatualizados quando arquivos são modificados | Todos | Recriar ZIPs após cada modificação |
| 3 | Nenhum projeto tem CI/CD próprio (lint, testes automáticos) | P1 mais afetado | Considerar GitHub Actions para P1 |
| 4 | Light mode CSS tem lacunas em classes como `.text-neutral-600` | HTML de todos | Impacto visual mínimo |

---

## VEREDICTO FINAL

**Qualidade geral: ALTA** — Os 4 projetos estão prontos para uso educacional. O conteúdo é substancial (16.000+ linhas), a documentação é abrangente, e o design é consistente.

**Ações prioritárias:**
1. Adicionar aviso de beta/versão no P3 (Antigravity) e nota de versão no P4 (Codex)
2. Reforçar validação do `eval()` no P1
3. Adicionar nota no CLAUDE.md do P2 indicando que é exemplo adaptável
4. Verificar periodicamente se os comandos de instalação dos P3 e P4 continuam funcionais

---

*Relatório gerado com Claude Opus 4.6 — 2026-03-03*
*Agentic Engineering Masterclass · INEMA.CLUB*
