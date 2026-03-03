# Roteiro de Estudo — Dominando o Claude Code

> Guia passo a passo para ir do zero ao desenvolvimento agentic avançado com o Claude Code. Cada passo tem duração estimada e exercícios práticos.

---

## Visão Geral

| Passo | Tema                              | Tempo Estimado |
|-------|-----------------------------------|----------------|
| 1     | Instalar e autenticar             | 10 min         |
| 2     | Criar seu primeiro CLAUDE.md      | 30 min         |
| 3     | Configurar permissões             | 20 min         |
| 4     | Criar seu primeiro hook           | 15 min         |
| 5     | Usar a skill /fix-issue           | 30 min         |
| 6     | Criar sua própria skill           | 45 min         |
| 7     | Configurar MCP servers            | 1h             |
| 8     | Desafio multi-agente              | 3h             |
| **Total** |                               | **~6h**        |

---

## Passo 1 — Instalar e autenticar o Claude Code

**Tempo estimado: 10 minutos**

### Objetivos
- Ter o Claude Code instalado e funcionando
- Autenticar com a Anthropic API
- Executar seu primeiro comando

### Pré-requisitos
- Node.js 18+ instalado
- Conta na Anthropic com API key ativa

### Instruções

**1.1. Instalar o Claude Code via npm:**

```bash
npm install -g @anthropic-ai/claude-code
```

Verificar se instalou corretamente:

```bash
claude --version
```

**1.2. Configurar a API key:**

```bash
# Exportar a variável de ambiente
export ANTHROPIC_API_KEY="sk-ant-api..."

# Para persistir entre sessões, adicione ao seu shell profile:
echo 'export ANTHROPIC_API_KEY="sk-ant-api..."' >> ~/.bashrc
source ~/.bashrc
```

**1.3. Iniciar o Claude Code em qualquer diretório:**

```bash
mkdir ~/meu-primeiro-projeto
cd ~/meu-primeiro-projeto
claude
```

**1.4. Seu primeiro comando:**

Dentro do Claude Code, pergunte algo simples:
```
Crie um arquivo hello.py que imprime "Olá, Claude Code!" e mostre o conteúdo.
```

### Checkpoint
- [ ] `claude --version` retorna a versão instalada
- [ ] Claude Code abre e responde a comandos
- [ ] Primeiro arquivo criado com sucesso

---

## Passo 2 — Criar seu primeiro CLAUDE.md

**Tempo estimado: 30 minutos**

### Objetivos
- Entender a função e importância do CLAUDE.md
- Criar um CLAUDE.md personalizado para um projeto real
- Verificar que o Claude usa o contexto definido

### O que é o CLAUDE.md

O CLAUDE.md é um arquivo Markdown na raiz do projeto que o Claude lê automaticamente ao iniciar. Ele funciona como um briefing: define o contexto, as regras e o comportamento esperado do Claude para aquele projeto específico.

Sem o CLAUDE.md, o Claude trabalha "às cegas". Com ele, o Claude se comporta como um desenvolvedor experiente do seu time, conhecendo a stack, as convenções e as regras do projeto.

### Instruções

**2.1. Abrir um projeto real ou criar um novo:**

```bash
# Usando um projeto existente
cd /caminho/do/seu/projeto

# Ou criando um novo projeto de exemplo
mkdir ~/projeto-estudo && cd ~/projeto-estudo
```

**2.2. Usar o template mínimo como ponto de partida:**

```bash
# Copiar o template mínimo deste projeto
cp exemplos/CLAUDE.md.minimal ~/projeto-estudo/CLAUDE.md
```

**2.3. Editar o CLAUDE.md para refletir SEU projeto:**

Abra o arquivo e substitua os placeholders:
- `[Nome do Projeto]` → nome real do seu projeto
- `[linguagem/framework]` → sua stack (ex: Python/FastAPI, Node/Express, Go)
- Comandos de dev/test → os comandos reais do seu projeto
- Regras de comportamento → as regras do seu time

**2.4. Testar se o Claude usa o contexto:**

Inicie o Claude Code no diretório e pergunte:

```
Qual é a linguagem principal deste projeto e como eu rodo os testes?
```

O Claude deve responder com base no seu CLAUDE.md.

### Dicas para um CLAUDE.md eficaz

- **Seja específico sobre comandos:** em vez de "rodar testes", escreva `pytest tests/ -v`
- **Defina regras de negação:** "nunca fazer git push --force", "nunca deletar arquivos sem confirmar"
- **Documente a arquitetura:** um diagrama de pastas ajuda muito
- **Inclua exemplos de código:** show, don't tell — exemplos de como o código deve ser escrito
- **Atualize regularmente:** o CLAUDE.md deve evoluir junto com o projeto

### Checkpoint
- [ ] CLAUDE.md criado com contexto real do projeto
- [ ] Claude responde usando o contexto do CLAUDE.md
- [ ] Claude usa os comandos corretos ao executar tarefas

---

## Passo 3 — Configurar permissões no settings.json

**Tempo estimado: 20 minutos**

### Objetivos
- Entender o sistema de permissões do Claude Code
- Configurar uma política de segurança para o projeto
- Testar comportamentos de allow e deny

### O que é o settings.json

O arquivo `.claude/settings.json` controla o que o Claude pode e não pode fazer no seu projeto. Ele define:

- **`permissions.allow`** — comandos que o Claude executa sem pedir confirmação
- **`permissions.deny`** — comandos que o Claude nunca executará, mesmo se solicitado

### Instruções

**3.1. Criar a estrutura .claude:**

```bash
mkdir -p .claude
```

**3.2. Criar o settings.json inicial:**

```json
{
  "permissions": {
    "allow": [],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(git push --force:*)"
    ]
  }
}
```

**3.3. Adicionar permissões específicas para sua stack:**

Para um projeto Python/pytest:
```json
{
  "permissions": {
    "allow": [
      "Bash(pytest:*)",
      "Bash(python:*)",
      "Bash(pip install:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git checkout:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(git push --force:*)",
      "Bash(DROP TABLE:*)"
    ]
  }
}
```

Para um projeto Node.js:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)",
      "Bash(npx:*)",
      "Bash(node:*)"
    ]
  }
}
```

**3.4. Testar as permissões:**

No Claude Code, tente executar um comando bloqueado:
```
Execute: rm -rf /tmp/teste
```

O Claude deve recusar ou pedir confirmação.

**3.5. Verificar com o script de checagem:**

```bash
./scripts/check-config.sh
```

### Boas práticas de segurança

- Use o princípio do menor privilégio: só adicione o que for necessário
- Sempre bloqueie `rm -rf`, `sudo` e `git push --force`
- Bloqueie comandos de banco que são destrutivos: `DROP`, `DELETE FROM` sem WHERE
- Para projetos de produção, seja ainda mais restritivo

### Checkpoint
- [ ] `.claude/settings.json` criado com permissões configuradas
- [ ] Claude recusa executar comandos bloqueados
- [ ] Claude executa comandos permitidos sem pedir confirmação extra

---

## Passo 4 — Criar seu primeiro hook

**Tempo estimado: 15 minutos**

### Objetivos
- Entender o sistema de hooks do Claude Code
- Criar um hook PreToolUse e um PostToolUse
- Ver hooks sendo executados em tempo real

### O que são hooks

Hooks são scripts executados automaticamente em pontos específicos do ciclo de vida do Claude Code:

- **`PreToolUse`** — executado ANTES de qualquer ferramenta (Bash, Edit, Write, Read, etc.)
- **`PostToolUse`** — executado DEPOIS de qualquer ferramenta

Os hooks recebem informações sobre a ferramenta sendo usada via stdin como JSON.

### Instruções

**4.1. Adicionar hooks ao settings.json:**

```json
{
  "permissions": { ... },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[PRE-HOOK] Executando comando Bash: verificando...'"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[POST-HOOK] Arquivo editado! Lembre de rodar os testes.'"
          }
        ]
      }
    ]
  }
}
```

**4.2. Hook prático: rodar lint após editar arquivos Python:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if command -v ruff &>/dev/null; then ruff check --quiet .; fi"
          }
        ]
      }
    ]
  }
}
```

**4.3. Testar o hook:**

No Claude Code, peça para editar um arquivo:
```
Crie um arquivo teste.py com uma função simples
```

Observe o output do hook no terminal.

**4.4. Hook para log de auditoria:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M:%S')] Tool chamada\" >> .claude/audit.log"
          }
        ]
      }
    ]
  }
}
```

### Checkpoint
- [ ] Hook PreToolUse criado e funcionando
- [ ] Hook PostToolUse criado e funcionando
- [ ] Logs do hook aparecem no terminal

---

## Passo 5 — Usar a skill /fix-issue com uma issue real do GitHub

**Tempo estimado: 30 minutos**

### Objetivos
- Usar a skill fix-issue em um repositório real
- Observar o Claude executando um fluxo agentic completo
- Aprender com o comportamento do Claude durante a execução

### Pré-requisitos
- GitHub CLI (`gh`) instalado e autenticado: `gh auth login`
- Ter um repositório com pelo menos uma issue aberta
- Estar no diretório do repositório

### Instruções

**5.1. Verificar autenticação do GitHub CLI:**

```bash
gh auth status
gh repo view  # deve mostrar informações do repositório atual
```

**5.2. Listar issues abertas no repositório:**

```bash
gh issue list
```

Escolha uma issue simples para começar — bugs de comportamento incorreto ou melhorias pontuais funcionam melhor do que refatorações grandes.

**5.3. Executar a skill:**

No Claude Code:
```
/fix-issue <numero-da-issue>
```

**5.4. Observar o fluxo de execução:**

Preste atenção em cada passo que o Claude executa:
1. Busca a issue com `gh issue view`
2. Analisa o código com Grep e Read
3. Cria uma branch com nomenclatura correta
4. Implementa a correção
5. Roda os testes
6. Commita com referência à issue

**5.5. Após a execução, verificar o resultado:**

```bash
git log --oneline -5  # ver o commit criado
git diff main...HEAD  # ver as mudanças
pytest                # confirmar que os testes passam
```

### O que observar e aprender

- Como o Claude decide quais arquivos são relevantes para a issue
- Como ele lida com ambiguidade quando a issue não está clara
- Como ele estrutura as mensagens de commit
- Como ele trata falhas nos testes

### Checkpoint
- [ ] Skill /fix-issue executada com sucesso
- [ ] Branch criada com nomenclatura correta
- [ ] Commit feito com referência à issue
- [ ] Testes passando após o fix

---

## Passo 6 — Criar sua própria skill customizada

**Tempo estimado: 45 minutos**

### Objetivos
- Entender a anatomia de uma skill
- Criar uma skill do zero para um fluxo que você usa frequentemente
- Testar e refinar a skill

### Idéias de skills para criar

Escolha uma que faça sentido para seu projeto:

- `/deploy` — automatizar o deploy para staging
- `/changelog` — gerar CHANGELOG.md a partir dos commits
- `/migrate` — criar e aplicar migrations de banco de dados
- `/seed` — popular o banco com dados de teste
- `/perf-test` — rodar testes de performance e gerar relatório
- `/doc-api` — gerar documentação dos endpoints a partir do código
- `/security-scan` — verificar vulnerabilidades no código

### Instruções

**6.1. Criar a estrutura da skill:**

```bash
mkdir -p .claude/skills/minha-skill
touch .claude/skills/minha-skill/SKILL.md
```

**6.2. Estrutura mínima do SKILL.md:**

```markdown
# Skill: minha-skill

## Descrição
[O que a skill faz em 2-3 frases claras]

## Como Usar
`/minha-skill <argumento-opcional>`

## Passos de Execução

### Passo 1 — [Nome do passo]
[O que o Claude deve fazer neste passo]

### Passo 2 — [Nome do passo]
[O que o Claude deve fazer neste passo]

## Ferramentas Disponíveis
| Ferramenta | Uso |
|------------|-----|
| Bash       | [para que usar] |
| Read       | [para que usar] |

## Saída Esperada
[O que o Claude deve apresentar ao final]
```

**6.3. Dicas para escrever uma boa skill:**

- **Seja prescritivo:** use linguagem imperativa. "O Claude DEVE fazer X antes de Y"
- **Defina a sequência:** numere os passos e seja explícito sobre a ordem
- **Antecipe erros:** inclua uma seção "Comportamento em Casos Especiais"
- **Defina a saída:** especifique exatamente o que o usuário deve ver ao final
- **Teste iterativamente:** execute a skill, observe onde ela desvia do esperado, refine

**6.4. Testar a skill:**

```
/minha-skill
```

Observe o comportamento, identifique onde o Claude desviou das instruções, refine o SKILL.md e teste novamente.

**6.5. Versionamento da skill:**

```bash
git add .claude/skills/minha-skill/SKILL.md
git commit -m "Adiciona skill /minha-skill para [descricao]"
```

### Checkpoint
- [ ] SKILL.md criado com estrutura completa
- [ ] Skill executada pelo menos uma vez
- [ ] Pelo menos uma iteração de refinamento feita
- [ ] Skill commitada no repositório

---

## Passo 7 — Configurar MCP servers

**Tempo estimado: 1 hora**

### Objetivos
- Entender o Model Context Protocol (MCP)
- Configurar pelo menos 2 MCP servers
- Usar ferramentas MCP dentro do Claude Code

### O que é MCP

O Model Context Protocol (MCP) é um protocolo padronizado que permite ao Claude se conectar a ferramentas e fontes de dados externas. Com MCP servers, o Claude pode:

- Ler e escrever arquivos (filesystem)
- Interagir com o GitHub diretamente
- Consultar bancos de dados
- Buscar na web
- Acessar APIs específicas do seu domínio

### Instruções

**7.1. Entender a estrutura do mcp-config.json:**

Consulte o arquivo de exemplo:
```bash
cat exemplos/mcp-config.json
```

**7.2. Configurar o MCP server do filesystem:**

O mais simples para começar — permite ao Claude trabalhar com arquivos de forma mais direta:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/caminho/do/seu/projeto"
      ]
    }
  }
}
```

Salvar em `.claude/mcp-config.json` e iniciar com:
```bash
claude --mcp-config .claude/mcp-config.json
```

**7.3. Configurar o MCP server do GitHub:**

Requer um Personal Access Token do GitHub:

```bash
# Gerar token em: https://github.com/settings/tokens
# Permissões necessárias: repo, read:user
export GITHUB_TOKEN="ghp_..."
```

Adicionar ao mcp-config.json (veja `exemplos/mcp-config.json` para o formato completo).

**7.4. Testar os MCP servers:**

No Claude Code com MCP habilitado:
```
Liste os 5 arquivos mais recentemente modificados neste projeto
```

```
Busque as últimas 3 issues abertas no repositório atual
```

**7.5. Explorar outros MCP servers disponíveis:**

- `@modelcontextprotocol/server-postgres` — acesso a banco PostgreSQL
- `@modelcontextprotocol/server-sqlite` — acesso a banco SQLite
- `@modelcontextprotocol/server-brave-search` — busca na web via Brave
- `@modelcontextprotocol/server-puppeteer` — automação de browser

Instalar e testar pelo menos mais um server além do filesystem.

### Checkpoint
- [ ] mcp-config.json configurado com pelo menos 2 servers
- [ ] MCP filesystem funcionando
- [ ] MCP GitHub funcionando
- [ ] Claude consegue usar ferramentas MCP em uma tarefa real

---

## Passo 8 — Desafio: criar um sistema multi-agente com subagentes

**Tempo estimado: 3 horas**

### Objetivos
- Entender o conceito de orquestração de agentes
- Criar um agente orquestrador que delega tarefas para subagentes
- Implementar um fluxo de trabalho agentic completo e útil

### O conceito de multi-agente

No Claude Code, você pode criar workflows onde:
- Um **agente orquestrador** recebe uma tarefa grande e a divide
- **Subagentes** executam partes específicas de forma paralela ou sequencial
- O orquestrador consolida os resultados

### Desafio proposto

Criar um sistema de **revisão automatizada de código** que funciona assim:

1. Recebe um PR ou um conjunto de arquivos modificados
2. O orquestrador divide o trabalho em 3 análises paralelas:
   - Subagente de Segurança: verifica vulnerabilidades
   - Subagente de Qualidade: verifica complexidade, duplicação, legibilidade
   - Subagente de Testes: verifica cobertura e qualidade dos testes
3. O orquestrador consolida as análises em um relatório único

### Instruções

**8.1. Criar a skill do orquestrador:**

```bash
mkdir -p .claude/skills/code-audit
```

O SKILL.md do orquestrador deve definir:
- Como receber a lista de arquivos a analisar
- Como delegar cada análise para um subagente (usando a ferramenta `Task` ou múltiplas chamadas)
- Como consolidar os resultados
- O formato do relatório final

**8.2. Criar as skills dos subagentes:**

```bash
mkdir -p .claude/skills/audit-security
mkdir -p .claude/skills/audit-quality
mkdir -p .claude/skills/audit-tests
```

Cada subagente deve ter um SKILL.md focado em sua responsabilidade específica.

**8.3. Implementar e testar:**

Comece pequeno: faça o orquestrador chamar apenas um subagente, depois adicione os outros.

```
/code-audit app/services/task_service.py
```

**8.4. Refinar o sistema:**

Após o primeiro teste:
- Identifique onde os subagentes produziram resultados inconsistentes
- Refine os prompts nos SKILL.md de cada subagente
- Adicione validação no orquestrador
- Teste com arquivos mais complexos

**8.5. Documentar o sistema:**

Crie um `SKILL.md` no diretório raiz da skill descrevendo:
- A arquitetura do sistema multi-agente
- Como os subagentes se comunicam
- Como adicionar novos subagentes
- Limitações conhecidas

### Variações do desafio

Se o desafio principal for muito fácil, tente uma dessas variações:

**Variação A:** Sistema de deploy inteligente que analisa as mudanças, decide qual ambiente testar primeiro, executa os testes e só promove para produção se tudo passar.

**Variação B:** Agente de refatoração que analisa o código, cria um plano de refatoração, executa em etapas com testes entre cada etapa e gera o PR automaticamente.

**Variação C:** Pipeline de dados agentic que lê dados de múltiplas fontes, transforma, valida a qualidade dos dados e carrega no destino — com tratamento de erros e retry automático.

### Checkpoint
- [ ] Sistema multi-agente funcional com pelo menos 2 subagentes
- [ ] Orquestrador consolidando resultados corretamente
- [ ] Pelo menos uma tarefa real executada com o sistema
- [ ] Documentação do sistema criada

---

## Recursos adicionais para continuar aprendendo

### Documentação oficial
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — documentação completa
- [MCP Specification](https://modelcontextprotocol.io) — especificação do protocolo
- [Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook) — exemplos práticos

### Comunidade
- [Anthropic Discord](https://discord.gg/anthropic) — comunidade de desenvolvedores
- [Claude Code GitHub](https://github.com/anthropics/claude-code) — issues e discussões

### Próximos desafios sugeridos
1. Integrar Claude Code ao seu pipeline de CI/CD
2. Criar um agente de monitoramento que analisa logs e cria issues automaticamente
3. Implementar um sistema de documentação automática que mantém o README atualizado
4. Criar um agente de migração de banco de dados que verifica compatibilidade antes de aplicar
