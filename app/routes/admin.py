"""Главный маршрут админки"""
from flask import Blueprint, redirect, url_for, request, session, current_app
from core.auth import get_current_user
import os
import werkzeug.utils
from core.database import get_db_cursor

bp = Blueprint('admin', __name__, url_prefix='/admin')

@bp.route('')
@bp.route('/')
def dashboard():
    """Главная страница админки - редирект на статистику"""
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    section = request.args.get('section', 'statistics')
    
    if section == 'statistics':
        return redirect(url_for('admin_statistics.list_statistics'))
    elif section == 'employees':
        return redirect(url_for('admin_employees.list_employees'))
    elif section == 'equipment':
        return redirect(url_for('admin_equipment.list_equipment'))
    elif section == 'warehouse':
        return redirect(url_for('admin_warehouse.list_warehouse'))
    elif section == 'pto':
        return redirect(url_for('admin_pto.list_pto'))
    elif section == 'tasks':
        return redirect(url_for('admin_tasks.list_tasks'))
    else:
        return redirect(url_for('admin_statistics.list_statistics'))

@bp.route('/upload-avatar', methods=["POST"])
def upload_avatar():
    """Загрузка аватара"""
    if 'user_id' not in session:
        return redirect(url_for("auth.login"))
    
    if 'avatar' not in request.files:
        return redirect(url_for("admin.dashboard"))
    
    file = request.files['avatar']
    if file.filename == '':
        return redirect(url_for("admin.dashboard"))
    
    if file:
        # Генерируем безопасное имя файла
        filename = f"avatar_{session['user_id']}_{werkzeug.utils.secure_filename(file.filename)}"
        upload_folder = current_app.config['UPLOAD_FOLDER']
        filepath = os.path.join(upload_folder, filename)
        file.save(filepath)
        
        # Сохраняем путь в БД (относительный путь для Flask)
        relative_path = f"images/workers/{filename}"
        with get_db_cursor(commit=True) as cur:
            cur.execute(
                "UPDATE employee SET avatar_path = %s WHERE employee_id = %s",
                (relative_path, session['user_id'])
            )
        
        # Обновляем сессию
        session['avatar_path'] = relative_path
    
    return redirect(url_for("admin.dashboard"))

