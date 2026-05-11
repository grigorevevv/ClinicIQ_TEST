# Переменные (замени ссылку на реальную)
DUMP_URL = "https://disk.360.yandex.ru/d/ycgshfxumqR45Q"
DUMP_PATH = ./init-db/demo_server_20260507.dump

.PHONY: up down clean help

help:
	@echo "Команды:"
	@echo "make up    - Скачать дамп и запустить проект"
	@echo "make down  - Остановить проект"
	@echo "make clean - Удалить данные базы и дамп"

up: prepare-dir download-dump
	docker-compose up -d --build
	@echo "Сервис запущен. API: http://localhost:8000, UI: http://localhost:8501"

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
	rm -rf ./init-db/*.sql