-- =============================================================================
-- АВТОЗАПУСК
-- =============================================================================
-- Программы, запускающиеся при старте Hyprland
-- (демоны уведомлений, статус-бары, обои и т.д.)

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/quickshell/scripts/start.sh")
    hl.exec_cmd([[sh -c 'WALL=$(cat ~/.config/quickshell/wallpaper/selected-wallpaper 2>/dev/null); [ -n "$WALL" ] && swaybg -i "$WALL" -m fill']])
end)