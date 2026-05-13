#!/bin/bash
set -e

# Путь к нашему скачанному дампу внутри контейнера
DUMP_FILE="/docker-entrypoint-initdb.d/demo_server_20260507.dump"

if [ -f "$DUMP_FILE" ]; then
    echo "Начинаем восстановление базы данных из $DUMP_FILE..."
    
    # pg_restore восстанавливает дамп. 
    # -U - пользователь, -d - база данных, -1 - выполнить в одной транзакции
    # --clean - очистить объекты перед созданием (если вдруг база не пустая)
    pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists --no-owner --no-privileges -1 "$DUMP_FILE"
    
    echo "Восстановление успешно завершено!"
else
    echo "ВНИМАНИЕ: Файл дампа $DUMP_FILE не найден."
fi