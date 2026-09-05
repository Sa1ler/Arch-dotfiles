#!/usr/bin/env bash
# sync.sh — собрать актуальное состояние системы и запушить в GitHub
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/configs.sh"

log_step "=== РЕЖИМ СИНХРОНИЗАЦИИ ==="

# 1. Собираем пакеты
collect_packages

# 2. Собираем конфиги
collect_configs

# 3. Коммит и пуш
log_step "Коммит и пуш в GitHub"
cd "$ROOT_DIR"

# Проверяем, есть ли изменения
if git diff --quiet && git diff --cached --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
    log_ok "Изменений нет, нечего коммитить"
    exit 0
fi

git add -A
git commit -m "sync: $(date '+%Y-%m-%d %H:%M:%S')"

# Пытаемся запушить
if git push 2>&1; then
    log_ok "Синхронизация завершена"
else
    log_warn "Локальная и удалённая ветки разошлись, делаю rebase..."
    git pull --rebase origin "$(git branch --show-current)"
    git push
    log_ok "Синхронизация завершена (после rebase)"
fi