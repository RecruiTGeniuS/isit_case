"""Маршруты для работы с сотрудниками (админ-панель)"""
from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for
from core.auth import get_current_user
from core.database import get_db_cursor
from services.admin_employee_service import AdminEmployeeService
from utils.formatters import format_phone, get_role_translation

bp = Blueprint('admin_employees', __name__, url_prefix='/admin/employees')

def check_auth():
    """Проверка авторизации"""
    if 'user_id' not in session:
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
        return redirect(url_for('auth.login'))
    return None

@bp.route('', methods=['GET'])
def list_employees():
    """Список сотрудников"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    service = AdminEmployeeService()
    
    # Получаем department_id пользователя, если он начальник ремонтной службы
    department_id = None
    if user['role'] == 'repair_head':
        department_id = service.get_user_department_id(user['user_id'])
    
    employees = service.get_all(user_role=user['role'], department_id=department_id)
    
    # Подготовка данных для фильтров
    role_options = sorted({emp['role'] for emp in employees if emp.get('role')})
    department_options = sorted({emp['department'] for emp in employees if emp.get('department')})
    facility_options = sorted({emp['facility'] for emp in employees if emp.get('facility')})
    role_labels = {role: get_role_translation(role) for role in role_options}
    
    # Доступные отделы и предприятия
    department_choices = service.get_departments()
    facility_choices = []
    seen_facilities = set()
    for dept in department_choices:
        facility_id = dept.get('facility_id')
        facility_name = dept.get('facility_name')
        if facility_id and facility_id not in seen_facilities:
            seen_facilities.add(facility_id)
            facility_choices.append({
                'id': facility_id,
                'name': facility_name
            })
    facility_choices.sort(key=lambda item: (item['name'] or '').lower())
    
    return render_template('admin.html', 
                         section='employees',
                         employees=employees,
                         user=session,  # Используем session напрямую для совместимости с шаблоном
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         role_options=role_options,
                         department_options=department_options,
                         facility_options=facility_options,
                         role_labels=role_labels,
                         department_choices=department_choices,
                         facility_choices=facility_choices)

@bp.route('', methods=['POST'])
def create_employee():
    """Создание сотрудника"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    required_fields = ['last_name', 'first_name', 'post', 'role', 'login', 'password', 'department_id']
    missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
    if missing:
        return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
    
    try:
        department_id = int(data.get('department_id'))
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректный отдел.'}), 400
    
    try:
        service = AdminEmployeeService()
        employee = service.create(data)
        return jsonify({'success': True, 'employee': employee})
    except Exception as e:
        return jsonify({'success': False, 'message': 'Не удалось добавить сотрудника.'}), 500

@bp.route('/<int:employee_id>', methods=['PATCH'])
def update_employee_field(employee_id):
    """Обновление поля сотрудника"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    payload = request.get_json(silent=True) or {}
    field = payload.get('field')
    value = payload.get('value', '')
    
    try:
        service = AdminEmployeeService()
        service.update_field(employee_id, field, value)
        
        display_value = value or ''
        if field == 'phone' and display_value:
            display_value = format_phone(display_value)
        elif field == 'facility':
            # При обновлении предприятия возвращаем переданное значение
            # (так как facility_name берется из JOIN и может быть NULL если отдел сброшен)
            display_value = value or '—'
            # Отдел всегда будет прочерк, так как при смене предприятия он сбрасывается
            return jsonify({
                'success': True, 
                'value': display_value,
                'department': '—'
            })
        elif field == 'department_id':
            # При обновлении отдела получаем обновлённые данные для отображения
            employee = service.get_by_id(employee_id)
            if employee:
                display_value = employee.get('department') or '—'
                return jsonify({
                    'success': True, 
                    'value': display_value
                })
        
        return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/<int:employee_id>', methods=['DELETE'])
def delete_employee(employee_id):
    """Удаление сотрудника"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEmployeeService()
        service.delete(employee_id)
        return jsonify({'success': True, 'message': 'Сотрудник успешно удалён'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось удалить сотрудника.'}), 500

