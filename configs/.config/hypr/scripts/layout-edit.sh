#!/bin/bash

STATE_FILE="/tmp/hypr-layout-edit.state"

# ============================================================
# ВХОД В РЕЖИМ РЕДАКТИРОВАНИЯ
# ============================================================

if [ ! -f "$STATE_FILE" ]; then

    echo "EDIT" > "$STATE_FILE"

    # Получаем все окна
    hyprctl clients -j | jq -c '.[] | select(.mapped == true)' | while read -r client; do

        address=$(echo "$client" | jq -r '.address')
        workspace=$(echo "$client" | jq -r '.workspace.id')

        x=$(echo "$client" | jq -r '.at[0]')
        y=$(echo "$client" | jq -r '.at[1]')
        w=$(echo "$client" | jq -r '.size[0]')
        h=$(echo "$client" | jq -r '.size[1]')

        echo "$address|$workspace|$x|$y|$w|$h" >> "$STATE_FILE"

        # Переводим окно во floating
        hyprctl dispatch togglefloating "address:$address"

    done

    # Небольшая задержка, чтобы Hyprland применил floating
    sleep 0.15

    # Сохраняем исходные координаты уже после перехода
    echo "EDIT MODE"

# ============================================================
# ВЫХОД ИЗ РЕЖИМА РЕДАКТИРОВАНИЯ
# ============================================================

else

    # Пропускаем первую строку EDIT
    tail -n +2 "$STATE_FILE" | while IFS='|' read -r address workspace x y w h; do

        # Если окно всё ещё существует
        if hyprctl clients -j | jq -e ".[] | select(.address == \"$address\")" >/dev/null; then

            # Возвращаем окно на исходный workspace
            hyprctl dispatch movetoworkspace "$workspace,address:$address"

            # Возвращаем размер
            hyprctl dispatch resizewindowpixel "exact $w $h,address:$address"

            # Возвращаем позицию
            hyprctl dispatch movewindowpixel "exact $x $y,address:$address"

            # Возвращаем tiled
            hyprctl dispatch togglefloating "address:$address"

        fi

    done

    rm -f "$STATE_FILE"

    echo "NORMAL MODE"

fi






