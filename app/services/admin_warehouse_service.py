"""Сервис для работы со складом (админ-панель)"""
from core.database import get_db_cursor

class AdminWarehouseService:
    """Сервис для работы со складом"""
    
    def get_all(self, user_role=None, department_id=None):
        """Получить все записи склада с данными о запчастях"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    psq.part_stock_quantity_id,
                    psq.quantity,
                    sp.spare_part_id,
                    sp.spare_part_name,
                    sp.spare_part_type,
                    w.warehouse_id,
                    w.warehouse_type,
                    w.warehouse_address,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM part_stock_quantity psq
                LEFT JOIN spare_part sp ON psq.spare_part_id = sp.spare_part_id
                LEFT JOIN warehouse w ON psq.warehouse_id = w.warehouse_id
                LEFT JOIN department d ON w.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE 1=1
            """
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND w.department_id = %s"
                params.append(department_id)
            
            query += " ORDER BY sp.spare_part_name, f.facility_name, d.department_name"
            
            cur.execute(query, params)
            rows = cur.fetchall()
            return [self._row_to_dict(row) for row in rows]
    
    def get_by_id(self, part_stock_quantity_id):
        """Получить запись склада по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    psq.part_stock_quantity_id,
                    psq.quantity,
                    sp.spare_part_id,
                    sp.spare_part_name,
                    sp.spare_part_type,
                    w.warehouse_id,
                    w.warehouse_type,
                    w.warehouse_address,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM part_stock_quantity psq
                LEFT JOIN spare_part sp ON psq.spare_part_id = sp.spare_part_id
                LEFT JOIN warehouse w ON psq.warehouse_id = w.warehouse_id
                LEFT JOIN department d ON w.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE psq.part_stock_quantity_id = %s
            """, (part_stock_quantity_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
    def get_spare_parts(self):
        """Получить список всех запчастей"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT spare_part_id, spare_part_name
                FROM spare_part
                ORDER BY spare_part_name
            """)
            return [
                {
                    'id': row[0],
                    'name': row[1] or '—'
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
    
    def create(self, data):
        """Создать новую запись на складе"""
        with get_db_cursor(commit=True) as cur:
            # Сначала проверяем, существует ли запчасть с таким названием
            cur.execute("""
                SELECT spare_part_id FROM spare_part WHERE spare_part_name = %s
            """, (data.get('spare_part_name').strip(),))
            existing_part = cur.fetchone()
            
            spare_part_type = data.get('spare_part_type', '').strip() or None
            
            if existing_part:
                spare_part_id = existing_part[0]
                # Обновляем тип детали, если он указан
                if spare_part_type:
                    cur.execute("""
                        UPDATE spare_part 
                        SET spare_part_type = %s 
                        WHERE spare_part_id = %s
                    """, (spare_part_type, spare_part_id))
            else:
                # Создаем новую запчасть
                cur.execute("""
                    INSERT INTO spare_part (spare_part_name, spare_part_type)
                    VALUES (%s, %s)
                    RETURNING spare_part_id
                """, (data.get('spare_part_name').strip(), spare_part_type))
                spare_part_id = cur.fetchone()[0]
            
            # Проверяем, существует ли уже запись для этой запчасти на этом складе
            cur.execute("""
                SELECT part_stock_quantity_id, quantity 
                FROM part_stock_quantity 
                WHERE spare_part_id = %s AND warehouse_id = %s
            """, (spare_part_id, data.get('warehouse_id')))
            existing_record = cur.fetchone()
            
            if existing_record:
                # Обновляем количество
                new_quantity = existing_record[1] + int(data.get('quantity', 0))
                cur.execute("""
                    UPDATE part_stock_quantity 
                    SET quantity = %s 
                    WHERE part_stock_quantity_id = %s
                """, (new_quantity, existing_record[0]))
                return self.get_by_id(existing_record[0])
            else:
                # Создаем новую запись
                cur.execute("""
                    INSERT INTO part_stock_quantity (spare_part_id, warehouse_id, quantity)
                    VALUES (%s, %s, %s)
                    RETURNING part_stock_quantity_id
                """, (spare_part_id, data.get('warehouse_id'), data.get('quantity', 0)))
                new_id = cur.fetchone()[0]
                return self.get_by_id(new_id)
    
    def get_warehouses(self):
        """Получить список всех складов"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT w.warehouse_id, w.warehouse_type, w.warehouse_address, d.department_id, d.department_name, f.facility_id, f.facility_name
                FROM warehouse w
                LEFT JOIN department d ON w.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                ORDER BY f.facility_name NULLS LAST, w.warehouse_type
            """)
            return [
                {
                    'id': row[0],
                    'type': row[1] or '—',
                    'address': row[2] or '—',
                    'department_id': row[3],
                    'department': row[4],
                    'facility_id': row[5],
                    'facility': row[6]
                }
                for row in cur.fetchall()
            ]
    
    def delete(self, part_stock_quantity_id):
        """Удалить запись со склада"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("DELETE FROM part_stock_quantity WHERE part_stock_quantity_id = %s", (part_stock_quantity_id,))
            if cur.rowcount == 0:
                raise ValueError('Запись не найдена')
    
    def update_field(self, part_stock_quantity_id, field, value):
        """Обновить поле записи склада"""
        editable_fields = {
            'warehouse_id': 'warehouse_id',
            'facility': 'facility',  # Специальная обработка для предприятия
            'spare_part_name': 'spare_part_name',  # Название детали
            'spare_part_type': 'spare_part_type',  # Тип детали
            'quantity': 'quantity'  # Количество
        }
        
        if field not in editable_fields:
            raise ValueError(f'Поле {field} недоступно для редактирования')
        
        # Для spare_part_name обновляем название детали
        if field == 'spare_part_name':
            spare_part_name = value.strip() if isinstance(value, str) else ''
            if not spare_part_name:
                raise ValueError('Название детали не может быть пустым')
            
            # Получаем текущую запись, чтобы узнать spare_part_id
            part = self.get_by_id(part_stock_quantity_id)
            if not part:
                raise ValueError('Запись не найдена')
            
            spare_part_id = part.get('spare_part_id')
            if not spare_part_id:
                raise ValueError('Не найден ID детали')
            
            # Обновляем название детали
            with get_db_cursor(commit=True) as cur:
                cur.execute("""
                    UPDATE spare_part 
                    SET spare_part_name = %s 
                    WHERE spare_part_id = %s
                """, (spare_part_name, spare_part_id))
                if cur.rowcount == 0:
                    raise ValueError('Деталь не найдена')
            return
        
        # Для spare_part_type обновляем тип детали
        if field == 'spare_part_type':
            spare_part_type = value.strip() if isinstance(value, str) else None
            if not spare_part_type or spare_part_type == '—':
                spare_part_type = None
            
            # Получаем текущую запись, чтобы узнать spare_part_id
            part = self.get_by_id(part_stock_quantity_id)
            if not part:
                raise ValueError('Запись не найдена')
            
            spare_part_id = part.get('spare_part_id')
            if not spare_part_id:
                raise ValueError('Не найден ID детали')
            
            # Обновляем тип детали
            with get_db_cursor(commit=True) as cur:
                cur.execute("""
                    UPDATE spare_part 
                    SET spare_part_type = %s 
                    WHERE spare_part_id = %s
                """, (spare_part_type, spare_part_id))
                if cur.rowcount == 0:
                    raise ValueError('Деталь не найдена')
            return
        
        # Для quantity обновляем количество
        if field == 'quantity':
            try:
                quantity = int(value) if value else 0
                if quantity < 0:
                    raise ValueError('Количество не может быть отрицательным')
            except (TypeError, ValueError):
                raise ValueError('Некорректное количество')
            
            with get_db_cursor(commit=True) as cur:
                cur.execute("""
                    UPDATE part_stock_quantity 
                    SET quantity = %s 
                    WHERE part_stock_quantity_id = %s
                """, (quantity, part_stock_quantity_id))
                if cur.rowcount == 0:
                    raise ValueError('Запись не найдена')
            return
        
        # Для facility нужно найти warehouse_id для выбранного предприятия или сбросить его
        if field == 'facility':
            facility_name = value.strip() if isinstance(value, str) else ''
            
            if not facility_name:
                # Если предприятие пустое, сбрасываем warehouse_id
                with get_db_cursor(commit=True) as cur:
                    cur.execute("""
                        UPDATE part_stock_quantity 
                        SET warehouse_id = NULL 
                        WHERE part_stock_quantity_id = %s
                    """, (part_stock_quantity_id,))
                    if cur.rowcount == 0:
                        raise ValueError('Запись не найдена')
                return
            
            # Находим facility_id по названию
            with get_db_cursor() as cur:
                cur.execute("SELECT facility_id FROM facility WHERE facility_name = %s", (facility_name,))
                facility_row = cur.fetchone()
                
                if not facility_row:
                    raise ValueError(f'Предприятие "{facility_name}" не найдено')
                
                facility_id = facility_row[0]
                
                # Находим первый склад для этого предприятия (если есть)
                # Но по требованию пользователя не устанавливаем автоматически, а сбрасываем
                # warehouse_id будет установлен позже при выборе склада
                with get_db_cursor(commit=True) as cur2:
                    cur2.execute("""
                        UPDATE part_stock_quantity 
                        SET warehouse_id = NULL 
                        WHERE part_stock_quantity_id = %s
                    """, (part_stock_quantity_id,))
                    if cur2.rowcount == 0:
                        raise ValueError('Запись не найдена')
            return
        
        # Для warehouse_id обрабатываем как число
        if field == 'warehouse_id':
            if value == '' or value is None:
                db_value = None
            else:
                try:
                    db_value = int(value)
                except (TypeError, ValueError):
                    raise ValueError('Некорректный ID склада')
            
            with get_db_cursor(commit=True) as cur:
                cur.execute("""
                    UPDATE part_stock_quantity 
                    SET warehouse_id = %s 
                    WHERE part_stock_quantity_id = %s
                """, (db_value, part_stock_quantity_id))
                if cur.rowcount == 0:
                    raise ValueError('Запись не найдена')
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        return {
            'id': row[0],
            'quantity': row[1],
            'spare_part_id': row[2],
            'spare_part_name': row[3] or '—',
            'spare_part_type': row[4] or '—',
            'warehouse_id': row[5],
            'warehouse_type': row[6] or '—',
            'warehouse_address': row[7] or '—',
            'department_id': row[8],
            'department_name': row[9],
            'facility_id': row[10],
            'facility_name': row[11] or '—',
        }

