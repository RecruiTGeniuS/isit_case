"""Утилиты для форматирования данных"""
def get_role_translation(role):
    """Перевод ролей на русский"""
    translations = {
        'dept_head': 'Начальник отдела',
        'repair_head': 'Начальник ремонтной службы',
        'store_keeper': 'Заведующий складом',
        'geology_head': 'Начальник геологоразведочного отдела',
        'workshop_head': 'Начальник цеха',
        'repair_worker': 'Сотрудник ремонтной службы',
        'maintenance_admin': 'Администратор ТОиР',
        'procurement_analyst': 'Производственный аналитик',
        'operations_manager': 'Управляющий производством',
        'spare_buyer': 'Закупщик деталей на склад'
    }
    return translations.get(role, role)

def format_phone(phone):
    """Форматирование телефонного номера"""
    if not phone:
        return None
    digits = ''.join(filter(str.isdigit, phone))
    if len(digits) == 11 and digits.startswith('7'):
        return f"+7 ({digits[1:4]}) {digits[4:7]}-{digits[7:9]}-{digits[9:11]}"
    if len(digits) == 10:
        return f"+7 ({digits[0:3]}) {digits[3:6]}-{digits[6:8]}-{digits[8:10]}"
    return phone






