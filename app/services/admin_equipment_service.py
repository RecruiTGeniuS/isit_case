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
                WHERE e.equipment_id = %s
                LIMIT 1
            """, (equipment_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
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
            cur.execute("""
                SELECT 
                    em.equipment_movement_id,
                    em.move_date,
                    fd.department_name as from_department,
                    ffd.facility_name as from_facility,
                    td.department_name as to_department,
                    tfd.facility_name as to_facility
                FROM equipment_movement em
                LEFT JOIN department fd ON em.from_department_id = fd.department_id
                LEFT JOIN facility ffd ON fd.facility_id = ffd.facility_id
                LEFT JOIN department td ON em.to_department_id = td.department_id
                LEFT JOIN facility tfd ON td.facility_id = tfd.facility_id
                WHERE em.equipment_assignment_id = %s
                ORDER BY em.move_date DESC, em.equipment_movement_id DESC
            """, (equipment_assignment_id,))
            rows = cur.fetchall()
            return [
                {
                    'id': row[0],
                    'move_date': row[1],
                    'from_location': f"{row[3] or ''} {row[2] or ''}".strip() if row[2] or row[3] else '—',
                    'to_location': f"{row[5] or ''} {row[4] or ''}".strip() if row[4] or row[5] else '—'
                }
                for row in rows
            ]
    
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

