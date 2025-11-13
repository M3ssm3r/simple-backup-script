#!/bin/bash

# Скрипт для ночного бэкапа. Добавить в cron и забыть.
# chmod +x backup.sh

# --- НАСТРОЙКИ (ТУТ МЕНЯТЬ) ---
SITE_DIR="/var/www/my-super-site"       # Что бэкапим
BACKUP_DIR="/var/backups/my-super-site" # Куда складываем

DB_NAME="super_site_db"
DB_USER="root"
DB_PASS="Ryt_Kpl-!98_Secret" # Да, пароль в скрипте - это плохо. Но для простоты сойдет.

# --- ДАЛЬШЕ НЕ ТРОГАТЬ ---
export LANG=ru_RU.UTF-8
set -e # Прерываем скрипт при любой ошибке

DATE=$(date +"%Y-%m-%d_%H-%M")
BACKUP_PATH="$BACKUP_DIR/$DATE"
mkdir -p "$BACKUP_PATH" # Создаем папку для сегодняшнего бэкапа

echo "--- Начинаю бэкап сайта $SITE_DIR ---"

# 1. Бэкап базы данных
echo "Дамплю базу данных: $DB_NAME..."
mysqldump -u"$DB_USER" -p"$DB_PASS" --databases "$DB_NAME" | gzip > "$BACKUP_PATH/$DB_NAME.sql.gz"

# 2. Бэкап файлов
echo "Архивирую файлы из $SITE_DIR..."
# Флаги tar:
# -c: создать архив
# -z: сжать gzip'ом
# -f: в файл
# -C: сменить директорию (чтобы в архиве не было полного пути /var/www/...)
tar -czf "$BACKUP_PATH/site_files.tar.gz" -C "$(dirname "$SITE_DIR")" "$(basename "$SITE_DIR")"

# 3. Чистка
echo "Удаляю бэкапы старше 7 дней..."
# Ищем все директории (-type d) в $BACKUP_DIR, которые старше 7 дней (-mtime +7) и безжалостно удаляем.
find "$BACKUP_DIR" -type d -mtime +7 -exec rm -rf {} \;

echo "--- Бэкап успешно завершен! Лежит тут: $BACKUP_PATH ---"
