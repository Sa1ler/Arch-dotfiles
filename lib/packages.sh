#!/usr/bin/env bash
# lib/packages.sh — работа с пакетами pacman и AUR (yay)

# Определить корень проекта, если ещё не задан
: "${ROOT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

PACMAN_LIST="$ROOT_DIR/packages/pacman.txt"
AUR_LIST="$ROOT_DIR/packages/aur.txt"

# ─────────────────────────────────────────────
# Сбор: записать текущие пакеты в файлы
# ─────────────────────────────────────────────
collect_packages() {
    log_step "Сбор установленных пакетов"

    # Явно установленные пакеты из официальных репозиториев
    pacman -Qqe | grep -vxFf <(pacman -Qqm) > "$PACMAN_LIST"
    log_ok "pacman.txt: $(wc -l < "$PACMAN_LIST") пакетов"

    # AUR / foreign пакеты
    pacman -Qqm > "$AUR_LIST"
    log_ok "aur.txt: $(wc -l < "$AUR_LIST") пакетов"
}

# ─────────────────────────────────────────────
# Установка: поставить пакеты из списков
# ─────────────────────────────────────────────
install_packages() {
    log_step "Установка пакетов"

    # Убедимся, что списки существуют
    [[ -s "$PACMAN_LIST" ]] || log_warn "pacman.txt пуст или отсутствует"
    [[ -s "$AUR_LIST" ]]    || log_warn "aur.txt пуст или отсутствует"

    # 1. Пакеты из pacman
    if [[ -s "$PACMAN_LIST" ]]; then
        log_info "Установка пакетов из pacman..."
        # --needed: пропустить уже установленные
        sudo pacman -S --needed --noconfirm $(cat "$PACMAN_LIST") 2>/dev/null
        log_ok "Пакеты из pacman установлены"
    fi

    # 2. Пакеты из AUR через yay
    if [[ -s "$AUR_LIST" ]]; then
        # Проверяем наличие yay
        if ! command -v yay &>/dev/null; then
            log_warn "yay не найден, устанавливаю..."
            _install_yay
        fi
        log_info "Установка пакетов из AUR..."
        yay -S --needed --noconfirm $(cat "$AUR_LIST") 2>/dev/null
        log_ok "Пакеты из AUR установлены"
    fi
}

# ─────────────────────────────────────────────
# Бэкап: сверить пакеты и восстановить
# ─────────────────────────────────────────────
backup_packages() {
    log_step "Сверка пакетов с сохранённым состоянием"

    local missing=()
    local extra=()

    # Проверяем пакеты из pacman.txt
    if [[ -s "$PACMAN_LIST" ]]; then
        while IFS= read -r pkg; do
            [[ -z "$pkg" || "$pkg" == \#* ]] && continue
            if ! pacman -Qi "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        done < "$PACMAN_LIST"
    fi

    # Проверяем пакеты из aur.txt
    if [[ -s "$AUR_LIST" ]]; then
        while IFS= read -r pkg; do
            [[ -z "$pkg" || "$pkg" == \#* ]] && continue
            if ! pacman -Qi "$pkg" &>/dev/null; then
                missing+=("$pkg")
            fi
        done < "$AUR_LIST"
    fi

    # Ищем лишние пакеты, которых нет в списках
    # (пакеты, установленные вручную после последнего синка)
    local current_explicit
    current_explicit=$(pacman -Qqe)
    local saved_pkgs
    saved_pkgs=$(cat "$PACMAN_LIST" "$AUR_LIST" 2>/dev/null | grep -v '^#' | grep -v '^$')

    while IFS= read -r pkg; do
        if ! echo "$saved_pkgs" | grep -qx "$pkg"; then
            extra+=("$pkg")
        fi
    done <<< "$current_explicit"

    # Устанавливаем недостающие
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warn "Недостающие пакеты (${#missing[@]}): ${missing[*]}"
        log_info "Устанавливаю недостающие..."
        sudo pacman -S --needed --noconfirm "${missing[@]}" 2>/dev/null
        log_ok "Недостающие пакеты установлены"
    else
        log_ok "Все пакеты из списка установлены"
    fi

    # Сообщаем о лишних
    if [[ ${#extra[@]} -gt 0 ]]; then
        log_warn "Лишние пакеты, не в списке (${#extra[@]}): ${extra[*]}"
        log_info "Для удаления выполни: sudo pacman -Rs ${extra[*]}"
    fi
}

# ─────────────────────────────────────────────
# Вспомогательное: установка yay
# ─────────────────────────────────────────────
_install_yay() {
    local tmp
    tmp=$(mktemp -d)
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    log_ok "yay установлен"
}