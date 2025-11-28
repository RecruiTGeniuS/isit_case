"""Основные маршруты"""
from flask import Blueprint, render_template, send_from_directory
from core.database import get_db_cursor

bp = Blueprint('main', __name__)

@bp.route("/static/<path:filename>")
def static_files(filename):
    """Статические файлы"""
    return send_from_directory('static', filename)

@bp.route("/home")
def index():
    """Главная страница"""
    with get_db_cursor() as cur:
        cur.execute("SELECT facility_name FROM facility LIMIT 5;")
        facilities = [row[0] for row in cur.fetchall()]
    return render_template("index.html", facilities=facilities)
