# ROTEIRO — Dominando o OpenAI Codex CLI

> Roteiro passo a passo para sair do zero ate usar o Codex CLI em pipelines de producao.
> Tempo total estimado: **~6 horas**

---

## Visao geral do roteiro

```
Passo 1: Instalar (10 min)
    ↓
Passo 2: Obter API key (5 min)
    ↓
Passo 3: Criar AGENTS.md (30 min)
    ↓
Passo 4: Configurar .codex/config.toml (20 min)
    ↓
Passo 5: Primeira sessao interativa (30 min)
    ↓
Passo 6: Modo auto-edit (30 min)
    ↓
Passo 7: Integrar com GitHub Actions (1h)
    ↓
Passo 8: Pipeline de desenvolvimento autonomo (3h)
```

---

## Passo 1 — Instalar Node.js e Codex CLI

**Tempo estimado:** 10 minutos

### 1.1 Verificar se o Node.js esta instalado

```bash
node --version
```

Se aparecer `v18.0.0` ou superior, pule para o item 1.3.

### 1.2 Instalar o Node.js (caso necessario)

**Linux (Ubuntu/Debian):**
```bash
# Usando o gerenciador de versoes nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

**macOS:**
```bash
# Com Homebrew
brew install node@20
```

**Windows:**
Acesse [nodejs.org](https://nodejs.org) e baixe o instalador LTS.

### 1.3 Instalar o Codex CLI

```bash
npm install -g @openai/codex
```

### 1.4 Verificar a instalacao

```bash
codex --version
# Deve exibir a versao instalada, ex: 0.1.x
```

**Checkpoint:** O comando `codex --version` deve funcionar sem erros.

---

## Passo 2 — Obter a API key da OpenAI e configurar

**Tempo estimado:** 5 minutos

### 2.1 Obter a chave

1. Acesse [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Clique em **"Create new secret key"**
3. Copie a chave (começa com `sk-...`) — ela nao sera exibida novamente

### 2.2 Configurar no ambiente

**Opção recomendada — adicionar permanentemente ao shell:**
```bash
# Para bash
echo 'export OPENAI_API_KEY="sk-SUA_CHAVE_AQUI"' >> ~/.bashrc
source ~/.bashrc

# Para zsh
echo 'export OPENAI_API_KEY="sk-SUA_CHAVE_AQUI"' >> ~/.zshrc
source ~/.zshrc
```

**Opcao alternativa — arquivo .env no projeto:**
```bash
cp .env.example .env
# Edite o arquivo .env e adicione sua chave
```

### 2.3 Verificar a configuracao

```bash
echo $OPENAI_API_KEY
# Deve exibir sua chave (ou parte dela)
```

### 2.4 Testar a conexao

```bash
codex "diga 'funcionou' em uma palavra"
# O agente deve responder brevemente
```

**Checkpoint:** O Codex deve responder sem erros de autenticacao.

---

## Passo 3 — Criar seu AGENTS.md

**Tempo estimado:** 30 minutos

O `AGENTS.md` e o coração da sua configuracao agentica. E lido automaticamente pelo Codex no inicio de cada sessao, dando contexto sobre o projeto sem que voce precise repetir isso toda vez.

### 3.1 Entender a estrutura do AGENTS.md

Abra o template de referencia:
```bash
cat AGENTS.md
```

As secoes essenciais sao:
1. **Contexto do Projeto** — o que o projeto faz, stack tecnologica
2. **Comandos de Desenvolvimento** — como instalar, rodar, testar
3. **Convencoes de Codigo** — nomenclatura, imports, padrao de erros
4. **Regras de Comportamento** — o que o agente NUNCA deve fazer
5. **Arquitetura** — estrutura de pastas, padroes arquiteturais

### 3.2 Criar para o seu projeto

```bash
# No diretorio do SEU projeto (nao neste diretório)
cd /caminho/do/seu/projeto

# Copiar o template
cp /home/nmaldaner/projetos/agentic/projetos/projeto-4-codex/AGENTS.md ./AGENTS.md

# Abrir no editor e personalizar
code AGENTS.md   # VS Code
# ou
nano AGENTS.md   # terminal
```

### 3.3 O que personalizar

Substitua cada secao com informacoes reais do seu projeto:

- [ ] Nome e descricao do projeto
- [ ] Stack tecnologica (linguagem, framework, banco de dados)
- [ ] Comandos de instalacao e execucao
- [ ] Comandos de teste e lint
- [ ] Convencoes de nomenclatura da sua equipe
- [ ] Lista de arquivos criticos que o agente nao deve modificar
- [ ] Estrutura de pastas do projeto

### 3.4 Dicas para um bom AGENTS.md

- **Seja especifico:** "Use camelCase para variaveis" e melhor que "siga boas praticas"
- **Liste o que nao fazer:** Proibicoes explicitas evitam acidentes
- **Mantenha atualizado:** Cada vez que mudar a stack, atualize o AGENTS.md
- **Inclua exemplos de codigo:** O agente aprende com exemplos concretos

**Checkpoint:** Voce tem um `AGENTS.md` personalizado no diretorio do seu projeto.

---

## Passo 4 — Configurar .codex/config.toml com modo suggest

**Tempo estimado:** 20 minutos

O arquivo `.codex/config.toml` controla o comportamento padrao do Codex. Configurar com modo `suggest` garante que o agente nunca fara nada sem sua aprovacao — perfeito para comecar.

### 4.1 Criar a pasta e o arquivo

```bash
# No diretorio do SEU projeto
mkdir -p .codex

# Copiar a configuracao base
cp /home/nmaldaner/projetos/agentic/projetos/projeto-4-codex/.codex/config.toml ./.codex/config.toml
```

### 4.2 Verificar a configuracao

```bash
cat .codex/config.toml
```

Confirme que `approval_mode = "suggest"` esta definido. Isso significa:
- O agente pode ler todos os arquivos do projeto
- O agente mostra o que faria, mas nao executa nada
- Voce ve as sugestoes e decide como proceder

### 4.3 Opcoes de configuracao disponíveis

```toml
# Modo de aprovacao (suggest | auto-edit | full-auto)
approval_mode = "suggest"

# Modelo a usar
model = "gpt-4o"

# Temperatura (0.0 = deterministico, 1.0 = criativo)
temperature = 0.2

# Timeout por operacao (segundos)
timeout = 120

# Nivel de log (debug | info | warn | error)
log_level = "info"
```

### 4.4 Por que comecar com suggest

No modo `suggest`:
- Zero risco de mudancas acidentais
- Voce aprende o que o agente faria antes de confiar nele
- Otimo para explorar o comportamento em projetos novos

**Checkpoint:** O arquivo `.codex/config.toml` existe com `approval_mode = "suggest"`.

---

## Passo 5 — Primeira sessao interativa com o Codex

**Tempo estimado:** 30 minutos

Chegou a hora de conversar com o agente de verdade.

### 5.1 Iniciar o Codex no diretorio do projeto

```bash
# No diretorio do seu projeto (que tem AGENTS.md)
cd /caminho/do/seu/projeto
codex
```

O Codex vai:
1. Ler o `AGENTS.md` automaticamente
2. Abrir o prompt interativo
3. Aguardar suas instrucoes

### 5.2 Exercicios para a primeira sessao

Execute estes exercicios na ordem. Eles vao do mais simples ao mais complexo:

**Exercicio A — Explorar o projeto (5 min):**
```
Voce: "Liste os arquivos mais importantes deste projeto e explique a funcao de cada um"
```

**Exercicio B — Entender o codigo (10 min):**
```
Voce: "Explique como funciona o fluxo de autenticacao neste projeto"
```

**Exercicio C — Pedir uma sugestao de melhoria (10 min):**
```
Voce: "Quais melhorias de seguranca voce sugere para este projeto?"
```

**Exercicio D — Sugestao de codigo (5 min):**
```
Voce: "Mostre como eu adicionaria um endpoint GET /api/users/:id/tasks que retorna as tarefas de um usuario especifico"
```

### 5.3 O que observar durante a sessao

- O Codex vai referenciar informacoes do `AGENTS.md` nas respostas
- No modo `suggest`, ele mostra code diffs mas nao aplica
- Voce pode fazer perguntas de acompanhamento na mesma sessao
- Use Ctrl+C para sair

### 5.4 Sair e refletir

Ao terminar, responda para si mesmo:
- O agente entendeu a stack do projeto?
- As sugestoes faziam sentido para o contexto?
- O que esta faltando no AGENTS.md?

**Checkpoint:** Voce completou uma sessao interativa e tem ideias de como melhorar o AGENTS.md.

---

## Passo 6 — Modo auto-edit: deixar o agente editar com aprovacao

**Tempo estimado:** 30 minutos

Agora vamos dar mais autonomia ao agente, mas ainda com controle sobre execucao de comandos.

### 6.1 Mudar para o modo auto-edit

Edite o `.codex/config.toml`:
```toml
approval_mode = "auto-edit"
```

Ou use o flag direto no comando:
```bash
codex --approval-mode auto-edit "sua instrucao aqui"
```

### 6.2 O que muda no modo auto-edit

Permitido sem aprovacao:
- Criar novos arquivos
- Editar arquivos existentes
- Ler qualquer arquivo do projeto

Ainda requer aprovacao:
- Rodar comandos no terminal (`npm test`, `git commit`, etc.)
- Instalar dependencias
- Qualquer operacao de rede

### 6.3 Exercicios para o modo auto-edit

**Exercicio A — Criar um novo arquivo (10 min):**
```bash
codex --approval-mode auto-edit "crie um arquivo src/utils/format-date.js com uma funcao formatDate que recebe uma data ISO e retorna no formato DD/MM/AAAA"
```

Revise o arquivo criado e verifique se:
- [ ] O arquivo foi criado no local correto
- [ ] O codigo segue as convencoes do projeto (conforme AGENTS.md)
- [ ] A funcao faz o que foi pedido

**Exercicio B — Refatorar codigo existente (20 min):**
```bash
codex --approval-mode auto-edit "no arquivo [escolha um arquivo existente], refatore para melhorar a legibilidade sem mudar o comportamento"
```

Use `git diff` para ver exatamente o que mudou:
```bash
git diff
```

### 6.4 Fluxo de trabalho recomendado

```bash
# 1. Criar branch antes de deixar o agente editar
git checkout -b ai/refactor-user-module

# 2. Rodar o Codex em modo auto-edit
codex --approval-mode auto-edit "sua tarefa"

# 3. Revisar todas as mudancas
git diff

# 4. Rodar os testes
npm test

# 5. Se tudo OK, commitar
git add .
git commit -m "refactor: [descricao do que o agente fez]"
```

**Checkpoint:** Voce usou o modo auto-edit e revisou as mudancas com `git diff`.

---

## Passo 7 — Integrar com GitHub Actions (CI/CD headless)

**Tempo estimado:** 1 hora

O Codex em modo headless (sem interacao humana) e perfeito para pipelines de CI/CD.

### 7.1 Entender o modo headless

No modo headless, o Codex:
- Recebe a instrucao como argumento de linha de comando
- Executa sem prompt interativo
- Retorna o resultado no stdout
- Retorna codigo de saida 0 (sucesso) ou 1 (falha)

```bash
# Exemplo de uso headless
codex --approval-mode full-auto --quiet "rodar os testes e reportar falhas"
echo "Codigo de saida: $?"
```

### 7.2 Copiar o workflow de exemplo

```bash
# No repositorio do seu projeto
mkdir -p .github/workflows
cp /home/nmaldaner/projetos/agentic/projetos/projeto-4-codex/exemplos/github-actions.yml .github/workflows/ai-review.yml
```

### 7.3 Configurar o secret da API key

No GitHub:
1. Va em **Settings > Secrets and variables > Actions**
2. Clique em **"New repository secret"**
3. Nome: `OPENAI_API_KEY`
4. Valor: sua chave de API

### 7.4 Adaptar o workflow ao seu projeto

Abra `.github/workflows/ai-review.yml` e personalize:

```yaml
# Altere a instrucao para o review do seu projeto
run: |
  codex --approval-mode suggest \
    "Revise este PR buscando:
    1. Bugs e erros logicos
    2. Problemas de seguranca
    3. Violacoes das convencoes do AGENTS.md
    4. Oportunidades de melhoria de performance"
```

### 7.5 Testar o workflow

```bash
# Criar um PR de teste
git checkout -b test/codex-integration
echo "// teste" >> src/index.js
git add .
git commit -m "test: testar integracao com Codex"
git push origin test/codex-integration
# Abrir PR no GitHub e observar o workflow rodar
```

### 7.6 Usos avancados de CI/CD

**Review automatico de PR:**
```yaml
run: codex --approval-mode suggest "revise este PR para bugs e melhorias"
```

**Geracao automatica de changelog:**
```yaml
run: codex --approval-mode auto-edit "gere um CHANGELOG.md baseado nos commits desde a ultima tag"
```

**Verificacao de cobertura de testes:**
```yaml
run: codex --approval-mode full-auto "identifique funcoes sem testes e crie testes unitarios basicos"
```

**Checkpoint:** Voce tem um workflow de GitHub Actions funcionando que usa o Codex.

---

## Passo 8 — Desafio final: pipeline de desenvolvimento autonomo

**Tempo estimado:** 3 horas

Este e o passo final — e o mais avancado. Voce vai construir um pipeline onde o Codex executa um ciclo completo de desenvolvimento com minima intervencao humana.

### 8.1 O desafio

Implemente uma feature completa usando o seguinte pipeline:

```
Requisito em linguagem natural
    ↓ [Codex — modo suggest]
Plano de implementacao aprovado
    ↓ [Codex — modo auto-edit]
Codigo escrito e refatorado
    ↓ [Codex — modo full-auto]
Testes gerados e executados
    ↓ [Review humano]
PR criado e aprovado
```

### 8.2 Feature para implementar

Escolha uma dessas features para o seu projeto de exemplo:

**Opcao A (facil):** Endpoint de busca com filtros
```
"Implemente um endpoint GET /api/tasks/search que aceita
os parametros: q (texto), status, priority, dueDate.
Inclua validacao de input, paginacao e testes."
```

**Opcao B (media):** Sistema de notificacoes
```
"Crie um sistema de notificacoes em tempo real usando
Server-Sent Events (SSE) para notificar o usuario quando
uma tarefa e atribuida a ele."
```

**Opcao C (avancada):** Cache inteligente
```
"Implemente uma camada de cache Redis para os endpoints
mais acessados. O cache deve ser invalidado automaticamente
quando os dados relevantes sao modificados."
```

### 8.3 Executar o pipeline

**Fase 1 — Planejamento (20 min):**
```bash
codex --approval-mode suggest "Quero implementar [FEATURE ESCOLHIDA].
Crie um plano detalhado de implementacao com:
- Arquivos a criar/modificar
- Ordem de implementacao
- Pontos de atencao e riscos
- Estimativa de linhas de codigo"
```

Revise o plano e decida se esta de acordo. Ajuste se necessario.

**Fase 2 — Implementacao (1h):**
```bash
# Criar branch
git checkout -b feature/[nome-da-feature]

# Deixar o agente implementar
codex --approval-mode auto-edit "Implemente [FEATURE] conforme o plano aprovado.
Siga todas as convencoes do AGENTS.md."
```

Revise cada mudanca com `git diff` antes de continuar.

**Fase 3 — Testes (40 min):**
```bash
codex --approval-mode full-auto "
1. Rode os testes existentes e confirme que nao quebramos nada
2. Gere testes unitarios para o codigo novo
3. Gere testes de integracao para os endpoints novos
4. Verifique se a cobertura atingiu 80%"
```

**Fase 4 — Documentacao (20 min):**
```bash
codex --approval-mode auto-edit "
Atualize a documentacao:
1. Adicione os novos endpoints ao Swagger (se existir)
2. Atualize o README com as novas funcionalidades
3. Adicione comentarios JSDoc nas funcoes publicas novas"
```

**Fase 5 — Review e PR (40 min):**
```bash
# Revisar tudo
git diff main

# Rodar testes finais
npm test
npm run lint

# Criar PR
git push origin feature/[nome-da-feature]
# Abrir PR no GitHub com descricao do que foi implementado
```

### 8.4 Reflexao pos-desafio

Ao terminar, documente suas aprendizagens:

- Onde o agente foi mais util?
- Onde o agente errou e precisou de correcao humana?
- O AGENTS.md precisa de atualizacoes?
- Qual seria o proximo passo para automatizar mais?

### 8.5 Indo alem

Apos completar o desafio, experimente:

```bash
# Multi-agente: um agente planeja, outro implementa
codex "crie um plano detalhado para refatorar o modulo X" > plano.md
codex --approval-mode auto-edit "implemente o plano em plano.md"

# Revisao de seguranca automatica
codex --approval-mode suggest "faca uma auditoria de seguranca completa e liste vulnerabilidades"

# Atualizacao de dependencias segura
codex --approval-mode full-auto "atualize as dependencias desatualizadas, rodando os testes apos cada atualizacao"
```

---

## Resumo e proximos passos

Parabens! Ao completar este roteiro, voce aprendeu a:

- [x] Instalar e configurar o Codex CLI
- [x] Criar um AGENTS.md eficaz para dar contexto ao agente
- [x] Usar os 3 modos de aprovacao de forma estrategica
- [x] Integrar o Codex em pipelines de CI/CD com GitHub Actions
- [x] Executar um ciclo completo de desenvolvimento agentico

**Proximos projetos recomendados:**
- Projeto 5: Multi-agente com CrewAI
- Projeto 6: Agente com ferramentas customizadas (MCP)
- Projeto 7: Monitoramento e observabilidade de agentes

---

*Parte do curso de desenvolvimento agentico — Projeto 4 de 8*
