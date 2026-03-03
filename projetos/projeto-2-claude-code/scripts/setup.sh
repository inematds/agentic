#!/usr/bin/env bash
# =============================================================================
# Script de setup para projetos com Claude Code
# =============================================================================
# Uso: ./scripts/setup.sh [--target /caminho/do/projeto]
# Sem argumentos: configura o diretório atual
# =============================================================================

set -e  # parar em caso de erro

# -----------------------------------------------------------------------------
# Cores para terminal
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# -----------------------------------------------------------------------------
# Funções utilitárias
# -----------------------------------------------------------------------------

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

sucesso() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

aviso() {
    echo -e "${YELLOW}[AVISO]${RESET} $1"
}

erro() {
    echo -e "${RED}[ERRO]${RESET} $1"
}

titulo() {
    echo ""
    echo -e "${BOLD}${CYAN}=== $1 ===${RESET}"
    echo ""
}

# -----------------------------------------------------------------------------
# Banner de boas-vindas
# -----------------------------------------------------------------------------

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║        Setup do Projeto com Claude Code              ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# -----------------------------------------------------------------------------
# Processar argumentos
# -----------------------------------------------------------------------------

TARGET_DIR="$(pwd)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target|-t)
            TARGET_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Uso: $0 [--target /caminho/do/projeto]"
            echo ""
            echo "Opções:"
            echo "  --target, -t   Diretório alvo (padrão: diretório atual)"
            echo "  --help,   -h   Exibe esta ajuda"
            exit 0
            ;;
        *)
            erro "Argumento desconhecido: $1"
            exit 1
            ;;
    esac
done

# Resolver caminho absoluto
TARGET_DIR="$(realpath "$TARGET_DIR")"
info "Diretório alvo: ${BOLD}${TARGET_DIR}${RESET}"

# Verificar se o diretório existe
if [ ! -d "$TARGET_DIR" ]; then
    erro "Diretório não encontrado: $TARGET_DIR"
    exit 1
fi

# Diretório onde este script está localizado (para copiar arquivos de template)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"

# -----------------------------------------------------------------------------
# Passo 1: Verificar dependências
# -----------------------------------------------------------------------------

titulo "Verificando dependências"

# Verificar Node.js
if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 18 ]; then
        sucesso "Node.js $NODE_VERSION encontrado"
    else
        aviso "Node.js $NODE_VERSION encontrado, mas a versão recomendada é 18+. Considere atualizar."
    fi
else
    erro "Node.js não encontrado. Instale em: https://nodejs.org"
    echo "  Sugestão de instalação via nvm:"
    echo "    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo "    nvm install 20"
    exit 1
fi

# Verificar npm
if command -v npm &>/dev/null; then
    NPM_VERSION=$(npm --version)
    sucesso "npm $NPM_VERSION encontrado"
else
    erro "npm não encontrado. Reinstale o Node.js de: https://nodejs.org"
    exit 1
fi

# Verificar Claude Code
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "versão desconhecida")
    sucesso "Claude Code encontrado ($CLAUDE_VERSION)"
else
    aviso "Claude Code não encontrado. Instalando..."
    echo ""
    info "Executando: npm install -g @anthropic-ai/claude-code"
    if npm install -g @anthropic-ai/claude-code; then
        sucesso "Claude Code instalado com sucesso"
    else
        erro "Falha ao instalar Claude Code"
        echo "  Tente instalar manualmente:"
        echo "    npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
fi

# Verificar gh CLI (opcional mas recomendado)
if command -v gh &>/dev/null; then
    GH_VERSION=$(gh --version | head -1)
    sucesso "GitHub CLI encontrado ($GH_VERSION)"
else
    aviso "GitHub CLI (gh) não encontrado — necessário para as skills de issue e PR"
    echo "  Instale em: https://cli.github.com"
    echo "  Ubuntu/Debian: sudo apt install gh"
    echo "  macOS: brew install gh"
fi

# -----------------------------------------------------------------------------
# Passo 2: Criar estrutura .claude no projeto alvo
# -----------------------------------------------------------------------------

titulo "Criando estrutura de diretórios"

# Criar diretórios necessários
DIRS=(
    "$TARGET_DIR/.claude"
    "$TARGET_DIR/.claude/skills"
    "$TARGET_DIR/.claude/skills/fix-issue"
    "$TARGET_DIR/.claude/skills/review-pr"
    "$TARGET_DIR/.claude/skills/write-tests"
)

for DIR in "${DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        sucesso "Criado: ${DIR#$TARGET_DIR/}"
    else
        info "Já existe: ${DIR#$TARGET_DIR/}"
    fi
done

# -----------------------------------------------------------------------------
# Passo 3: Copiar arquivos de configuração
# -----------------------------------------------------------------------------

titulo "Copiando arquivos de configuração"

# Função para copiar arquivo com verificação de sobrescrita
copiar_arquivo() {
    local ORIGEM="$1"
    local DESTINO="$2"
    local DESCRICAO="$3"

    if [ ! -f "$ORIGEM" ]; then
        aviso "Arquivo de template não encontrado: $ORIGEM"
        return
    fi

    if [ -f "$DESTINO" ]; then
        aviso "$DESCRICAO já existe. Pulando (use --force para sobrescrever)"
    else
        cp "$ORIGEM" "$DESTINO"
        sucesso "Copiado: $DESCRICAO"
    fi
}

# Copiar settings.json
copiar_arquivo \
    "$TEMPLATE_DIR/.claude/settings.json" \
    "$TARGET_DIR/.claude/settings.json" \
    ".claude/settings.json"

# Copiar skills
copiar_arquivo \
    "$TEMPLATE_DIR/.claude/skills/fix-issue/SKILL.md" \
    "$TARGET_DIR/.claude/skills/fix-issue/SKILL.md" \
    ".claude/skills/fix-issue/SKILL.md"

copiar_arquivo \
    "$TEMPLATE_DIR/.claude/skills/review-pr/SKILL.md" \
    "$TARGET_DIR/.claude/skills/review-pr/SKILL.md" \
    ".claude/skills/review-pr/SKILL.md"

copiar_arquivo \
    "$TEMPLATE_DIR/.claude/skills/write-tests/SKILL.md" \
    "$TARGET_DIR/.claude/skills/write-tests/SKILL.md" \
    ".claude/skills/write-tests/SKILL.md"

# Copiar CLAUDE.md (se não existir)
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    # Verificar se existe uma versão mínima para usar como ponto de partida
    if [ -f "$TEMPLATE_DIR/exemplos/CLAUDE.md.minimal" ]; then
        cp "$TEMPLATE_DIR/exemplos/CLAUDE.md.minimal" "$TARGET_DIR/CLAUDE.md"
        sucesso "CLAUDE.md criado a partir do template mínimo"
        aviso "Edite o CLAUDE.md para refletir o contexto do SEU projeto!"
    else
        aviso "CLAUDE.md não encontrado. Você precisará criar manualmente."
    fi
else
    info "CLAUDE.md já existe. Mantendo o arquivo atual."
fi

# -----------------------------------------------------------------------------
# Passo 4: Verificar ANTHROPIC_API_KEY
# -----------------------------------------------------------------------------

titulo "Verificando variáveis de ambiente"

# Verificar se a chave está no ambiente atual
if [ -n "$ANTHROPIC_API_KEY" ]; then
    KEY_PREVIEW="${ANTHROPIC_API_KEY:0:10}..."
    sucesso "ANTHROPIC_API_KEY encontrada no ambiente ($KEY_PREVIEW)"
else
    aviso "ANTHROPIC_API_KEY não encontrada no ambiente"

    # Verificar se existe um arquivo .env no diretório alvo
    if [ -f "$TARGET_DIR/.env" ]; then
        if grep -q "ANTHROPIC_API_KEY" "$TARGET_DIR/.env"; then
            info "ANTHROPIC_API_KEY encontrada no arquivo .env"
        else
            aviso "Arquivo .env existe mas não contém ANTHROPIC_API_KEY"
            echo "  Adicione ao .env:"
            echo "    ANTHROPIC_API_KEY=sk-ant-..."
        fi
    else
        echo ""
        echo "  Para configurar a chave de API, escolha uma opção:"
        echo ""
        echo "  Opção 1 — Variável de ambiente (recomendado):"
        echo "    export ANTHROPIC_API_KEY='sk-ant-...'"
        echo "    # Adicione ao ~/.bashrc ou ~/.zshrc para persistir"
        echo ""
        echo "  Opção 2 — Arquivo .env no projeto:"
        echo "    echo 'ANTHROPIC_API_KEY=sk-ant-...' >> $TARGET_DIR/.env"
        echo "    # Certifique-se de adicionar .env ao .gitignore!"
        echo ""
    fi
fi

# Verificar .gitignore para garantir que .env não seja commitado
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if grep -q "\.env" "$TARGET_DIR/.gitignore"; then
        sucesso ".env está no .gitignore"
    else
        aviso ".env NÃO está no .gitignore — risco de expor credenciais!"
        echo "  Adicione ao .gitignore: echo '.env' >> $TARGET_DIR/.gitignore"
    fi
else
    info ".gitignore não encontrado no projeto"
fi

# -----------------------------------------------------------------------------
# Passo 5: Verificar se a configuração está válida
# -----------------------------------------------------------------------------

titulo "Verificando configuração"

SETTINGS_FILE="$TARGET_DIR/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    if python3 -m json.tool "$SETTINGS_FILE" &>/dev/null 2>&1; then
        sucesso "settings.json é um JSON válido"
    elif node -e "require('$SETTINGS_FILE')" &>/dev/null 2>&1; then
        sucesso "settings.json é um JSON válido"
    else
        erro "settings.json não é um JSON válido! Verifique a sintaxe."
    fi
else
    aviso "settings.json não encontrado em .claude/"
fi

# -----------------------------------------------------------------------------
# Resumo final
# -----------------------------------------------------------------------------

titulo "Setup concluído"

echo -e "${GREEN}${BOLD}A estrutura do Claude Code foi configurada com sucesso!${RESET}"
echo ""
echo "Estrutura criada em: ${BOLD}$TARGET_DIR${RESET}"
echo ""
echo "Proximos passos:"
echo ""
echo -e "  ${CYAN}1.${RESET} Edite o ${BOLD}CLAUDE.md${RESET} com o contexto do seu projeto:"
echo "     Substitua os exemplos pela sua stack real (linguagem, framework, comandos)"
echo ""
echo -e "  ${CYAN}2.${RESET} Ajuste as permissões em ${BOLD}.claude/settings.json${RESET}:"
echo "     Configure quais comandos o Claude pode executar sem confirmação"
echo ""
echo -e "  ${CYAN}3.${RESET} Configure sua ${BOLD}ANTHROPIC_API_KEY${RESET}:"
echo "     export ANTHROPIC_API_KEY='sua-chave-aqui'"
echo ""
echo -e "  ${CYAN}4.${RESET} Inicie o Claude Code no seu projeto:"
echo "     cd $TARGET_DIR && claude"
echo ""
echo -e "  ${CYAN}5.${RESET} Experimente as skills disponíveis:"
echo "     /fix-issue 123"
echo "     /review-pr 45"
echo "     /write-tests caminho/do/arquivo.py"
echo ""
echo -e "${YELLOW}Dica:${RESET} Execute ${BOLD}./scripts/check-config.sh${RESET} a qualquer momento para verificar a configuração"
echo ""
