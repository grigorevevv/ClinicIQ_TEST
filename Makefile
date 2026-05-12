# Переменные
DUMP_URL = "https://disk.360.yandex.ru/d/ycgshfxumqR45Q"
DUMP_PATH = ./init-db/demo_server_20260507.dump
MARKER_FILE = .superset_initialized

.PHONY: up down clean help init-superset

help:
	@echo "Команды:"
	@echo "make up    - Запустить проект (инициализация пройдет автоматически)"
	@echo "make down  - Остановить проект"
	@echo "make clean - Удалить данные БД и сбросить маркер инициализации"

up: prepare-dir download-dump
	docker-compose up -d --build
	@echo "Контейнеры запущены. Даем им 10 секунд на старт базы данных..."
	@sleep 10
	@$(MAKE) init-superset
	@echo "✅ Проект полностью готов!"
	@echo "👉 Superset: http://localhost:8088 (логин: admin, пароль: admin)"

# Выделяем инициализацию в отдельный скрытый блок
init-superset:
	@if [ ! -f $(MARKER_FILE) ]; then \
	    echo "🔥 Создаем аналитические витрины (View) в базе данных..."; \
		docker exec -i -e PGPASSWORD="admin" medical_db psql -U admin -d MIS < init-db/02-create-views.sql; \
		echo "🔥 Запуск первичной настройки Superset (это займет около минуты)..."; \
		docker exec superset_bi superset db upgrade; \
		docker exec superset_bi superset fab create-admin --username admin --firstname Admin --lastname User --email admin@superset.com --password admin; \
		docker exec superset_bi superset init; \
		touch $(MARKER_FILE); \
		echo "Инициализация успешно завершена!"; \
	else \
		echo "⚡ Superset уже был инициализирован ранее. Пропускаем настройку."; \
	fi

prepare-dir:
	mkdir -p ./init-db

download-dump:
	@if [ ! -f $(DUMP_PATH) ]; then \
		echo "Скачивание дампа..."; \
		curl -L $(DUMP_URL) -o $(DUMP_PATH); \
	else \
		echo "Дамп уже существует, скачивание не требуется."; \
	fi

down:
	docker-compose down

clean:
	docker-compose down -v
#	rm -rf ./init-db/demo_server_20260507.dump
	rm -f $(MARKER_FILE)
	@echo "Все данные и маркеры очищены."