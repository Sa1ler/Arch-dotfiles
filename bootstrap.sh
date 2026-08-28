#!/usr/bin/env bash
# bootstrap.sh — главная точка входа
# Использование:
#   ./bootstrap.sh install   — установка на новую систему
#   ./bootstrap.sh backup    — откат к сохранённому состоянию
#   ./bootstrap.sh sync      — синхронизация с GitHub
#
# Удалённый запуск:
#   curl -fsSL https://raw.githubusercontent.com/USER/quickahell/main/bootstrap.sh | bash -s -- install

set -euo pipefail

REPO_URL="https://github.com/Sa1ler/Arch-dotfiles.git"  # ← замени на свой
INSTALL_DIR="$HOME/dotfiles"
MODE="${1:-help}"

# Цвета для вывода до загрузки логгера
_info()  { echo -e "\033[0;34m[INFO]\033[0m $*"; }
_error() { echo -e "\033[0;31m[FAIL]\033[0m $*" >&2; }

usage() {
    echo "Использование: $0 <режим>"
    echo ""
    echo "Режимы:"
    echo "  install   Развернуть систему на новой машине"
    echo "  backup    Откатить изменения к сохранённому состоянию"
    echo "  sync      Собрать изменения и запушить в GitHub"
    echo ""
    echo "Примеры:"
    echo "  $0 install"
    echo "  curl -fsSL <url>/bootstrap.sh | bash -s -- install"
    exit 1
}

# ─────────────────────────────────────────────
# Если репозиторий ещё не скачан — клонируем
# ─────────────────────────────────────────────
ensure_repo() {
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        _info "Репозиторий найден в $INSTALL_DIR, обновляю..."
        git -C "$INSTALL_DIR" pull --ff-only
    elif [[ -d "$INSTALL_DIR" && -f "$INSTALL_DIR/bootstrap.sh" ]]; then
        # Локальный запуск без git (разработка)
        _info "Локальный запуск из $INSTALL_DIR"
        return
    else
        _info "Клонирую репозиторий..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
}

# ─────────────────────────────────────────────
# Основная логика
# ─────────────────────────────────────────────
case "$MODE" in
    install)
        ensure_repo
        exec bash "$INSTALL_DIR/install.sh"
        ;;
    backup)
        ensure_repo
        exec bash "$INSTALL_DIR/backup.sh"
        ;;
    sync)
        ensure_repo
        exec bash "$INSTALL_DIR/sync.sh"
        ;;
    help|--help|-h|"")
        usage
        ;;
    *)
        _error "Неизвестный режим: $MODE"
        usage
        ;;
esac