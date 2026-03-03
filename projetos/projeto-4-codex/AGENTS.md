# AGENTS.md — Guia de Contexto para o Codex CLI

> Este arquivo é lido automaticamente pelo OpenAI Codex CLI em toda sessão.
> Equivalente ao CLAUDE.md no ecossistema Anthropic.
> Mantenha este arquivo atualizado à medida que o projeto evolui.

---

## 1. Contexto do Projeto

**Nome:** API de Gerenciamento de Tarefas (Task Manager API)
**Versão:** 2.3.1
**Tipo:** REST API — Backend de aplicação web

### O que é este projeto
Uma API RESTful construída com Node.js e Express para gerenciar tarefas, projetos e usuários. Utilizada por três frontends distintos: uma SPA em React, um app mobile em React Native e um cliente desktop em Electron. A API é a fonte de verdade de todos os dados.

### Stack Tecnológica
- **Runtime:** Node.js 20 LTS
- **Framework:** Express 4.18
- **Banco de dados:** PostgreSQL 15 (ORM: Prisma 5)
- **Cache:** Redis 7
- **Autenticação:** JWT + Refresh Tokens
- **Validação:** Zod
- **Testes:** Jest + Supertest
- **Linting:** ESLint (config: airbnb-base) + Prettier
- **Build:** sem build step (Node ESM nativo)
- **Deploy:** Docker + docker-compose em VPS (produção), Railway (staging)

---

## 2. Comandos de Desenvolvimento

### Instalação
```bash
# Instalar dependências
npm install

# Configurar banco de dados (primeira vez)
npm run db:migrate
npm run db:seed

# Verificar se tudo está funcionando
npm run health-check
```

### Desenvolvimento
```bash
# Rodar servidor em modo desenvolvimento (hot reload com nodemon)
npm run dev

# Servidor escuta em: http://localhost:3000
# Documentação Swagger: http://localhost:3000/api-docs
```

### Build e Produção
```bash
# Verificar se o código está pronto para produção
npm run lint
npm run typecheck
npm test

# Rodar em modo produção (não usar em dev)
npm start
```

### Banco de Dados
```bash
# Criar nova migration
npm run db:migrate:create -- --name nome-da-migration

# Aplicar migrations pendentes
npm run db:migrate

# Resetar banco (CUIDADO — apaga todos os dados)
npm run db:reset

# Abrir Prisma Studio (interface visual)
npm run db:studio
```

### Cache e Utilitários
```bash
# Limpar cache Redis
npm run cache:flush

# Gerar tipos TypeScript do Prisma
npm run db:generate
```

---

## 3. Comandos de Teste

```bash
# Rodar todos os testes unitários
npm test

# Rodar testes com watch mode (desenvolvimento)
npm run test:watch

# Rodar testes de integração (requer banco de dados de teste)
npm run test:integration

# Rodar testes E2E (requer servidor rodando)
npm run e2e

# Cobertura de código (meta: mínimo 80%)
npm run test:coverage

# Rodar apenas testes de um arquivo específico
npx jest src/modules/tasks/tasks.service.test.js

# Rodar testes que correspondem a um padrão
npx jest --testNamePattern="deve criar uma tarefa"
```

### Configuração de Teste
- Banco de dados de teste: `task_manager_test` (configurado em `.env.test`)
- Testes unitários usam mocks do Prisma Client
- Testes de integração usam banco real com transações revertidas após cada teste
- Testes E2E usam servidor completo em porta 3001

---

## 4. Convenções de Código

### Nomenclatura
- **Variáveis e funções:** camelCase (`getUserById`, `taskTitle`)
- **Classes:** PascalCase (`UserService`, `TaskRepository`)
- **Constantes:** SCREAMING_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`, `DEFAULT_PAGE_SIZE`)
- **Arquivos:** kebab-case (`user-service.js`, `task-repository.js`)
- **Pastas de módulo:** kebab-case (`user-management/`, `task-scheduler/`)
- **Tabelas do banco:** snake_case plural (`users`, `task_assignments`)
- **Colunas do banco:** snake_case (`created_at`, `user_id`)

### Imports
```javascript
// Ordem obrigatória de imports (ESLint enforces)
// 1. Módulos nativos do Node
import { readFile } from 'node:fs/promises';
import path from 'node:path';

// 2. Dependências externas
import express from 'express';
import { z } from 'zod';

// 3. Imports internos (usar alias @/)
import { UserService } from '@/modules/users/user.service.js';
import { AppError } from '@/shared/errors/app-error.js';
import { logger } from '@/shared/logger.js';

// Sempre usar extensão .js nos imports (Node ESM)
// Sempre usar alias @/ para imports internos (configurado em jsconfig.json)
```

### ESLint — Regras Importantes
```javascript
// PROIBIDO — sem console.log em produção
console.log('debug'); // Use logger.debug() em vez disso

// PROIBIDO — callbacks aninhados
app.get('/users', (req, res) => {
  db.query('SELECT *', (err, rows) => { // Não faça isso
    res.json(rows);
  });
});

// CORRETO — async/await
app.get('/users', async (req, res, next) => {
  try {
    const users = await userService.findAll();
    res.json(users);
  } catch (error) {
    next(error);
  }
});
```

### Tratamento de Erros
```javascript
// Sempre usar AppError para erros esperados
throw new AppError('Tarefa não encontrada', 404, 'TASK_NOT_FOUND');

// Nunca expor stack traces em produção
// O error handler global em src/shared/middleware/error-handler.js cuida disso

// Sempre logar erros inesperados antes de propagar
logger.error({ error, context: 'UserService.create' }, 'Erro inesperado ao criar usuário');
```

### Validação
```javascript
// Sempre validar input com Zod nos controllers
const createTaskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(2000).optional(),
  dueDate: z.string().datetime().optional(),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
});

// O middleware validateRequest em src/shared/middleware/validate-request.js
// aplica o schema e retorna 400 automaticamente se inválido
```

---

## 5. Regras de Comportamento para o Agente

### NUNCA faça sem aprovação explícita:
- Modificar arquivos em `src/migrations/` (migrations são irreversíveis)
- Alterar `package.json` ou `package-lock.json`
- Modificar qualquer arquivo `.env` ou `.env.*`
- Executar `npm publish`, `git push --force`, ou `docker push`
- Modificar arquivos de configuração de produção em `config/production/`
- Deletar arquivos de banco de dados ou de backup
- Alterar as definições de schema do Prisma sem criar migration correspondente

### SEMPRE faça:
- Criar branches com prefixo `feature/`, `fix/`, `chore/`, `refactor/`
- Rodar `npm run lint` antes de qualquer commit
- Rodar `npm test` antes de propor um PR
- Adicionar testes para qualquer código novo (cobertura mínima: 80%)
- Usar o logger (`import { logger } from '@/shared/logger.js'`) em vez de console
- Verificar se existe um teste quebrado antes de modificar código existente
- Documentar funções públicas com JSDoc

### Ao criar novos endpoints:
1. Criar rota em `src/modules/{modulo}/{modulo}.routes.js`
2. Criar controller em `src/modules/{modulo}/{modulo}.controller.js`
3. Criar service em `src/modules/{modulo}/{modulo}.service.js`
4. Criar repository em `src/modules/{modulo}/{modulo}.repository.js`
5. Adicionar validação Zod no controller
6. Escrever testes unitários para o service
7. Escrever testes de integração para o endpoint
8. Atualizar a documentação Swagger em `src/modules/{modulo}/{modulo}.swagger.js`

---

## 6. Arquitetura do Projeto

### Estrutura de Pastas
```
task-manager-api/
├── src/
│   ├── modules/              # Módulos de domínio (feature folders)
│   │   ├── users/            # Tudo relacionado a usuários
│   │   │   ├── user.routes.js
│   │   │   ├── user.controller.js
│   │   │   ├── user.service.js
│   │   │   ├── user.repository.js
│   │   │   ├── user.schema.js      # Schemas Zod
│   │   │   ├── user.swagger.js     # Documentação OpenAPI
│   │   │   └── user.service.test.js
│   │   ├── tasks/
│   │   ├── projects/
│   │   └── notifications/
│   ├── shared/               # Código compartilhado entre módulos
│   │   ├── middleware/       # Express middlewares
│   │   │   ├── auth.js           # Verificação JWT
│   │   │   ├── error-handler.js  # Handler global de erros
│   │   │   ├── rate-limiter.js   # Rate limiting por IP
│   │   │   └── validate-request.js
│   │   ├── errors/           # Classes de erro customizadas
│   │   │   └── app-error.js
│   │   ├── logger.js         # Pino logger configurado
│   │   └── prisma.js         # Singleton do Prisma Client
│   ├── config/               # Configurações da aplicação
│   │   ├── env.js            # Validação de variáveis de ambiente com Zod
│   │   ├── database.js       # Config do PostgreSQL
│   │   └── redis.js          # Config do Redis
│   └── app.js                # Express app (sem listen — separado do server.js)
├── server.js                 # Entry point — chama app.listen()
├── prisma/
│   ├── schema.prisma         # Schema do banco de dados
│   ├── migrations/           # Migrations geradas pelo Prisma
│   └── seed.js               # Dados iniciais de desenvolvimento
├── tests/
│   ├── integration/          # Testes de integração (Supertest)
│   ├── e2e/                  # Testes E2E
│   └── fixtures/             # Dados de teste reutilizáveis
├── config/
│   ├── development/
│   └── production/           # NUNCA modificar sem aprovação
├── .env.example              # Template de variáveis (sem valores reais)
├── .env                      # Variáveis locais (nunca comitar — no .gitignore)
├── .env.test                 # Variáveis para testes
├── AGENTS.md                 # Este arquivo
├── ARCHITECTURE.md           # Decisões arquiteturais detalhadas
└── README.md                 # Documentação pública
```

### Padrão de Camadas
```
Request → Routes → Controller → Service → Repository → Database
                     ↓
                Validação (Zod)
                     ↓
                Middleware (Auth, RateLimit)
```

- **Routes:** apenas definição de rotas e middlewares aplicados
- **Controller:** recebe request, valida input, chama service, retorna response
- **Service:** lógica de negócio, orquestra repositories, não conhece HTTP
- **Repository:** acesso ao banco via Prisma, sem lógica de negócio

---

## 7. Ambiente e Variáveis de Ambiente

### Variáveis Obrigatórias (ver `.env.example`)
```bash
# Servidor
NODE_ENV=development          # development | staging | production
PORT=3000

# Banco de Dados
DATABASE_URL=postgresql://user:password@localhost:5432/task_manager

# Redis
REDIS_URL=redis://localhost:6379

# Autenticação
JWT_SECRET=seu-secret-aqui-minimo-32-chars
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_SECRET=outro-secret-aqui-minimo-32-chars
REFRESH_TOKEN_EXPIRES_IN=7d

# Email (para notificações)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@seudominio.com
SMTP_PASS=app-password-aqui

# Monitoramento (opcional em dev)
SENTRY_DSN=https://...@sentry.io/...

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000   # 15 minutos
RATE_LIMIT_MAX=100            # requisições por janela
```

### Regras de Variáveis de Ambiente
- Nunca hardcodar valores de configuração no código
- Sempre validar variáveis de ambiente na inicialização (ver `src/config/env.js`)
- Variáveis não definidas devem causar falha na inicialização (fail fast)
- Usar `.env.example` como documentação — sempre manter atualizado
- Nunca comitar arquivos `.env` com valores reais

---

## 8. Endpoints Principais da API

### Autenticação (`/api/auth`)
```
POST   /api/auth/register          # Criar conta
POST   /api/auth/login             # Login, retorna JWT + refresh token
POST   /api/auth/refresh           # Renovar access token
POST   /api/auth/logout            # Invalidar refresh token
POST   /api/auth/forgot-password   # Solicitar reset de senha
POST   /api/auth/reset-password    # Confirmar reset de senha
```

### Usuários (`/api/users`) — requer auth
```
GET    /api/users/me               # Perfil do usuário autenticado
PATCH  /api/users/me               # Atualizar perfil
DELETE /api/users/me               # Deletar conta
GET    /api/users/:id              # Perfil público de usuário
```

### Tarefas (`/api/tasks`) — requer auth
```
GET    /api/tasks                  # Listar tarefas (com filtros e paginação)
POST   /api/tasks                  # Criar tarefa
GET    /api/tasks/:id              # Detalhe de uma tarefa
PATCH  /api/tasks/:id              # Atualizar tarefa
DELETE /api/tasks/:id              # Deletar tarefa
POST   /api/tasks/:id/complete     # Marcar como concluída
POST   /api/tasks/:id/assign       # Atribuir a usuário
```

### Projetos (`/api/projects`) — requer auth
```
GET    /api/projects               # Listar projetos do usuário
POST   /api/projects               # Criar projeto
GET    /api/projects/:id           # Detalhe do projeto
PATCH  /api/projects/:id           # Atualizar projeto
DELETE /api/projects/:id           # Arquivar projeto
GET    /api/projects/:id/tasks     # Tarefas do projeto
POST   /api/projects/:id/members   # Adicionar membro
DELETE /api/projects/:id/members/:userId  # Remover membro
```

### Saúde e Monitoramento
```
GET    /health                     # Health check básico (sem auth)
GET    /health/detailed            # Status detalhado (requer admin)
GET    /api-docs                   # Documentação Swagger UI
```

### Parâmetros de Query Comuns
```
?page=1&limit=20          # Paginação
?sort=createdAt:desc      # Ordenação
?filter[status]=pending   # Filtros
?search=texto             # Busca full-text
?include=project,assignee # Relações a incluir
```

---

## 9. Padrões de Response

### Sucesso
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### Erro
```json
{
  "success": false,
  "error": {
    "code": "TASK_NOT_FOUND",
    "message": "Tarefa não encontrada",
    "statusCode": 404
  }
}
```

### Erro de Validação
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Dados inválidos",
    "statusCode": 400,
    "details": [
      { "field": "title", "message": "Título é obrigatório" },
      { "field": "dueDate", "message": "Data inválida" }
    ]
  }
}
```

---

## 10. Informações Adicionais para o Agente

### Quando o agente não souber algo:
- Consultar `ARCHITECTURE.md` para decisões arquiteturais
- Consultar a documentação do Prisma em `prisma/schema.prisma`
- Verificar testes existentes para entender o comportamento esperado
- Não assumir — perguntar ao desenvolvedor

### Contexto de Equipe:
- Equipe pequena: 3 desenvolvedores backend, 2 frontend
- Code review obrigatório para PRs que tocam auth, billing ou dados de usuário
- Deploy automático para staging a cada merge em `develop`
- Deploy para produção é manual e requer aprovação de 2 pessoas

### Prioridades:
1. Segurança (nunca sacrificar por conveniência)
2. Confiabilidade (testes antes de features)
3. Performance (monitorar com Sentry e logs)
4. Manutenibilidade (código limpo e documentado)
