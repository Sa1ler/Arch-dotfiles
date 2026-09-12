-- =============================================================================
-- ГОРЯЧИЕ КЛАВИШИ (Hyprland 0.56 Lua)
-- =============================================================================
-- Документация: https://wiki.hypr.land/Configuring/Binds/

local mainMod = "SUPER"

-- Сигнатура текущего инстанса Hyprland (нужна для hyprctl dispatch)
local hypr_sig = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""

-- Обёртка для диспетчеров, не имеющих нативного Lua-аналога (movewindow и т.п.)
local function hycmd(cmd)
    return hl.dsp.exec_cmd("HYPRLAND_INSTANCE_SIGNATURE=" .. hypr_sig .. " hyprctl dispatch " .. cmd)
end

-- ----------------------------------------------------------------------------
-- ЗАПУСК ПРИЛОЖЕНИЙ
-- ----------------------------------------------------------------------------
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs -c bar ipc call topbar toggleWallpaper"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("qs -c bar ipc call topbar toggleTheme"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("qs -c bar ipc call topbar toggleLauncher"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs -c generalmenu ipc call panel toggle"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs -c bar ipc call topbar toggleClipboard"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(vpn))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("/home/" .. os.getenv("USER") .. "/.local/bin/hypr-float toggle 70"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.float({ action = "toggle" }))
hl.bind("F10", hl.dsp.exec_cmd("qs -c bar ipc call topbar toggleScreenshot"))

-- ----------------------------------------------------------------------------
-- ЗВУК
-- ----------------------------------------------------------------------------
hl.bind("F2", hl.dsp.exec_cmd("~/.config/volume-osd/scripts/volume-control.sh down"))
hl.bind("F3", hl.dsp.exec_cmd("~/.config/volume-osd/scripts/volume-control.sh up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/volume-osd/scripts/volume-control.sh down"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/volume-osd/scripts/volume-control.sh up"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/volume-osd/scripts/volume-control.sh mute"))

-- ----------------------------------------------------------------------------
-- УПРАВЛЕНИЕ ФОКУСОМ
-- ----------------------------------------------------------------------------
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- ----------------------------------------------------------------------------
-- ПЕРЕКЛЮЧЕНИЕ РАБОЧИХ СТОЛОВ (1-10)
-- ----------------------------------------------------------------------------
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- ----------------------------------------------------------------------------
-- ПЕРЕМЕЩЕНИЕ ОКОН МЕЖДУ РАБОЧИМИ СТОЛАМИ (SHIFT + 1-10)
-- ----------------------------------------------------------------------------
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- ----------------------------------------------------------------------------
-- МУЛЬТИМЕДИЙНЫЕ КЛАВИШИ (аналог bindel: repeating + locked)
-- ----------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { repeating = true, locked = true })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))

-- ----------------------------------------------------------------------------
-- УПРАВЛЕНИЕ ПЛЕЕРОМ (аналог bindl: locked)
-- ----------------------------------------------------------------------------
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ----------------------------------------------------------------------------
-- СПЕЦИАЛЬНЫЙ РАБОЧИЙ СТОЛ (SCRATCHPAD)
-- ----------------------------------------------------------------------------
hl.bind(mainMod .. " + S", hl.dsp.focus({ workspace = "special:magic" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ----------------------------------------------------------------------------
-- НАВИГАЦИЯ КОЛЁСИКОМ МЫШИ
-- ----------------------------------------------------------------------------
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ----------------------------------------------------------------------------
-- ПЕРЕТАСКИВАНИЕ/РЕСАЙЗ МЫШЬЮ (аналог bindm)
-- ----------------------------------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hycmd("movewindow"), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hycmd("resizewindow"), { mouse = true })
