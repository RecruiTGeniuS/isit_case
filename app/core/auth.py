"""Модуль аутентификации и авторизации"""
from flask import session
from core.database import get_db_cursor

def get_current_user():
    """Получить текущего пользователя из сессии"""
    if 'user_id' not in session:
        return None
    return {
        'user_id': session.get('user_id'),
        'login': session.get('login'),
        'last_name': session.get('last_name'),
        'first_name': session.get('first_name'),
        'patronymic': session.get('patronymic'),
        'post': session.get('post'),
        'role': session.get('role'),
        'avatar_path': session.get('avatar_path'),
    }

def authenticate_user(login, password):
    """Аутентификация пользователя"""
    with get_db_cursor() as cur:
        cur.execute("""
            SELECT employee_id, login, password, last_name, first_name, 
                   patronymic, employee_post, user_role, avatar_path 
            FROM employee 
            WHERE login = %s
        """, (login,))
        user = cur.fetchone()
        
        if user and user[2] == password:
            return {
                'employee_id': user[0],
                'login': user[1],
                'password': user[2],
                'last_name': user[3],
                'first_name': user[4],
                'patronymic': user[5],
                'post': user[6],
                'role': user[7],
                'avatar_path': user[8],
            }
        return None

def save_user_to_session(user):
    """Сохранить пользователя в сессию"""
    session['user_id'] = user['employee_id']
    session['login'] = user['login']
    session['last_name'] = user['last_name']
    session['first_name'] = user['first_name']
    session['patronymic'] = user['patronymic']
    session['post'] = user['post']
    session['role'] = user['role']
    session['avatar_path'] = user['avatar_path']
    session['password'] = user['password']

