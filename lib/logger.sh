#!/usr/bin/env bash
# lib/logger.sh — красивый вывод

if [[ -t 1 ]]; then
    C_RESET='\033[0m'
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[1;33m'
    C_BLUE='\033[0;34m'
    C_CYAN='\033[0;36m'
    C_BOLD='\033[1m'
else
    C_RESET='' C_RED='' C_GREEN='' C_YELLOW=''
    C_BLUE='' C_CYAN='' C_BOLD=''
fi

log_info()  { echo -e "${C_BLUE}[INFO]${C_RESET} $*"; }
log_ok()    { echo -e "${C_GREEN}[ OK ]${C_RESET} $*"; }
log_warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
log_error() { echo -e "${C_RED}[FAIL]${C_RESET} $*" >&2; }
log_step()  { echo -e "\n${C_BOLD}${C_CYAN}==> $*${C_RESET}"; }

die() {
    log_error "$@"
    exit 1
}
