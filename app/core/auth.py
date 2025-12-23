"""Модуль аутентификации и авторизации"""
import secrets
from datetime import datetime, timedelta
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

def create_user_token(employee_id):
    """Создать токен для пользователя"""
    token = secrets.token_urlsafe(32)
    expires_at = datetime.now() + timedelta(days=30)  # Токен действителен 30 дней
    
    with get_db_cursor(commit=True) as cur:
        # Удаляем старые токены для этого пользователя
        cur.execute("""
            DELETE FROM user_token 
            WHERE employee_id = %s
        """, (employee_id,))
        
        # Создаем новый токен
        cur.execute("""
            INSERT INTO user_token (employee_id, token, expires_at, created_at, last_used_at)
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            RETURNING token_id
        """, (employee_id, token, expires_at))
        cur.fetchone()
    
    return token

def get_user_by_token(token):
    """Получить пользователя по токену"""
    if not token:
        return None
    
    with get_db_cursor() as cur:
        cur.execute("""
            SELECT ut.employee_id, ut.token, ut.expires_at, ut.last_used_at,
                   e.login, e.password, e.last_name, e.first_name, 
                   e.patronymic, e.employee_post, e.user_role, e.avatar_path
            FROM user_token ut
            JOIN employee e ON ut.employee_id = e.employee_id
            WHERE ut.token = %s AND ut.expires_at > CURRENT_TIMESTAMP
        """, (token,))
        result = cur.fetchone()
        
        if result:
            # Обновляем last_used_at
            cur.execute("""
                UPDATE user_token 
                SET last_used_at = CURRENT_TIMESTAMP 
                WHERE token = %s
            """, (token,))
            cur.connection.commit()
            
            return {
                'employee_id': result[0],
                'login': result[4],
                'password': result[5],
                'last_name': result[6],
                'first_name': result[7],
                'patronymic': result[8],
                'post': result[9],
                'role': result[10],
                'avatar_path': result[11],
            }
    
    return None

def delete_user_token(token):
    """Удалить токен пользователя"""
    if not token:
        return
    
    with get_db_cursor(commit=True) as cur:
        cur.execute("""
            DELETE FROM user_token 
            WHERE token = %s
        """, (token,))

