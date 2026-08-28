#!/usr/bin/env bash
# install.sh — установка системы на новую машину
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/configs.sh"

log_step "=== РЕЖИМ УСТАНОВКИ ==="

# 1. Проверяем зависимости
log_step "Проверка зависимостей"
if ! command -v rsync &>/dev/null; then
    log_info "Устанавливаю rsync..."
    sudo pacman -S --needed --noconfirm rsync
fi

if ! command -v git &>/dev/null; then
    log_info "Устанавливаю git..."
    sudo pacman -S --needed --noconfirm git
fi
log_ok "Зависимости в порядке"

# 2. Ставим пакеты
install_packages

# 3. Ставим конфиги
install_configs

log_ok "Установка завершена!"