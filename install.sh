#!/usr/bin/env bash
# install.sh — установка системы на новую машину
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/configs.sh"
source "$ROOT_DIR/lib/services.sh"

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

# 3. Устанавливаем Starship (промпт для shell)
log_step "Установка Starship"
if ! command -v starship &>/dev/null; then
    log_info "Устанавливаю Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    log_ok "Starship установлен"
else
    log_ok "Starship уже установлен"
fi

# 5. Ставим конфиги
install_configs

# 6. Отключаем ненужные сервисы
disable_unwanted_services

log_ok "Установка завершена!"
