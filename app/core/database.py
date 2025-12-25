"""Модуль для работы с базой данных"""
import psycopg2
from contextlib import contextmanager
from config import Config

def get_db_connection():
    """Создает подключение к базе данных"""
    conn = psycopg2.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        dbname=Config.DB_NAME,
        options="-c search_path=public"
    )
    return conn

@contextmanager
def get_db_cursor(commit=False):
    """Контекстный менеджер для работы с курсором БД"""
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        # Явно устанавливаем search_path для текущей сессии
        cur.execute("SET search_path TO public")
        yield cur
        if commit:
            conn.commit()
        else:
            conn.rollback()
    finally:
        cur.close()
        conn.close()

