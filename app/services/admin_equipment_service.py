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

