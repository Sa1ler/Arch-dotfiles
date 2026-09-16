#!/usr/bin/env bash

# Кэш-директория для quickshell
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
export QS_RUN_MUSIC="$CACHE_DIR/music"

# Создаёт кэш-папку для указанного модуля
qs_ensure_cache() {
    local name="$1"
    mkdir -p "$CACHE_DIR/$name"
}
