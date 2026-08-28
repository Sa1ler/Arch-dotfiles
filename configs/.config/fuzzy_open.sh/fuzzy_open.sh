#!/bin/bash

TERMINAL="ghostty"
SEARCH_DIR="/home/graff"

# Проверка директории
[ ! -d "$SEARCH_DIR" ] && echo "Ошибка: Директория $SEARCH_DIR не существует" && exit 1

# Генерация списка
ITEMS=$(find "$SEARCH_DIR" -type f -o -type d 2>/dev/null | grep -v "^$SEARCH_DIR$")

# fzf выбор с прямым вызовом команд
FILE=$(echo "$ITEMS" | fzf \
    --height=40% \
    --layout=reverse \
    --border \
    --ansi \
    --prompt="Search: " \
    --preview 'if [ -f {} ]; then (bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null); elif [ -d {} ]; then ls -la --color=always {} 2>/dev/null | head -n 20; fi' \
    --bind 'enter:execute(nvim {+})' \
    --bind 'ctrl-o:execute('"$TERMINAL"' --working-directory={+})' \
    --exact)

[ -z "$FILE" ] && exit 0

if [ -f "$FILE" ]; then
    nvim "$FILE"
elif [ -d "$FILE" ]; then
    $TERMINAL --working-directory="$FILE"
fi
