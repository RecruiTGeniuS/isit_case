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
    
    tasks = service.get_all(user_role=user['role'], department_id=department_id)
    
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
    required_fields = ['department_id', 'heading', 'repair_task_description']
    missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
    if missing:
        return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
    
    try:
        department_id = int(data.get('department_id'))
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректный отдел.'}), 400
    
    try:
        service = AdminTasksService()
        task = service.create(data)
        return jsonify({'success': True, 'task': task})
    except Exception as e:
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

