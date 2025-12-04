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
        return jsonify({'success': False, 'message': 'Ошибка поиска.'}), 500

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
    
    # Проверяем, это новое или существующее оборудование
    if data.get('existing_equipment_id'):
        # Существующее оборудование - только создаем assignment
        try:
            service = AdminEquipmentService()
            equipment = service.create_assignment(data)
            return jsonify({'success': True, 'equipment': equipment})
        except Exception as e:
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
    
    try:
        service = AdminEquipmentService()
        service.update_field(equipment_id, field, value)
        
        display_value = value or ''
        
        return jsonify({'success': True, 'value': display_value})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500

@bp.route('/<int:equipment_id>', methods=['DELETE'])
def delete_equipment(equipment_id):
    """Удаление оборудования"""
    auth_check = check_auth()
    if auth_check:
        return auth_check
    
    try:
        service = AdminEquipmentService()
        service.delete(equipment_id)
        return jsonify({'success': True, 'message': 'Оборудование успешно удалено'})
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400
    except Exception:
        return jsonify({'success': False, 'message': 'Не удалось удалить оборудование.'}), 500

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
    
    return render_template('admin.html',
                         section='equipment_passport',
                         equipment=equipment,
                         movement_history=movement_history,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         format_date=format_date,
                         format_characteristics=format_characteristics,
                         role_labels={},  # Пустой словарь для оборудования
                         department_choices=department_choices,
                         facility_choices=facility_choices)

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

