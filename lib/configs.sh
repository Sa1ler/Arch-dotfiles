#!/usr/bin/env bash
# lib/configs.sh — работа с конфигами

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

        # Создаём целевую директорию
        mkdir -p "$(dirname "$dst")"

        # Копируем с удалением файлов, которых нет в источнике
        rsync -a --delete "$src/" "$dst/"
        log_ok "Собран: $rel_path"
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

        mkdir -p "$(dirname "$dst")"

        # rsync сам пропустит идентичные файлы
        # --itemize-changes покажет, что изменилось
        local changes
        changes=$(rsync -ai --delete "$src/" "$dst/")

        if [[ -z "$changes" ]]; then
            log_info "Без изменений: $rel_path"
        else
            log_ok "Обновлён: $rel_path"
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

        # Проверяем, есть ли различия
        local diff_output
        diff_output=$(rsync -ain --delete "$src/" "$dst/" 2>/dev/null)

        if [[ -z "$diff_output" ]]; then
            log_info "Без изменений: $rel_path"
        else
            # Показываем что изменится
            log_warn "Восстанавливаю: $rel_path"
            echo "$diff_output" | head -20 | while read -r line; do
                echo "  $line"
            done
            rsync -a --delete "$src/" "$dst/"
            ((restored++))
        fi
    done

    if [[ $restored -eq 0 ]]; then
        log_ok "Все конфиги соответствуют сохранённым"
    else
        log_ok "Восстановлено конфигов: $restored"
    fi
}