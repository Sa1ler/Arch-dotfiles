#!/usr/bin/env bash
# backup.sh — восстановить систему к сохранённому состоянию
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/configs.sh"

log_step "=== РЕЖИМ БЭКАПА (ОТКАТ) ==="

# 1. Восстанавливаем пакеты
backup_packages

# 2. Восстанавливаем конфиги
backup_configs

log_ok "Откат завершён"