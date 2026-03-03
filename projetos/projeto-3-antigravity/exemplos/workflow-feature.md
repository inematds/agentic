# Exemplo: Implementando uma Feature com o Antigravity

Este exemplo mostra o ciclo completo de implementacao de uma feature usando o Antigravity e o agente Gemini. O caso de uso e a adicao de um sistema de notificacoes em tempo real a uma aplicacao de gerenciamento de tasks.

---

## Contexto da feature

**Feature solicitada:** Notificacoes em tempo real quando um membro do time menciona voce em um comentario de task.

**Criterios de aceite:**
- Quando alguem escreve `@usuario` em um comentario, o usuario mencionado recebe uma notificacao
- As notificacoes aparecem em tempo real (sem necessidade de recarregar a pagina)
- O usuario pode marcar notificacoes como lidas
- Maximo de 50 notificacoes nao lidas por usuario

---

## O prompt inicial para o agente

Este e o prompt enviado ao Antigravity para iniciar o workflow:

```
@agent implement feature: sistema de notificacoes em tempo real para mencoes em comentarios.

Descricao completa:
Quando um usuario escreve @username em um comentario de task, o usuario mencionado
deve receber uma notificacao em tempo real. As notificacoes devem aparecer no sino
de notificacoes no canto superior direito da interface.

Requisitos funcionais:
- Detectar mencoes no formato @username ao salvar um comentario
- Criar uma notificacao para cada usuario mencionado (ignorar auto-mencoes)
- Entregar a notificacao em tempo real via WebSocket
- Endpoint GET /api/notifications: lista notificacoes do usuario autenticado (max 50)
- Endpoint PATCH /api/notifications/:id/read: marca uma notificacao como lida
- Endpoint PATCH /api/notifications/read-all: marca todas como lidas
- Componente React NotificationBell no header que mostra o numero de nao lidas
- Componente NotificationList que lista as notificacoes ao clicar no sino

Requisitos tecnicos:
- WebSocket usando a biblioteca ws (ja e uma dependencia do Fastify)
- Notificacoes persistidas no PostgreSQL (tabela notifications)
- Cache do contador de nao lidas no Redis (TTL: 5 minutos)
- Testes unitarios para o servico de deteccao de mencoes
- Testes unitarios para os endpoints da API
- Sem testes E2E nesta iteracao (sera feito em sprint separado)
```

---

## O plano gerado pelo agente

Apos receber o prompt, o agente gerou o seguinte plano (etapa **Plan** do workflow):

```
Plano de implementacao: Sistema de Notificacoes em Tempo Real

ANALISE INICIAL
---------------
Arquivos existentes relevantes identificados:
- src/backend/routes/comments.ts — onde vou hookar a deteccao de mencoes
- src/backend/services/commentService.ts — vou adicionar logica de mencao aqui
- src/frontend/components/Header.tsx — onde vou inserir o NotificationBell
- src/backend/app.ts — onde vou registrar as novas rotas e o WebSocket
- prisma/schema.prisma — onde vou adicionar o modelo Notification

MUDANCAS NO BANCO DE DADOS
--------------------------
1. Adicionar modelo Notification ao schema.prisma:
   - id: UUID
   - userId: FK para User (destinatario)
   - actorId: FK para User (quem mencionou)
   - taskId: FK para Task
   - commentId: FK para Comment
   - message: String
   - read: Boolean (default: false)
   - createdAt: DateTime

2. Gerar e aplicar migracao:
   - npx prisma migrate dev --name add_notifications

BACKEND — Novos arquivos a criar
---------------------------------
3. src/backend/services/notificationService.ts
   - detectMentions(text: string): string[] — extrai @usernames do texto
   - createMentionNotifications(commentId, authorId, mentionedUsernames) — cria notificacoes
   - getNotifications(userId): Notification[] — busca com cache Redis
   - markAsRead(notificationId, userId): void
   - markAllAsRead(userId): void
   - invalidateCache(userId): void — chamado apos criar/marcar notificacoes

4. src/backend/routes/notifications.ts
   - GET /api/notifications (authRequired)
   - PATCH /api/notifications/:id/read (authRequired)
   - PATCH /api/notifications/read-all (authRequired)

5. src/backend/websocket/notificationGateway.ts
   - Gerencia conexoes WebSocket por userId
   - sendNotification(userId, notification) — envia para o cliente correto

BACKEND — Arquivos a modificar
--------------------------------
6. src/backend/services/commentService.ts
   - Apos salvar o comentario, chamar notificationService.createMentionNotifications()

7. src/backend/app.ts
   - Registrar rotas de notificacoes
   - Inicializar o WebSocket gateway

8. prisma/schema.prisma
   - Adicionar modelo Notification (conforme descrito acima)

FRONTEND — Novos arquivos a criar
-----------------------------------
9. src/frontend/components/NotificationBell.tsx
   - Mostra icone de sino com badge de contagem de nao lidas
   - Ao clicar, abre/fecha NotificationList

10. src/frontend/components/NotificationList.tsx
    - Lista as notificacoes
    - Botao "Marcar todas como lidas"
    - Cada item tem link para a task

11. src/frontend/hooks/useNotifications.ts
    - Gerencia estado das notificacoes
    - Conecta ao WebSocket para receber novas notificacoes em tempo real
    - Funcoes: markAsRead, markAllAsRead

12. src/frontend/stores/notificationStore.ts
    - Estado global das notificacoes (Zustand)
    - notifications: Notification[]
    - unreadCount: number

FRONTEND — Arquivos a modificar
---------------------------------
13. src/frontend/components/Header.tsx
    - Adicionar <NotificationBell /> no canto superior direito

TESTES
-------
14. tests/unit/notificationService.test.ts
    - Testa detectMentions com varios formatos de @mencao
    - Testa que auto-mencoes sao ignoradas
    - Testa criacao de notificacoes

15. tests/unit/notifications.route.test.ts
    - Testa GET /api/notifications (com e sem autenticacao)
    - Testa PATCH /api/notifications/:id/read
    - Testa PATCH /api/notifications/read-all

ORDEM DE EXECUCAO
------------------
1. Schema do banco (prisma)
2. Servico de notificacoes
3. Gateway WebSocket
4. Rotas da API
5. Modificacoes em commentService e app.ts
6. Componentes React
7. Modificacao no Header
8. Testes

DEPENDENCIAS NECESSARIAS
--------------------------
Nenhuma nova dependencia necessaria. ws e uma dependencia transitiva do Fastify.

RISCOS IDENTIFICADOS
---------------------
- A conexao WebSocket pode causar problemas em ambientes com proxy reverso
  (ex: Nginx). Documentarei isso nos comentarios do gateway.
- O cache Redis para o contador de nao lidas pode ficar desatualizado por ate
  5 minutos. Isso e aceitavel para notificacoes nao urgentes.

Estimativa: 18 arquivos criados/modificados, ~650 linhas de codigo novo.

Posso prosseguir com a implementacao? (s/n)
```

---

## Como aprovar etapas

O Antigravity apresenta o plano e aguarda confirmacao antes de escrever qualquer codigo. Voce tem algumas opcoes:

### Aprovacao simples

Se o plano estiver bom, simplesmente escreva:

```
s
```

Ou clique no botao **Aprovar** na interface.

### Aprovacao com ajustes

Se quiser fazer alteracoes no plano antes de executar:

```
Aprovado, mas com duas alteracoes:
1. No passo 3, adicione tambem uma funcao getUnreadCount(userId) que retorna
   apenas o contador — sera mais eficiente para o badge do sino.
2. No passo 9, o NotificationBell deve mostrar "99+" quando houver mais de 99
   nao lidas, nao o numero exato.
Atualize o plano e aguarde minha confirmacao.
```

O agente atualizara o plano e pedira nova confirmacao antes de executar.

### Rejeicao do plano

Se o plano tiver problemas estruturais:

```
Nao aprovado. O plano nao considerou que ja temos um sistema de eventos
interno (src/backend/events/eventBus.ts) que deve ser usado para
comunicacao entre servicos. Refaca o plano usando o eventBus para
triggar as notificacoes ao inves de chamar o notificationService
diretamente no commentService.
```

---

## O que o agente executa em cada passo

### Passo 1 — Schema do banco

O agente modifica o `prisma/schema.prisma`:

```prisma
model Notification {
  id        String   @id @default(uuid())
  userId    String
  actorId   String
  taskId    String
  commentId String
  message   String
  read      Boolean  @default(false)
  createdAt DateTime @default(now())

  user    User    @relation("NotificationRecipient", fields: [userId], references: [id])
  actor   User    @relation("NotificationActor", fields: [actorId], references: [id])
  task    Task    @relation(fields: [taskId], references: [id])
  comment Comment @relation(fields: [commentId], references: [id])

  @@index([userId, read])
  @@index([createdAt])
}
```

Em seguida, executa no terminal:
```bash
npx prisma migrate dev --name add_notifications
npx prisma generate
```

### Passo 2 — Servico de notificacoes

O agente cria `src/backend/services/notificationService.ts` com a logica de deteccao de mencoes e criacao de notificacoes. A funcao `detectMentions` usa uma expressao regular para extrair `@usernames` do texto do comentario.

Trecho representativo gerado pelo agente:

```typescript
// src/backend/services/notificationService.ts

const MENTION_REGEX = /@([a-zA-Z0-9_-]+)/g

export function detectMentions(text: string): string[] {
  const matches = text.matchAll(MENTION_REGEX)
  const usernames = new Set<string>()
  for (const match of matches) {
    usernames.add(match[1].toLowerCase())
  }
  return Array.from(usernames)
}

export async function createMentionNotifications(
  commentId: string,
  comment: string,
  authorUsername: string,
  taskId: string
): Promise<void> {
  const mentionedUsernames = detectMentions(comment)
    .filter(username => username !== authorUsername) // ignora auto-mencao

  if (mentionedUsernames.length === 0) return

  const mentionedUsers = await prisma.user.findMany({
    where: { username: { in: mentionedUsernames } },
    select: { id: true, username: true }
  })

  const author = await prisma.user.findUnique({
    where: { username: authorUsername },
    select: { id: true, displayName: true }
  })

  if (!author) return

  const notifications = mentionedUsers.map(user => ({
    userId: user.id,
    actorId: author.id,
    taskId,
    commentId,
    message: `${author.displayName} mencionou voce em um comentario`
  }))

  await prisma.notification.createMany({ data: notifications })

  // Invalidar cache Redis e notificar via WebSocket
  for (const user of mentionedUsers) {
    await invalidateCache(user.id)
    await notificationGateway.sendNotification(user.id, notifications.find(n => n.userId === user.id)!)
  }
}
```

### Passo 3 — Gateway WebSocket

O agente cria `src/backend/websocket/notificationGateway.ts` que gerencia conexoes WebSocket indexadas por `userId`. Quando o servidor quer enviar uma notificacao a um usuario, ele busca a conexao desse usuario e envia a mensagem.

### Passo 4 — Rotas da API

O agente cria `src/backend/routes/notifications.ts` com os tres endpoints especificados, usando o middleware `authRequired` ja existente para proteger as rotas.

### Passo 5 — Componentes React

O agente cria os componentes `NotificationBell` e `NotificationList`, o hook `useNotifications` e o store Zustand. O hook estabelece a conexao WebSocket ao montar o componente e fecha ao desmontar.

### Passo 6 — Modificacoes no Header

O agente modifica `Header.tsx` para incluir o `NotificationBell`:

```tsx
// Antes (trecho do Header.tsx)
<nav>
  <UserMenu />
</nav>

// Depois
<nav>
  <NotificationBell />
  <UserMenu />
</nav>
```

### Passo 7 — Testes

O agente cria os arquivos de teste e os executa:

```
Executando testes...
> vitest run tests/unit/notificationService.test.ts

PASS  tests/unit/notificationService.test.ts
  detectMentions
    ✓ extrai username simples: "@joao" -> ["joao"]
    ✓ extrai multiplas mencoes: "@joao e @maria" -> ["joao", "maria"]
    ✓ ignora email: "email@dominio.com" -> []
    ✓ deduplica mencoes repetidas
    ✓ retorna lista vazia para texto sem mencoes

  createMentionNotifications
    ✓ cria notificacao para usuario mencionado
    ✓ nao cria notificacao para auto-mencao
    ✓ ignora usernames que nao existem no banco

PASS  tests/unit/notifications.route.test.ts
  GET /api/notifications
    ✓ retorna 401 sem autenticacao
    ✓ retorna lista vazia para usuario sem notificacoes
    ✓ retorna notificacoes do usuario autenticado
    ✓ nao retorna notificacoes de outros usuarios

  PATCH /api/notifications/:id/read
    ✓ marca notificacao como lida
    ✓ retorna 404 para notificacao inexistente
    ✓ retorna 403 para notificacao de outro usuario

  PATCH /api/notifications/read-all
    ✓ marca todas as notificacoes como lidas
    ✓ retorna contagem de notificacoes atualizadas

Testes: 17 passaram, 0 falharam
```

---

## Resultado final esperado

Ao final do workflow, voce tera:

**Backend:**
- Tabela `notifications` no banco de dados (com indices otimizados)
- Servico completo de notificacoes com cache Redis
- Gateway WebSocket para entrega em tempo real
- 3 endpoints REST documentados e testados
- Hook no sistema de comentarios para detectar mencoes

**Frontend:**
- Icone de sino no header com badge de contagem
- Lista de notificacoes ao clicar no sino
- Atualizacao em tempo real via WebSocket (sem recarregar a pagina)
- Estado global gerenciado pelo Zustand

**Testes:**
- 17 testes unitarios passando
- Cobertura de todos os casos criticos do servico de notificacoes

**Codigo:**
- Seguindo todas as convencoes definidas no CONTEXT.md
- Sem dependencias novas (usou apenas o que ja estava no projeto)
- Comentarios nos trechos nao obvios (especialmente no gateway WebSocket)

**Commit gerado pelo agente:**
```
feat: add real-time mention notifications

Implements WebSocket-based notification system for @mentions in task
comments. Users receive instant notifications when mentioned, with
Redis-cached unread counts and REST endpoints for notification management.

Closes #47
```

---

*Este exemplo e baseado em um caso de uso real, simplificado para fins didaticos.*
*Os trechos de codigo sao representativos e podem variar conforme o estado real do projeto.*
