#!/bin/bash
# === Система макетов окон для Hyprland ===
# Использование: apply-layout.sh <layout-name>
# Макеты: split, master, triple, grid, focus, stack

LAYOUT="$1"
BAR_HEIGHT=45      # topMargin + barHeight из TopBar
GAP=6              # отступ между окнами
PADDING=3          # отступ от краёв экрана

# === Получаем размер экрана ===
MONITOR=$(hyprctl monitors -j | jq -r '.[0]')
W=$(echo "$MONITOR" | jq -r '.width')
H=$(echo "$MONITOR" | jq -r '.height')

# Доступная область (с учётом бара)
TOP=$((BAR_HEIGHT + PADDING))
USABLE_H=$((H - BAR_HEIGHT - PADDING * 2))
USABLE_W=$((W - PADDING * 2))

echo "[apply-layout] Applying: $LAYOUT"
echo "[apply-layout] Screen: ${W}x${H}, usable: ${USABLE_W}x${USABLE_H}"

# === Получаем окна текущего воркспейса ===
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $CURRENT_WS) | .address")
COUNT=$(echo "$WINDOWS" | wc -l)

echo "[apply-layout] Found $COUNT windows on workspace $CURRENT_WS"

if [ "$COUNT" -eq 0 ]; then
    notify-send "❌ Нет окон" "Откройте окна перед применением макета" -t 2000
    exit 1
fi

# === Функция позиционирования окна ===
position_window() {
    local addr="$1"
    local x="$2"
    local y="$3"
    local w="$4"
    local h="$5"
    
    hyprctl dispatch focuswindow "address:$addr" 2>/dev/null
    sleep 0.05
    hyprctl dispatch resizeactive "exact ${w}x${h}" 2>/dev/null
    hyprctl dispatch moveactive "exact ${x} ${y}" 2>/dev/null
}

# === Применение макета ===
case "$LAYOUT" in
    
    # === SPLIT: Два окна пополам ===
    "split")
        if [ "$COUNT" -lt 2 ]; then
            notify-send "⚠️ Нужно 2 окна" "Откройте ещё одно окно" -t 2000
            exit 1
        fi
        
        WIN1=$(echo "$WINDOWS" | sed -n '1p')
        WIN2=$(echo "$WINDOWS" | sed -n '2p')
        
        HALF_W=$(( (USABLE_W - GAP) / 2 ))
        
        position_window "$WIN1" $PADDING $TOP $HALF_W $USABLE_H
        position_window "$WIN2" $((PADDING + HALF_W + GAP)) $TOP $HALF_W $USABLE_H
        ;;
    
    # === MASTER: Одно большое + стек справа ===
    "master")
        WIN1=$(echo "$WINDOWS" | sed -n '1p')
        
        MASTER_W=$(( (USABLE_W - GAP) * 70 / 100 ))
        STACK_W=$(( USABLE_W - MASTER_W - GAP ))
        
        # Мастер-окно (большое слева)
        position_window "$WIN1" $PADDING $TOP $MASTER_W $USABLE_H
        
        # Остальные окна в стеке справа
        if [ "$COUNT" -gt 1 ]; then
            STACK_COUNT=$((COUNT - 1))
            STACK_H=$(( (USABLE_H - GAP * (STACK_COUNT - 1)) / STACK_COUNT ))
            STACK_X=$((PADDING + MASTER_W + GAP))
            
            for i in $(seq 2 $COUNT); do
                WIN=$(echo "$WINDOWS" | sed -n "${i}p")
                STACK_Y=$((TOP + (i - 2) * (STACK_H + GAP)))
                position_window "$WIN" $STACK_X $STACK_Y $STACK_W $STACK_H
            done
        fi
        ;;
    
    # === TRIPLE: Три колонки ===
    "triple")
        if [ "$COUNT" -lt 3 ]; then
            notify-send "⚠️ Нужно 3 окна" "Откройте ещё окна" -t 2000
            exit 1
        fi
        
        COL_W=$(( (USABLE_W - GAP * 2) / 3 ))
        
        for i in 1 2 3; do
            WIN=$(echo "$WINDOWS" | sed -n "${i}p")
            COL_X=$((PADDING + (i - 1) * (COL_W + GAP)))
            position_window "$WIN" $COL_X $TOP $COL_W $USABLE_H
        done
        ;;
    
    # === GRID: Сетка 2x2 ===
    "grid")
        if [ "$COUNT" -lt 4 ]; then
            notify-send "⚠️ Нужно 4 окна" "Откройте ещё окна" -t 2000
            exit 1
        fi
        
        CELL_W=$(( (USABLE_W - GAP) / 2 ))
        CELL_H=$(( (USABLE_H - GAP) / 2 ))
        
        # Позиции: [0,0], [1,0], [0,1], [1,1]
        for i in 1 2 3 4; do
            WIN=$(echo "$WINDOWS" | sed -n "${i}p")
            COL=$(( (i - 1) % 2 ))
            ROW=$(( (i - 1) / 2 ))
            CELL_X=$((PADDING + COL * (CELL_W + GAP)))
            CELL_Y=$((TOP + ROW * (CELL_H + GAP)))
            position_window "$WIN" $CELL_X $CELL_Y $CELL_W $CELL_H
        done
        ;;
    
    # === FOCUS: Редактор + панель ===
    "focus")
        if [ "$COUNT" -lt 2 ]; then
            notify-send "⚠️ Нужно 2 окна" "Откройте ещё одно окно" -t 2000
            exit 1
        fi
        
        WIN1=$(echo "$WINDOWS" | sed -n '1p')
        WIN2=$(echo "$WINDOWS" | sed -n '2p')
        
        EDITOR_W=$(( (USABLE_W - GAP) * 75 / 100 ))
        PANEL_W=$(( USABLE_W - EDITOR_W - GAP ))
        
        position_window "$WIN1" $PADDING $TOP $EDITOR_W $USABLE_H
        position_window "$WIN2" $((PADDING + EDITOR_W + GAP)) $TOP $PANEL_W $USABLE_H
        ;;
    
    # === STACK: Три горизонтальных полосы ===
    "stack")
        if [ "$COUNT" -lt 3 ]; then
            notify-send "⚠️ Нужно 3 окна" "Откройте ещё окна" -t 2000
            exit 1
        fi
        
        ROW_H=$(( (USABLE_H - GAP * 2) / 3 ))
        
        for i in 1 2 3; do
            WIN=$(echo "$WINDOWS" | sed -n "${i}p")
            ROW_Y=$((TOP + (i - 1) * (ROW_H + GAP)))
            position_window "$WIN" $PADDING $ROW_Y $USABLE_W $ROW_H
        done
        ;;
    
    *)
        notify-send "❌ Неизвестный макет" "$LAYOUT" -t 2000
        exit 1
        ;;
esac

notify-send "✅ Макет применён" "$LAYOUT" -t 1500 -i view-grid-symbolic
exit 0
