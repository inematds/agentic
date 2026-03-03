# Projeto 4 — Agentic com Codex CLI

![Status](https://img.shields.io/badge/status-ativo-brightgreen)
![Node](https://img.shields.io/badge/node-%3E%3D18-blue)
![Licença](https://img.shields.io/badge/licen%C3%A7a-MIT-green)
![OpenAI](https://img.shields.io/badge/powered%20by-OpenAI%20Codex-412991)

> Configuração do OpenAI Codex CLI para desenvolvimento agentic

---

## O que e este projeto

Este projeto contém tudo que você precisa para configurar o **OpenAI Codex CLI** no seu ambiente de desenvolvimento e começar a usar IA de forma agentica — ou seja, deixar o agente executar tarefas reais no seu código com diferentes níveis de autonomia.

---

## O que esta incluido

| Arquivo | Descrição |
|---|---|
| `AGENTS.md` | Guia de contexto lido automaticamente pelo Codex em toda sessão |
| `.codex/config.toml` | Configuração do comportamento do agente (modelo, modo, timeouts) |
| `scripts/setup.sh` | Script de instalação e configuração do ambiente |
| `scripts/run-headless.sh` | Executa tarefas sem interação humana (modo CI/CD) |
| `exemplos/github-actions.yml` | Workflow completo de code review automático com GitHub Actions |
| `.env.example` | Template de variáveis de ambiente |
| `COMO_EXECUTAR.txt` | Guia para iniciantes em linguagem simples |
| `ROTEIRO.md` | Roteiro passo a passo para dominar o Codex CLI |

---

## Pre-requisitos

Antes de começar, certifique-se de ter:

- **Node.js 18 ou superior** — [download em nodejs.org](https://nodejs.org)
- **npm** — vem junto com o Node.js
- **Chave de API da OpenAI** — obtenha em [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Git** — para clonar repositórios e usar o modo de revisão de PR

Para verificar se já tem o Node.js instalado:
```bash
node --version
# Deve mostrar v18.0.0 ou superior
```

---

## Instalação

```bash
# Instalar o Codex CLI globalmente
npm install -g @openai/codex

# Verificar se instalou corretamente
codex --version

# Configurar a API key (escolha uma das opções abaixo)

# Opção 1: Variável de ambiente temporária (dura apenas na sessão atual)
export OPENAI_API_KEY="sk-..."

# Opção 2: Adicionar permanentemente ao seu shell (recomendado)
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
source ~/.bashrc

# Opção 3: Arquivo .env no projeto (para times — nunca commitar com o valor real)
cp .env.example .env
# Edite o arquivo .env com sua chave
```

---

## Como usar os arquivos deste projeto

### Opção 1: Usar como template (recomendado)

Copie os arquivos relevantes para o seu projeto:

```bash
# Copiar o AGENTS.md (adapte para o contexto do seu projeto)
cp AGENTS.md /caminho/do/seu/projeto/AGENTS.md

# Copiar a configuração do Codex
mkdir -p /caminho/do/seu/projeto/.codex
cp .codex/config.toml /caminho/do/seu/projeto/.codex/config.toml

# Copiar os scripts
cp scripts/*.sh /caminho/do/seu/projeto/scripts/
chmod +x /caminho/do/seu/projeto/scripts/*.sh
```

### Opção 2: Rodar o script de setup

```bash
# O script verifica dependências e configura tudo automaticamente
bash scripts/setup.sh
```

### Opção 3: Usar diretamente neste diretório

Se você quiser testar sem copiar para outro projeto, basta executar o Codex aqui:

```bash
codex "explique a estrutura do AGENTS.md deste projeto"
```

---

## Os 3 modos de aprovacao

O Codex CLI possui três níveis de autonomia. Escolha conforme o quanto você confia no agente para cada tarefa:

### Modo 1: `suggest` (Sugerir)

O agente **lê o código e sugere mudancas**, mas nao executa nada. Voce ve as sugestões e decide o que fazer.

```bash
codex --approval-mode suggest "adicione tratamento de erro na função authenticate"
```

**Quando usar:** Revisão de código, explorar possibilidades, aprender o que o agente faria. Ideal para iniciantes ou para mudanças de alto risco.

---

### Modo 2: `auto-edit` (Editar com aprovacao)

O agente **pode editar arquivos**, mas precisa de aprovação sua para executar comandos no terminal (como rodar testes, instalar pacotes, etc.).

```bash
codex --approval-mode auto-edit "refatore o módulo de autenticação para usar async/await"
```

**Quando usar:** Refatorações, criação de novos arquivos, pequenas features. O fluxo mais comum no dia a dia.

---

### Modo 3: `full-auto` (Totalmente automatico)

O agente **tem autonomia total**: edita arquivos, executa comandos, roda testes. Trabalha sem pedir confirmação.

```bash
codex --approval-mode full-auto "crie testes unitários para o UserService"
```

**Quando usar:** Tarefas repetitivas bem definidas, pipelines de CI/CD, geração de código boilerplate. Use com cuidado em código de produção.

---

## Claude Code vs Codex CLI — quando usar cada um

| Criterio | Claude Code | Codex CLI |
|---|---|---|
| **Empresa** | Anthropic | OpenAI |
| **Modelo base** | Claude (Sonnet/Opus) | GPT-4o / o3 |
| **Melhor para** | Raciocínio complexo, arquitetura, explicações longas | Geração de código, refatorações, tarefas bem definidas |
| **Contexto do projeto** | `CLAUDE.md` | `AGENTS.md` |
| **Uso em CI/CD** | Possível mas menos nativo | Excelente (modo headless) |
| **Custo** | Por token (Claude API) | Por token (OpenAI API) |
| **Interface** | CLI interativo | CLI interativo + headless |
| **Integração GitHub** | Manual | GitHub Actions nativo |
| **Quando preferir** | Discussões arquiteturais, debugging complexo, análise de código | Automação, geração em massa, pipelines CI/CD |

**Regra prática:** Use Claude Code quando precisar _pensar junto_ com o agente. Use Codex quando precisar _executar_ uma tarefa bem definida.

---

## Dicas de produtividade

### 1. Seja especifico nas instrucoes

```bash
# Ruim — muito vago
codex "melhore o código"

# Bom — especifico e acionável
codex "refatore a função createUser em src/modules/users/user.service.js para usar early returns e reduzir aninhamento"
```

### 2. Use o AGENTS.md para dar contexto

Quanto mais detalhado seu `AGENTS.md`, menos você precisa explicar em cada sessão. Documente:
- Stack tecnológica
- Convencoes de nomenclatura
- Comandos de teste e lint
- O que o agente NUNCA deve fazer

### 3. Comece com `suggest`, evoluia para `auto-edit`

Para tarefas novas ou desconhecidas, sempre comece em modo `suggest`. Quando ganhar confiança no que o agente faz, mude para `auto-edit`.

### 4. Combine com Git

Antes de usar o modo `full-auto`, crie um branch:
```bash
git checkout -b feature/ai-refactor
codex --approval-mode full-auto "refatore todos os controllers para usar o padrão X"
git diff  # Revise as mudanças
```

### 5. Use o modo headless para tarefas repetitivas

```bash
# Gerar testes para vários arquivos
for file in src/modules/*/service.js; do
  ./scripts/run-headless.sh "escreva testes unitários para $file"
done
```

### 6. Salve sessoes longas

Se uma sessão for interrompida, o Codex mantém contexto do projeto via `AGENTS.md`. Descreva o que estava fazendo no início da nova sessão:

```bash
codex "continuando de onde paramos: estávamos refatorando o módulo de auth. O service já foi atualizado, falta o controller e os testes"
```

---

## Estrutura do projeto

```
projeto-4-codex/
├── AGENTS.md                  # Contexto do projeto para o Codex
├── .codex/
│   └── config.toml            # Configuração do agente
├── scripts/
│   ├── setup.sh               # Instalação e configuração
│   └── run-headless.sh        # Execução sem interação
├── exemplos/
│   └── github-actions.yml     # Workflow de CI/CD com Codex
├── .env.example               # Template de variáveis
├── README.md                  # Este arquivo
├── ROTEIRO.md                 # Guia passo a passo
└── COMO_EXECUTAR.txt          # Guia para iniciantes
```

---

## Recursos e documentacao

- [Documentação oficial do Codex CLI](https://github.com/openai/codex)
- [Referência da API OpenAI](https://platform.openai.com/docs)
- [Exemplos de AGENTS.md](https://github.com/openai/codex/tree/main/examples)
- [GitHub Actions com OpenAI](https://docs.github.com/en/actions)

---

*Parte do curso de desenvolvimento agentico — Projeto 4 de 8*
