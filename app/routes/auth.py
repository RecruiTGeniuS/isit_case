"""Маршруты для аутентификации"""
from flask import Blueprint, render_template, request, redirect, url_for, session, make_response
from core.auth import authenticate_user, save_user_to_session, create_user_token, get_user_by_token, delete_user_token

bp = Blueprint('auth', __name__)

@bp.route("/", methods=["GET", "POST"])
@bp.route("/login", methods=["GET", "POST"])
def login():
    """Страница входа"""
    if request.method == "POST":
        login_name = request.form.get("login")
        password = request.form.get("password")
        remember = request.form.get("remember") == "on"
        
        user = authenticate_user(login_name, password)
        if user:
            save_user_to_session(user)
            response = make_response(redirect(url_for("admin.dashboard")))
            
            # Если установлена галочка "Запомнить меня"
            if remember:
                # Создаем токен
                token = create_user_token(user['employee_id'])
                # Сохраняем токен в cookie (срок действия 30 дней)
                response.set_cookie('remember_token', token, max_age=30*24*60*60, httponly=True, samesite='Lax')
                # Сохраняем логин и пароль в cookie для подстановки в форму
                response.set_cookie('remember_login', login_name, max_age=30*24*60*60, httponly=False, samesite='Lax')
                response.set_cookie('remember_password', password, max_age=30*24*60*60, httponly=False, samesite='Lax')
            else:
                # Удаляем токен, логин и пароль из cookie, если галочка не установлена
                response.set_cookie('remember_token', '', expires=0)
                response.set_cookie('remember_login', '', expires=0)
                response.set_cookie('remember_password', '', expires=0)
            
            return response
        else:
            return render_template("login.html", error="Неверный логин или пароль")
    
    # Проверяем, не авторизован ли уже пользователь
    if 'user_id' in session:
        return redirect(url_for("admin.dashboard"))
    
    # Проверяем токен в cookie для автоматической авторизации
    remember_token = request.cookies.get('remember_token')
    if remember_token:
        user = get_user_by_token(remember_token)
        if user:
            save_user_to_session(user)
            return redirect(url_for("admin.dashboard"))
        else:
            # Токен невалидный, удаляем его
            response = make_response(render_template("login.html"))
            response.set_cookie('remember_token', '', expires=0)
            response.set_cookie('remember_login', '', expires=0)
            response.set_cookie('remember_password', '', expires=0)
            return response
    
    # Получаем сохраненный логин и пароль для подстановки в форму
    saved_login = request.cookies.get('remember_login', '')
    saved_password = request.cookies.get('remember_password', '')
    return render_template("login.html", saved_login=saved_login, saved_password=saved_password)

@bp.route("/logout")
def logout():
    """Выход из системы"""
    # Удаляем токен из БД, если он есть
    remember_token = request.cookies.get('remember_token')
    if remember_token:
        delete_user_token(remember_token)
    
    session.clear()
    response = make_response(redirect(url_for("auth.login")))
    # Удаляем cookies
    response.set_cookie('remember_token', '', expires=0)
    response.set_cookie('remember_login', '', expires=0)
    response.set_cookie('remember_password', '', expires=0)
    return response

@bp.route("/forgot-password")
def forgot_password():
    """Страница восстановления пароля"""
    # Проверяем, не авторизован ли уже пользователь
    if 'user_id' in session:
        return redirect(url_for("admin.dashboard"))
    
    return render_template("forgot_password.html")

