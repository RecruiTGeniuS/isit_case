"""Сервис для работы с оборудованием (админ-панель)"""
from core.database import get_db_cursor

class AdminEquipmentService:
    """Сервис для работы с оборудованием"""
    
    def get_all(self, user_role=None, department_id=None):
        """Получить все оборудование с присвоениями"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    ea.equipment_assignment_id,
                    ea.location,
                    ea.equipment_status,
                    ea.department_id,
                    d.department_name,
                    f.facility_name
                FROM equipment e
                INNER JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE e.equipment_name IS NOT NULL 
                AND e.equipment_name != ''
                AND ea.equipment_assignment_id IS NOT NULL
            """
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND ea.department_id = %s"
                params.append(department_id)
            
            query += " ORDER BY e.equipment_name"
            
            cur.execute(query, params)
            rows = cur.fetchall()
            # Фильтруем записи без названия оборудования
            result = []
            for row in rows:
                equipment_dict = self._row_to_dict(row)
                # Пропускаем записи без названия оборудования
                if equipment_dict.get('equipment_name') and equipment_dict.get('equipment_name').strip():
                    result.append(equipment_dict)
            return result
    
    def get_by_id(self, equipment_id):
        """Получить оборудование по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    e.image_path,
                    e.characteristics,
                    e.warranty_period,
                    e.maintenance_frequency,
                    ea.equipment_assignment_id,
                    ea.location,
                    ea.equipment_status,
                    ea.department_id,
                    ea.acquisition_date,
                    d.department_name,
                    f.facility_name
                FROM equipment e
                LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE e.equipment_id = %s
                LIMIT 1
            """, (equipment_id,))
            row = cur.fetchone()
            if row:
                equipment = self._row_to_dict(row)
                # Вычисляем дату истечения гарантии
                if equipment.get('acquisition_date') and equipment.get('warranty_period'):
                    from datetime import timedelta
                    acquisition_date = equipment['acquisition_date']
                    if isinstance(acquisition_date, str):
                        from datetime import datetime
                        acquisition_date = datetime.strptime(acquisition_date, '%Y-%m-%d').date()
                    equipment['warranty_expiration'] = acquisition_date + timedelta(days=equipment['warranty_period'])
                else:
                    equipment['warranty_expiration'] = None
                
                # Формируем текст периодичности ТО
                maintenance_frequency = equipment.get('maintenance_frequency')
                if maintenance_frequency:
                    if maintenance_frequency == 7:
                        equipment['maintenance_frequency_text'] = 'Раз в неделю (7 дней)'
                    elif maintenance_frequency == 30:
                        equipment['maintenance_frequency_text'] = 'Раз в месяц (30 дней)'
                    elif maintenance_frequency == 90:
                        equipment['maintenance_frequency_text'] = 'Раз в квартал (90 дней)'
                    elif maintenance_frequency == 365:
                        equipment['maintenance_frequency_text'] = 'Раз в год (365 дней)'
                    else:
                        equipment['maintenance_frequency_text'] = f'{maintenance_frequency} дней'
                else:
                    equipment['maintenance_frequency_text'] = None
                
                return equipment
            return None
    
    def update_field(self, equipment_id, field, value, equipment_assignment_id=None):
        """Обновить поле оборудования"""
        editable_fields = {
            'equipment_name': ('equipment', 'equipment_name'),
            'equipment_type': ('equipment', 'equipment_type'),
            'location': ('equipment_assignment', 'location'),
            'equipment_status': ('equipment_assignment', 'equipment_status'),
            'department_id': ('equipment_assignment', 'department_id')
        }
        
        if field not in editable_fields:
            raise ValueError(f'Поле {field} недоступно для редактирования')
        
        table_name, column_name = editable_fields[field]
        
        # Для полей из equipment_assignment нужно проверить наличие записи
        if table_name == 'equipment_assignment':
            # Если передан equipment_assignment_id, используем его для обновления
            if equipment_assignment_id:
                with get_db_cursor(commit=True) as cur:
                    # Проверяем, что assignment существует и принадлежит данному equipment
                    cur.execute("""
                        SELECT equipment_assignment_id 
                        FROM equipment_assignment 
                        WHERE equipment_assignment_id = %s AND equipment_id = %s
                    """, (equipment_assignment_id, equipment_id))
                    if not cur.fetchone():
                        raise ValueError('Размещение оборудования не найдено')
                    
                    # Преобразуем значение для department_id
                    db_value = value
                    if field == 'department_id':
                        if value:
                            try:
                                db_value = int(value)
                            except (TypeError, ValueError):
                                db_value = None
                        else:
                            db_value = None
                    else:
                        db_value = value.strip() if isinstance(value, str) else value
                        db_value = db_value if db_value != '' else None
                    
                    cur.execute(f"""
                        UPDATE equipment_assignment 
                        SET {column_name} = %s 
                        WHERE equipment_assignment_id = %s
                    """, (db_value, equipment_assignment_id))
                    if cur.rowcount == 0:
                        raise ValueError('Размещение оборудования не найдено')
            else:
                # Ищем assignment по equipment_id
                with get_db_cursor() as cur:
                    cur.execute("""
                        SELECT equipment_assignment_id 
                        FROM equipment_assignment 
                        WHERE equipment_id = %s
                        LIMIT 1
                    """, (equipment_id,))
                    assignment = cur.fetchone()
                    
                    if not assignment:
                        # Создаем запись в equipment_assignment
                        with get_db_cursor(commit=True) as cur2:
                            # Преобразуем значение для department_id
                            db_value = value
                            if field == 'department_id':
                                if value:
                                    try:
                                        db_value = int(value)
                                    except (TypeError, ValueError):
                                        db_value = None
                                else:
                                    db_value = None
                            else:
                                db_value = value.strip() if isinstance(value, str) else value
                                db_value = db_value if db_value != '' else None
                            
                            cur2.execute("""
                                INSERT INTO equipment_assignment (equipment_id, location, equipment_status, department_id)
                                VALUES (%s, %s, %s, %s)
                                RETURNING equipment_assignment_id
                            """, (
                                equipment_id,
                                db_value if field == 'location' else None,
                                db_value if field == 'equipment_status' else None,
                                db_value if field == 'department_id' else None
                            ))
                    else:
                        # Обновляем существующую запись
                        with get_db_cursor(commit=True) as cur2:
                            # Преобразуем значение для department_id
                            db_value = value
                            if field == 'department_id':
                                if value:
                                    try:
                                        db_value = int(value)
                                    except (TypeError, ValueError):
                                        db_value = None
                                else:
                                    db_value = None
                            else:
                                db_value = value.strip() if isinstance(value, str) else value
                                db_value = db_value if db_value != '' else None
                            
                            cur2.execute(f"""
                                UPDATE equipment_assignment 
                                SET {column_name} = %s 
                                WHERE equipment_id = %s
                            """, (db_value, equipment_id))
                            if cur2.rowcount == 0:
                                raise ValueError('Оборудование не найдено')
        else:
            # Обновляем поле в таблице equipment
            db_value = value.strip() if isinstance(value, str) else value
            db_value = db_value if db_value != '' else None
            
            with get_db_cursor(commit=True) as cur:
                cur.execute(f"UPDATE equipment SET {column_name} = %s WHERE equipment_id = %s", 
                           (db_value, equipment_id))
                if cur.rowcount == 0:
                    raise ValueError('Оборудование не найдено')
    
    def delete(self, equipment_id):
        """Удалить оборудование"""
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование оборудования
            cur.execute("SELECT equipment_id FROM equipment WHERE equipment_id = %s", (equipment_id,))
            if not cur.fetchone():
                raise ValueError('Оборудование не найдено')
            
            # Получаем все equipment_assignment_id для этого оборудования
            cur.execute("""
                SELECT equipment_assignment_id 
                FROM equipment_assignment 
                WHERE equipment_id = %s
            """, (equipment_id,))
            assignment_ids = [row[0] for row in cur.fetchall()]
            
            # 1. Удаляем связанные записи в repair_task_employee через repair_task
            if assignment_ids:
                # Используем подзапрос вместо ANY для совместимости
                cur.execute("""
                    DELETE FROM repair_task_employee 
                    WHERE repair_task_id IN (
                        SELECT repair_task_id 
                        FROM repair_task 
                        WHERE equipment_assignment_id IN (
                            SELECT equipment_assignment_id 
                            FROM equipment_assignment 
                            WHERE equipment_id = %s
                        )
                    )
                """, (equipment_id,))
                
                # 2. Удаляем связанные записи в repair_spare_part через repair_task
                cur.execute("""
                    DELETE FROM repair_spare_part 
                    WHERE repair_task_id IN (
                        SELECT repair_task_id 
                        FROM repair_task 
                        WHERE equipment_assignment_id IN (
                            SELECT equipment_assignment_id 
                            FROM equipment_assignment 
                            WHERE equipment_id = %s
                        )
                    )
                """, (equipment_id,))
                
                # 3. Удаляем связанные записи в repair_task
                cur.execute("""
                    DELETE FROM repair_task 
                    WHERE equipment_assignment_id IN (
                        SELECT equipment_assignment_id 
                        FROM equipment_assignment 
                        WHERE equipment_id = %s
                    )
                """, (equipment_id,))
            
            # 4. Удаляем связанные записи в maintenace_employee через maintenance_plan
            cur.execute("""
                DELETE FROM maintenace_employee 
                WHERE maintenante_plan_id IN (
                    SELECT maintenance_plan_id 
                    FROM maintenance_plan 
                    WHERE equipment_id = %s
                )
            """, (equipment_id,))
            
            # 5. Удаляем связанные записи в maintenance_spare_part через maintenance_plan
            cur.execute("""
                DELETE FROM maintenance_spare_part 
                WHERE maintenance_plan_id IN (
                    SELECT maintenance_plan_id 
                    FROM maintenance_plan 
                    WHERE equipment_id = %s
                )
            """, (equipment_id,))
            
            # 6. Удаляем связанные записи в maintenance_plan
            cur.execute("DELETE FROM maintenance_plan WHERE equipment_id = %s", (equipment_id,))
            
            # 7. Удаляем связанные записи в equipment_movement для всех assignment'ов этого оборудования
            cur.execute("""
                DELETE FROM equipment_movement 
                WHERE equipment_assignment_id IN (
                    SELECT equipment_assignment_id 
                    FROM equipment_assignment 
                    WHERE equipment_id = %s
                )
            """, (equipment_id,))
            
            # 8. Удаляем связанные записи в equipment_assignment
            cur.execute("DELETE FROM equipment_assignment WHERE equipment_id = %s", (equipment_id,))
            
            # 9. Удаляем связанные записи в spare_part
            cur.execute("DELETE FROM spare_part WHERE equipment_id = %s", (equipment_id,))
            
            # 10. Удаляем само оборудование
            cur.execute("DELETE FROM equipment WHERE equipment_id = %s", (equipment_id,))
            if cur.rowcount == 0:
                raise ValueError('Оборудование не найдено')
    
    def delete_assignment(self, equipment_assignment_id):
        """Удалить размещение оборудования (только assignment, не само оборудование)"""
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование assignment
            cur.execute("""
                SELECT equipment_assignment_id 
                FROM equipment_assignment 
                WHERE equipment_assignment_id = %s
            """, (equipment_assignment_id,))
            if not cur.fetchone():
                raise ValueError('Размещение оборудования не найдено')
            
            # Сначала удаляем связанные записи в equipment_movement
            cur.execute("""
                DELETE FROM equipment_movement 
                WHERE equipment_assignment_id = %s
            """, (equipment_assignment_id,))
            
            # Затем удаляем само размещение
            cur.execute("""
                DELETE FROM equipment_assignment 
                WHERE equipment_assignment_id = %s
            """, (equipment_assignment_id,))
            
            if cur.rowcount == 0:
                raise ValueError('Размещение оборудования не найдено')
    
    def update_movement_field(self, movement_id, field, value):
        """Обновить поле перемещения"""
        from datetime import datetime
        
        # Маппинг полей на колонки БД
        field_mapping = {
            'move_date': 'move_date',
            'from_location': 'from_location',
            'to_location': 'to_location',
            'from_department_id': 'from_department_id',
            'to_department_id': 'to_department_id'
        }
        
        column_name = field_mapping.get(field)
        if not column_name:
            raise ValueError(f'Неизвестное поле: {field}')
        
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование перемещения
            cur.execute("""
                SELECT equipment_movement_id 
                FROM equipment_movement 
                WHERE equipment_movement_id = %s
            """, (movement_id,))
            if not cur.fetchone():
                raise ValueError('Перемещение не найдено')
            
            # Проверяем наличие колонок локаций, если пытаемся обновить локацию
            if field in ('from_location', 'to_location'):
                cur.execute("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'equipment_movement' 
                    AND column_name = %s
                """, (column_name,))
                if not cur.fetchone():
                    raise ValueError(f'Колонка {column_name} не существует в таблице equipment_movement. Пожалуйста, добавьте её в базу данных.')
            
            # Обрабатываем значение в зависимости от типа поля
            if field == 'move_date':
                if isinstance(value, str) and value.strip():
                    try:
                        # Парсим дату из формата DD.MM.YYYY или YYYY-MM-DD
                        if '.' in value:
                            db_value = datetime.strptime(value.strip(), '%d.%m.%Y').date()
                        else:
                            db_value = datetime.strptime(value.strip(), '%Y-%m-%d').date()
                    except ValueError:
                        raise ValueError('Неверный формат даты. Используйте DD.MM.YYYY')
                else:
                    raise ValueError('Дата не может быть пустой')
            elif field in ('from_department_id', 'to_department_id'):
                db_value = self._parse_int(value)
            else:
                db_value = value.strip() if isinstance(value, str) else value
                db_value = db_value if db_value != '' else None
            
            # Обновляем поле
            cur.execute(f"UPDATE equipment_movement SET {column_name} = %s WHERE equipment_movement_id = %s", 
                       (db_value, movement_id))
            if cur.rowcount == 0:
                raise ValueError('Перемещение не найдено')
    
    def get_movement_by_id(self, movement_id):
        """Получить перемещение по ID"""
        with get_db_cursor() as cur:
            # Проверяем наличие колонок локаций
            cur.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'equipment_movement' 
                AND column_name IN ('from_location', 'to_location')
            """)
            location_columns = {row[0] for row in cur.fetchall()}
            has_location_columns = 'from_location' in location_columns and 'to_location' in location_columns
            
            if has_location_columns:
                cur.execute("""
                    SELECT 
                        em.equipment_movement_id,
                        em.move_date,
                        COALESCE(fd.facility_name || ' - ' || d1.department_name, '—') as from_location,
                        COALESCE(td.facility_name || ' - ' || d2.department_name, '—') as to_location,
                        em.from_location as from_location_detail,
                        em.to_location as to_location_detail,
                        em.from_department_id,
                        em.to_department_id
                    FROM equipment_movement em
                    LEFT JOIN department d1 ON em.from_department_id = d1.department_id
                    LEFT JOIN facility fd ON d1.facility_id = fd.facility_id
                    LEFT JOIN department d2 ON em.to_department_id = d2.department_id
                    LEFT JOIN facility td ON d2.facility_id = td.facility_id
                    WHERE em.equipment_movement_id = %s
                """, (movement_id,))
            else:
                cur.execute("""
                    SELECT 
                        em.equipment_movement_id,
                        em.move_date,
                        COALESCE(fd.facility_name || ' - ' || d1.department_name, '—') as from_location,
                        COALESCE(td.facility_name || ' - ' || d2.department_name, '—') as to_location,
                        em.from_department_id,
                        em.to_department_id
                    FROM equipment_movement em
                    LEFT JOIN department d1 ON em.from_department_id = d1.department_id
                    LEFT JOIN facility fd ON d1.facility_id = fd.facility_id
                    LEFT JOIN department d2 ON em.to_department_id = d2.department_id
                    LEFT JOIN facility td ON d2.facility_id = td.facility_id
                    WHERE em.equipment_movement_id = %s
                """, (movement_id,))
            
            row = cur.fetchone()
            if row:
                if has_location_columns:
                    return {
                        'id': row[0],
                        'move_date': row[1],
                        'from_location': row[2] or '—',
                        'to_location': row[3] or '—',
                        'from_location_detail': row[4] or '—',
                        'to_location_detail': row[5] or '—',
                        'from_department_id': row[6],
                        'to_department_id': row[7]
                    }
                else:
                    return {
                        'id': row[0],
                        'move_date': row[1],
                        'from_location': row[2] or '—',
                        'to_location': row[3] or '—',
                        'from_location_detail': '—',
                        'to_location_detail': '—',
                        'from_department_id': row[4],
                        'to_department_id': row[5]
                    }
            return None
    
    def delete_movement(self, movement_id):
        """Удалить запись о перемещении оборудования"""
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование перемещения
            cur.execute("""
                SELECT equipment_movement_id 
                FROM equipment_movement 
                WHERE equipment_movement_id = %s
            """, (movement_id,))
            if not cur.fetchone():
                raise ValueError('Перемещение не найдено')
            
            # Удаляем запись о перемещении
            cur.execute("""
                DELETE FROM equipment_movement 
                WHERE equipment_movement_id = %s
            """, (movement_id,))
            
            if cur.rowcount == 0:
                raise ValueError('Перемещение не найдено')
    
    def create_assignment(self, data):
        """Создать размещение для существующего оборудования"""
        existing_equipment_id = data.get('existing_equipment_id')
        if not existing_equipment_id:
            raise ValueError('Не указан ID существующего оборудования')
        
        try:
            existing_equipment_id = int(existing_equipment_id)
        except (TypeError, ValueError):
            raise ValueError('Некорректный ID оборудования')
        
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование оборудования
            cur.execute("""
                SELECT equipment_id 
                FROM equipment 
                WHERE equipment_id = %s
            """, (existing_equipment_id,))
            if not cur.fetchone():
                raise ValueError('Оборудование не найдено')
            
            # Получаем department_id
            department_id = data.get('department_id')
            if department_id:
                try:
                    department_id = int(department_id)
                except (TypeError, ValueError):
                    department_id = None
            
            # Создаем запись в equipment_assignment
            cur.execute("""
                INSERT INTO equipment_assignment (
                    equipment_id, department_id, acquisition_date,
                    location, equipment_status
                )
                VALUES (%s, %s, %s, %s, %s)
                RETURNING equipment_assignment_id
            """, (
                existing_equipment_id,
                department_id,
                data.get('acquisition_date') or None,
                data.get('location', '').strip() or None,
                data.get('equipment_status', '').strip() or None
            ))
            equipment_assignment_id = cur.fetchone()[0]
            
            # Получаем полную информацию о созданном assignment
            return self.get_by_assignment_id(equipment_assignment_id)
    
    def get_by_assignment_id(self, equipment_assignment_id):
        """Получить оборудование по ID размещения"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    ea.equipment_assignment_id,
                    ea.location,
                    ea.equipment_status,
                    ea.department_id,
                    d.department_name,
                    f.facility_name
                FROM equipment_assignment ea
                JOIN equipment e ON ea.equipment_id = e.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE ea.equipment_assignment_id = %s
                LIMIT 1
            """, (equipment_assignment_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
    def get_movement_history(self, equipment_assignment_id):
        """Получить историю перемещений оборудования"""
        with get_db_cursor() as cur:
            # Проверяем наличие колонок локаций
            cur.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'equipment_movement' 
                AND column_name IN ('from_location', 'to_location')
            """)
            location_columns = {row[0] for row in cur.fetchall()}
            has_location_columns = 'from_location' in location_columns and 'to_location' in location_columns
            
            if has_location_columns:
                cur.execute("""
                    SELECT 
                        em.equipment_movement_id,
                        em.move_date,
                        fd.department_name as from_department,
                        ffd.facility_name as from_facility,
                        td.department_name as to_department,
                        tfd.facility_name as to_facility,
                        em.from_location,
                        em.to_location,
                        em.from_department_id,
                        em.to_department_id
                    FROM equipment_movement em
                    LEFT JOIN department fd ON em.from_department_id = fd.department_id
                    LEFT JOIN facility ffd ON fd.facility_id = ffd.facility_id
                    LEFT JOIN department td ON em.to_department_id = td.department_id
                    LEFT JOIN facility tfd ON td.facility_id = tfd.facility_id
                    WHERE em.equipment_assignment_id = %s
                    ORDER BY em.move_date DESC, em.equipment_movement_id DESC
                """, (equipment_assignment_id,))
            else:
                cur.execute("""
                    SELECT 
                        em.equipment_movement_id,
                        em.move_date,
                        fd.department_name as from_department,
                        ffd.facility_name as from_facility,
                        td.department_name as to_department,
                        tfd.facility_name as to_facility,
                        em.from_department_id,
                        em.to_department_id
                    FROM equipment_movement em
                    LEFT JOIN department fd ON em.from_department_id = fd.department_id
                    LEFT JOIN facility ffd ON fd.facility_id = ffd.facility_id
                    LEFT JOIN department td ON em.to_department_id = td.department_id
                    LEFT JOIN facility tfd ON td.facility_id = tfd.facility_id
                    WHERE em.equipment_assignment_id = %s
                    ORDER BY em.move_date DESC, em.equipment_movement_id DESC
                """, (equipment_assignment_id,))
            
            rows = cur.fetchall()
            if has_location_columns:
                result = []
                for row in rows:
                    # Формируем "Предприятие - Отдел" для отображения
                    from_facility = row[3] or ''
                    from_department = row[2] or ''
                    if from_facility and from_department:
                        from_location_display = f"{from_facility} - {from_department}"
                    elif from_department:
                        from_location_display = from_department
                    elif from_facility:
                        from_location_display = from_facility
                    else:
                        from_location_display = '—'
                    
                    to_facility = row[5] or ''
                    to_department = row[4] or ''
                    if to_facility and to_department:
                        to_location_display = f"{to_facility} - {to_department}"
                    elif to_department:
                        to_location_display = to_department
                    elif to_facility:
                        to_location_display = to_facility
                    else:
                        to_location_display = '—'
                    
                    # Значения из колонок from_location и to_location (дополнительная локация)
                    # Убираем название предприятия, если оно есть в строке
                    from_location_raw = row[6] if row[6] else ''
                    to_location_raw = row[7] if row[7] else ''
                    
                    # Функция для удаления названия предприятия из локации
                    def clean_location(location_str, facility_name):
                        if not location_str:
                            return '—'
                        if not facility_name:
                            return location_str.strip() or '—'
                        
                        import re
                        location = location_str.strip()
                        facility = facility_name.strip()
                        
                        # Убираем название предприятия из начала строки (точное совпадение)
                        if location.startswith(facility):
                            location = location[len(facility):].strip()
                            # Убираем возможные разделители после предприятия
                            location = re.sub(r'^[\s"\'\-]+', '', location)
                        # Также проверяем, если предприятие где-то в строке
                        elif facility in location:
                            # Пытаемся найти локацию после названия предприятия
                            # Учитываем возможные разделители: пробел, кавычки, дефис
                            # Паттерн для поиска предприятия с возможными кавычками и разделителями
                            pattern = re.escape(facility) + r'[\s"\'\-]*'
                            location = re.sub(pattern, '', location, count=1).strip()
                        
                        # Убираем лишние пробелы и кавычки в начале/конце
                        location = location.strip(' "\'')
                        
                        return location if location else '—'
                    
                    from_location_detail = clean_location(from_location_raw, from_facility)
                    to_location_detail = clean_location(to_location_raw, to_facility)
                    
                    result.append({
                        'id': row[0],
                        'move_date': row[1],
                        'from_location': from_location_display,  # "Предприятие - Отдел" для колонки "Откуда перемещено"
                        'to_location': to_location_display,  # "Предприятие - Отдел" для колонки "Куда перемещено"
                        'from_location_detail': from_location_detail,  # Значение из em.from_location для колонки "Локация (откуда)"
                        'to_location_detail': to_location_detail,  # Значение из em.to_location для колонки "Локация (куда)"
                        'from_department_id': row[8],
                        'to_department_id': row[9],
                        'from_facility': from_facility,  # Название предприятия для dropdown
                        'to_facility': to_facility  # Название предприятия для dropdown
                    })
                return result
            else:
                result = []
                for row in rows:
                    # Формируем "Предприятие - Отдел" для отображения
                    from_facility = row[3] or ''
                    from_department = row[2] or ''
                    if from_facility and from_department:
                        from_location_display = f"{from_facility} - {from_department}"
                    elif from_department:
                        from_location_display = from_department
                    elif from_facility:
                        from_location_display = from_facility
                    else:
                        from_location_display = '—'
                    
                    to_facility = row[5] or ''
                    to_department = row[4] or ''
                    if to_facility and to_department:
                        to_location_display = f"{to_facility} - {to_department}"
                    elif to_department:
                        to_location_display = to_department
                    elif to_facility:
                        to_location_display = to_facility
                    else:
                        to_location_display = '—'
                    
                    result.append({
                        'id': row[0],
                        'move_date': row[1],
                        'from_location': from_location_display,  # "Предприятие - Отдел" для колонки "Откуда перемещено"
                        'to_location': to_location_display,  # "Предприятие - Отдел" для колонки "Куда перемещено"
                        'from_location_detail': '—',
                        'to_location_detail': '—',
                        'from_department_id': row[6],
                        'to_department_id': row[7],
                        'from_facility': from_facility,  # Название предприятия для dropdown
                        'to_facility': to_facility  # Название предприятия для dropdown
                    })
                return result
    
    def create_movement(self, equipment_assignment_id, data):
        """Создать запись о перемещении оборудования"""
        from datetime import date, datetime
        
        with get_db_cursor(commit=True) as cur:
            from_department_id = self._parse_int(data.get('from_department_id'))
            to_department_id = self._parse_int(data.get('to_department_id'))
            move_date_str = data.get('move_date')
            
            if not from_department_id or not to_department_id:
                raise ValueError('Необходимо указать отделы "откуда" и "куда"')
            
            if not move_date_str:
                raise ValueError('Необходимо указать дату перемещения')
            
            # Преобразуем строку даты в объект date
            if isinstance(move_date_str, str):
                move_date = datetime.strptime(move_date_str, '%Y-%m-%d').date()
            else:
                move_date = move_date_str
            
            # Получаем локации из данных
            from_location = data.get('from_location', '').strip() or None
            to_location = data.get('to_location', '').strip() or None
            
            # Проверяем наличие колонок локаций
            cur.execute("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'equipment_movement' 
                AND column_name IN ('from_location', 'to_location')
            """)
            location_columns = {row[0] for row in cur.fetchall()}
            has_location_columns = 'from_location' in location_columns and 'to_location' in location_columns
            
            # Вставляем запись о перемещении
            if has_location_columns:
                cur.execute("""
                    INSERT INTO equipment_movement (
                        equipment_assignment_id,
                        from_department_id,
                        to_department_id,
                        move_date,
                        from_location,
                        to_location
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING equipment_movement_id
                """, (equipment_assignment_id, from_department_id, to_department_id, move_date, from_location, to_location))
            else:
                cur.execute("""
                    INSERT INTO equipment_movement (
                        equipment_assignment_id,
                        from_department_id,
                        to_department_id,
                        move_date
                    )
                    VALUES (%s, %s, %s, %s)
                    RETURNING equipment_movement_id
                """, (equipment_assignment_id, from_department_id, to_department_id, move_date))
            
            movement_id = cur.fetchone()[0]
            
            # Проверяем, является ли дата перемещения сегодняшней или в прошлом
            today = date.today()
            location_updated = False
            
            if move_date <= today:
                # Если дата сегодняшняя или в прошлом, сразу обновляем текущее расположение
                # Обновляем department_id
                cur.execute("""
                    UPDATE equipment_assignment
                    SET department_id = %s
                    WHERE equipment_assignment_id = %s
                """, (to_department_id, equipment_assignment_id))
                
                # Обновляем location только если указано to_location
                # Если to_location не указано, оставляем текущее значение location без изменений
                if to_location and to_location.strip():
                    cur.execute("""
                        UPDATE equipment_assignment
                        SET location = %s
                        WHERE equipment_assignment_id = %s
                    """, (to_location.strip(), equipment_assignment_id))
                    location_updated = True
                else:
                    location_updated = True
            # Если дата в будущем, просто не обновляем расположение сейчас
            # Оно будет обновлено автоматически при обработке запланированных перемещений
            
            return movement_id, location_updated
    
    def process_scheduled_movements(self):
        """Обработать запланированные перемещения с датой <= сегодня"""
        from datetime import date
        
        with get_db_cursor(commit=True) as cur:
            today = date.today()
            
            # Находим все перемещения с датой <= сегодня, которые еще не обработаны
            # (проверяем, что текущее расположение не совпадает с целевым)
            cur.execute("""
                SELECT 
                    em.equipment_movement_id,
                    em.equipment_assignment_id,
                    em.to_department_id,
                    em.to_location,
                    ea.department_id as current_department_id
                FROM equipment_movement em
                JOIN equipment_assignment ea ON em.equipment_assignment_id = ea.equipment_assignment_id
                WHERE em.move_date <= %s
                AND (ea.department_id IS NULL OR ea.department_id != em.to_department_id)
            """, (today,))
            
            movements = cur.fetchall()
            
            for movement in movements:
                movement_id, assignment_id, to_department_id, to_location, current_department_id = movement
                
                # Обновляем department_id
                cur.execute("""
                    UPDATE equipment_assignment
                    SET department_id = %s
                    WHERE equipment_assignment_id = %s
                """, (to_department_id, assignment_id))
                
                # Обновляем location только если указано to_location в перемещении
                # Если to_location не указано, оставляем текущее значение location без изменений
                if to_location and to_location.strip():
                    cur.execute("""
                        UPDATE equipment_assignment
                        SET location = %s
                        WHERE equipment_assignment_id = %s
                    """, (to_location.strip(), assignment_id))
            
            return len(movements)
    
    def get_types(self):
        """Получить список типов оборудования"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT equipment_type 
                FROM equipment 
                WHERE equipment_type IS NOT NULL 
                ORDER BY equipment_type
            """)
            return [row[0] for row in cur.fetchall()]
    
    def get_statuses(self):
        """Получить список статусов оборудования"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT equipment_status 
                FROM equipment_assignment 
                WHERE equipment_status IS NOT NULL 
                ORDER BY equipment_status
            """)
            return [row[0] for row in cur.fetchall()]
    
    def get_locations(self):
        """Получить список расположений"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT location 
                FROM equipment_assignment 
                WHERE location IS NOT NULL 
                ORDER BY location
            """)
            return [row[0] for row in cur.fetchall()]
    
    def get_departments(self):
        """Получить список отделов"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT d.department_id, d.department_name, f.facility_id, f.facility_name
                FROM department d
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                ORDER BY f.facility_name NULLS LAST, d.department_name
            """)
            return [
                {
                    'id': row[0],
                    'name': row[1],
                    'facility_id': row[2],
                    'facility_name': row[3]
                }
                for row in cur.fetchall()
            ]
    
    def get_spare_part_types(self):
        """Получить список типов деталей"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT spare_part_type 
                FROM spare_part 
                WHERE spare_part_type IS NOT NULL 
                ORDER BY spare_part_type
            """)
            return [row[0] for row in cur.fetchall()]
    
    def get_spare_parts(self, equipment_id):
        """Получить список деталей для оборудования"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    spare_part_id,
                    spare_part_name,
                    spare_part_type
                FROM spare_part
                WHERE equipment_id = %s
                ORDER BY spare_part_name
            """, (equipment_id,))
            rows = cur.fetchall()
            return [
                {
                    'id': row[0],
                    'name': row[1] or '—',
                    'type': row[2] or '—'
                }
                for row in rows
            ]
    
    def add_spare_part(self, equipment_id, spare_part_name, spare_part_type):
        """Добавить деталь к оборудованию"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("""
                INSERT INTO spare_part (equipment_id, spare_part_name, spare_part_type)
                VALUES (%s, %s, %s)
                RETURNING spare_part_id
            """, (equipment_id, spare_part_name, spare_part_type))
            result = cur.fetchone()
            if result:
                return result[0]
            return None
    
    def update_spare_part_field(self, spare_part_id, field, value):
        """Обновить поле детали"""
        # Маппинг полей на колонки БД
        field_mapping = {
            'name': 'spare_part_name',
            'type': 'spare_part_type'
        }
        
        column_name = field_mapping.get(field)
        if not column_name:
            raise ValueError(f'Неизвестное поле: {field}')
        
        with get_db_cursor(commit=True) as cur:
            # Проверяем существование детали
            cur.execute("SELECT spare_part_id FROM spare_part WHERE spare_part_id = %s", (spare_part_id,))
            if not cur.fetchone():
                raise ValueError('Деталь не найдена')
            
            # Обновляем поле
            db_value = value.strip() if isinstance(value, str) else value
            db_value = db_value if db_value != '' else None
            
            cur.execute(f"UPDATE spare_part SET {column_name} = %s WHERE spare_part_id = %s", 
                       (db_value, spare_part_id))
            if cur.rowcount == 0:
                raise ValueError('Деталь не найдена')
    
    def get_spare_part_by_id(self, spare_part_id):
        """Получить деталь по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    spare_part_id,
                    spare_part_name,
                    spare_part_type
                FROM spare_part
                WHERE spare_part_id = %s
            """, (spare_part_id,))
            row = cur.fetchone()
            if row:
                return {
                    'id': row[0],
                    'name': row[1] or '—',
                    'type': row[2] or '—'
                }
            return None
    
    def delete_spare_part(self, spare_part_id):
        """Удалить деталь"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("DELETE FROM spare_part WHERE spare_part_id = %s", (spare_part_id,))
            if cur.rowcount == 0:
                raise ValueError('Деталь не найдена')
            return True
    
    def get_image_paths(self):
        """Получить список путей к изображениям"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT image_path 
                FROM equipment 
                WHERE image_path IS NOT NULL 
                ORDER BY image_path
            """)
            return [row[0] for row in cur.fetchall()]
    
    def get_maintenance_frequencies(self):
        """Получить список периодичностей ТО"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT maintenance_frequency 
                FROM equipment 
                WHERE maintenance_frequency IS NOT NULL 
                ORDER BY maintenance_frequency
            """)
            return [row[0] for row in cur.fetchall()]
    
    def search_equipment_by_name(self, query):
        """Поиск оборудования по названию"""
        if not query or len(query) < 2:
            return []
        
        with get_db_cursor() as cur:
            # Поиск по названию оборудования (case-insensitive)
            # Используем ILIKE для PostgreSQL (case-insensitive LIKE)
            search_pattern = f'%{query}%'
            
            cur.execute("""
                SELECT DISTINCT
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type
                FROM equipment e
                WHERE e.equipment_name ILIKE %s
                ORDER BY e.equipment_name
                LIMIT 10
            """, (search_pattern,))
            rows = cur.fetchall()
            return [
                {
                    'id': row[0],
                    'equipment_name': row[1],
                    'equipment_type': row[2] or ''
                }
                for row in rows
            ]
    
    def create(self, data):
        """Создать новое оборудование"""
        with get_db_cursor(commit=True) as cur:
            # Создаем запись в equipment
            cur.execute("""
                INSERT INTO equipment (
                    equipment_name, equipment_type, image_path, 
                    characteristics, guarantee_date, maintenance_frequency
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING equipment_id
            """, (
                data.get('equipment_name', '').strip(),
                data.get('equipment_type', '').strip() or None,
                data.get('image_path', '').strip() or None,
                data.get('characteristics', '').strip() or None,
                data.get('guarantee_date') or None,
                self._parse_int(data.get('maintenance_frequency'))
            ))
            equipment_id = cur.fetchone()[0]
            
            # Создаем запись в equipment_assignment
            department_id = data.get('department_id')
            if department_id:
                try:
                    department_id = int(department_id)
                except (TypeError, ValueError):
                    department_id = None
            
            cur.execute("""
                INSERT INTO equipment_assignment (
                    equipment_id, department_id, acquisition_date
                )
                VALUES (%s, %s, %s)
                RETURNING equipment_assignment_id
            """, (
                equipment_id,
                department_id,
                data.get('acquisition_date') or None
            ))
            
            # Создаем записи в spare_part для типов деталей
            spare_part_types = data.get('spare_part_types', [])
            if spare_part_types:
                for spare_part_type in spare_part_types:
                    if spare_part_type and spare_part_type.strip():
                        cur.execute("""
                            INSERT INTO spare_part (equipment_id, spare_part_type)
                            VALUES (%s, %s)
                        """, (equipment_id, spare_part_type.strip()))
            
            return self.get_by_id(equipment_id)
    
    def _parse_int(self, value):
        """Преобразовать значение в int или вернуть None"""
        if value is None or value == '':
            return None
        try:
            return int(value)
        except (TypeError, ValueError):
            return None
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        # Определяем количество полей для разных запросов
        if len(row) == 9:
            # Для get_all (9 полей)
            return {
                'id': row[0],
                'equipment_name': row[1] or '',
                'equipment_type': row[2] or '',
                'equipment_assignment_id': row[3],
                'location': row[4] or '',
                'equipment_status': row[5] or '',
                'department_id': row[6],
                'department': row[7] or '',
                'facility': row[8] or '',
            }
        elif len(row) == 14:
            # Для get_by_id (14 полей)
            return {
                'id': row[0],
                'equipment_id': row[0],  # Добавляем для совместимости
                'equipment_name': row[1] or '',
                'equipment_type': row[2] or '',
                'image_path': row[3] or '',
                'characteristics': row[4] or '',
                'warranty_period': row[5],
                'maintenance_frequency': row[6],
                'equipment_assignment_id': row[7],
                'location': row[8] or '',
                'equipment_status': row[9] or '',
                'department_id': row[10],
                'acquisition_date': row[11],
                'department': row[12] or '',
                'facility': row[13] or '',
            }
        else:
            # Fallback для других случаев
            return {
                'id': row[0] if len(row) > 0 else None,
                'equipment_name': row[1] if len(row) > 1 else '',
                'equipment_type': row[2] if len(row) > 2 else '',
            }

