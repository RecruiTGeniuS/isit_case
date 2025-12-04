"""Сервис для работы с ПТО"""
from datetime import datetime, date, timedelta
from core.database import get_db_cursor


class AdminPTOService:
    """Сервис для работы с ПТО"""
    
    def calculate_maintenance_dates(self, acquisition_date, maintenance_frequency, start_date=None, end_date=None):
        """
        Рассчитывает даты ПТО на основе даты приобретения и частоты обслуживания
        
        Args:
            acquisition_date: Дата приобретения оборудования
            maintenance_frequency: Частота проведения ПТО в днях
            start_date: Начальная дата для расчета (опционально)
            end_date: Конечная дата для расчета (опционально)
        
        Returns:
            Список дат ПТО
        """
        if not acquisition_date or not maintenance_frequency:
            return []
        
        if isinstance(acquisition_date, str):
            acquisition_date = datetime.strptime(acquisition_date, '%Y-%m-%d').date()
        
        if isinstance(start_date, str):
            start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
        
        if isinstance(end_date, str):
            end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
        
        maintenance_dates = []
        current_date = acquisition_date + timedelta(days=maintenance_frequency)
        
        # Если указан диапазон, рассчитываем только в его пределах
        if start_date and end_date:
            # Находим первую дату ПТО после или равную start_date
            while current_date < start_date:
                current_date += timedelta(days=maintenance_frequency)
            
            while current_date <= end_date:
                maintenance_dates.append(current_date)
                current_date += timedelta(days=maintenance_frequency)
        else:
            # Рассчитываем на год вперед
            end_calc = date.today() + timedelta(days=365)
            while current_date <= end_calc:
                maintenance_dates.append(current_date)
                current_date += timedelta(days=maintenance_frequency)
        
        return maintenance_dates
    
    def get_maintenance_data_for_month(self, year, month):
        """
        Получает данные ПТО для указанного месяца
        
        Args:
            year: Год
            month: Месяц (1-12)
        
        Returns:
            Словарь с датами в качестве ключей и списками ПТО в качестве значений
        """
        # Определяем диапазон дат для месяца
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(year, month + 1, 1) - timedelta(days=1)
        
        maintenance_data = {}
        
        with get_db_cursor() as cur:
            # Получаем все назначения оборудования с их данными
            cur.execute("""
                SELECT 
                    ea.equipment_assignment_id,
                    ea.acquisition_date,
                    ea.location,
                    ea.department_id,
                    e.equipment_id,
                    e.equipment_name,
                    e.maintenance_frequency,
                    d.department_name
                FROM equipment_assignment ea
                JOIN equipment e ON ea.equipment_id = e.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE ea.acquisition_date IS NOT NULL 
                    AND e.maintenance_frequency IS NOT NULL
                    AND e.maintenance_frequency > 0
            """)
            
            assignments = cur.fetchall()
            
            for assignment in assignments:
                assignment_id = assignment[0]
                acquisition_date = assignment[1]
                location = assignment[2]
                department_id = assignment[3]
                equipment_id = assignment[4]
                equipment_name = assignment[5]
                maintenance_frequency = assignment[6]
                department_name = assignment[7] or ''
                
                # Рассчитываем даты ПТО для этого оборудования
                maintenance_dates = self.calculate_maintenance_dates(
                    acquisition_date,
                    maintenance_frequency,
                    start_date,
                    end_date
                )
                
                # Получаем статусы ПТО из maintenance_plan
                for maint_date in maintenance_dates:
                    date_str = maint_date.strftime('%Y-%m-%d')
                    
                    # Проверяем статус ПТО в базе данных
                    cur.execute("""
                        SELECT maintenance_status
                        FROM maintenance_plan
                        WHERE equipment_id = %s
                            AND maintenance_start_date = %s
                        ORDER BY maintenance_plan_id DESC
                        LIMIT 1
                    """, (equipment_id, maint_date))
                    
                    status_row = cur.fetchone()
                    status = None
                    if status_row:
                        status = status_row[0]
                    
                    # Определяем цвет индикатора
                    today = date.today()
                    if maint_date > today:
                        # Планируемое ПТО (еще не наступило)
                        indicator_color = 'yellow'
                        status_display = 'Ожидает ПТО'
                    elif status:
                        # Есть запись в maintenance_plan
                        status_lower = status.lower()
                        if any(word in status_lower for word in ['успешно', 'завершено', 'completed', 'success', 'выполнено', 'готово']):
                            indicator_color = 'green'
                            status_display = 'Завершено успешно'
                        elif any(word in status_lower for word in ['не', 'failed', 'провал', 'ошибка', 'error', 'отменено', 'cancelled']):
                            indicator_color = 'red'
                            status_display = 'Не завершилось успешно'
                        else:
                            # Неизвестный статус - считаем ожидающим
                            indicator_color = 'yellow'
                            status_display = status
                    else:
                        # Прошло, но нет записи - считаем ожидающим
                        indicator_color = 'yellow'
                        status_display = 'Ожидает ПТО'
                    
                    if date_str not in maintenance_data:
                        maintenance_data[date_str] = []
                    
                    maintenance_data[date_str].append({
                        'equipment_assignment_id': assignment_id,
                        'equipment_id': equipment_id,
                        'equipment_name': equipment_name,
                        'department_name': department_name,
                        'location': location or '',
                        'status': status_display,
                        'indicator_color': indicator_color,
                        'maintenance_date': date_str
                    })
        
        return maintenance_data
    
    def get_maintenance_data_for_date(self, target_date):
        """
        Получает данные ПТО для конкретной даты
        
        Args:
            target_date: Дата в формате 'YYYY-MM-DD' или объект date
        
        Returns:
            Список словарей с данными ПТО
        """
        if isinstance(target_date, str):
            target_date = datetime.strptime(target_date, '%Y-%m-%d').date()
        
        result = []
        
        with get_db_cursor() as cur:
            # Получаем все назначения оборудования
            cur.execute("""
                SELECT 
                    ea.equipment_assignment_id,
                    ea.acquisition_date,
                    ea.location,
                    ea.department_id,
                    e.equipment_id,
                    e.equipment_name,
                    e.maintenance_frequency,
                    d.department_name
                FROM equipment_assignment ea
                JOIN equipment e ON ea.equipment_id = e.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE ea.acquisition_date IS NOT NULL 
                    AND e.maintenance_frequency IS NOT NULL
                    AND e.maintenance_frequency > 0
            """)
            
            assignments = cur.fetchall()
            
            for assignment in assignments:
                assignment_id = assignment[0]
                acquisition_date = assignment[1]
                location = assignment[2]
                department_id = assignment[3]
                equipment_id = assignment[4]
                equipment_name = assignment[5]
                maintenance_frequency = assignment[6]
                department_name = assignment[7] or ''
                
                # Рассчитываем даты ПТО для этого оборудования
                maintenance_dates = self.calculate_maintenance_dates(
                    acquisition_date,
                    maintenance_frequency
                )
                
                # Проверяем, есть ли ПТО на целевую дату
                if target_date in maintenance_dates:
                    # Получаем статус ПТО из maintenance_plan
                    cur.execute("""
                        SELECT maintenance_status
                        FROM maintenance_plan
                        WHERE equipment_id = %s
                            AND maintenance_start_date = %s
                        ORDER BY maintenance_plan_id DESC
                        LIMIT 1
                    """, (equipment_id, target_date))
                    
                    status_row = cur.fetchone()
                    status = None
                    if status_row:
                        status = status_row[0]
                    
                    # Определяем статус для отображения
                    today = date.today()
                    if target_date > today:
                        status_display = 'Ожидает ПТО'
                    elif status:
                        status_lower = status.lower()
                        if any(word in status_lower for word in ['успешно', 'завершено', 'completed', 'success', 'выполнено', 'готово']):
                            status_display = 'Завершено успешно'
                        elif any(word in status_lower for word in ['не', 'failed', 'провал', 'ошибка', 'error', 'отменено', 'cancelled']):
                            status_display = 'Не завершилось успешно'
                        else:
                            status_display = status
                    else:
                        status_display = 'Ожидает ПТО'
                    
                    result.append({
                        'equipment_assignment_id': assignment_id,
                        'equipment_id': equipment_id,
                        'equipment_name': equipment_name,
                        'department_name': department_name,
                        'location': location or '',
                        'status': status_display
                    })
        
        return result

