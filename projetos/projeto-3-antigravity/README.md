# Projeto 3 — Antigravity

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Plataforma](https://img.shields.io/badge/plataforma-Antigravity%20IDE-blue)
![Modelo](https://img.shields.io/badge/modelo-Gemini%202.0-orange)
![Licenca](https://img.shields.io/badge/licen%C3%A7a-MIT-green)

Configuracao do Antigravity — IDE agent-first do Google.

Este projeto contem os arquivos de configuracao necessarios para usar o **Antigravity**, a IDE experimental do Google projetada desde o inicio para desenvolvimento assistido por agentes de IA. O Antigravity usa o Gemini como modelo central e permite que o agente planeje, escreva codigo, execute testes e realize deploys de forma autonoma, com supervisao humana nos pontos criticos.

---

## O que esta incluido

```
projeto-3-antigravity/
├── workspace.json          # Configuracao principal do workspace Antigravity
├── CONTEXT.md              # Contexto persistente carregado pelo agente Gemini
├── README.md               # Este arquivo
├── ROTEIRO.md              # Passo a passo para dominar o Antigravity
├── COMO_EXECUTAR.txt       # Guia para iniciantes (sem formatacao)
├── scripts/
│   └── setup-mcp.sh        # Script de instalacao dos servidores MCP
└── exemplos/
    ├── workflow-feature.md  # Exemplo de implementacao de feature com o agente
    └── context-minimal.md   # Versao minima do CONTEXT.md para projetos simples
```

### `workspace.json`

Arquivo de configuracao principal do Antigravity. Define:

- **Modelo de IA** usado pelo agente (Gemini 2.0 Flash)
- **Servidores MCP** conectados (filesystem, GitHub)
- **Workflows** pre-definidos (feature, bugfix)
- **Permissoes** do agente (o que ele pode fazer automaticamente e o que precisa de aprovacao)
- **Ferramentas** habilitadas (browser, terminal)

### `CONTEXT.md`

Arquivo de contexto persistente carregado automaticamente pelo agente em toda sessao. E o equivalente do `CLAUDE.md` no Claude Code, mas otimizado para o Gemini e o ambiente Antigravity. Contem:

- Identidade e descricao do projeto
- Stack tecnologica completa
- Estrutura de diretorios
- Convencoes de codigo e commits
- Workflows automatizados disponiveis
- Regras de negocio criticas
- Restricoes e politicas de seguranca

---

## Pre-requisitos

Antes de comecar, voce precisara de:

1. **Conta Google** — qualquer conta Gmail ou Google Workspace
2. **Acesso ao Antigravity beta** — solicite em [g.co/antigravity](https://g.co/antigravity) (programa de acesso antecipado do Google)
3. **Node.js 20+** — para os servidores MCP ([nodejs.org](https://nodejs.org))
4. **Git** — controle de versao ([git-scm.com](https://git-scm.com))
5. **Token GitHub** (opcional) — para o servidor MCP do GitHub, gere em [github.com/settings/tokens](https://github.com/settings/tokens)

---

## Como usar os arquivos de configuracao no Antigravity

### 1. Importar o workspace.json

Ao abrir o Antigravity pela primeira vez em um projeto:

1. Clique em **File > Import Workspace Configuration**
2. Selecione o arquivo `workspace.json` deste projeto
3. O Antigravity carregara automaticamente todas as configuracoes: modelo, ferramentas e workflows

Alternativamente, copie o `workspace.json` para a raiz do seu proprio projeto e o Antigravity o detectara automaticamente ao abrir a pasta.

### 2. Instalar os servidores MCP

Os servidores MCP (Model Context Protocol) dao ao agente acesso ao sistema de arquivos e ao GitHub. Execute o script de instalacao:

```bash
chmod +x scripts/setup-mcp.sh
./scripts/setup-mcp.sh
```

Ou instale manualmente:

```bash
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
```

### 3. Configurar o CONTEXT.md

Copie o `CONTEXT.md` para a raiz do seu projeto e edite as secoes marcadas com `[EDITAR]`. Veja a secao abaixo para detalhes.

### 4. Configurar variaveis de ambiente

Crie um arquivo `.env` na raiz do seu projeto (nunca commite este arquivo):

```bash
GITHUB_TOKEN=seu_token_aqui
GOOGLE_CLIENT_ID=seu_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=seu_client_secret
```

### 5. Iniciar o Antigravity

Abra o Antigravity, aponte para a pasta do seu projeto e o agente estara pronto. Use os triggers definidos no `CONTEXT.md` para iniciar workflows:

```
@agent implement feature: adicionar pagina de perfil do usuario
@agent fix bug: botao de login nao funciona no Safari
@agent deploy to staging
```

---

## Sobre o CONTEXT.md e como adaptar para seu projeto

O `CONTEXT.md` e o arquivo mais importante desta configuracao. Ele define a "memoria" do agente — tudo o que o Gemini precisa saber sobre o seu projeto para tomar decisoes corretas.

### Secoes obrigatorias

| Secao | Por que e importante |
|-------|---------------------|
| **Identidade do Projeto** | O agente precisa saber o nome, versao e repositorio para gerar commits e PRs corretos |
| **Stack Tecnologica** | Define quais frameworks, bibliotecas e padroes o agente deve usar ao gerar codigo |
| **Convencoes de Codigo** | Garante que o codigo gerado pelo agente seja consistente com o resto do projeto |
| **Restricoes e Politicas** | O mais critico — define o que o agente pode e nao pode fazer sem pedir permissao |

### Como adaptar para seu projeto

1. **Identidade:** substitua `meu-projeto-agentic` pelo nome real do seu projeto e ajuste a URL do repositorio
2. **Stack:** remova as tecnologias que voce nao usa e adicione as que usa (ex: Vue em vez de React, Django em vez de Fastify)
3. **Estrutura de diretorios:** atualize para refletir a estrutura real do seu projeto
4. **Regras de negocio:** esta secao e unica para cada projeto — descreva as regras que o agente precisa respeitar
5. **Restricoes:** revise cuidadosamente o que o agente pode fazer automaticamente vs. o que precisa de aprovacao

### Versao minima

Se o seu projeto e simples, veja o arquivo `exemplos/context-minimal.md` para uma versao reduzida do CONTEXT.md com apenas o essencial.

---

## Dicas de uso para desenvolvimento agentic

### Seja especifico nos prompts

Prefira:
```
@agent implement feature: adicionar endpoint POST /api/tasks que recebe {title, projectId}
e retorna a task criada com status 201
```

Em vez de:
```
@agent adiciona tasks
```

Quanto mais contexto voce der, menos o agente precisara perguntar e menos erros comettera.

### Revise o plano antes de executar

O workflow padrao inclui uma etapa de **Plan** antes de qualquer implementacao. Sempre leia o plano gerado antes de aprovar — e mais facil corrigir um plano do que reverter codigo ja escrito.

### Use `auto_approve: false` em producao

O `workspace.json` ja vem com `auto_approve: false`. Mantenha assim — especialmente para operacoes que afetam infraestrutura, banco de dados e deploys.

### Mantenha o CONTEXT.md atualizado

Sempre que voce mudar a stack, adicionar uma nova regra de negocio ou alterar uma convencao de codigo, atualize o `CONTEXT.md`. Um contexto desatualizado e pior do que nenhum contexto — o agente pode gerar codigo inconsistente.

### Use workflows para tarefas repetitivas

O Antigravity brilha em tarefas com estrutura clara e repetitiva:
- Implementar CRUDs seguindo o padrao do projeto
- Adicionar testes para funcoes existentes
- Refatorar componentes para seguir novas convencoes
- Gerar documentacao a partir do codigo

Para tarefas altamente criativas ou que envolvam decisoes arquiteturais importantes, colabore mais ativamente em vez de delegar completamente.

### Conecte o servidor MCP do GitHub

Com o servidor MCP do GitHub configurado, o agente pode:
- Ler issues e pull requests diretamente
- Criar branches e commitar codigo
- Abrir PRs automaticamente apos implementar uma feature

Isso fecha o loop de desenvolvimento agentic completo.

---

## Referencias

- [Antigravity — pagina oficial do Google](https://g.co/antigravity)
- [Model Context Protocol — documentacao](https://modelcontextprotocol.io)
- [Gemini API — documentacao](https://ai.google.dev)
- [Google Cloud — documentacao](https://cloud.google.com/docs)

---

*Ultima atualizacao: 2026-03-03*
