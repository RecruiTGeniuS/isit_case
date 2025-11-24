# Используем официальный образ Python
FROM python:3.12-slim

# Устанавливаем зависимости для psycopg2
RUN apt-get update && apt-get install -y \
    libpq-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Создаём рабочую папку
WORKDIR /app

# Копируем requirements
COPY requirements.txt .

# Устанавливаем Python-зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь код приложения
COPY . .

# Открываем порт
EXPOSE 5000

# Команда запуска приложения
CMD ["python", "app.py"]
