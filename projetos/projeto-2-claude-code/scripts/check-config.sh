#!/usr/bin/env bash
# =============================================================================
# Script de verificação da configuração do Claude Code
# =============================================================================
# Uso: ./scripts/check-config.sh [--dir /caminho/do/projeto]
# Sem argumentos: verifica o diretório atual
# =============================================================================

# Cores para terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Contadores de resultados
PASSOU=0
FALHOU=0
AVISOS=0

# -----------------------------------------------------------------------------
# Funções de verificação
# -----------------------------------------------------------------------------

# Imprimir resultado de verificação com cor
verificacao_ok() {
    local MENSAGEM="$1"
    echo -e "  ${GREEN}[PASSOU]${RESET} $MENSAGEM"
    PASSOU=$((PASSOU + 1))
}

verificacao_falhou() {
    local MENSAGEM="$1"
    local DICA="${2:-}"
    echo -e "  ${RED}[FALHOU]${RESET} $MENSAGEM"
    if [ -n "$DICA" ]; then
        echo -e "           ${YELLOW}Dica:${RESET} $DICA"
    fi
    FALHOU=$((FALHOU + 1))
}

verificacao_aviso() {
    local MENSAGEM="$1"
    local DICA="${2:-}"
    echo -e "  ${YELLOW}[AVISO]${RESET}  $MENSAGEM"
    if [ -n "$DICA" ]; then
        echo -e "           ${YELLOW}Dica:${RESET} $DICA"
    fi
    AVISOS=$((AVISOS + 1))
}

secao() {
    echo ""
    echo -e "${BOLD}${CYAN}>>> $1${RESET}"
    echo ""
}

# -----------------------------------------------------------------------------
# Processar argumentos
# -----------------------------------------------------------------------------

TARGET_DIR="$(pwd)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir|-d)
            TARGET_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Uso: $0 [--dir /caminho/do/projeto]"
            echo ""
            echo "Opções:"
            echo "  --dir, -d   Diretório do projeto (padrão: diretório atual)"
            echo "  --help, -h  Exibe esta ajuda"
            exit 0
            ;;
        *)
            echo -e "${RED}[ERRO]${RESET} Argumento desconhecido: $1"
            exit 1
            ;;
    esac
done

TARGET_DIR="$(realpath "$TARGET_DIR")"

# -----------------------------------------------------------------------------
# Banner
# -----------------------------------------------------------------------------

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║       Verificação de Configuração — Claude Code      ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Verificando: ${BOLD}$TARGET_DIR${RESET}"

# -----------------------------------------------------------------------------
# Seção 1: Pré-requisitos do sistema
# -----------------------------------------------------------------------------

secao "Pré-requisitos do sistema"

# Verificar Node.js
if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 18 ]; then
        verificacao_ok "Node.js $NODE_VERSION (>= 18)"
    else
        verificacao_aviso "Node.js $NODE_VERSION encontrado, mas versão recomendada é 18+" \
            "Atualize: nvm install 20 && nvm use 20"
    fi
else
    verificacao_falhou "Node.js não instalado" \
        "Instale em: https://nodejs.org"
fi

# Verificar Claude Code
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "versão desconhecida")
    verificacao_ok "Claude Code instalado ($CLAUDE_VERSION)"
else
    verificacao_falhou "Claude Code não encontrado" \
        "Instale: npm install -g @anthropic-ai/claude-code"
fi

# Verificar gh CLI
if command -v gh &>/dev/null; then
    GH_VERSION=$(gh --version | head -1 | awk '{print $3}')
    verificacao_ok "GitHub CLI (gh) $GH_VERSION instalado"

    # Verificar autenticação do gh
    if gh auth status &>/dev/null 2>&1; then
        verificacao_ok "GitHub CLI autenticado"
    else
        verificacao_aviso "GitHub CLI não autenticado" \
            "Execute: gh auth login"
    fi
else
    verificacao_aviso "GitHub CLI (gh) não instalado — necessário para skills de issue/PR" \
        "Instale: sudo apt install gh  ou  brew install gh"
fi

# -----------------------------------------------------------------------------
# Seção 2: Estrutura de arquivos .claude
# -----------------------------------------------------------------------------

secao "Estrutura de arquivos .claude"

# Verificar diretório .claude
if [ -d "$TARGET_DIR/.claude" ]; then
    verificacao_ok "Diretório .claude/ existe"
else
    verificacao_falhou "Diretório .claude/ não encontrado" \
        "Execute o script de setup: ./scripts/setup.sh"
fi

# Verificar settings.json — existência
SETTINGS_FILE="$TARGET_DIR/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    verificacao_ok ".claude/settings.json existe"

    # Verificar se é um JSON válido
    JSON_VALIDO=false
    if command -v python3 &>/dev/null; then
        if python3 -m json.tool "$SETTINGS_FILE" &>/dev/null 2>&1; then
            JSON_VALIDO=true
        fi
    elif command -v node &>/dev/null; then
        if node -e "JSON.parse(require('fs').readFileSync('$SETTINGS_FILE', 'utf8'))" &>/dev/null 2>&1; then
            JSON_VALIDO=true
        fi
    fi

    if [ "$JSON_VALIDO" = true ]; then
        verificacao_ok ".claude/settings.json é um JSON válido"
    else
        verificacao_falhou ".claude/settings.json contém JSON inválido" \
            "Valide em: python3 -m json.tool .claude/settings.json"
    fi

    # Verificar se tem seção de permissions
    if command -v python3 &>/dev/null; then
        HAS_PERMISSIONS=$(python3 -c "
import json, sys
try:
    data = json.load(open('$SETTINGS_FILE'))
    print('sim' if 'permissions' in data else 'nao')
except:
    print('erro')
" 2>/dev/null)
        if [ "$HAS_PERMISSIONS" = "sim" ]; then
            verificacao_ok "settings.json tem seção 'permissions' configurada"
        else
            verificacao_aviso "settings.json não tem seção 'permissions'" \
                "Adicione allow/deny de comandos para maior controle"
        fi
    fi
else
    verificacao_falhou ".claude/settings.json não encontrado" \
        "Copie o template: cp /caminho/template/.claude/settings.json .claude/"
fi

# Verificar diretório de skills
if [ -d "$TARGET_DIR/.claude/skills" ]; then
    verificacao_ok "Diretório .claude/skills/ existe"

    # Contar skills disponíveis
    SKILL_COUNT=$(find "$TARGET_DIR/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l)
    if [ "$SKILL_COUNT" -gt 0 ]; then
        verificacao_ok "$SKILL_COUNT skill(s) encontrada(s) em .claude/skills/"
        # Listar skills
        while IFS= read -r SKILL_FILE; do
            SKILL_NAME=$(basename "$(dirname "$SKILL_FILE")")
            echo -e "           ${BLUE}/${SKILL_NAME}${RESET}"
        done < <(find "$TARGET_DIR/.claude/skills" -name "SKILL.md" 2>/dev/null | sort)
    else
        verificacao_aviso "Nenhuma skill encontrada em .claude/skills/" \
            "Adicione skills em .claude/skills/<nome-da-skill>/SKILL.md"
    fi
else
    verificacao_aviso "Diretório .claude/skills/ não encontrado" \
        "Crie: mkdir -p .claude/skills"
fi

# -----------------------------------------------------------------------------
# Seção 3: CLAUDE.md
# -----------------------------------------------------------------------------

secao "Arquivo CLAUDE.md"

CLAUDE_MD="$TARGET_DIR/CLAUDE.md"

# Verificar existência
if [ -f "$CLAUDE_MD" ]; then
    verificacao_ok "CLAUDE.md existe"

    # Verificar tamanho mínimo (mais de 100 bytes)
    FILE_SIZE=$(wc -c < "$CLAUDE_MD")
    if [ "$FILE_SIZE" -gt 100 ]; then
        verificacao_ok "CLAUDE.md tem conteúdo substancial ($FILE_SIZE bytes)"
    else
        verificacao_falhou "CLAUDE.md tem menos de 100 bytes ($FILE_SIZE bytes) — provavelmente vazio" \
            "Edite o CLAUDE.md com o contexto completo do seu projeto"
    fi

    # Verificar se tem as seções principais
    SECOES_ESPERADAS=(
        "## Contexto"
        "## Comandos"
        "## Regras"
    )

    for SECAO_ESPERADA in "${SECOES_ESPERADAS[@]}"; do
        if grep -qi "$SECAO_ESPERADA" "$CLAUDE_MD" 2>/dev/null; then
            verificacao_ok "CLAUDE.md tem seção: $SECAO_ESPERADA"
        else
            verificacao_aviso "CLAUDE.md não tem seção: $SECAO_ESPERADA" \
                "Adicione esta seção para melhor contexto"
        fi
    done

    # Verificar se ainda tem conteúdo genérico do template
    if grep -qi "seu-projeto\|your-project\|meu-projeto" "$CLAUDE_MD" 2>/dev/null; then
        verificacao_aviso "CLAUDE.md pode ter conteúdo genérico de template não customizado" \
            "Revise e substitua os placeholders pelo contexto real do seu projeto"
    fi
else
    verificacao_falhou "CLAUDE.md não encontrado" \
        "Crie o CLAUDE.md na raiz do projeto. Use o template mínimo: cp exemplos/CLAUDE.md.minimal CLAUDE.md"
fi

# -----------------------------------------------------------------------------
# Seção 4: Variáveis de ambiente
# -----------------------------------------------------------------------------

secao "Variáveis de ambiente"

# Verificar ANTHROPIC_API_KEY
if [ -n "$ANTHROPIC_API_KEY" ]; then
    KEY_LEN=${#ANTHROPIC_API_KEY}
    KEY_PREVIEW="${ANTHROPIC_API_KEY:0:12}..."
    if [ "$KEY_LEN" -gt 20 ]; then
        verificacao_ok "ANTHROPIC_API_KEY configurada no ambiente ($KEY_PREVIEW)"
    else
        verificacao_aviso "ANTHROPIC_API_KEY parece muito curta ($KEY_LEN caracteres)" \
            "Verifique se a chave está completa"
    fi
else
    # Verificar se está no .env
    if [ -f "$TARGET_DIR/.env" ] && grep -q "ANTHROPIC_API_KEY" "$TARGET_DIR/.env"; then
        verificacao_aviso "ANTHROPIC_API_KEY encontrada no .env mas não exportada para o ambiente" \
            "Execute: export ANTHROPIC_API_KEY=\$(grep ANTHROPIC_API_KEY .env | cut -d= -f2)"
    else
        verificacao_falhou "ANTHROPIC_API_KEY não configurada" \
            "Configure: export ANTHROPIC_API_KEY='sk-ant-...'"
    fi
fi

# Verificar .gitignore
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if grep -q "\.env" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        verificacao_ok ".env está no .gitignore (credenciais protegidas)"
    else
        verificacao_aviso ".env NÃO está no .gitignore" \
            "Execute: echo '.env' >> .gitignore"
    fi
else
    verificacao_aviso ".gitignore não encontrado" \
        "Crie um .gitignore para evitar commitar arquivos sensíveis"
fi

# -----------------------------------------------------------------------------
# Resumo final
# -----------------------------------------------------------------------------

echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  Resultado da verificação:"
echo ""
echo -e "    ${GREEN}Passou:${RESET}  $PASSOU verificação(ões)"
echo -e "    ${YELLOW}Avisos:${RESET}  $AVISOS aviso(s)"
echo -e "    ${RED}Falhou:${RESET}  $FALHOU verificação(ões)"
echo ""

# Determinar status geral
if [ "$FALHOU" -eq 0 ] && [ "$AVISOS" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}Configuracao perfeita! Claude Code pronto para uso.${RESET}"
    echo ""
    echo -e "  Inicie com: ${BOLD}claude${RESET}"
elif [ "$FALHOU" -eq 0 ]; then
    echo -e "  ${YELLOW}${BOLD}Configuracao funcional com avisos. Revise os avisos acima.${RESET}"
    echo ""
    echo -e "  Inicie com: ${BOLD}claude${RESET}"
else
    echo -e "  ${RED}${BOLD}Ha problemas que precisam ser corrigidos antes de usar o Claude Code.${RESET}"
    echo ""
    echo -e "  Corrija os itens marcados como ${RED}[FALHOU]${RESET} e execute este script novamente."
fi

echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Retornar código de saída baseado em falhas
if [ "$FALHOU" -gt 0 ]; then
    exit 1
else
    exit 0
fi
