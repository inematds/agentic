#!/usr/bin/env bash
# =============================================================================
# Roda uma task com Codex CLI em modo headless (sem interacao humana)
# =============================================================================
# Uso: ./scripts/run-headless.sh "descricao da task"
#
# Exemplos:
#   ./scripts/run-headless.sh "revise o codigo de autenticacao e aponte problemas"
#   ./scripts/run-headless.sh "gere testes unitarios para src/modules/users/user.service.js"
#   ./scripts/run-headless.sh "atualize o README com os novos endpoints"
#
# Variaveis de ambiente opcionais:
#   CODEX_MODEL          Modelo a usar (default: gpt-4o)
#   CODEX_APPROVAL_MODE  Modo de aprovacao (default: full-auto)
#   CODEX_LOG_LEVEL      Nivel de log: debug | info | warn | error (default: info)
#   CODEX_OUTPUT_DIR     Diretorio para salvar logs (default: ./logs/codex)
# =============================================================================

set -e

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

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[AVISO]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${RESET} $1" >&2
}

usage() {
    echo ""
    echo -e "${BOLD}Uso:${RESET}"
    echo "  $(basename "$0") \"descricao da task\""
    echo ""
    echo -e "${BOLD}Exemplos:${RESET}"
    echo "  $(basename "$0") \"revise o codigo de autenticacao e aponte problemas\""
    echo "  $(basename "$0") \"gere testes para o UserService\""
    echo "  $(basename "$0") \"refatore a funcao parseDate para usar date-fns\""
    echo ""
    echo -e "${BOLD}Variaveis de ambiente:${RESET}"
    echo "  OPENAI_API_KEY     (obrigatorio) Sua chave de API da OpenAI"
    echo "  CODEX_MODEL        Modelo a usar            (default: gpt-4o)"
    echo "  CODEX_APPROVAL_MODE Modo de aprovacao       (default: full-auto)"
    echo "  CODEX_LOG_LEVEL    Nivel de log             (default: info)"
    echo "  CODEX_OUTPUT_DIR   Diretorio para logs      (default: ./logs/codex)"
    echo ""
    echo -e "${BOLD}Modos de aprovacao:${RESET}"
    echo "  suggest    Le e sugere mudancas, nao altera nada"
    echo "  auto-edit  Pode editar arquivos, pede aprovacao para comandos"
    echo "  full-auto  Autonomia total — edita arquivos e executa comandos"
    echo ""
    exit 1
}

# ---------------------------------------------------------------------------
# Validar argumentos
# ---------------------------------------------------------------------------

TASK="${1:-}"

if [ -z "$TASK" ]; then
    log_error "Descricao da task nao fornecida."
    usage
fi

# Remover espacos em branco extras no inicio e fim
TASK="$(echo "$TASK" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [ ${#TASK} -lt 5 ]; then
    log_error "Descricao muito curta. Por favor, seja mais especifico."
    echo ""
    echo "  Exemplo: $(basename "$0") \"revise o modulo de autenticacao e aponte vulnerabilidades\""
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# Verificar dependencias
# ---------------------------------------------------------------------------

if ! command -v codex &>/dev/null; then
    log_error "Codex CLI nao encontrado. Instale com:"
    echo ""
    echo "  npm install -g @openai/codex"
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# Verificar API key
# ---------------------------------------------------------------------------

if [ -z "${OPENAI_API_KEY:-}" ]; then
    # Tentar carregar do .env na raiz do projeto
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
    ENV_FILE="$PROJECT_DIR/.env"

    if [ -f "$ENV_FILE" ]; then
        # Carregar variaveis do .env (apenas as que comecam com OPENAI_ ou CODEX_)
        set -a
        # shellcheck disable=SC1090
        source <(grep -E '^(OPENAI_|CODEX_)' "$ENV_FILE" | sed 's/#.*$//')
        set +a
        log_info "Variaveis carregadas de $ENV_FILE"
    fi
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
    log_error "OPENAI_API_KEY nao configurada."
    echo ""
    echo "  Configure com:"
    echo "  export OPENAI_API_KEY=\"sk-...\""
    echo ""
    echo "  Ou adicione ao arquivo .env do projeto:"
    echo "  OPENAI_API_KEY=sk-..."
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# Configuracoes com defaults
# ---------------------------------------------------------------------------

MODEL="${CODEX_MODEL:-gpt-4o}"
APPROVAL_MODE="${CODEX_APPROVAL_MODE:-full-auto}"
LOG_LEVEL="${CODEX_LOG_LEVEL:-info}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${CODEX_OUTPUT_DIR:-$PROJECT_DIR/logs/codex}"

# Validar modo de aprovacao
case "$APPROVAL_MODE" in
    suggest|auto-edit|full-auto)
        ;;
    *)
        log_error "Modo de aprovacao invalido: '$APPROVAL_MODE'"
        echo "  Valores validos: suggest | auto-edit | full-auto"
        exit 1
        ;;
esac

# ---------------------------------------------------------------------------
# Criar diretorio de logs
# ---------------------------------------------------------------------------

mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$OUTPUT_DIR/codex_${TIMESTAMP}.log"

# ---------------------------------------------------------------------------
# Exibir configuracao antes de executar
# ---------------------------------------------------------------------------

echo ""
echo -e "${CYAN}${BOLD}============================================${RESET}"
echo -e "${CYAN}${BOLD}  Codex CLI — Modo Headless${RESET}"
echo -e "${CYAN}${BOLD}============================================${RESET}"
echo ""
log_info "Modelo:          $MODEL"
log_info "Modo aprovacao:  $APPROVAL_MODE"
log_info "Log level:       $LOG_LEVEL"
log_info "Log file:        $LOG_FILE"
log_info "Diretorio:       $PROJECT_DIR"
echo ""
echo -e "${BOLD}Task:${RESET}"
echo -e "  ${CYAN}$TASK${RESET}"
echo ""

# Aviso para modo full-auto
if [ "$APPROVAL_MODE" = "full-auto" ]; then
    log_warning "Modo full-auto ativo — o agente pode editar arquivos e executar comandos sem confirmacao."
    echo ""
fi

# ---------------------------------------------------------------------------
# Executar o Codex
# ---------------------------------------------------------------------------

log_info "Iniciando execucao... (${TIMESTAMP})"
echo ""

START_TIME=$(date +%s)

# Executar o Codex e capturar saida e codigo de retorno
EXIT_CODE=0
{
    codex \
        --approval-mode "$APPROVAL_MODE" \
        --quiet \
        "$TASK"
} 2>&1 | tee "$LOG_FILE" || EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo -e "${CYAN}${BOLD}============================================${RESET}"

if [ $EXIT_CODE -eq 0 ]; then
    log_success "Task concluida em ${DURATION}s"
    log_success "Log salvo em: $LOG_FILE"
else
    log_error "Task falhou com codigo de saida $EXIT_CODE (duracao: ${DURATION}s)"
    log_error "Verifique o log: $LOG_FILE"
    echo ""
    echo -e "  Possiveis causas:"
    echo -e "  - API key invalida ou sem credito"
    echo -e "  - Timeout na execucao (task muito complexa)"
    echo -e "  - Erro de permissao ao escrever arquivos"
    echo -e "  - Limite de rate da API atingido"
    echo ""
fi

echo -e "${CYAN}${BOLD}============================================${RESET}"
echo ""

exit $EXIT_CODE
