#!/usr/bin/env bash
# =============================================================================
# Setup do Projeto Codex CLI
# =============================================================================
# Verifica dependencias, instala o Codex CLI e configura o ambiente.
# Uso: bash scripts/setup.sh
# =============================================================================

set -e  # Interrompe o script em caso de erro

# ---------------------------------------------------------------------------
# Cores para output
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Funcoes utilitarias
# ---------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}============================================${RESET}"
    echo -e "${CYAN}${BOLD}  $1${RESET}"
    echo -e "${CYAN}${BOLD}============================================${RESET}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[PASSO]${RESET} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${RESET} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${RESET} $1"
}

print_info() {
    echo -e "  ${CYAN}→${RESET} $1"
}

# Verifica se um comando existe no PATH
command_exists() {
    command -v "$1" &>/dev/null
}

# ---------------------------------------------------------------------------
# Inicio do script
# ---------------------------------------------------------------------------

print_header "Configurando Codex CLI"
echo -e "  Sistema: $(uname -s) $(uname -m)"
echo -e "  Data:    $(date '+%d/%m/%Y %H:%M')"
echo ""

# ---------------------------------------------------------------------------
# Passo 1: Verificar Node.js versao >= 18
# ---------------------------------------------------------------------------

print_step "Verificando Node.js..."

if ! command_exists node; then
    print_error "Node.js nao encontrado no PATH."
    echo ""
    echo -e "  Por favor, instale o Node.js 18 ou superior:"
    echo -e "  ${CYAN}https://nodejs.org${RESET}"
    echo ""
    echo -e "  Instalacao rapida com nvm:"
    print_info "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
    print_info "source ~/.bashrc"
    print_info "nvm install 20"
    echo ""
    exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

if [ "$NODE_MAJOR" -lt 18 ]; then
    print_error "Node.js versao $NODE_VERSION encontrada, mas a versao minima e 18."
    echo ""
    print_info "Atualize com: nvm install 20 && nvm use 20"
    echo ""
    exit 1
fi

print_success "Node.js v$NODE_VERSION (>= 18) — OK"

# ---------------------------------------------------------------------------
# Passo 2: Verificar npm
# ---------------------------------------------------------------------------

print_step "Verificando npm..."

if ! command_exists npm; then
    print_error "npm nao encontrado. Reinstale o Node.js."
    exit 1
fi

NPM_VERSION=$(npm --version)
print_success "npm v$NPM_VERSION — OK"

# ---------------------------------------------------------------------------
# Passo 3: Instalar @openai/codex globalmente (se nao instalado)
# ---------------------------------------------------------------------------

print_step "Verificando instalacao do Codex CLI..."

if command_exists codex; then
    CODEX_VERSION=$(codex --version 2>/dev/null || echo "desconhecida")
    print_success "Codex CLI ja instalado (versao: $CODEX_VERSION) — pulando instalacao"
else
    print_info "Codex CLI nao encontrado. Instalando globalmente..."
    echo ""

    if npm install -g @openai/codex; then
        print_success "Codex CLI instalado com sucesso!"
        CODEX_VERSION=$(codex --version 2>/dev/null || echo "desconhecida")
        print_info "Versao instalada: $CODEX_VERSION"
    else
        print_error "Falha ao instalar o Codex CLI."
        echo ""
        echo -e "  Tente manualmente:"
        print_info "sudo npm install -g @openai/codex"
        echo ""
        exit 1
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# Passo 4: Verificar OPENAI_API_KEY no ambiente
# ---------------------------------------------------------------------------

print_step "Verificando variavel de ambiente OPENAI_API_KEY..."

if [ -z "${OPENAI_API_KEY}" ]; then
    print_warning "OPENAI_API_KEY nao definida no ambiente."
    echo ""
    echo -e "  Para obter sua API key:"
    print_info "Acesse: https://platform.openai.com/api-keys"
    print_info "Clique em 'Create new secret key'"
    print_info "Copie a chave (comeca com 'sk-')"
    echo ""
    echo -e "  Para configurar permanentemente:"
    print_info "echo 'export OPENAI_API_KEY=\"sk-...\"' >> ~/.bashrc"
    print_info "source ~/.bashrc"
    echo ""
    API_KEY_CONFIGURED=false
else
    # Mostra apenas os primeiros e ultimos caracteres por seguranca
    KEY_START="${OPENAI_API_KEY:0:7}"
    KEY_END="${OPENAI_API_KEY: -4}"
    print_success "OPENAI_API_KEY configurada: ${KEY_START}...${KEY_END}"
    API_KEY_CONFIGURED=true
fi

# ---------------------------------------------------------------------------
# Passo 5: Criar .env se nao existir
# ---------------------------------------------------------------------------

print_step "Verificando arquivo .env..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"
ENV_EXAMPLE="$PROJECT_DIR/.env.example"

if [ -f "$ENV_FILE" ]; then
    print_success "Arquivo .env ja existe — nao sobrescrevendo"
else
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        print_success "Arquivo .env criado a partir do .env.example"
        print_info "Edite o arquivo $ENV_FILE e adicione suas chaves reais"
    else
        print_warning "Arquivo .env.example nao encontrado — criando .env basico"
        cat > "$ENV_FILE" <<'ENVFILE'
# Configuracao do Codex CLI
# Obtida em: https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-substitua-pela-sua-chave-aqui

# Nivel de log: debug | info | warn | error
CODEX_LOG_LEVEL=info
ENVFILE
        print_info "Arquivo $ENV_FILE criado. Edite e adicione sua API key."
    fi
fi

# ---------------------------------------------------------------------------
# Passo 6: Verificar existencia dos arquivos de configuracao do Codex
# ---------------------------------------------------------------------------

print_step "Verificando arquivos de configuracao do Codex..."

CODEX_DIR="$PROJECT_DIR/.codex"
CODEX_CONFIG="$CODEX_DIR/config.toml"

if [ -f "$CODEX_CONFIG" ]; then
    print_success "Arquivo .codex/config.toml encontrado"
else
    print_warning ".codex/config.toml nao encontrado"
    print_info "Crie o arquivo com: mkdir -p .codex && nano .codex/config.toml"
fi

if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
    print_success "AGENTS.md encontrado — o Codex vai usar automaticamente"
else
    print_warning "AGENTS.md nao encontrado no diretorio raiz"
    print_info "Crie um AGENTS.md para dar contexto ao agente (ver template no projeto)"
fi

# ---------------------------------------------------------------------------
# Resumo e instrucoes de uso
# ---------------------------------------------------------------------------

echo ""
print_header "Setup concluido!"

echo -e "  ${BOLD}Status das verificacoes:${RESET}"
echo ""
echo -e "  Node.js v$NODE_VERSION          ${GREEN}[OK]${RESET}"
echo -e "  npm v$NPM_VERSION               ${GREEN}[OK]${RESET}"
echo -e "  Codex CLI                   ${GREEN}[OK]${RESET}"
if [ "$API_KEY_CONFIGURED" = true ]; then
    echo -e "  OPENAI_API_KEY              ${GREEN}[OK]${RESET}"
else
    echo -e "  OPENAI_API_KEY              ${YELLOW}[PENDENTE]${RESET}"
fi
echo ""

if [ "$API_KEY_CONFIGURED" = false ]; then
    echo -e "${YELLOW}${BOLD}ATENCAO:${RESET} Configure a OPENAI_API_KEY antes de continuar."
    echo ""
fi

echo -e "  ${BOLD}Como usar o Codex CLI:${RESET}"
echo ""
echo -e "  ${CYAN}# Modo interativo (conversa com o agente)${RESET}"
print_info "codex"
echo ""
echo -e "  ${CYAN}# Modo suggest (so sugestoes, sem alteracoes)${RESET}"
print_info "codex --approval-mode suggest 'revise o codigo de auth'"
echo ""
echo -e "  ${CYAN}# Modo auto-edit (edita arquivos, pede aprovacao para comandos)${RESET}"
print_info "codex --approval-mode auto-edit 'adicione tratamento de erro'"
echo ""
echo -e "  ${CYAN}# Modo headless (totalmente autonomo — use com cuidado)${RESET}"
print_info "bash scripts/run-headless.sh 'sua tarefa aqui'"
echo ""
echo -e "  ${BOLD}Proximos passos:${RESET}"
echo ""
print_info "Leia o ROTEIRO.md para guia passo a passo"
print_info "Personalize o AGENTS.md para o seu projeto"
print_info "Experimente: codex 'explique a estrutura deste projeto'"
echo ""
