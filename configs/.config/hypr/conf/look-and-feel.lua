-- =============================================================================
-- ВНЕШНИЙ ВИД И ОФОРМЛЕНИЕ
-- =============================================================================
-- Премиум-анимации: мягкие пружины, плавные переходы, деликатные эффекты

-- ----------------------------------------------------------------------------
-- ОБЩИЕ НАСТРОЙКИ
-- ----------------------------------------------------------------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 0,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
})

-- ----------------------------------------------------------------------------
-- ОФОРМЛЕНИЕ ОКОН
-- ----------------------------------------------------------------------------
hl.config({
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 7,
            render_power = 4,
            color = "rgba(0a0a0aee)",
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.2,
            new_optimizations = true,
        },
    },
})

-- =============================================================================
-- КРИВЫЕ АНИМАЦИЙ
-- =============================================================================
-- SPRING (пружинные) — физически корректные, мягкие, отзывчивые
-- ----------------------------------------------------------------------------
hl.curve("springSoft", {
    type = "spring",
    mass = 1.0,
    stiffness = 120,
    dampening = 16,
})

hl.curve("springResponsive", {
    type = "spring",
    mass = 1.0,
    stiffness = 200,
    dampening = 20,
})

hl.curve("springGentle", {
    type = "spring",
    mass = 1.2,
    stiffness = 80,
    dampening = 14,
})

hl.curve("springSnap", {
    type = "spring",
    mass = 0.8,
    stiffness = 280,
    dampening = 24,
})

-- "Цветение" при открытии: быстрый старт, один мягкий overshoot, плавная усадка
hl.curve("bloomSpring", {
    type = "spring",
    mass = 1.0,
    stiffness = 170,
    dampening = 13, -- ниже критического демпфирования => один нежный "отскок"
})

-- "Улёт" при закрытии: окно начинает медленно и набирает скорость
hl.curve("closeEase", {
    type = "bezier",
    points = { {0.45, 0.05}, {0.85, 0.4} },
})

-- ----------------------------------------------------------------------------
-- BEZIER — для fade, border и специфичных эффектов
-- ----------------------------------------------------------------------------
hl.curve("fadeSmooth", {
    type = "bezier",
    points = { {0.25, 0.1}, {0.25, 1.0} },
})

hl.curve("fadeGentle", {
    type = "bezier",
    points = { {0.33, 0.0}, {0.67, 1.0} },
})

hl.curve("fadeDreamy", {
    type = "bezier",
    points = { {0.55, 0.085}, {0.68, 0.53} },
})

hl.curve("borderRotate", {
    type = "bezier",
    points = { {0.4, 0.0}, {0.2, 1.0} },
})

hl.curve("popElegant", {
    type = "bezier",
    points = { {0.22, 1.4}, {0.35, 1.0} },
})

hl.curve("popSubtle", {
    type = "bezier",
    points = { {0.34, 1.15}, {0.64, 1.0} },
})

hl.curve("dissolve", { 
    type = "bezier", 
    points = { {0.4, 0.0}, {0.2, 1.0} } })

-- =============================================================================
-- АНИМАЦИИ
-- =============================================================================
-- ВАЖНО: для пружинных кривых используем поле `spring`, для bezier — `bezier`
-- ----------------------------------------------------------------------------

-- 1. ГЛОБАЛЬНАЯ
hl.animation({
    leaf = "global",
    enabled = true,
    speed = 6,
    spring = "springResponsive", -- ИСПРАВЛЕНО: spring вместо bezier
})

-- ----------------------------------------------------------------------------
-- ОКНА — signature look: bloom на вход, улёт на выход
-- ----------------------------------------------------------------------------
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 6,
    spring = "springResponsive",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 5,
    bezier = "dissolve"
})

hl.animation({ 
    leaf = "windowsOut",
    enabled = true, 
    speed = 5, 
    bezier = "dissolve" 
})

hl.animation({ 
    leaf = "windowsMove", 
    enabled = true,
    speed = 8, 
    spring = "springSnap" 
})

-- 3. ГРАНИЦЫ
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5,
    bezier = "fadeSmooth",
})

hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 4,
    bezier = "borderRotate",
})

-- 4. FADE
hl.animation({ leaf = "fade", enabled = false })

hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 3,
    bezier = "fadeDreamy",
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 2.5,
    bezier = "fadeGentle",
})

hl.animation({
    leaf = "fadeSwitch",
    enabled = true,
    speed = 4,
    bezier = "fadeSmooth",
})

hl.animation({
    leaf = "fadeShadow",
    enabled = true,
    speed = 2.5,
    bezier = "fadeSmooth",
})

hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 2.5,
    bezier = "fadeGentle",
})

hl.animation({
    leaf = "fadeDpms",
    enabled = true,
    speed = 3,
    bezier = "fadeSmooth",
})

-- 5. СЛОИ (layers)
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 5,
    spring = "springResponsive",
})

hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.5,
    spring = "springSoft",
    style = "popin 95%",
})

hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 4,
    spring = "springGentle",
    style = "popin 97%",
})

hl.animation({
    leaf = "fadeLayers",
    enabled = true,
    speed = 3,
    bezier = "fadeSmooth",
})

hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2.5,
    bezier = "fadeDreamy",
})

hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2.5,
    bezier = "fadeGentle",
})

-- 6. РАБОЧИЕ СТОЛЫ
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 6,
    spring = "springResponsive",
    style = "slidefade",
})

hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 5,
    spring = "springSoft",
    style = "slidefade",
})

hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 5,
    spring = "springGentle",
    style = "slidefade",
})

-- 7. СПЕЦИАЛЬНЫЙ РАБОЧИЙ СТОЛ (scratchpad)
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 5,
    spring = "springSoft",
    style = "slidefadevert -50%",
})

hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 4,
    spring = "springSoft",
    style = "slidefadevert -50%",
})

hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 4,
    spring = "springGentle",
    style = "slidefadevert 50%",
})

-- 8. POPUPS
hl.animation({
    leaf = "fadePopups",
    enabled = true,
    speed = 3,
    bezier = "fadeSmooth",
})

hl.animation({
    leaf = "fadePopupsIn",
    enabled = true,
    speed = 2.5,
    bezier = "popElegant",
})

hl.animation({
    leaf = "fadePopupsOut",
    enabled = true,
    speed = 2,
    bezier = "fadeGentle",
})

-- 9. ZOOM
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 6,
    spring = "springResponsive",
})

-- 10. МОНИТОРЫ (только monitorAdded — monitorRemoved не существует)
hl.animation({
    leaf = "monitorAdded",
    enabled = true,
    speed = 5,
    spring = "springGentle",
})

-- =============================================================================
-- РАСКЛАДКИ (LAYOUTS)
-- =============================================================================
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

-- ----------------------------------------------------------------------------
-- РАЗНОЕ
-- ----------------------------------------------------------------------------
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
    },
})

-- =============================================================================
-- ПРАВИЛА ОКОН
-- =============================================================================
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$", title = "^$", xwayland = true,
        float = true, fullscreen = false, pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})