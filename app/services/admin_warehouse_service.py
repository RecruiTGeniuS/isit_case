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
    
    def create(self, data):
        """Создать новую запись на складе"""
        with get_db_cursor(commit=True) as cur:
            # Сначала проверяем, существует ли запчасть с таким названием
            cur.execute("""
                SELECT spare_part_id FROM spare_part WHERE spare_part_name = %s
            """, (data.get('spare_part_name').strip(),))
            existing_part = cur.fetchone()
            
            if existing_part:
                spare_part_id = existing_part[0]
            else:
                # Создаем новую запчасть
                cur.execute("""
                    INSERT INTO spare_part (spare_part_name)
                    VALUES (%s)
                    RETURNING spare_part_id
                """, (data.get('spare_part_name').strip(),))
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
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        return {
            'id': row[0],
            'quantity': row[1],
            'spare_part_id': row[2],
            'spare_part_name': row[3] or '—',
            'warehouse_id': row[4],
            'warehouse_type': row[5] or '—',
            'warehouse_address': row[6] or '—',
            'department_id': row[7],
            'department_name': row[8],
            'facility_id': row[9],
            'facility_name': row[10] or '—',
        }

