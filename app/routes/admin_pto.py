"""Маршруты для работы с ПТО (админ-панель)"""
from flask import Blueprint, render_template, session, redirect, url_for, jsonify, request
from core.auth import get_current_user
from utils.formatters import get_role_translation, format_phone
from services.admin_pto_service import AdminPTOService
from datetime import datetime

bp = Blueprint('admin_pto', __name__, url_prefix='/admin/pto')
pto_service = AdminPTOService()

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

@bp.route('/api/calendar', methods=['GET'])
def get_calendar_data():
    """Получить данные ПТО для календаря"""
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    year = request.args.get('year', type=int)
    month = request.args.get('month', type=int)
    
    if not year or not month:
        # Используем текущую дату по умолчанию
        today = datetime.now()
        year = year or today.year
        month = month or today.month
    
    try:
        maintenance_data = pto_service.get_maintenance_data_for_month(year, month)
        return jsonify(maintenance_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/api/date', methods=['GET'])
def get_date_data():
    """Получить данные ПТО для конкретной даты"""
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    date_str = request.args.get('date')
    
    if not date_str:
        # Используем текущую дату по умолчанию
        date_str = datetime.now().strftime('%Y-%m-%d')
    
    try:
        maintenance_data = pto_service.get_maintenance_data_for_date(date_str)
        return jsonify(maintenance_data)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@bp.route('/api/update-status', methods=['POST'])
def update_status():
    """Обновить статус ПТО"""
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    
    data = request.get_json()
    equipment_id = data.get('equipment_id')
    maintenance_date = data.get('maintenance_date')
    status = data.get('status')
    
    if not equipment_id or not maintenance_date or not status:
        return jsonify({'error': 'Missing required parameters'}), 400
    
    try:
        pto_service.update_maintenance_status(equipment_id, maintenance_date, status)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500






