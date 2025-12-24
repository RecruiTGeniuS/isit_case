"""Маршруты для работы с оборудованием (админ-панель)"""
from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for, current_app
from core.auth import get_current_user
from services.admin_equipment_service import AdminEquipmentService
from utils.formatters import get_role_translation, format_phone, format_date, format_characteristics
import os
import werkzeug.utils
from datetime import datetime

bp = Blueprint('admin_equipment', __name__, url_prefix='/admin/equipment')

def check_auth():
    """Проверка авторизации"""
    if 'user_id' not in session:
        if request.is_json or request.headers.get('Content-Type') == 'application/json':
            return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
        return redirect(url_for('auth.login'))
    return None

@bp.route('', methods=['GET'])
def list_equipment():
    """Список оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    service = AdminEquipmentService()
    
    # Получаем department_id пользователя, если он начальник ремонтной службы
    department_id = None
    if user['role'] == 'repair_head':
        # Получаем department_id из employee
        from services.admin_employee_service import AdminEmployeeService
        emp_service = AdminEmployeeService()
        department_id = emp_service.get_user_department_id(user['user_id'])
    
    # Обрабатываем запланированные перемещения перед загрузкой списка
    service.process_scheduled_movements()
    
    equipment = service.get_all(user_role=user['role'], department_id=department_id)
    
    # Подготовка данных для фильтров
    type_options = sorted({eq['equipment_type'] for eq in equipment if eq.get('equipment_type')})
    status_options = sorted({eq['equipment_status'] for eq in equipment if eq.get('equipment_status')})
    location_options = sorted({eq['location'] for eq in equipment if eq.get('location')})
    department_options = sorted({eq['department'] for eq in equipment if eq.get('department')})
    
    # Доступные отделы
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
    
    # Данные для формы добавления
    equipment_types = service.get_types()
    spare_part_types = service.get_spare_part_types()
    image_paths = service.get_image_paths()
    maintenance_frequencies = service.get_maintenance_frequencies()
    
    return render_template('admin.html', 
                         section='equipment',
                         equipment=equipment,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         type_options=type_options,
                         status_options=status_options,
                         location_options=location_options,
                         department_options=department_options,
                         role_labels={},  # Пустой словарь для оборудования
                         department_choices=department_choices,
                         facility_choices=facility_choices,
                         equipment_types=equipment_types,
                         spare_part_types=spare_part_types,
                         image_paths=image_paths,
                         maintenance_frequencies=maintenance_frequencies)

@bp.route('/search', methods=['GET'])
def search_equipment():
    """Поиск оборудования по названию"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    query = request.args.get('q', '').strip()
    if not query or len(query) < 2:
        return jsonify({'success': True, 'results': []})
    
    try:
        service = AdminEquipmentService()
        results = service.search_equipment_by_name(query)
        return jsonify({'success': True, 'results': results})
    except Exception as e:
        current_app.logger.error(f'Ошибка поиска оборудования: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': f'Ошибка поиска: {str(e)}'}), 500

@bp.route('/upload-image', methods=['POST'])
def upload_equipment_image_new():
    """Загрузка изображения оборудования при создании нового"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    if 'equipment_image' not in request.files:
        return jsonify({'success': False, 'message': 'Файл не выбран.'}), 400
    
    file = request.files['equipment_image']
    if file.filename == '':
        return jsonify({'success': False, 'message': 'Файл не выбран.'}), 400
    
    if file:
        # Создаем папку для изображений оборудования, если её нет
        upload_folder = os.path.join(current_app.root_path, 'static', 'images', 'equipment')
        os.makedirs(upload_folder, exist_ok=True)
        
        # Генерируем безопасное имя файла
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"equipment_{timestamp}_{werkzeug.utils.secure_filename(file.filename)}"
        filepath = os.path.join(upload_folder, filename)
        file.save(filepath)
        
        # Возвращаем относительный путь для Flask
        relative_path = f"images/equipment/{filename}"
        return jsonify({'success': True, 'image_path': relative_path})
    
    return jsonify({'success': False, 'message': 'Ошибка загрузки файла.'}), 500

@bp.route('', methods=['POST'])
def create_equipment():
    """Создание оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    data = request.get_json(silent=True) or {}
    
    # Логируем входящие данные для отладки
    current_app.logger.info(f'Создание оборудования. Данные: {data}')
    
    # Проверяем, это новое или существующее оборудование
    if data.get('existing_equipment_id'):
        # Существующее оборудование - только создаем assignment
        try:
            # Логируем данные для отладки
            current_app.logger.info(f'Создание assignment. Данные: {data}')
            service = AdminEquipmentService()
            equipment = service.create_assignment(data)
            return jsonify({'success': True, 'equipment': equipment})
        except ValueError as e:
            current_app.logger.error(f'Ошибка валидации при создании assignment: {str(e)}')
            return jsonify({'success': False, 'message': str(e)}), 400
        except Exception as e:
            current_app.logger.error(f'Ошибка создания assignment: {str(e)}', exc_info=True)
            return jsonify({'success': False, 'message': 'Не удалось добавить оборудование.'}), 500
    else:
        # Новое оборудование
        required_fields = ['equipment_name']
        missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
        if missing:
            return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
        
        try:
            service = AdminEquipmentService()
            equipment = service.create(data)
            return jsonify({'success': True, 'equipment': equipment})
        except Exception as e:
            current_app.logger.error(f'Ошибка создания оборудования: {str(e)}', exc_info=True)
            return jsonify({'success': False, 'message': 'Не удалось добавить оборудование.'}), 500

@bp.route('/<int:equipment_id>', methods=['PATCH'])
def update_equipment_field(equipment_id):
    """Обновление поля оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    payload = request.get_json(silent=True) or {}
    field = payload.get('field')
    value = payload.get('value', '')
    equipment_assignment_id = payload.get('equipment_assignment_id')
    
    try:
        service = AdminEquipmentService()
        service.update_field(equipment_id, field, value, equipment_assignment_id)
        
        # Для department_id нужно вернуть название отдела и предприятия
        if field == 'department_id':
            if value:
                departments = service.get_departments()
                dept = next((d for d in departments if d['id'] == int(value)), None)
                display_value = dept['name'] if dept else value
                facility_name = dept['facility_name'] if dept else None
            else:
                display_value = ''
                facility_name = None
            return jsonify({'success': True, 'value': display_value, 'facility_name': facility_name})
        else:
            display_value = value or ''
            return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/<int:equipment_id>', methods=['DELETE'])
def delete_equipment(equipment_id):
    """Удаление оборудования (полное удаление со всеми assignment'ами)"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEquipmentService()
        service.delete(equipment_id)
        return jsonify({'success': True, 'message': 'Оборудование успешно удалено'})
    except ValueError as e:
        current_app.logger.error(f'Ошибка валидации при удалении оборудования {equipment_id}: {str(e)}')
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка удаления оборудования {equipment_id}: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось удалить оборудование.'}), 500

@bp.route('/assignment/<int:equipment_assignment_id>', methods=['DELETE'])
def delete_equipment_assignment(equipment_assignment_id):
    """Удаление размещения оборудования (только assignment, не само оборудование)"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEquipmentService()
        service.delete_assignment(equipment_assignment_id)
        return jsonify({'success': True, 'message': 'Размещение оборудования успешно удалено'})
    except ValueError as e:
        current_app.logger.error(f'Ошибка валидации при удалении размещения {equipment_assignment_id}: {str(e)}')
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка удаления размещения {equipment_assignment_id}: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось удалить размещение оборудования.'}), 500

@bp.route('/passport/<int:equipment_id>/spare-part', methods=['POST'])
def add_spare_part(equipment_id):
    """Добавить деталь к оборудованию"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'message': 'Данные не получены.'}), 400
        
        spare_part_name = data.get('spare_part_name', '').strip()
        spare_part_type = data.get('spare_part_type', '').strip()
        
        if not spare_part_name:
            return jsonify({'success': False, 'message': 'Укажите название детали.'}), 400
        
        if not spare_part_type:
            return jsonify({'success': False, 'message': 'Укажите тип детали.'}), 400
        
        service = AdminEquipmentService()
        spare_part_id = service.add_spare_part(equipment_id, spare_part_name, spare_part_type)
        
        if spare_part_id:
            # Получаем обновленный список деталей
            spare_parts = service.get_spare_parts(equipment_id)
            
            return jsonify({
                'success': True,
                'message': 'Деталь успешно добавлена',
                'spare_part_id': spare_part_id,
                'spare_parts': spare_parts
            })
        else:
            return jsonify({'success': False, 'message': 'Не удалось добавить деталь.'}), 500
    except Exception as e:
        current_app.logger.error(f'Ошибка добавления детали: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось добавить деталь.'}), 500

@bp.route('/spare-part/<int:spare_part_id>', methods=['PATCH'])
def update_spare_part(spare_part_id):
    """Обновить поле детали"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'message': 'Данные не получены.'}), 400
        
        field = data.get('field')
        value = data.get('value', '').strip()
        
        if not field:
            return jsonify({'success': False, 'message': 'Не указано поле для обновления.'}), 400
        
        service = AdminEquipmentService()
        service.update_spare_part_field(spare_part_id, field, value)
        
        # Получаем обновленную деталь для возврата актуального значения
        spare_part = service.get_spare_part_by_id(spare_part_id)
        if not spare_part:
            return jsonify({'success': False, 'message': 'Деталь не найдена.'}), 404
        
        # Возвращаем значение в зависимости от поля
        if field == 'name':
            display_value = spare_part.get('name') or '—'
        elif field == 'type':
            display_value = spare_part.get('type') or '—'
        else:
            display_value = value
        
        return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка обновления детали: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/spare-part/<int:spare_part_id>', methods=['DELETE'])
def delete_spare_part(spare_part_id):
    """Удалить деталь"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEquipmentService()
        service.delete_spare_part(spare_part_id)
        return jsonify({'success': True, 'message': 'Деталь успешно удалена'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 404
    except Exception as e:
        current_app.logger.error(f'Ошибка удаления детали: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось удалить деталь.'}), 500

@bp.route('/movement/<int:movement_id>', methods=['PATCH'])
def update_movement(movement_id):
    """Обновить поле перемещения"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'message': 'Данные не получены.'}), 400
        
        field = data.get('field')
        value = data.get('value', '').strip()
        
        if not field:
            return jsonify({'success': False, 'message': 'Не указано поле для обновления.'}), 400
        
        service = AdminEquipmentService()
        service.update_movement_field(movement_id, field, value)
        
        # Получаем обновленное перемещение для возврата актуального значения
        movement = service.get_movement_by_id(movement_id)
        if not movement:
            return jsonify({'success': False, 'message': 'Перемещение не найдено.'}), 404
        
        # Возвращаем значение в зависимости от поля
        if field == 'move_date':
            from utils.formatters import format_date
            display_value = format_date(movement.get('move_date')) or '—'
        else:
            display_value = value
        
        return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка обновления перемещения: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/movement/<int:movement_id>', methods=['DELETE'])
def delete_movement(movement_id):
    """Удаление записи о перемещении оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEquipmentService()
        service.delete_movement(movement_id)
        return jsonify({'success': True, 'message': 'Перемещение успешно удалено'})
    except ValueError as e:
        current_app.logger.error(f'Ошибка валидации при удалении перемещения {movement_id}: {str(e)}')
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка удаления перемещения {movement_id}: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось удалить перемещение.'}), 500

@bp.route('/passport/<int:equipment_id>', methods=['GET'])
def equipment_passport(equipment_id):
    """Страница паспорта оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    user = get_current_user()
    service = AdminEquipmentService()
    equipment = service.get_by_id(equipment_id)
    
    if not equipment:
        return redirect(url_for('admin_equipment.list_equipment'))
    
    # Получаем необходимые данные для шаблона
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
    
    # Получаем историю перемещений
    movement_history = []
    if equipment.get('equipment_assignment_id'):
        movement_history = service.get_movement_history(equipment['equipment_assignment_id'])
    
    # Подготовка данных для фильтров
    from_location_options = sorted({m['from_location'] for m in movement_history if m.get('from_location') and m.get('from_location') != '—'})
    to_location_options = sorted({m['to_location'] for m in movement_history if m.get('to_location') and m.get('to_location') != '—'})
    
    # Получаем список деталей для оборудования
    spare_parts = []
    equipment_id_for_parts = equipment.get('equipment_id') or equipment.get('id')
    if equipment_id_for_parts:
        spare_parts = service.get_spare_parts(equipment_id_for_parts)
    
    # Получаем типы деталей для фильтра и добавления
    spare_part_types = service.get_spare_part_types()
    
    return render_template('admin.html',
                         section='equipment_passport',
                         equipment=equipment,
                         movement_history=movement_history,
                         spare_parts=spare_parts,
                         spare_part_types=spare_part_types,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         format_date=format_date,
                         format_characteristics=format_characteristics,
                         role_labels={},  # Пустой словарь для оборудования
                         department_choices=department_choices,
                         facility_choices=facility_choices,
                         from_location_options=from_location_options,
                         to_location_options=to_location_options)

@bp.route('/passport/<int:equipment_id>/movement', methods=['POST'])
def create_movement(equipment_id):
    """Создать запись о перемещении оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'message': 'Данные не получены.'}), 400
        
        service = AdminEquipmentService()
        equipment = service.get_by_id(equipment_id)
        
        if not equipment or not equipment.get('equipment_assignment_id'):
            return jsonify({'success': False, 'message': 'Оборудование не найдено или не имеет размещения.'}), 404
        
        movement_id, location_updated = service.create_movement(equipment['equipment_assignment_id'], data)
        
        # Получаем обновленную историю перемещений
        movement_history = service.get_movement_history(equipment['equipment_assignment_id'])
        
        return jsonify({
            'success': True,
            'message': 'Перемещение успешно добавлено',
            'movement_id': movement_id,
            'movement_history': movement_history,
            'location_updated': location_updated
        })
    except ValueError as e:
        current_app.logger.error(f'Ошибка валидации при создании перемещения: {str(e)}')
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка создания перемещения: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось создать перемещение.'}), 500

@bp.route('/<int:equipment_id>/movement', methods=['POST'])
def create_movement_from_table(equipment_id):
    """Создать запись о перемещении оборудования из таблицы"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'message': 'Данные не получены.'}), 400
        
        service = AdminEquipmentService()
        equipment = service.get_by_id(equipment_id)
        
        if not equipment or not equipment.get('equipment_assignment_id'):
            return jsonify({'success': False, 'message': 'Оборудование не найдено или не имеет размещения.'}), 404
        
        movement_id, location_updated = service.create_movement(equipment['equipment_assignment_id'], data)
        
        return jsonify({
            'success': True,
            'message': 'Перемещение успешно добавлено',
            'movement_id': movement_id,
            'location_updated': location_updated
        })
    except ValueError as e:
        current_app.logger.error(f'Ошибка валидации при создании перемещения: {str(e)}')
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception as e:
        current_app.logger.error(f'Ошибка создания перемещения: {str(e)}', exc_info=True)
        return jsonify({'success': False, 'message': 'Не удалось создать перемещение.'}), 500

@bp.route('/passport/<int:equipment_id>/upload-image', methods=['POST'])
def upload_equipment_image(equipment_id):
    """Загрузка изображения оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    if 'image' not in request.files:
        return jsonify({'success': False, 'message': 'Файл не найден'}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({'success': False, 'message': 'Файл не выбран'}), 400
    
    if file:
        # Проверяем, что это изображение
        if not file.filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp')):
            return jsonify({'success': False, 'message': 'Недопустимый формат файла'}), 400
        
        # Создаем папку для изображений оборудования, если её нет
        equipment_images_folder = os.path.join(
            os.path.dirname(__file__), '..', 'static', 'images', 'equipment'
        )
        os.makedirs(equipment_images_folder, exist_ok=True)
        
        # Генерируем безопасное имя файла
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"equipment_{equipment_id}_{timestamp}_{werkzeug.utils.secure_filename(file.filename)}"
        filepath = os.path.join(equipment_images_folder, filename)
        file.save(filepath)
        
        # Сохраняем путь в БД (относительный путь для Flask)
        relative_path = f"images/equipment/{filename}"
        service = AdminEquipmentService()
        
        from core.database import get_db_cursor
        with get_db_cursor(commit=True) as cur:
            cur.execute(
                "UPDATE equipment SET image_path = %s WHERE equipment_id = %s",
                (relative_path, equipment_id)
            )
        
        return jsonify({
            'success': True,
            'message': 'Изображение успешно загружено',
            'image_path': relative_path
        })
    
    return jsonify({'success': False, 'message': 'Ошибка при загрузке файла'}), 500

