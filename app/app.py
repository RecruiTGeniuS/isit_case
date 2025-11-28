"""Точка входа в приложение"""
import sys
import os

# Добавляем текущую директорию в путь для импортов
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

# Импортируем create_app из factory.py
from factory import create_app

app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
