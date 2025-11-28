"""Модуль для работы с базой данных"""
import psycopg2
from contextlib import contextmanager
from config import Config

def get_db_connection():
    """Создает подключение к базе данных"""
    return psycopg2.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        dbname=Config.DB_NAME
    )

@contextmanager
def get_db_cursor(commit=False):
    """Контекстный менеджер для работы с курсором БД"""
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        yield cur
        if commit:
            conn.commit()
        else:
            conn.rollback()
    finally:
        cur.close()
        conn.close()

