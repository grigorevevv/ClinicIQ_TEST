# Берем официальный образ за основу
FROM apache/superset:latest

# Переключаемся на суперпользователя, чтобы иметь права на установку пакетов
USER root

# Устанавливаем драйвер PostgreSQL
RUN pip install psycopg2-binary -t /app/pythonpath

# Обязательно возвращаемся обратно на безопасного пользователя superset
USER superset