"""Маршруты для работы со складом (админ-панель)"""
from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for
from core.auth import get_current_user
from services.admin_warehouse_service import AdminWarehouseService
from utils.formatters import get_role_translation, format_phone

bp = Blueprint('admin_warehouse', __name__, url_prefix='/admin/warehouse')

def check_auth():
    """Проверка авторизации"""
    if 'user_id' not in session:
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
        return redirect(url_for('auth.login'))
    return None

@bp.route('', methods=['GET'])
def list_warehouse():
    """Список склада"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    service = AdminWarehouseService()
    
    # Получаем department_id пользователя, если он начальник ремонтной службы
    department_id = None
    if user['role'] == 'repair_head':
        from services.admin_employee_service import AdminEmployeeService
        emp_service = AdminEmployeeService()
        department_id = emp_service.get_user_department_id(user['user_id'])
    
    parts = service.get_all(user_role=user['role'], department_id=department_id)
    
    # Подготовка данных для фильтров
    facility_options = sorted({part['facility_name'] for part in parts if part.get('facility_name') and part['facility_name'] != '—'})
    warehouse_options = sorted({part['department_name'] for part in parts if part.get('department_name') and part['department_name'] != '—'})
    spare_part_options = sorted({part['spare_part_name'] for part in parts if part.get('spare_part_name') and part['spare_part_name'] != '—'})
    
    # Доступные запчасти и склады для формы добавления
    spare_part_choices = service.get_spare_parts()
    warehouse_choices = service.get_warehouses()
    
    # Получаем список предприятий для формы
    from services.admin_employee_service import AdminEmployeeService
    emp_service = AdminEmployeeService()
    department_choices = emp_service.get_departments()
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
                         section='warehouse',
                         parts=parts,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         facility_options=facility_options,
                         warehouse_options=warehouse_options,
                         spare_part_options=spare_part_options,
                         spare_part_choices=spare_part_choices,
                         warehouse_choices=warehouse_choices,
                         facility_choices=facility_choices)

@bp.route('', methods=['POST'])
def create_part():
    """Создание записи на складе"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    required_fields = ['spare_part_name', 'quantity', 'warehouse_id']
    missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
    if missing:
        return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
    
    try:
        quantity = int(data.get('quantity', 0))
        if quantity <= 0:
            return jsonify({'success': False, 'message': 'Количество должно быть больше нуля.'}), 400
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректное количество.'}), 400
    
    try:
        warehouse_id = int(data.get('warehouse_id'))
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректный склад.'}), 400
    
    try:
        service = AdminWarehouseService()
        part = service.create(data)
        return jsonify({'success': True, 'part': part})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Не удалось добавить деталь: {str(e)}'}), 500

@bp.route('/<int:part_id>', methods=['PATCH'])
def update_part_field(part_id):
    """Обновление поля записи склада"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    payload = request.get_json(silent=True) or {}
    field = payload.get('field')
    value = payload.get('value', '')
    
    try:
        service = AdminWarehouseService()
        service.update_field(part_id, field, value)
        
        display_value = value or ''
        if field == 'facility':
            # При обновлении предприятия возвращаем переданное значение
            display_value = value or '—'
            # Склад всегда будет прочерк, так как при смене предприятия он сбрасывается
            return jsonify({
                'success': True, 
                'value': display_value,
                'warehouse': '—'
            })
        elif field == 'warehouse_id':
            # При обновлении склада получаем обновлённые данные для отображения
            part = service.get_by_id(part_id)
            if part:
                display_value = part.get('department_name') or '—'
                # Также возвращаем предприятие, если оно изменилось
                facility_name = part.get('facility_name') or '—'
                return jsonify({
                    'success': True, 
                    'value': display_value,
                    'facility': facility_name
                })
        elif field == 'spare_part_name':
            # При обновлении названия детали возвращаем обновлённое значение
            part = service.get_by_id(part_id)
            if part:
                display_value = part.get('spare_part_name') or '—'
                return jsonify({'success': True, 'value': display_value})
        elif field == 'quantity':
            # При обновлении количества возвращаем число
            part = service.get_by_id(part_id)
            if part:
                quantity = part.get('quantity')
                display_value = str(quantity) if quantity is not None else '—'
                return jsonify({'success': True, 'value': display_value})
        
        return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/<int:part_id>', methods=['DELETE'])
def delete_part(part_id):
    """Удаление записи со склада"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminWarehouseService()
        service.delete(part_id)
        return jsonify({'success': True, 'message': 'Запись успешно удалена'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось удалить запись.'}), 500
