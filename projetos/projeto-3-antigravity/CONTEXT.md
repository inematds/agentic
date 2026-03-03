# CONTEXT.md — Antigravity / Gemini Agent Context

> Este arquivo é carregado automaticamente pelo Antigravity como contexto persistente para o agente Gemini.
> Equivalente ao CLAUDE.md do Claude Code, mas otimizado para o modelo Gemini e o ambiente Antigravity.

---

## Identidade do Projeto

**Nome:** meu-projeto-agentic
**Versão:** 1.0.0
**Descrição:** Aplicação web desenvolvida com metodologia agentic-first usando o Antigravity IDE.
**Repositório:** https://github.com/usuario/meu-projeto-agentic
**Ambiente:** Antigravity (Google Agent-First IDE)
**Modelo primário:** gemini-2.0-flash-exp

---

## Stack Tecnológica

### Frontend
- **Framework:** React 18 com TypeScript
- **Estilização:** Tailwind CSS 3.x
- **Build tool:** Vite 5.x
- **Gerenciamento de estado:** Zustand
- **Roteamento:** React Router v6

### Backend
- **Runtime:** Node.js 20 LTS
- **Framework:** Fastify 4.x
- **ORM:** Prisma com PostgreSQL
- **Autenticação:** Google OAuth 2.0 via Firebase Auth
- **Cache:** Redis 7.x

### Infraestrutura
- **Cloud:** Google Cloud Platform
- **Hospedagem backend:** Cloud Run (serverless containers)
- **Hospedagem frontend:** Firebase Hosting
- **Banco de dados:** Cloud SQL (PostgreSQL 15)
- **CI/CD:** GitHub Actions + Cloud Build

### Ferramentas de Desenvolvimento
- **IDE:** Antigravity (agent-first)
- **Controle de versão:** Git + GitHub
- **Testes:** Vitest (unit), Playwright (E2E)
- **Linting:** ESLint + Prettier
- **Monitoramento:** Google Cloud Monitoring + Sentry

---

## Estrutura de Diretórios

```
meu-projeto-agentic/
├── CONTEXT.md              # Este arquivo — contexto do agente
├── ARCHITECTURE.md         # Documentação de arquitetura
├── workspace.json          # Configuração do Antigravity
├── src/
│   ├── frontend/           # Aplicação React
│   │   ├── components/     # Componentes reutilizáveis
│   │   ├── pages/          # Páginas da aplicação
│   │   ├── hooks/          # React hooks customizados
│   │   ├── stores/         # Estado global (Zustand)
│   │   └── utils/          # Funções utilitárias
│   └── backend/            # API Fastify
│       ├── routes/         # Definição de rotas
│       ├── services/       # Lógica de negócio
│       ├── middleware/      # Middlewares
│       └── prisma/         # Schema e migrações
├── tests/
│   ├── unit/               # Testes unitários (Vitest)
│   └── e2e/                # Testes E2E (Playwright)
├── infra/
│   ├── terraform/          # Infraestrutura como código
│   └── docker/             # Dockerfiles
└── .github/
    └── workflows/          # CI/CD pipelines
```

---

## Convenções de Código

### Nomenclatura
- **Arquivos de componentes React:** PascalCase — `UserProfile.tsx`
- **Arquivos de hooks:** camelCase com prefixo `use` — `useAuthState.ts`
- **Arquivos de serviço backend:** camelCase — `userService.ts`
- **Constantes:** UPPER_SNAKE_CASE — `MAX_RETRY_ATTEMPTS`
- **Variáveis e funções:** camelCase — `fetchUserData()`
- **Tipos e interfaces TypeScript:** PascalCase — `UserProfileData`

### TypeScript
- Sempre usar tipagem explícita em funções públicas
- Evitar `any` — usar `unknown` quando o tipo não é conhecido
- Preferir `interface` para objetos, `type` para unions e intersections
- Exportar tipos junto com as implementações no mesmo arquivo

### React
- Componentes funcionais com hooks (sem class components)
- Props sempre tipadas com interface dedicada
- Evitar prop drilling — usar Zustand para estado compartilhado
- Memoização apenas quando necessário (não prematuramente)

### Commits
- Seguir Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- Mensagens em inglês, imperativo presente: "Add user authentication"
- Máximo 72 caracteres no título
- Corpo do commit explica o "por quê", não o "o quê"

### Testes
- Cobertura mínima: 80% para lógica de negócio crítica
- Cada função de serviço deve ter pelo menos um teste unitário
- Testes E2E para fluxos críticos do usuário (login, checkout, etc.)

---

## Fluxos de Trabalho Automatizados

### Workflow: Nova Feature (`feature`)
O agente segue este loop ao receber uma solicitação de nova funcionalidade:

1. **Plan** — Analisa o pedido, mapeia arquivos afetados, descreve mudanças necessárias
2. **Implement** — Escreve o código seguindo as convenções definidas acima
3. **Test** — Cria testes unitários e verifica se passam
4. **Review** — Revisa o código gerado antes de commitar, aguarda aprovação humana

**Trigger:** `@agent implement feature: [descrição]`

### Workflow: Correção de Bug (`bugfix`)
1. **Analyze** — Reproduz o bug, identifica a causa raiz
2. **Fix** — Implementa a correção mínima necessária
3. **Verify** — Executa testes relevantes e confirma que o bug foi corrigido

**Trigger:** `@agent fix bug: [descrição do problema]`

### Workflow: Refatoração (`refactor`)
1. **Audit** — Identifica code smells e oportunidades de melhoria
2. **Refactor** — Aplica melhorias sem alterar comportamento externo
3. **Validate** — Garante que todos os testes passam após refatoração

**Trigger:** `@agent refactor: [arquivo ou componente]`

### Workflow: Deploy (`deploy`)
1. **Build** — Compila frontend e backend
2. **Test** — Executa suite completa de testes
3. **Push** — Faz push para o registry de containers
4. **Deploy** — Faz deploy no Cloud Run / Firebase Hosting
5. **Verify** — Verifica health check nos endpoints críticos

**Trigger:** `@agent deploy to [staging|production]`

---

## Contexto de Domínio

### Entidades Principais
- **User** — Usuário autenticado via Google OAuth
- **Project** — Projeto criado pelo usuário
- **Task** — Tarefa dentro de um projeto
- **Comment** — Comentário em uma tarefa

### Regras de Negócio Críticas
1. Um usuário só pode ver projetos dos quais é membro
2. Apenas o owner do projeto pode deletar o projeto
3. Tasks arquivadas não aparecem na listagem padrão
4. Comentários deletados mostram "[Comentário removido]" para preservar threading
5. Limite de 100 projetos ativos por usuário no plano gratuito

### Glossário
- **Workspace:** Conjunto de projetos de uma organização
- **Sprint:** Período de trabalho (2 semanas padrão)
- **Velocity:** Quantidade de tasks concluídas por sprint
- **Burndown:** Gráfico de progresso do sprint

---

## Integrações Externas

### Google Workspace
- **Google Calendar:** Sincronização de deadlines de tasks
- **Google Drive:** Anexos de arquivos em tasks
- **Gmail:** Notificações por email

### Configuração de Autenticação
```typescript
// src/backend/config/auth.ts
export const authConfig = {
  provider: 'google',
  clientId: process.env.GOOGLE_CLIENT_ID,
  scopes: ['email', 'profile', 'openid'],
  callbackUrl: `${process.env.APP_URL}/auth/callback`
}
```

---

## Variáveis de Ambiente

### Obrigatórias (desenvolvimento)
```bash
DATABASE_URL="postgresql://user:pass@localhost:5432/myapp"
REDIS_URL="redis://localhost:6379"
GOOGLE_CLIENT_ID="seu-client-id.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="seu-client-secret"
JWT_SECRET="chave-secreta-minimo-32-chars"
```

### Obrigatórias (produção)
```bash
# Injete via Google Secret Manager — nunca hardcode
DATABASE_URL         # Via Cloud SQL connector
REDIS_URL            # Via Memorystore
GOOGLE_CLIENT_ID     # Via Secret Manager
GOOGLE_CLIENT_SECRET # Via Secret Manager
JWT_SECRET           # Via Secret Manager
SENTRY_DSN           # Via Secret Manager
```

---

## Restrições e Políticas

### O que o Agente PODE fazer automaticamente
- Criar e modificar arquivos de código-fonte
- Executar comandos de build e teste
- Criar branches e commits (nunca para `main` diretamente)
- Instalar dependências npm (apenas de fontes confiáveis)
- Fazer chamadas de leitura à API do GitHub

### O que o Agente DEVE pedir aprovação antes
- Modificar arquivos de configuração de infraestrutura (`.tf`, `cloudbuild.yaml`)
- Fazer push de código para qualquer branch remota
- Executar migrações de banco de dados
- Modificar variáveis de ambiente ou secrets
- Fazer deploy para qualquer ambiente

### O que o Agente NUNCA deve fazer
- Commitar diretamente para a branch `main` ou `production`
- Armazenar ou logar credenciais, tokens ou senhas
- Instalar dependências com vulnerabilidades conhecidas (CVSS > 7.0)
- Fazer chamadas de rede para domínios não listados nas integrações aprovadas
- Deletar dados de produção

---

## Comandos Úteis

```bash
# Desenvolvimento local
npm run dev              # Inicia frontend + backend em modo dev
npm run test             # Executa todos os testes
npm run test:e2e         # Executa testes E2E com Playwright
npm run lint             # Verifica linting
npm run build            # Build de produção

# Banco de dados
npx prisma migrate dev   # Aplica migrações em desenvolvimento
npx prisma studio        # Interface visual do banco de dados
npx prisma generate      # Regenera o Prisma Client

# Docker
docker-compose up -d     # Sobe serviços locais (postgres, redis)
docker-compose down      # Para os serviços

# Deploy
gcloud run deploy        # Deploy manual no Cloud Run
firebase deploy          # Deploy manual no Firebase Hosting
```

---

## Notas para o Agente Gemini

- Sempre leia este arquivo antes de qualquer tarefa
- Ao criar novos arquivos, siga as convenções de nomenclatura definidas acima
- Antes de implementar, verifique se existe código similar que pode ser reutilizado
- Prefira soluções simples e idiomáticas ao invés de abstrações desnecessárias
- Quando em dúvida sobre uma decisão de design, pergunte antes de implementar
- Documente decisões de arquitetura não óbvias com comentários no código
- Mantenha este arquivo atualizado quando a stack ou convenções mudarem

---

*Última atualização: 2026-03-03*
*Mantido por: Equipe de Desenvolvimento + Agente Gemini*
