"""Маршруты для работы со статистикой (админ-панель)"""
from flask import Blueprint, render_template, session, redirect, url_for, jsonify
from core.auth import get_current_user
from utils.formatters import get_role_translation, format_phone
from services.admin_statistics_service import AdminStatisticsService
from services.admin_employee_service import AdminEmployeeService

bp = Blueprint('admin_statistics', __name__, url_prefix='/admin/statistics')

def check_auth():
    """Проверка авторизации"""
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    return None

@bp.route('', methods=['GET'])
def list_statistics():
    """Страница статистики"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    
    # Получаем department_id пользователя, если он начальник ремонтной службы
    department_id = None
    if user['role'] == 'repair_head':
        emp_service = AdminEmployeeService()
        department_id = emp_service.get_user_department_id(user['user_id'])
    
    # Передаем пустые списки и словари для совместимости с шаблоном
    employees = []
    role_options = []
    department_options = []
    facility_options = []
    role_labels = {}
    department_choices = []
    facility_choices = []
    
    return render_template('admin.html',
                         section='statistics',
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

@bp.route('/api/data', methods=['GET'])
def get_statistics_data():
    """API для получения статистических данных"""
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
    
    try:
        user = get_current_user()
        
        # Получаем department_id пользователя, если он начальник ремонтной службы
        department_id = None
        if user['role'] == 'repair_head':
            try:
                emp_service = AdminEmployeeService()
                department_id = emp_service.get_user_department_id(user['user_id'])
            except Exception as e:
                print(f"Ошибка получения department_id: {e}")
                department_id = None
        
        service = AdminStatisticsService()
        statistics = service.get_all_statistics(user_role=user['role'], department_id=department_id)
        
        # Отладочный вывод
        print(f"PTO statistics: {statistics.get('pto', {})}")
        print(f"PTO by_status: {statistics.get('pto', {}).get('by_status', {})}")
        print(f"PTO by_month: {statistics.get('pto', {}).get('by_month', {})}")
        
        return jsonify({'success': True, 'data': statistics})
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Ошибка получения статистики: {error_trace}")
        return jsonify({'success': False, 'message': f'Ошибка загрузки статистики: {str(e)}'}), 500






