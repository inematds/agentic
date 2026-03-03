# CONTEXT.md — Versao Minima

> Versao reduzida do CONTEXT.md para projetos simples ou para quem esta comecando.
> Copie o conteudo abaixo para um arquivo `CONTEXT.md` na raiz do seu projeto
> e substitua os valores entre colchetes.

---

## Como usar este template

Este e o conjunto minimo de informacoes que o agente Gemini precisa para ser util no seu projeto. Para projetos mais complexos, use o `CONTEXT.md` completo disponivel na raiz deste repositorio.

**Regra pratica:** se voce gasta mais de 30 minutos escrevendo o CONTEXT.md, ele esta detalhado demais para comecar. Comece com o minimo, adicione detalhes conforme o agente fizer perguntas ou cometer erros.

---

## Template minimo (copie a partir daqui)

```markdown
# CONTEXT.md

> Contexto persistente do projeto para o agente Gemini no Antigravity.

## Projeto

**Nome:** [nome-do-projeto]
**Descricao:** [Uma frase descrevendo o que o projeto faz]
**Repositorio:** [https://github.com/usuario/repositorio]

## Stack

[Liste apenas as tecnologias que voce realmente usa]

- **Linguagem:** [ex: TypeScript, Python, Go]
- **Frontend:** [ex: React 18, Vue 3, ou "nao tem frontend"]
- **Backend:** [ex: Fastify, FastAPI, ou "nao tem backend"]
- **Banco de dados:** [ex: PostgreSQL, MongoDB, ou "nao tem banco"]
- **Hospedagem:** [ex: Vercel, Heroku, Cloud Run]

## Convencoes

- **Linguagem dos commits:** [portugues / ingles]
- **Formato de commits:** [ex: Conventional Commits — feat:, fix:, docs:]
- **Estilo de codigo:** [ex: "seguir o .eslintrc existente" ou "indentacao com 2 espacos"]
- **Onde ficam os testes:** [ex: tests/, __tests__/, ou "sem testes ainda"]

## Restricoes importantes

### O agente PODE fazer automaticamente:
- Criar e modificar arquivos de codigo
- Executar comandos de build e teste
- Instalar dependencias npm/pip/go

### O agente DEVE pedir aprovacao antes de:
- Fazer qualquer push para o repositorio remoto
- Modificar arquivos de configuracao de deploy
- Executar comandos que afetam o banco de dados

### O agente NUNCA deve:
- Fazer commit diretamente para a branch main/master
- Armazenar senhas ou tokens no codigo
- Deletar arquivos sem confirmacao explica

## Comandos principais

```bash
# Instalar dependencias
[ex: npm install]

# Rodar em desenvolvimento
[ex: npm run dev]

# Executar testes
[ex: npm test]

# Build de producao
[ex: npm run build]
```

---
*Ultima atualizacao: [data]*
```

---

## Guia de preenchimento

### "Projeto" — o que escrever

A descricao deve responder: "O que este software faz para o usuario?"

Exemplos bons:
- "Sistema de agendamento de consultas para clinicas medicas"
- "API para processar pagamentos via PIX"
- "Dashboard para visualizar metricas de vendas em tempo real"

Exemplos ruins (muito vagos):
- "Sistema web"
- "API REST"
- "Projeto da faculdade"

### "Stack" — o que incluir

Inclua apenas o que for relevante para o agente ao escrever codigo. Se voce nao tem banco de dados, nao escreva "sem banco". Apenas omita essa linha.

Dica: pense no que um desenvolvedor novo precisaria saber para abrir um Pull Request no seu projeto.

### "Convencoes" — o que e mais importante

A convencao de commits e a mais importante para o agente. Se os seus commits sao em ingles, declare isso. O agente vai gerar commits no idioma e formato que voce especificar.

Se voce tem um arquivo `.eslintrc` ou `prettier.config.js`, voce pode simplesmente escrever "seguir a configuracao do ESLint/Prettier" e o agente vai ler esses arquivos automaticamente.

### "Restricoes" — nao pule esta secao

As restricoes sao a parte mais critica. Um agente sem restricoes pode fazer push para main, rodar migrations em producao ou deletar arquivos sem perguntar. Sempre defina o que requer aprovacao humana.

Para projetos pessoais simples, um conjunto minimo de restricoes e:

```markdown
### O agente PODE fazer automaticamente:
- Criar e modificar arquivos de codigo local
- Executar testes

### O agente DEVE pedir aprovacao antes de:
- Qualquer operacao git (commit, push, branch)
- Qualquer instalacao de dependencia nova

### O agente NUNCA deve:
- Modificar arquivos fora da pasta do projeto
```

---

## Quando expandir o CONTEXT.md

Expanda para o CONTEXT.md completo quando:

- O agente comecar a gerar codigo inconsistente com o estilo do projeto
- Voce se pegar repetindo as mesmas instrucoes em todas as conversas
- O projeto crescer e ter regras de negocio que o agente precisa conhecer
- Voce adicionar integrracoes externas que o agente vai precisar usar
- O time crescer e precisar de convencoes documentadas de qualquer forma

---

## Exemplo preenchido — projeto frontend simples

```markdown
# CONTEXT.md

> Contexto persistente do projeto para o agente Gemini no Antigravity.

## Projeto

**Nome:** portfolio-pessoal
**Descricao:** Site de portfolio pessoal com projetos, blog e formulario de contato
**Repositorio:** https://github.com/joao/portfolio

## Stack

- **Linguagem:** TypeScript
- **Frontend:** Astro 4 com componentes React para partes interativas
- **Banco de dados:** nao tem — conteudo estatico via Markdown
- **Hospedagem:** Vercel (deploy automatico via GitHub)

## Convencoes

- **Linguagem dos commits:** portugues
- **Formato de commits:** "Adiciona X", "Corrige Y", "Atualiza Z" (sem prefixo)
- **Estilo de codigo:** seguir o .eslintrc e prettier.config.js existentes
- **Onde ficam os testes:** sem testes automatizados por ora

## Restricoes importantes

### O agente PODE fazer automaticamente:
- Criar e modificar arquivos de codigo e conteudo
- Executar npm run build para verificar se compila

### O agente DEVE pedir aprovacao antes de:
- Qualquer operacao git
- Adicionar novas dependencias ao package.json
- Modificar arquivos de configuracao (astro.config.mjs, vercel.json)

### O agente NUNCA deve:
- Commitar ou fazer push sem aprovacao explicita
- Remover posts do blog existentes

## Comandos principais

```bash
npm install        # Instalar dependencias
npm run dev        # Servidor de desenvolvimento (localhost:4321)
npm run build      # Build de producao
npm run preview    # Preview do build de producao
```

---
*Ultima atualizacao: 2026-03-03*
```

---

*Para o CONTEXT.md completo com todas as secoes, veja `/CONTEXT.md` na raiz deste projeto.*
