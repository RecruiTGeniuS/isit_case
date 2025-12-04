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
                LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE 1=1
            """
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND ea.department_id = %s"
                params.append(department_id)
            
            query += " ORDER BY e.equipment_name"
            
            cur.execute(query, params)
            rows = cur.fetchall()
            return [self._row_to_dict(row) for row in rows]
    
    def get_by_id(self, equipment_id):
        """Получить оборудование по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    e.characteristics,
                    e.image_path,
                    e.warranty_period,
                    e.maintenance_frequency,
                    ea.equipment_assignment_id,
                    ea.location,
                    ea.equipment_status,
                    ea.acquisition_date,
                    ea.department_id,
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
            return self._row_to_dict_passport(row) if row else None
    
    def update_field(self, equipment_id, field, value):
        """Обновить поле оборудования"""
        editable_fields = {
            'equipment_name': ('equipment', 'equipment_name'),
            'equipment_type': ('equipment', 'equipment_type'),
            'location': ('equipment_assignment', 'location'),
            'equipment_status': ('equipment_assignment', 'equipment_status')
        }
        
        if field not in editable_fields:
            raise ValueError(f'Поле {field} недоступно для редактирования')
        
        table_name, column_name = editable_fields[field]
        
        # Для полей из equipment_assignment нужно проверить наличие записи
        if table_name == 'equipment_assignment':
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
                        cur2.execute("""
                            INSERT INTO equipment_assignment (equipment_id, location, equipment_status)
                            VALUES (%s, %s, %s)
                            RETURNING equipment_assignment_id
                        """, (
                            equipment_id,
                            value if field == 'location' else None,
                            value if field == 'equipment_status' else None
                        ))
                else:
                    # Обновляем существующую запись
                    with get_db_cursor(commit=True) as cur2:
                        cur2.execute(f"""
                            UPDATE equipment_assignment 
                            SET {column_name} = %s 
                            WHERE equipment_id = %s
                        """, (value.strip() if isinstance(value, str) else value, equipment_id))
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
            # Сначала удаляем связанные записи в equipment_assignment
            cur.execute("DELETE FROM equipment_assignment WHERE equipment_id = %s", (equipment_id,))
            # Затем удаляем само оборудование
            cur.execute("DELETE FROM equipment WHERE equipment_id = %s", (equipment_id,))
            if cur.rowcount == 0:
                raise ValueError('Оборудование не найдено')
    
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
    
    def search_equipment_by_name(self, name_query, limit=10):
        """Поиск оборудования по названию"""
        if not name_query or len(name_query.strip()) < 2:
            return []
        
        query_trimmed = name_query.strip()
        query_lower = query_trimmed.lower()
        # Ищем только те, которые начинаются с запроса
        search_pattern_start = f'{query_lower}%'
        # Ищем как отдельное слово (с пробелами или дефисами перед/после)
        search_pattern_word = f'% {query_lower} %'
        search_pattern_word_start = f'{query_lower} %'
        search_pattern_word_end = f'% {query_lower}'
        search_pattern_hyphen = f'%-{query_lower}%'
        
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT DISTINCT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    e.characteristics,
                    e.image_path,
                    CASE 
                        WHEN LOWER(TRIM(e.equipment_name)) = LOWER(TRIM(%s)) THEN 1
                        WHEN LOWER(TRIM(e.equipment_name)) LIKE %s THEN 2
                        WHEN LOWER(e.equipment_name) LIKE %s THEN 3
                        WHEN LOWER(e.equipment_name) LIKE %s THEN 3
                        WHEN LOWER(e.equipment_name) LIKE %s THEN 3
                        WHEN LOWER(e.equipment_name) LIKE %s THEN 3
                        ELSE 4
                    END as match_priority
                FROM equipment e
                WHERE LOWER(TRIM(e.equipment_name)) = LOWER(TRIM(%s))
                   OR LOWER(e.equipment_name) LIKE %s
                   OR LOWER(e.equipment_name) LIKE %s
                   OR LOWER(e.equipment_name) LIKE %s
                   OR LOWER(e.equipment_name) LIKE %s
                   OR LOWER(e.equipment_name) LIKE %s
                ORDER BY match_priority, e.equipment_name
                LIMIT %s
            """, (query_trimmed, search_pattern_start, search_pattern_word, 
                  search_pattern_word_start, search_pattern_word_end, search_pattern_hyphen,
                  query_trimmed, search_pattern_start, search_pattern_word,
                  search_pattern_word_start, search_pattern_word_end, search_pattern_hyphen, limit))
            return [
                {
                    'id': row[0],
                    'equipment_name': row[1],
                    'equipment_type': row[2] or '',
                    'characteristics': row[3] or '',
                    'image_path': row[4],
                    'is_exact_match': row[5] == 1
                }
                for row in cur.fetchall()
            ]
    
    def get_equipment_by_name(self, name):
        """Получить оборудование по точному названию"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    e.characteristics,
                    e.image_path,
                    e.guarantee_date,
                    e.maintenance_frequency
                FROM equipment e
                WHERE LOWER(TRIM(e.equipment_name)) = LOWER(TRIM(%s))
                LIMIT 1
            """, (name,))
            row = cur.fetchone()
            if row:
                return {
                    'id': row[0],
                    'equipment_name': row[1],
                    'equipment_type': row[2] or '',
                    'characteristics': row[3] or '',
                    'image_path': row[4],
                    'guarantee_date': row[5],
                    'maintenance_frequency': row[6]
                }
            return None
    
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
    
    def create(self, data):
        """Создать новое оборудование"""
        with get_db_cursor(commit=True) as cur:
            # Создаем запись в equipment
            # Примечание: если поле guarantee_date не существует в таблице equipment,
            # нужно добавить его через ALTER TABLE equipment ADD COLUMN guarantee_date DATE;
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
    
    def create_assignment(self, data):
        """Создать assignment для существующего оборудования"""
        equipment_id = data.get('existing_equipment_id')
        if not equipment_id:
            raise ValueError('Не указан ID оборудования')
        
        with get_db_cursor(commit=True) as cur:
            # Проверяем, что оборудование существует
            cur.execute("SELECT equipment_id FROM equipment WHERE equipment_id = %s", (equipment_id,))
            if not cur.fetchone():
                raise ValueError('Оборудование не найдено')
            
            # Создаем запись в equipment_assignment
            department_id = data.get('department_id')
            if department_id:
                try:
                    department_id = int(department_id)
                except (TypeError, ValueError):
                    department_id = None
            
            cur.execute("""
                INSERT INTO equipment_assignment (
                    equipment_id, department_id, acquisition_date, location, equipment_status
                )
                VALUES (%s, %s, %s, %s, %s)
                RETURNING equipment_assignment_id
            """, (
                equipment_id,
                department_id,
                data.get('acquisition_date') or None,
                data.get('location', '').strip() or None,
                data.get('equipment_status', 'В работе') or 'В работе'
            ))
            
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
    
    def _row_to_dict_passport(self, row):
        """Преобразование строки БД в словарь для паспорта оборудования"""
        from datetime import datetime, timedelta
        
        equipment_id = row[0]
        equipment_name = row[1] or ''
        equipment_type = row[2] or ''
        characteristics = row[3] or ''
        image_path = row[4]
        warranty_period = row[5]  # в днях
        maintenance_frequency = row[6]  # в днях
        equipment_assignment_id = row[7]
        location = row[8] or ''
        equipment_status = row[9] or ''
        acquisition_date = row[10]  # дата приобретения/ввода в эксплуатацию
        department_id = row[11]
        department_name = row[12] or ''
        facility_name = row[13] or ''
        
        # Вычисляем дату истечения гарантии (warranty_period в днях)
        warranty_expiration = None
        if acquisition_date and warranty_period:
            try:
                if isinstance(acquisition_date, str):
                    acquisition_date_obj = datetime.strptime(acquisition_date, '%Y-%m-%d').date()
                else:
                    acquisition_date_obj = acquisition_date
                
                # Добавляем дни гарантии
                warranty_expiration = acquisition_date_obj + timedelta(days=warranty_period)
            except (ValueError, TypeError, AttributeError):
                warranty_expiration = None
        
        # Форматируем периодичность ТО (в днях) - "раз в X мес." или "раз в X дн."
        maintenance_frequency_text = None
        if maintenance_frequency:
            try:
                freq_days = int(maintenance_frequency)
                
                # Переводим дни в месяцы и дни
                if freq_days >= 30:
                    months = freq_days // 30
                    days = freq_days % 30
                    
                    if days == 0:
                        if months == 1:
                            maintenance_frequency_text = 'раз в 1 мес.'
                        elif months < 12:
                            maintenance_frequency_text = f'раз в {months} мес.'
                        else:
                            years = months // 12
                            remaining_months = months % 12
                            if remaining_months == 0:
                                if years == 1:
                                    maintenance_frequency_text = 'раз в 1 год'
                                else:
                                    maintenance_frequency_text = f'раз в {years} лет'
                            else:
                                if years == 1:
                                    maintenance_frequency_text = f'раз в 1 год {remaining_months} мес.'
                                else:
                                    maintenance_frequency_text = f'раз в {years} лет {remaining_months} мес.'
                    else:
                        if months == 1:
                            maintenance_frequency_text = f'раз в 1 мес. {days} дн.'
                        else:
                            maintenance_frequency_text = f'раз в {months} мес. {days} дн.'
                else:
                    if freq_days == 1:
                        maintenance_frequency_text = 'раз в 1 день'
                    else:
                        maintenance_frequency_text = f'раз в {freq_days} дн.'
            except (ValueError, TypeError):
                maintenance_frequency_text = str(maintenance_frequency) if maintenance_frequency else None
        
        return {
            'id': equipment_id,
            'equipment_name': equipment_name,
            'equipment_type': equipment_type,
            'characteristics': characteristics,
            'image_path': image_path,
            'warranty_period': warranty_period,
            'warranty_expiration': warranty_expiration,
            'maintenance_frequency': maintenance_frequency,
            'maintenance_frequency_text': maintenance_frequency_text,
            'acquisition_date': acquisition_date,
            'equipment_assignment_id': equipment_assignment_id,
            'location': location,
            'equipment_status': equipment_status,
            'department_id': department_id,
            'department': department_name,
            'facility': facility_name,
        }
    
    def get_movement_history(self, equipment_assignment_id):
        """Получить историю перемещений оборудования"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    em.equipment_movement_id,
                    em.move_date,
                    em.from_department_id,
                    em.to_department_id,
                    from_dept.department_name as from_department_name,
                    from_fac.facility_name as from_facility_name,
                    to_dept.department_name as to_department_name,
                    to_fac.facility_name as to_facility_name
                FROM equipment_movement em
                LEFT JOIN department from_dept ON em.from_department_id = from_dept.department_id
                LEFT JOIN facility from_fac ON from_dept.facility_id = from_fac.facility_id
                LEFT JOIN department to_dept ON em.to_department_id = to_dept.department_id
                LEFT JOIN facility to_fac ON to_dept.facility_id = to_fac.facility_id
                WHERE em.equipment_assignment_id = %s
                ORDER BY em.move_date DESC
            """, (equipment_assignment_id,))
            rows = cur.fetchall()
            return [
                {
                    'id': row[0],
                    'move_date': row[1],
                    'from_department_id': row[2],
                    'to_department_id': row[3],
                    'from_department': row[4] or '—',
                    'from_facility': row[5] or '',
                    'to_department': row[6] or '—',
                    'to_facility': row[7] or '',
                    'from_location': f"{row[5] or ''} - {row[4] or '—'}" if row[5] else (row[4] or '—'),
                    'to_location': f"{row[7] or ''} - {row[6] or '—'}" if row[7] else (row[6] or '—'),
                }
                for row in rows
            ]

