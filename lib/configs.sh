#!/usr/bin/env bash
# lib/configs.sh — работа с конфигами (папки и одиночные файлы)

: "${ROOT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

CONFIG_LIST="$ROOT_DIR/config.list"
CONFIGS_DIR="$ROOT_DIR/configs"

# ─────────────────────────────────────────────
# Чтение списка конфигов
# ─────────────────────────────────────────────
_read_config_list() {
    local paths=()
    while IFS= read -r line; do
        # Пропускаем пустые строки и комментарии
        [[ -z "$line" || "$line" == \#* ]] && continue
        paths+=("$line")
    done < "$CONFIG_LIST"
    echo "${paths[@]}"
}

# ─────────────────────────────────────────────
# Сбор: скопировать конфиги из $HOME в репозиторий
# ─────────────────────────────────────────────
collect_configs() {
    log_step "Сбор конфигов из \$HOME"

    local paths
    read -ra paths <<< "$(_read_config_list)"

    for rel_path in "${paths[@]}"; do
        local src="$HOME/$rel_path"
        local dst="$CONFIGS_DIR/$rel_path"

        if [[ ! -e "$src" ]]; then
            log_warn "Пропуск: $src не найден"
            continue
        fi

        if [[ -d "$src" ]]; then
            # Это папка
            mkdir -p "$dst"
            rsync -a --delete "$src/" "$dst/"
            log_ok "Собран (папка): $rel_path"
        elif [[ -f "$src" ]]; then
            # Это файл
            mkdir -p "$(dirname "$dst")"
            rsync -a "$src" "$dst"
            log_ok "Собран (файл): $rel_path"
        fi
    done
}

# ─────────────────────────────────────────────
# Установка: скопировать конфиги из репозитория в $HOME
# Пропускаем, если файлы идентичны
# ─────────────────────────────────────────────
install_configs() {
    log_step "Установка конфигов"

    local paths
    read -ra paths <<< "$(_read_config_list)"

    for rel_path in "${paths[@]}"; do
        local src="$CONFIGS_DIR/$rel_path"
        local dst="$HOME/$rel_path"

        if [[ ! -e "$src" ]]; then
            log_warn "Пропуск: $src не найден в репозитории"
            continue
        fi

        if [[ -d "$src" ]]; then
            # Это папка
            mkdir -p "$dst"
            local changes
            changes=$(rsync -ai --delete "$src/" "$dst/")
            if [[ -z "$changes" ]]; then
                log_info "Без изменений: $rel_path"
            else
                log_ok "Обновлён: $rel_path"
            fi
        elif [[ -f "$src" ]]; then
            # Это файл
            mkdir -p "$(dirname "$dst")"
            local changes
            changes=$(rsync -ai "$src" "$dst")
            if [[ -z "$changes" ]]; then
                log_info "Без изменений: $rel_path"
            else
                log_ok "Обновлён: $rel_path"
            fi
        fi
    done
}

# ─────────────────────────────────────────────
# Бэкап: восстановить конфиги из репозитория
# ─────────────────────────────────────────────
backup_configs() {
    log_step "Восстановление конфигов из сохранённого состояния"

    local paths
    read -ra paths <<< "$(_read_config_list)"
    local restored=0

    for rel_path in "${paths[@]}"; do
        local src="$CONFIGS_DIR/$rel_path"
        local dst="$HOME/$rel_path"

        if [[ ! -e "$src" ]]; then
            continue
        fi

        if [[ -d "$src" ]]; then
            # Это папка
            local diff_output
            diff_output=$(rsync -ain --delete "$src/" "$dst/" 2>/dev/null)
            if [[ -z "$diff_output" ]]; then
                log_info "Без изменений: $rel_path"
            else
                log_warn "Восстанавливаю: $rel_path"
                rsync -a --delete "$src/" "$dst/"
                ((restored++))
            fi
        elif [[ -f "$src" ]]; then
            # Это файл
            local diff_output
            diff_output=$(rsync -ain "$src" "$dst" 2>/dev/null)
            if [[ -z "$diff_output" ]]; then
                log_info "Без изменений: $rel_path"
            else
                log_warn "Восстанавливаю: $rel_path"
                rsync -a "$src" "$dst"
                ((restored++))
            fi
        fi
    done

    if [[ $restored -eq 0 ]]; then
        log_ok "Все конфиги соответствуют сохранённым"
    else
        log_ok "Восстановлено конфигов: $restored"
    fi
}