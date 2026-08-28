#!/usr/bin/env bash
# lib/services.sh — управление пользовательскими сервисами

# Отключить ненужные сервисы
disable_unwanted_services() {
    log_info "Отключаю ненужные сервисы..."

    # Останавливаем dunst, если он запущен
    pkill dunst 2>/dev/null || true

    # Отключаем автостарт и останавливаем сервис
    systemctl --user disable --now dunst.service 2>/dev/null || true

    log_ok "Сервисы обработаны"
}