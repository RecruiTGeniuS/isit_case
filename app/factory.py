"""Инициализация Flask приложения"""
from flask import Flask
import os
import sys

def create_app():
    """Фабрика приложения"""
    # Добавляем текущую директорию в путь для импортов
    current_dir = os.path.dirname(os.path.abspath(__file__))
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)
    
    app = Flask(__name__)
    app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here')
    app.config['UPLOAD_FOLDER'] = os.path.join(
        os.path.dirname(__file__), 'static', 'images', 'workers'
    )
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB
    
    # Создаем папку для аватарок, если её нет
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    
    # Регистрация blueprints
    from routes import auth, admin_employees, admin_equipment, admin_warehouse, admin_pto, admin_statistics, admin_tasks, admin, main
    
    app.register_blueprint(auth.bp)
    app.register_blueprint(admin_employees.bp)
    app.register_blueprint(admin_equipment.bp)
    app.register_blueprint(admin_warehouse.bp)
    app.register_blueprint(admin_pto.bp)
    app.register_blueprint(admin_statistics.bp)
    app.register_blueprint(admin_tasks.bp)
    app.register_blueprint(admin.bp)
    app.register_blueprint(main.bp)
    
    return app

