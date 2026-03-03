# Projeto 2 — Claude Code: Configuração Agentic Profissional

![Status](https://img.shields.io/badge/status-ativo-brightgreen)
![Claude Code](https://img.shields.io/badge/Claude%20Code-latest-blue)
![Node.js](https://img.shields.io/badge/Node.js-18%2B-green)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-lightgrey)

> Configuração profissional do Claude Code para desenvolvimento agentic — um kit completo com CLAUDE.md, permissões, hooks, skills e exemplos prontos para uso em projetos reais.

---

## O que está incluído

```
projeto-2-claude-code/
├── CLAUDE.md                          # Contexto completo do projeto para o Claude
├── .claude/
│   ├── settings.json                  # Permissões, hooks e variáveis de ambiente
│   └── skills/
│       ├── fix-issue/
│       │   └── SKILL.md               # Skill para corrigir issues do GitHub
│       ├── review-pr/
│       │   └── SKILL.md               # Skill para fazer review de Pull Requests
│       └── write-tests/
│           └── SKILL.md               # Skill para gerar testes automaticamente
├── scripts/
│   ├── setup.sh                       # Script de setup automatizado do projeto
│   └── check-config.sh                # Script de verificação da configuração
├── exemplos/
│   ├── mcp-config.json                # Exemplo de configuração de MCP servers
│   └── CLAUDE.md.minimal              # Versão mínima do CLAUDE.md para iniciantes
├── ROTEIRO.md                         # Roteiro de estudo passo a passo
└── README.md                          # Este arquivo
```

---

## Pré-requisitos

Antes de usar este projeto, certifique-se de ter instalado:

- **Node.js 18+** — [nodejs.org](https://nodejs.org)
- **npm** — incluído com o Node.js
- **Claude Code** — instalado globalmente via npm:

```bash
npm install -g @anthropic-ai/claude-code
```

- **ANTHROPIC_API_KEY** — chave de API da Anthropic configurada no ambiente:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
# Ou adicione ao seu .bashrc / .zshrc para persistir
```

- **gh CLI** (opcional, necessário para as skills de issue e PR) — [cli.github.com](https://cli.github.com)

```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Autenticar
gh auth login
```

---

## Como usar

### 1. Copiar os arquivos para seu projeto

```bash
# Clonar ou baixar este repositório
git clone https://github.com/seu-usuario/projeto-2-claude-code.git

# Copiar a estrutura .claude para seu projeto
cp -r projeto-2-claude-code/.claude /caminho/do/seu/projeto/

# Copiar o CLAUDE.md (você vai customizar este arquivo)
cp projeto-2-claude-code/CLAUDE.md /caminho/do/seu/projeto/
```

Ou execute o script de setup automatizado:

```bash
cd projeto-2-claude-code
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 2. Ajustar o CLAUDE.md para seu contexto

O `CLAUDE.md` é o arquivo mais importante. Ele define o contexto que o Claude vai usar em todas as interações. Edite-o para refletir **seu** projeto:

- Altere a stack tecnológica
- Atualize os comandos de desenvolvimento, teste e build
- Defina as convenções de código do seu time
- Configure as regras de comportamento desejadas
- Documente a arquitetura do projeto

### 3. Verificar a configuração

```bash
chmod +x scripts/check-config.sh
./scripts/check-config.sh
```

### 4. Iniciar o Claude Code

```bash
# No diretório do seu projeto
claude
```

---

## Descrição de cada arquivo

### `CLAUDE.md`

O arquivo central de configuração do Claude Code. Funciona como um briefing completo que o Claude lê automaticamente ao iniciar em um projeto.

**O que incluir:**
- Contexto e objetivo do projeto
- Stack tecnológica e versões
- Comandos de desenvolvimento (instalar, rodar, testar, buildar)
- Convenções de código (nomenclatura, formatação, imports)
- Regras de comportamento (o que pode e não pode fazer)
- Arquitetura de pastas
- Variáveis de ambiente necessárias

**Como customizar:**

```bash
# Abrir para edição
code CLAUDE.md  # VS Code
nano CLAUDE.md  # Terminal
```

Substitua os exemplos de FastAPI/Python pela sua stack real. Quanto mais detalhado o `CLAUDE.md`, mais preciso e útil será o comportamento do Claude.

---

### `.claude/settings.json`

Controla permissões, hooks de ciclo de vida e variáveis de ambiente do Claude Code.

**Seções principais:**

- `permissions.allow` — lista de comandos que o Claude pode executar sem pedir confirmação
- `permissions.deny` — lista de comandos bloqueados (nunca serão executados)
- `hooks.PreToolUse` — scripts executados antes de qualquer ferramenta
- `hooks.PostToolUse` — scripts executados após qualquer ferramenta
- `env` — variáveis de ambiente injetadas nas sessões

**Como customizar:**

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test:*)",
      "Bash(npx:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)"
    ]
  }
}
```

Ajuste os padrões de allow/deny conforme sua stack e política de segurança.

---

### `.claude/skills/fix-issue/SKILL.md`

Skill que automatiza o processo completo de corrigir uma issue do GitHub.

**Uso:** `/fix-issue <numero>`

Lê a issue, analisa o código, cria uma branch, implementa a correção, roda os testes e commita — tudo de forma autônoma.

---

### `.claude/skills/review-pr/SKILL.md`

Skill para fazer review estruturado de Pull Requests.

**Uso:** `/review-pr <numero>`

Busca o PR com `gh`, analisa as mudanças, verifica cobertura de testes, checa convenções de código e produz um comentário de review estruturado.

---

### `.claude/skills/write-tests/SKILL.md`

Skill para gerar testes unitários automaticamente para um arquivo.

**Uso:** `/write-tests <caminho/do/arquivo>`

Lê o arquivo, identifica todas as funções públicas sem testes correspondentes, cria o arquivo de testes com cobertura adequada e valida rodando o pytest.

---

### `scripts/setup.sh`

Script bash que automatiza a configuração inicial do Claude Code em um novo projeto.

**O que faz:**
- Verifica se Claude Code está instalado
- Cria a estrutura `.claude/` se não existir
- Verifica se `ANTHROPIC_API_KEY` está configurada
- Imprime instruções para os próximos passos

**Uso:**

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

---

### `scripts/check-config.sh`

Script de diagnóstico que verifica se a configuração está correta antes de iniciar o Claude Code.

**O que verifica:**
- Existência e validade do `.claude/settings.json`
- Existência e tamanho mínimo do `CLAUDE.md`
- Presença da `ANTHROPIC_API_KEY` no ambiente

**Uso:**

```bash
chmod +x scripts/check-config.sh
./scripts/check-config.sh
```

---

### `exemplos/mcp-config.json`

Exemplo completo de configuração de MCP (Model Context Protocol) servers para expandir as capacidades do Claude Code.

Inclui configurações prontas para: filesystem local, GitHub, Firebase e PostgreSQL.

---

### `exemplos/CLAUDE.md.minimal`

Versão simplificada do `CLAUDE.md`, ideal para quem está começando ou para projetos pequenos. Contém apenas as seções essenciais: contexto, comandos e regras básicas.

---

## Skills disponíveis

### `/fix-issue <numero>`

Corrige uma issue do GitHub de ponta a ponta:

```bash
# Dentro do Claude Code
/fix-issue 123
```

O Claude vai:
1. Ler os detalhes da issue com `gh issue view`
2. Analisar o código relacionado
3. Criar uma branch `fix/issue-123-descricao`
4. Implementar a correção
5. Rodar os testes
6. Commitar com referência à issue

### `/review-pr <numero>`

Faz review estruturado de um PR:

```bash
/review-pr 45
```

### `/write-tests <arquivo>`

Gera testes para um arquivo existente:

```bash
/write-tests app/services/task_service.py
```

---

### Como criar novas skills

Uma skill é um simples arquivo Markdown com instruções estruturadas. Para criar uma nova:

**1. Criar o diretório e o arquivo:**

```bash
mkdir -p .claude/skills/minha-skill
touch .claude/skills/minha-skill/SKILL.md
```

**2. Estrutura do `SKILL.md`:**

```markdown
# Skill: minha-skill

## Descrição
O que esta skill faz em 2-3 frases.

## Como Usar
`/minha-skill <argumento>`

## Passos de Execução
### Passo 1 — ...
### Passo 2 — ...

## Ferramentas Disponíveis
| Ferramenta | Uso |
|------------|-----|
| Bash       | ... |
| Read       | ... |

## Saída Esperada
O que o Claude deve apresentar ao final.
```

**3. Usar a skill:**

```bash
# No Claude Code
/minha-skill argumento
```

O Claude vai ler o `SKILL.md` correspondente e seguir as instruções definidas.

---

## Dicas avançadas de uso

### Modo não-interativo para CI/CD

```bash
# Executar um comando sem abrir o chat interativo
claude --print "Rode os testes e mostre o resultado"

# Usar em pipelines
echo "Analise os erros de lint" | claude --print
```

### Configuração por projeto vs global

```bash
# Configuração global (afeta todos os projetos)
~/.claude/settings.json

# Configuração por projeto (sobrescreve a global)
.claude/settings.json
```

### Hooks para automação

Use hooks para executar ações automaticamente. Exemplos práticos:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{
          "type": "command",
          "command": "npm run lint --silent 2>&1 | head -20"
        }]
      }
    ]
  }
}
```

### Múltiplos contextos com CLAUDE.md hierárquico

Você pode ter `CLAUDE.md` em subdiretórios para adicionar contexto específico:

```
projeto/
├── CLAUDE.md              # Contexto geral do projeto
├── frontend/
│   └── CLAUDE.md          # Contexto específico do frontend (React, etc.)
└── backend/
    └── CLAUDE.md          # Contexto específico do backend
```

### Variáveis de ambiente seguras

Nunca coloque chaves diretamente no `settings.json`. Use referências a variáveis de ambiente:

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
    "DATABASE_URL": "${DATABASE_URL}"
  }
}
```

### Debugar o comportamento do Claude

Se o Claude não estiver seguindo as instruções esperadas:

1. Verifique se o `CLAUDE.md` está no diretório raiz do projeto
2. Confira se o `settings.json` é um JSON válido: `python3 -m json.tool .claude/settings.json`
3. Use o comando `/config` dentro do Claude Code para ver as configurações ativas
4. Torne as instruções mais específicas e explícitas no `CLAUDE.md`

---

## Recursos adicionais

- [Documentacao oficial do Claude Code](https://docs.anthropic.com/claude-code)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [GitHub CLI (gh)](https://cli.github.com/manual)
- [ROTEIRO.md](./ROTEIRO.md) — guia de estudo passo a passo incluído neste projeto
