"""Маршруты для аутентификации"""
from flask import Blueprint, render_template, request, redirect, url_for, session
from core.auth import authenticate_user, save_user_to_session

bp = Blueprint('auth', __name__)

@bp.route("/", methods=["GET", "POST"])
@bp.route("/login", methods=["GET", "POST"])
def login():
    """Страница входа"""
    if request.method == "POST":
        login_name = request.form.get("login")
        password = request.form.get("password")
        
        user = authenticate_user(login_name, password)
        if user:
            save_user_to_session(user)
            return redirect(url_for("admin.dashboard"))
        else:
            return render_template("login.html", error="Неверный логин или пароль")
    
    # Проверяем, не авторизован ли уже пользователь
    if 'user_id' in session:
        return redirect(url_for("admin.dashboard"))
    
    return render_template("login.html")

@bp.route("/logout")
def logout():
    """Выход из системы"""
    session.clear()
    return redirect(url_for("auth.login"))

@bp.route("/forgot-password")
def forgot_password():
    """Страница восстановления пароля"""
    # Проверяем, не авторизован ли уже пользователь
    if 'user_id' in session:
        return redirect(url_for("admin.dashboard"))
    
    return render_template("forgot_password.html")

