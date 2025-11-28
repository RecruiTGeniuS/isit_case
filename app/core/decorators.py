"""Декораторы для маршрутов (опционально, но удобно)"""
from functools import wraps
from flask import session, redirect, url_for, jsonify

def login_required(f):
    """Декоратор для проверки авторизации"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            # Для AJAX запросов возвращаем JSON
            from flask import request
            if request.is_json or request.headers.get('Content-Type') == 'application/json':
                return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated_function


