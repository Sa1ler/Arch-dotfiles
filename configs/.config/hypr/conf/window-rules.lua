-- =============================================================================
-- ПРАВИЛА ДЛЯ ОКОН И РАБОЧИХ СТОЛОВ
-- =============================================================================
-- Настройка поведения окон и рабочих столов
-- Документация: 
--   - https://wiki.hypr.land/Configuring/Window-Rules/
--   - https://wiki.hypr.land/Configuring/Workspace-Rules/

-- ----------------------------------------------------------------------------
-- ПРАВИЛА ОКОН
-- ----------------------------------------------------------------------------

-- Отключение максимизации для всех окон
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Исправление проблем с перетаскиванием в XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Правило для hyprland-run (плавающее окно в определенной позиции)
hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})