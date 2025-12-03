"""Маршруты для работы с ПТО (админ-панель)"""
from flask import Blueprint, render_template, session, redirect, url_for
from core.auth import get_current_user
from utils.formatters import get_role_translation, format_phone

bp = Blueprint('admin_pto', __name__, url_prefix='/admin/pto')

@bp.route('', methods=['GET'])
def list_pto():
    """Список ПТО"""
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    user = get_current_user()
    
    # Передаем пустые списки и словари для совместимости с шаблоном
    employees = []
    role_options = []
    department_options = []
    facility_options = []
    role_labels = {}
    department_choices = []
    facility_choices = []
    
    return render_template('admin.html',
                         section='pto',
                         user=session,
                         employees=employees,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         role_options=role_options,
                         department_options=department_options,
                         facility_options=facility_options,
                         role_labels=role_labels,
                         department_choices=department_choices,
                         facility_choices=facility_choices)






