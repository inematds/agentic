#!/usr/bin/env bash
# =============================================================================
# setup-mcp.sh — Instala os servidores MCP para uso com o Antigravity
# =============================================================================
#
# Uso:
#   chmod +x scripts/setup-mcp.sh
#   ./scripts/setup-mcp.sh
#
# O que este script faz:
#   - Verifica pre-requisitos (Node.js, npm)
#   - Instala @modelcontextprotocol/server-filesystem globalmente
#   - Instala @modelcontextprotocol/server-github globalmente
#   - Verifica se as instalacoes foram bem-sucedidas
#   - Exibe instrucoes para configurar o GITHUB_TOKEN
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Cores para output no terminal
# -----------------------------------------------------------------------------
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NEGRITO='\033[1m'
SEM_COR='\033[0m'

# -----------------------------------------------------------------------------
# Funcoes auxiliares
# -----------------------------------------------------------------------------
info() {
    echo -e "${AZUL}[INFO]${SEM_COR} $1"
}

sucesso() {
    echo -e "${VERDE}[OK]${SEM_COR}   $1"
}

aviso() {
    echo -e "${AMARELO}[AVISO]${SEM_COR} $1"
}

erro() {
    echo -e "${VERMELHO}[ERRO]${SEM_COR}  $1"
}

titulo() {
    echo ""
    echo -e "${NEGRITO}${AZUL}========================================${SEM_COR}"
    echo -e "${NEGRITO}${AZUL}  $1${SEM_COR}"
    echo -e "${NEGRITO}${AZUL}========================================${SEM_COR}"
    echo ""
}

separador() {
    echo -e "${AZUL}----------------------------------------${SEM_COR}"
}

# -----------------------------------------------------------------------------
# Banner inicial
# -----------------------------------------------------------------------------
clear
echo ""
echo -e "${NEGRITO}${AZUL}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Setup MCP — Projeto 3 Antigravity  ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${SEM_COR}"
echo "  Instalando servidores Model Context Protocol"
echo "  para uso com o Antigravity IDE do Google."
echo ""

# -----------------------------------------------------------------------------
# Passo 1 — Verificar pre-requisitos
# -----------------------------------------------------------------------------
titulo "Passo 1 — Verificando pre-requisitos"

# Verificar Node.js
info "Verificando Node.js..."
if ! command -v node &> /dev/null; then
    erro "Node.js nao encontrado."
    echo ""
    echo "  Instale o Node.js 20 LTS antes de continuar:"
    echo "  https://nodejs.org"
    echo ""
    exit 1
fi

NODE_VERSION=$(node --version)
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1 | tr -d 'v')

if [ "$NODE_MAJOR" -lt 18 ]; then
    erro "Node.js $NODE_VERSION encontrado, mas a versao minima e 18."
    echo ""
    echo "  Atualize o Node.js em: https://nodejs.org"
    echo "  Ou use o nvm: https://github.com/nvm-sh/nvm"
    echo ""
    exit 1
fi

sucesso "Node.js $NODE_VERSION encontrado (minimo: 18)"

# Verificar npm
info "Verificando npm..."
if ! command -v npm &> /dev/null; then
    erro "npm nao encontrado. Ele deveria ter sido instalado junto com o Node.js."
    exit 1
fi

NPM_VERSION=$(npm --version)
sucesso "npm $NPM_VERSION encontrado"

# Verificar npx
info "Verificando npx..."
if ! command -v npx &> /dev/null; then
    aviso "npx nao encontrado. Instalando..."
    npm install -g npx
fi
sucesso "npx disponivel"

separador

# -----------------------------------------------------------------------------
# Passo 2 — Instalar servidor MCP de filesystem
# -----------------------------------------------------------------------------
titulo "Passo 2 — Instalando servidor MCP: filesystem"

info "Instalando @modelcontextprotocol/server-filesystem..."
echo ""

if npm install -g @modelcontextprotocol/server-filesystem; then
    echo ""
    sucesso "Servidor filesystem instalado com sucesso"
else
    echo ""
    erro "Falha ao instalar o servidor filesystem."
    echo ""
    echo "  Possiveis causas:"
    echo "  - Sem permissao para instalar pacotes globais"
    echo "    Solucao: sudo npm install -g @modelcontextprotocol/server-filesystem"
    echo "  - Sem conexao com a internet"
    echo "  - Registro npm indisponivel"
    echo ""
    exit 1
fi

separador

# -----------------------------------------------------------------------------
# Passo 3 — Instalar servidor MCP do GitHub
# -----------------------------------------------------------------------------
titulo "Passo 3 — Instalando servidor MCP: GitHub"

info "Instalando @modelcontextprotocol/server-github..."
echo ""

if npm install -g @modelcontextprotocol/server-github; then
    echo ""
    sucesso "Servidor GitHub instalado com sucesso"
else
    echo ""
    erro "Falha ao instalar o servidor GitHub."
    echo ""
    echo "  Execute manualmente:"
    echo "  npm install -g @modelcontextprotocol/server-github"
    echo ""
    exit 1
fi

separador

# -----------------------------------------------------------------------------
# Passo 4 — Verificar instalacoes
# -----------------------------------------------------------------------------
titulo "Passo 4 — Verificando instalacoes"

TODAS_OK=true

# Verificar servidor filesystem
info "Verificando servidor filesystem..."
if npm list -g @modelcontextprotocol/server-filesystem --depth=0 &> /dev/null; then
    VERSAO_FS=$(npm list -g @modelcontextprotocol/server-filesystem --depth=0 2>/dev/null | grep "server-filesystem" | awk -F@ '{print $NF}' | tr -d ' ')
    sucesso "server-filesystem@${VERSAO_FS:-instalado}"
else
    erro "server-filesystem NAO encontrado na instalacao global"
    TODAS_OK=false
fi

# Verificar servidor GitHub
info "Verificando servidor GitHub..."
if npm list -g @modelcontextprotocol/server-github --depth=0 &> /dev/null; then
    VERSAO_GH=$(npm list -g @modelcontextprotocol/server-github --depth=0 2>/dev/null | grep "server-github" | awk -F@ '{print $NF}' | tr -d ' ')
    sucesso "server-github@${VERSAO_GH:-instalado}"
else
    erro "server-github NAO encontrado na instalacao global"
    TODAS_OK=false
fi

separador

# -----------------------------------------------------------------------------
# Passo 5 — Configurar GITHUB_TOKEN
# -----------------------------------------------------------------------------
titulo "Passo 5 — Configuracao do GITHUB_TOKEN"

if [ -f ".env" ] && grep -q "GITHUB_TOKEN" .env 2>/dev/null; then
    sucesso "GITHUB_TOKEN ja configurado no arquivo .env"
else
    aviso "GITHUB_TOKEN nao configurado."
    echo ""
    echo "  O servidor MCP do GitHub precisa de um token de acesso pessoal."
    echo ""
    echo "  Como gerar:"
    echo "  1. Acesse: https://github.com/settings/tokens"
    echo "  2. Clique em 'Generate new token (classic)'"
    echo "  3. Selecione as permissoes: repo, read:user"
    echo "  4. Copie o token gerado"
    echo ""
    echo "  Como configurar:"
    echo "  Adicione ao arquivo .env na raiz do projeto:"
    echo ""
    echo -e "  ${AMARELO}GITHUB_TOKEN=ghp_seu_token_aqui${SEM_COR}"
    echo ""

    # Verificar se .env existe
    if [ ! -f ".env" ]; then
        info "Criando arquivo .env de exemplo..."
        cat > .env.exemplo << 'EOF'
# Arquivo de variaveis de ambiente — NUNCA commite este arquivo
# Copie para .env e preencha os valores reais

# GitHub — Token de acesso pessoal
# Gere em: https://github.com/settings/tokens
GITHUB_TOKEN=ghp_seu_token_aqui

# Google Cloud — Credenciais para deploy
GOOGLE_APPLICATION_CREDENTIALS=./chave-deploy.json
GOOGLE_CLOUD_PROJECT=seu-projeto-id

# Banco de dados
DATABASE_URL=postgresql://usuario:senha@localhost:5432/nome_banco

# Redis
REDIS_URL=redis://localhost:6379

# Google OAuth
GOOGLE_CLIENT_ID=seu-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=seu-client-secret

# JWT
JWT_SECRET=uma-chave-secreta-com-pelo-menos-32-caracteres-aqui
EOF
        sucesso "Arquivo .env.exemplo criado — copie para .env e preencha os valores"
    fi

    # Verificar se .gitignore inclui .env
    if [ -f ".gitignore" ]; then
        if grep -q "^\.env$" .gitignore 2>/dev/null; then
            sucesso ".env ja esta no .gitignore"
        else
            echo ".env" >> .gitignore
            echo ".env.local" >> .gitignore
            echo ".env.*.local" >> .gitignore
            sucesso ".env adicionado ao .gitignore"
        fi
    else
        aviso ".gitignore nao encontrado. Certifique-se de nao commitar o arquivo .env"
    fi
fi

separador

# -----------------------------------------------------------------------------
# Resultado final
# -----------------------------------------------------------------------------
titulo "Resultado"

if [ "$TODAS_OK" = true ]; then
    echo -e "${VERDE}${NEGRITO}"
    echo "  Instalacao concluida com sucesso!"
    echo -e "${SEM_COR}"
    echo "  Proximos passos:"
    echo ""
    echo "  1. Configure o GITHUB_TOKEN no arquivo .env (se ainda nao fez)"
    echo "  2. Abra o Antigravity e acesse Settings > MCP Servers"
    echo "  3. Verifique se os servidores 'filesystem' e 'github' aparecem conectados"
    echo "  4. Clique em 'Test Connection' em cada servidor para confirmar"
    echo ""
    echo "  Documentacao MCP: https://modelcontextprotocol.io"
    echo "  Antigravity: https://g.co/antigravity"
    echo ""
else
    echo -e "${VERMELHO}${NEGRITO}"
    echo "  Instalacao concluida com erros."
    echo -e "${SEM_COR}"
    echo "  Verifique as mensagens de erro acima e tente novamente."
    echo "  Se o problema persistir, instale manualmente:"
    echo ""
    echo "  npm install -g @modelcontextprotocol/server-filesystem"
    echo "  npm install -g @modelcontextprotocol/server-github"
    echo ""
    exit 1
fi
