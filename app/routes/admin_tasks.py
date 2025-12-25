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

@bp.route('/<int:task_id>/report', methods=['GET'])
def generate_task_report(task_id):
    """Генерация отчёта о завершённой задаче"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminTasksService()
        task = service.get_by_id(task_id)
        if not task:
            return jsonify({'success': False, 'message': 'Задача не найдена'}), 404
        
        # Проверяем, что задача завершена
        if task.get('status') not in ['Завершено', 'Завершена']:
            return jsonify({'success': False, 'message': 'Отчёт можно создать только для завершённых задач'}), 400
        
        # Получаем данные для отчёта
        employees = service.get_task_employees(task_id)
        
        # Получаем использованные запчасти
        from core.database import get_db_cursor
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    sp.spare_part_id,
                    sp.spare_part_name,
                    sp.spare_part_type,
                    COUNT(rsp.spare_part_id) as quantity_used
                FROM repair_spare_part rsp
                INNER JOIN spare_part sp ON rsp.spare_part_id = sp.spare_part_id
                WHERE rsp.repair_task_id = %s
                GROUP BY sp.spare_part_id, sp.spare_part_name, sp.spare_part_type
                ORDER BY sp.spare_part_name
            """, (task_id,))
            spare_parts = [
                {
                    'id': row[0],
                    'name': row[1] or '—',
                    'type': row[2] or '—',
                    'quantity': row[3] or 0
                }
                for row in cur.fetchall()
            ]
        
        # Формируем HTML отчёт
        from datetime import datetime
        report_html = f"""
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Отчёт о выполнении задачи #{task_id}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 20px;
            color: #333;
        }}
        .header {{
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #dd9e00;
            padding-bottom: 20px;
        }}
        .header h1 {{
            color: #dd9e00;
            margin: 0;
        }}
        .section {{
            margin-bottom: 25px;
        }}
        .section h2 {{
            color: #dd9e00;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
        }}
        .info-row {{
            display: flex;
            margin-bottom: 10px;
        }}
        .info-label {{
            font-weight: bold;
            width: 200px;
        }}
        .info-value {{
            flex: 1;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }}
        th, td {{
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }}
        th {{
            background-color: #f5f5f5;
            font-weight: bold;
        }}
        .resolution {{
            background-color: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #dd9e00;
            margin-top: 10px;
            white-space: pre-wrap;
        }}
        .footer {{
            margin-top: 30px;
            text-align: right;
            color: #666;
            font-size: 12px;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Отчёт о выполнении задачи на ремонт</h1>
        <p>Дата формирования: {datetime.now().strftime('%d.%m.%Y %H:%M')}</p>
    </div>
    
    <div class="section">
        <h2>Общая информация</h2>
        <div class="info-row">
            <div class="info-label">Номер задачи:</div>
            <div class="info-value">#{task_id}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Название:</div>
            <div class="info-value">{task.get('heading', '—')}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Дата начала:</div>
            <div class="info-value">{task.get('start_date', '—')}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Дата завершения:</div>
            <div class="info-value">{task.get('end_date', '—')}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Статус:</div>
            <div class="info-value">{task.get('status', '—')}</div>
        </div>
    </div>
    
    <div class="section">
        <h2>Оборудование для которого нужен был ремонт</h2>
        <div class="info-row">
            <div class="info-label">Название:</div>
            <div class="info-value">{task.get('equipment_name', '—')}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Отдел:</div>
            <div class="info-value">{task.get('department_name', '—')}</div>
        </div>
        <div class="info-row">
            <div class="info-label">Предприятие:</div>
            <div class="info-value">{task.get('facility_name', '—')}</div>
        </div>
    </div>
    
    <div class="section">
        <h2>Описание задачи</h2>
        <div class="resolution">{task.get('description', '—')}</div>
    </div>
    
    <div class="section">
        <h2>Выполненные работы</h2>
        <div class="resolution">{task.get('resolution', '—')}</div>
    </div>
    
    <div class="section">
        <h2>Сотрудники, выполнявшие ремонт</h2>
        {f'''
        <table>
            <thead>
                <tr>
                    <th>№</th>
                    <th>ФИО</th>
                    <th>Должность</th>
                </tr>
            </thead>
            <tbody>
                {''.join([f'''
                <tr>
                    <td>{i+1}</td>
                    <td>{emp.get('full_name', '—')}</td>
                    <td>{emp.get('post', '—')}</td>
                </tr>
                ''' for i, emp in enumerate(employees)])}
            </tbody>
        </table>
        ''' if employees else '<p>Сотрудники не назначены</p>'}
    </div>
    
    <div class="section">
        <h2>Используемые в ремонте детали</h2>
        {f'''
        <table>
            <thead>
                <tr>
                    <th>№</th>
                    <th>Название</th>
                    <th>Тип</th>
                    <th>Количество</th>
                </tr>
            </thead>
            <tbody>
                {''.join([f'''
                <tr>
                    <td>{i+1}</td>
                    <td>{part.get('name', '—')}</td>
                    <td>{part.get('type', '—')}</td>
                    <td>{part.get('quantity', 0)}</td>
                </tr>
                ''' for i, part in enumerate(spare_parts)])}
            </tbody>
        </table>
        ''' if spare_parts else '<p>Запчасти не использовались</p>'}
    </div>
    
    <div class="footer">
        <p>Сгенерировано системой УТОР</p>
    </div>
</body>
</html>
        """
        
        from flask import Response
        return Response(report_html, mimetype='text/html')
        
    except Exception as e:
        return jsonify({'success': False, 'message': f'Не удалось создать отчёт: {str(e)}'}), 500

