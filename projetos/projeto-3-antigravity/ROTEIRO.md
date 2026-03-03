# ROTEIRO — Dominando o Antigravity

Guia passo a passo para configurar e usar o Antigravity em um projeto real de desenvolvimento agentic.

**Tempo total estimado:** ~5h30min (em um unico dia ou dividido em sessoes)

---

## Visao geral do roteiro

```
Passo 1 → Acesso e instalacao          (15 min)
Passo 2 → Workspace e configuracao     (10 min)
Passo 3 → CONTEXT.md personalizado     (30 min)
Passo 4 → Servidores MCP               (20 min)
Passo 5 → Primeiro workflow            (30 min)
Passo 6 → Integracao Google Cloud      (1h)
Passo 7 → Desafio Plan→Execute→Verify  (3h)
```

---

## Passo 1 — Solicitar acesso beta e instalar o Antigravity

**Tempo estimado: 15 minutos**

### O que e este passo

O Antigravity ainda esta em beta fechado. Voce precisara solicitar acesso antes de comecar. Enquanto aguarda a aprovacao (pode levar de horas a dias), prepare seu ambiente.

### Como solicitar acesso

1. Acesse [g.co/antigravity](https://g.co/antigravity) com sua conta Google
2. Clique em **"Request Access"** e preencha o formulario:
   - Descreva brevemente como voce pretende usar o Antigravity
   - Mencione experiencia anterior com Claude Code, GitHub Copilot ou ferramentas similares — isso aumenta as chances de aprovacao rapida
3. Voce receberao email de confirmacao em seu Gmail quando o acesso for liberado

### Preparar o ambiente enquanto aguarda

Mesmo sem o Antigravity, instale as dependencias necessarias:

```bash
# Verificar versao do Node.js (precisa ser 20+)
node --version

# Se precisar instalar ou atualizar o Node.js:
# Acesse https://nodejs.org e baixe a versao LTS

# Verificar git
git --version

# Instalar os servidores MCP (pode fazer agora)
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
```

### Instalar o Antigravity (apos receber acesso)

1. Abra o email de aprovacao e clique no link de download
2. Baixe o instalador para o seu sistema operacional (Linux, macOS ou Windows)
3. Execute o instalador e siga as instrucoes na tela
4. Na primeira execucao, autentique com sua conta Google quando solicitado

### Resultado esperado

- Acesso solicitado (ou concedido) ao Antigravity beta
- Node.js 20+ instalado
- Git configurado
- Antigravity instalado e autenticado com conta Google

---

## Passo 2 — Criar workspace e importar workspace.json

**Tempo estimado: 10 minutos**

### O que e este passo

O `workspace.json` e o arquivo de configuracao que diz ao Antigravity qual modelo usar, quais ferramentas ativar e quais workflows estao disponiveis. Voce vai importa-lo e criar seu primeiro workspace configurado.

### Criar um novo projeto

1. Abra o Antigravity
2. Clique em **File > New Project** (ou use `Ctrl+Shift+N`)
3. Escolha um diretorio para o projeto — pode ser uma pasta existente com codigo ou uma pasta nova
4. O Antigravity abrira o workspace vazio

### Importar o workspace.json

**Opcao A — Importar pela interface:**
1. Clique em **File > Import Workspace Configuration**
2. Navegue ate o arquivo `workspace.json` deste projeto e selecione-o
3. O Antigravity carregara todas as configuracoes automaticamente

**Opcao B — Copiar diretamente:**
1. Copie o arquivo `workspace.json` para a raiz do seu projeto
2. O Antigravity detecta e carrega automaticamente ao abrir a pasta

### Verificar a configuracao carregada

No painel de configuracoes do Antigravity (icone de engrenagem), voce deve ver:

- **Modelo:** `gemini-2.0-flash-exp`
- **Temperatura:** `0.2`
- **Ferramentas ativas:** Filesystem MCP, GitHub MCP, Browser, Terminal
- **Workflows disponibles:** `feature`, `bugfix`
- **Permissoes:** file_write: ask, network: ask, shell_execute: ask

### Personalizacoes iniciais (opcional)

Edite o `workspace.json` para ajustar ao seu projeto:

```json
{
  "name": "nome-do-seu-projeto",    // Altere para o nome real
  "agent": {
    "temperature": 0.1,             // Mais baixo = mais deterministico
    "max_iterations": 10            // Reduza para projetos simples
  }
}
```

### Resultado esperado

- Workspace criado no Antigravity
- `workspace.json` importado com sucesso
- Configuracoes visiveis no painel do Antigravity

---

## Passo 3 — Configurar seu CONTEXT.md

**Tempo estimado: 30 minutos**

### O que e este passo

O `CONTEXT.md` e o arquivo mais importante para o desenvolvimento agentic. Ele da ao agente Gemini o contexto necessario para tomar decisoes corretas sobre o SEU projeto especifico. Sem um bom CONTEXT.md, o agente vai gerar codigo generico que pode nao se encaixar no seu projeto.

### Usar o template do projeto

Copie o `CONTEXT.md` deste projeto para a raiz do seu projeto:

```bash
cp /caminho/para/projeto-3-antigravity/CONTEXT.md /caminho/para/seu-projeto/CONTEXT.md
```

### Editar secao por secao

Abra o `CONTEXT.md` no editor e personalize cada secao:

#### Secao 1 — Identidade do Projeto (5 min)

```markdown
## Identidade do Projeto

**Nome:** nome-real-do-seu-projeto
**Versao:** 0.1.0
**Descricao:** O que seu projeto faz em uma ou duas frases
**Repositorio:** https://github.com/seu-usuario/seu-repositorio
**Ambiente:** Antigravity (Google Agent-First IDE)
**Modelo primario:** gemini-2.0-flash-exp
```

#### Secao 2 — Stack Tecnologica (10 min)

Liste apenas o que voce realmente usa. Remova tudo que nao se aplica ao seu projeto. Se voce usa Vue em vez de React, substitua. Se nao tem backend, remova essa subsecao inteira.

Exemplo para um projeto frontend simples:

```markdown
### Frontend
- **Framework:** Vue 3 com TypeScript
- **Estilizacao:** CSS Modules
- **Build tool:** Vite 5.x

### Infraestrutura
- **Hospedagem:** Vercel
```

#### Secao 3 — Convencoes de Codigo (5 min)

Ajuste as convencoes para o que seu time realmente usa. Se voce usa commits em portugues, mude. Se prefere `type` em vez de `interface`, documente isso. O agente seguira exatamente o que estiver escrito aqui.

#### Secao 4 — Regras de Negocio (10 min)

Esta e a secao mais critica e a mais especifica para o seu projeto. Documente as regras que o agente precisa conhecer para nao quebrar o sistema:

```markdown
## Regras de Negocio Criticas
1. [Regra mais importante do seu sistema]
2. [Segunda regra mais importante]
3. [...]
```

Se voce nao souber quais regras documentar, pense nas perguntas que um desenvolvedor novo faria na primeira semana de trabalho.

#### Secao 5 — Restricoes e Politicas

Revise cuidadosamente o que o agente pode fazer automaticamente. Para comecar, mantenha a configuracao conservadora: o agente precisa pedir permissao para quase tudo. Voce pode afrouxar as restricoes conforme ganhar confianca.

### Verificar se o CONTEXT.md foi carregado

Apos salvar o `CONTEXT.md`, inicie uma conversa com o agente no Antigravity e pergunte:

```
Qual e a stack tecnologica do nosso projeto?
```

Se o agente responder corretamente, o contexto foi carregado. Se ele nao souber, verifique se o arquivo esta na raiz do projeto e se o `workspace.json` lista `CONTEXT.md` em `context_files`.

### Resultado esperado

- `CONTEXT.md` personalizado para o seu projeto
- Agente capaz de responder perguntas sobre a stack e convencoes do projeto

---

## Passo 4 — Conectar servidores MCP

**Tempo estimado: 20 minutos**

### O que e este passo

Os servidores MCP (Model Context Protocol) sao processos que rodam localmente e dao ao agente acesso a ferramentas externas. Voce vai instalar e configurar os dois servidores MCP usados neste projeto: filesystem e GitHub.

### Instalar os servidores

Execute o script de instalacao incluido neste projeto:

```bash
chmod +x scripts/setup-mcp.sh
./scripts/setup-mcp.sh
```

Ou instale manualmente:

```bash
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
```

### Configurar o servidor GitHub

O servidor MCP do GitHub precisa de um token de acesso pessoal:

1. Acesse [github.com/settings/tokens](https://github.com/settings/tokens)
2. Clique em **"Generate new token (classic)"**
3. Selecione as permissoes:
   - `repo` — acesso completo a repositorios privados
   - `read:user` — ler informacoes do perfil
4. Gere o token e copie-o (ele sera mostrado apenas uma vez)
5. Crie um arquivo `.env` na raiz do seu projeto:

```bash
GITHUB_TOKEN=ghp_seu_token_aqui
```

**Importante:** adicione `.env` ao seu `.gitignore` para nao commitar o token:

```bash
echo ".env" >> .gitignore
```

### Verificar a conexao MCP no Antigravity

1. No Antigravity, acesse **Settings > MCP Servers**
2. Voce devera ver `filesystem` e `github` listados
3. Clique em **"Test Connection"** em cada um para verificar

Se algum servidor aparecer como desconectado:
- Verifique se o `npm install -g` foi executado com sucesso
- Confira se o `GITHUB_TOKEN` esta definido no `.env`
- Reinicie o Antigravity

### Testar os servidores MCP

Inicie uma conversa com o agente e teste:

```
Liste os 5 arquivos mais recentemente modificados neste projeto.
```

O agente devera usar o servidor filesystem para responder. Se funcionar, o MCP de filesystem esta operacional.

```
Qual e o numero de issues abertas no repositorio deste projeto?
```

Se o agente conseguir buscar essa informacao, o MCP do GitHub esta funcionando.

### Resultado esperado

- Servidores MCP filesystem e github instalados
- Token GitHub configurado no `.env`
- Ambos os servidores conectados e funcionando no Antigravity

---

## Passo 5 — Executar primeiro workflow automatizado

**Tempo estimado: 30 minutos**

### O que e este passo

Voce vai usar o workflow `feature` para implementar uma funcionalidade simples do zero. O objetivo e entender o ciclo completo: prompt → plano → aprovacao → execucao → resultado.

### Escolher uma feature simples

Para este primeiro workflow, escolha algo pequeno e bem definido. Sugestoes:

- Adicionar um endpoint de health check (`GET /health`)
- Criar um componente de botao reutilizavel
- Adicionar validacao de email em um formulario existente
- Criar uma funcao utilitaria com testes

### Iniciar o workflow

No painel de chat do Antigravity, escreva:

```
@agent implement feature: adicionar endpoint GET /api/health que retorna
{"status": "ok", "version": "1.0.0", "timestamp": "<ISO timestamp>"}
```

### Acompanhar o ciclo do agente

O agente executara o workflow em 4 etapas:

**Etapa 1 — Plan:**
O agente listara os arquivos que pretende criar ou modificar. Leia com atencao. Pergunte se algo parecer estranho antes de aprovar.

Exemplo de plano esperado:
```
Plano para implementar GET /api/health:

1. Criar src/backend/routes/health.ts
   - Registrar rota GET /health no Fastify
   - Retornar status, version e timestamp

2. Registrar a rota em src/backend/app.ts
   - Importar e registrar o modulo health

3. Criar tests/unit/health.test.ts
   - Teste: resposta tem status 200
   - Teste: resposta contem campos obrigatorios
   - Teste: timestamp e uma ISO string valida

Nenhuma alteracao em banco de dados ou infraestrutura.
Aprovacao necessaria? (s/n)
```

Clique em **Aprovar** ou escreva `s` para continuar.

**Etapa 2 — Implement:**
O agente escreve o codigo. Voce vera os arquivos sendo criados em tempo real. Nao interrompa — aguarde a etapa terminar.

**Etapa 3 — Test:**
O agente executara os testes criados. Acompanhe a saida do terminal. Se um teste falhar, o agente tentara corrigir automaticamente (ate `max_iterations` tentativas).

**Etapa 4 — Review:**
O agente apresenta um resumo do que foi feito e aguarda sua aprovacao final para commitar.

### Avaliar o resultado

Revise o codigo gerado:
- Ele segue as convencoes definidas no CONTEXT.md?
- Os testes fazem sentido?
- Ha algo que voce mudaria?

Se quiser ajustes, escreva no chat:
```
O endpoint precisa incluir tambem o campo "environment" com o valor de NODE_ENV.
Faca essa alteracao.
```

### Resultado esperado

- Feature implementada pelo agente
- Testes criados e passando
- Codigo revisado e aprovado
- Primeiro workflow completo executado com sucesso

---

## Passo 6 — Integrar com Google Cloud

**Tempo estimado: 1 hora**

### O que e este passo

Voce vai conectar o projeto ao Google Cloud para que o agente possa fazer deploys automatizados para Cloud Run e Firebase Hosting. Este passo requer uma conta Google Cloud com faturamento ativo.

### Pre-requisitos

```bash
# Instalar a Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Autenticar
gcloud auth login

# Configurar o projeto
gcloud config set project SEU_PROJETO_ID
```

### Configurar Firebase

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Fazer login
firebase login

# Inicializar no projeto
firebase init
# Selecione: Hosting, Functions (se necessario)
# Escolha o projeto criado no passo anterior
```

### Configurar Cloud Run

1. Ative a API do Cloud Run no Console do Google Cloud:
   - Acesse [console.cloud.google.com](https://console.cloud.google.com)
   - Navegue para **APIs & Services > Library**
   - Busque "Cloud Run" e clique em **Enable**

2. Configure as permissoes de deploy:

```bash
# Criar conta de servico para deploy
gcloud iam service-accounts create antigravity-deploy \
  --display-name="Antigravity Deploy"

# Conceder permissoes necessarias
gcloud projects add-iam-policy-binding SEU_PROJETO_ID \
  --member="serviceAccount:antigravity-deploy@SEU_PROJETO_ID.iam.gserviceaccount.com" \
  --role="roles/run.developer"

# Gerar chave da conta de servico
gcloud iam service-accounts keys create chave-deploy.json \
  --iam-account=antigravity-deploy@SEU_PROJETO_ID.iam.gserviceaccount.com
```

3. Adicione a chave ao `.env`:

```bash
GOOGLE_APPLICATION_CREDENTIALS=./chave-deploy.json
GOOGLE_CLOUD_PROJECT=SEU_PROJETO_ID
```

### Testar o workflow de deploy

```
@agent deploy to staging
```

O agente devera:
1. Fazer build da aplicacao
2. Executar os testes
3. Construir a imagem Docker
4. Fazer push para o Artifact Registry
5. Fazer deploy no Cloud Run
6. Verificar o health check do servico deployado

Acompanhe cada etapa e aprove as que requerem confirmacao.

### Resultado esperado

- Google Cloud CLI configurada e autenticada
- Firebase CLI configurada
- Cloud Run habilitado e com permissoes corretas
- Primeiro deploy realizado com sucesso pelo agente

---

## Passo 7 — Desafio: pipeline Plan→Execute→Verify completo

**Tempo estimado: 3 horas**

### O que e este passo

Este e o desafio final — implementar uma feature completa usando o ciclo agentic pleno, com revisao humana em cada fase critica. O objetivo e praticar a colaboracao efetiva com o agente: nem delegar tudo cegamente, nem microgerenciar cada linha de codigo.

### A feature do desafio

Implemente um sistema de autenticacao completo com as seguintes caracteristicas:

- Endpoint `POST /api/auth/login` com Google OAuth
- Endpoint `POST /api/auth/logout`
- Endpoint `GET /api/auth/me` (retorna usuario autenticado)
- Middleware de autenticacao para rotas protegidas
- Testes unitarios para cada endpoint
- Testes de integracao para o fluxo completo
- Documentacao dos endpoints

### Fase 1 — Plan (30 min)

Inicie com um prompt detalhado:

```
@agent implement feature: sistema de autenticacao com Google OAuth.

Requisitos:
- POST /api/auth/login: recebe o Google ID Token no body, valida com o Google,
  cria ou atualiza o usuario no banco, retorna um JWT proprio com 24h de expiracao
- POST /api/auth/logout: invalida o token JWT do usuario (blacklist em Redis)
- GET /api/auth/me: retorna os dados do usuario autenticado (requer JWT valido)
- Middleware authRequired: pode ser aplicado em qualquer rota para exigir autenticacao

Restricoes:
- Nunca armazenar o Google token no banco
- JWT deve conter apenas userId e email (sem dados sensiveis)
- Erros de autenticacao retornam 401, nao 403
```

**Sua tarefa nesta fase:** Revisar o plano gerado. Verificar se o agente:
- Mapeou todos os arquivos que precisam ser criados/modificados
- Identificou as dependencias necessarias (ex: biblioteca de validacao JWT)
- Planejou os testes corretamente
- Nao planejou alterar nada que nao deveria

Faca perguntas e corrija o plano antes de aprovar. Exemplo:
```
No plano, voce nao mencionou como vai armazenar a blacklist de tokens no Redis.
Qual e a estrategia?
```

### Fase 2 — Execute (1h30min)

Aprove o plano e acompanhe a execucao. Durante esta fase:

- **Intervenha quando** o agente parecer estar indo para uma direcao errada
- **Nao intervenha** para ajustes esteticos ou de estilo — deixe o agente terminar e faca ajustes depois
- **Documente** decisoes que o agente tomar e que voce achar relevantes

Se o agente travar em um erro apos multiplas tentativas:
```
O problema que voce esta tentando resolver e [descricao do problema].
Uma abordagem alternativa seria [sua sugestao]. Tente por esse caminho.
```

### Fase 3 — Verify (1h)

Apos o agente terminar a implementacao:

1. **Execute os testes manualmente:**
```bash
npm run test
npm run test:e2e
```

2. **Teste os endpoints manualmente com curl ou Postman:**
```bash
# Obtenha um Google ID Token de teste primeiro
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"idToken": "seu_google_id_token"}'
```

3. **Revise o codigo com o agente:**
```
Revise a implementacao do middleware authRequired e identifique
possiveis vulnerabilidades de seguranca.
```

4. **Faca o deploy para staging:**
```
@agent deploy to staging
```

5. **Verifique em staging:**
```
@agent verify deployment: teste os endpoints de autenticacao em staging
e confirme que estao funcionando corretamente
```

### Criterios de conclusao

O desafio esta completo quando:

- [ ] Todos os testes unitarios passam
- [ ] Todos os testes de integracao passam
- [ ] Os endpoints funcionam em ambiente local
- [ ] O deploy para staging foi realizado com sucesso
- [ ] Os endpoints funcionam em staging
- [ ] Voce consegue explicar cada decisao que o agente tomou

### Reflexao pos-desafio

Apos completar, responda a estas perguntas para consolidar o aprendizado:

1. Em que momentos voce interveio e por que?
2. O agente tomou alguma decisao que voce nao teria tomado? Foi uma decisao melhor ou pior?
3. Quanto tempo voce estima que levaria para implementar a mesma feature manualmente?
4. O que voce mudaria no CONTEXT.md baseado no que aprendeu neste desafio?

### Resultado esperado

- Sistema de autenticacao completo implementado pelo agente
- Testes passando (unitarios e integracao)
- Deploy realizado com sucesso em staging
- Entendimento profundo do ciclo agentic e de como colaborar efetivamente com o agente

---

*Conclusao do roteiro: voce agora tem experiencia pratica com o ciclo completo de desenvolvimento agentic usando o Antigravity.*

*Ultima atualizacao: 2026-03-03*
