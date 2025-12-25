"""Маршруты для работы с задачами на ремонт (админ-панель)"""
from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for
from core.auth import get_current_user
from services.admin_tasks_service import AdminTasksService
from utils.formatters import get_role_translation, format_phone

bp = Blueprint('admin_tasks', __name__, url_prefix='/admin/tasks')

def check_auth():
    """Проверка авторизации"""
    if 'user_id' not in session:
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
        return redirect(url_for('auth.login'))
    return None

@bp.route('', methods=['GET'])
def list_tasks():
    """Список задач на ремонт"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    service = AdminTasksService()
    
    # Получаем department_id пользователя, если он начальник ремонтной службы
    department_id = None
    if user['role'] == 'repair_head':
        from services.admin_employee_service import AdminEmployeeService
        emp_service = AdminEmployeeService()
        department_id = emp_service.get_user_department_id(user['user_id'])
    
    # Проверяем фильтр по статусу
    include_completed = request.args.get('include_completed', 'false').lower() == 'true'
    tasks = service.get_all(user_role=user['role'], department_id=department_id, include_completed=include_completed)
    
    # Получаем списки для выпадающих списков
    department_choices = service.get_departments()
    facility_choices = service.get_facilities()
    
    return render_template('admin.html',
                         section='tasks',
                         tasks=tasks,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         department_choices=department_choices,
                         facility_choices=facility_choices)

@bp.route('', methods=['POST'])
def create_task():
    """Создание задачи на ремонт"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    print(f"Получены данные для создания задачи: {data}")
    
    required_fields = ['equipment_assignment_id', 'heading', 'repair_task_description']
    missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
    if missing:
        print(f"Отсутствуют обязательные поля: {missing}")
        return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
    
    try:
        equipment_assignment_id_str = str(data.get('equipment_assignment_id', '')).strip()
        print(f"equipment_assignment_id (строка): {equipment_assignment_id_str}")
        if not equipment_assignment_id_str:
            return jsonify({'success': False, 'message': 'Не указано оборудование.'}), 400
        equipment_assignment_id = int(equipment_assignment_id_str)
        print(f"equipment_assignment_id (число): {equipment_assignment_id}")
        # Обновляем data для передачи в сервис
        data['equipment_assignment_id'] = equipment_assignment_id
    except (TypeError, ValueError) as e:
        print(f"Ошибка преобразования equipment_assignment_id: {e}, значение: {data.get('equipment_assignment_id')}")
        return jsonify({'success': False, 'message': f'Некорректное оборудование: {str(e)}'}), 400
    
    try:
        service = AdminTasksService()
        task = service.create(data)
        print(f"Задача успешно создана: {task}")
        return jsonify({'success': True, 'task': task})
    except Exception as e:
        print(f"Ошибка при создании задачи: {e}", exc_info=True)
        return jsonify({'success': False, 'message': f'Не удалось создать задачу: {str(e)}'}), 500

@bp.route('/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Получить задачу по ID"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        task = service.get_by_id(task_id)
        if not task:
            return jsonify({'success': False, 'message': 'Задача не найдена'}), 404
        return jsonify({'success': True, 'task': task})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@bp.route('/<int:task_id>/status', methods=['PATCH'])
def update_task_status(task_id):
    """Обновление статуса задачи"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    payload = request.get_json(silent=True) or {}
    status = payload.get('status')
    
    if not status:
        return jsonify({'success': False, 'message': 'Статус не указан'}), 400
    
    try:
        service = AdminTasksService()
        service.update_status(task_id, status)
        return jsonify({'success': True, 'message': 'Статус обновлен'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось обновить статус.'}), 500

@bp.route('/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Удаление задачи"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        service.delete(task_id)
        return jsonify({'success': True, 'message': 'Задача успешно удалена'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        return jsonify({'success': False, 'message': f'Не удалось удалить задачу: {str(e)}'}), 500

@bp.route('/equipment/<int:department_id>', methods=['GET'])
def get_equipment_by_department(department_id):
    """Получить оборудование по отделу"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        equipment = service.get_equipment_by_department(department_id)
        return jsonify({'success': True, 'equipment': equipment})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@bp.route('/<int:task_id>/employees', methods=['GET'])
def get_task_employees(task_id):
    """Получить сотрудников, назначенных на задачу"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        employees = service.get_task_employees(task_id)
        return jsonify({'success': True, 'employees': employees})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@bp.route('/employees/facility/<int:facility_id>', methods=['GET'])
def get_employees_by_facility(facility_id):
    """Получить сотрудников по предприятию"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        employees = service.get_employees_by_facility(facility_id)
        return jsonify({'success': True, 'employees': employees})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@bp.route('/<int:task_id>/assign-employees', methods=['POST'])
def assign_employees_to_task(task_id):
    """Назначить сотрудников на задачу"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    employee_ids = data.get('employee_ids', [])
    
    if not isinstance(employee_ids, list):
        return jsonify({'success': False, 'message': 'Некорректный формат данных'}), 400
    
    try:
        # Преобразуем в числа
        employee_ids = [int(emp_id) for emp_id in employee_ids if emp_id]
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректные ID сотрудников'}), 400
    
    try:
        service = AdminTasksService()
        service.assign_employees(task_id, employee_ids)
        return jsonify({'success': True, 'message': 'Сотрудники успешно назначены'})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Не удалось назначить сотрудников: {str(e)}'}), 500

@bp.route('/<int:task_id>/complete', methods=['POST'])
def complete_task(task_id):
    """Завершить задачу"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    resolution = data.get('resolution', '').strip()
    spare_part_quantities = data.get('spare_part_quantities', {})
    
    if not resolution:
        return jsonify({'success': False, 'message': 'Необходимо указать описание выполненных работ'}), 400
    
    if not isinstance(spare_part_quantities, dict):
        return jsonify({'success': False, 'message': 'Некорректный формат данных'}), 400
    
    try:
        # Преобразуем в словарь {spare_part_id: quantity}
        spare_part_quantities = {
            int(part_id): int(quantity) 
            for part_id, quantity in spare_part_quantities.items() 
            if part_id and quantity and int(quantity) > 0
        }
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректные данные о запчастях'}), 400
    
    try:
        service = AdminTasksService()
        service.complete_task(task_id, resolution, spare_part_quantities)
        return jsonify({'success': True, 'message': 'Задача успешно завершена'})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Не удалось завершить задачу: {str(e)}'}), 500

@bp.route('/<int:task_id>/spare-parts', methods=['GET'])
def get_spare_parts_for_task(task_id):
    """Получить список запчастей для задачи (по оборудованию и предприятию)"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        task = service.get_by_id(task_id)
        if not task:
            return jsonify({'success': False, 'message': 'Задача не найдена'}), 404
        
        equipment_id = task.get('equipment_id')
        facility_id = task.get('facility_id')
        
        if not equipment_id or not facility_id:
            return jsonify({'success': False, 'message': 'Не удалось определить оборудование или предприятие'}), 400
        
        spare_parts = service.get_spare_parts_for_equipment(equipment_id, facility_id)
        return jsonify({'success': True, 'spare_parts': spare_parts})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

