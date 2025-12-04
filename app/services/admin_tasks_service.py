"""Сервис для работы с задачами на ремонт (админ-панель)"""
from core.database import get_db_cursor
from datetime import datetime

class AdminTasksService:
    """Сервис для работы с задачами на ремонт"""
    
    def get_all(self, user_role=None, department_id=None):
        """Получить все задачи на ремонт (только незавершенные)"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    rt.repair_task_id,
                    rt.heading,
                    rt.repair_task_description,
                    rt.repair_task_creation_date,
                    rt.repair_task_status,
                    rt.repair_task_start_date,
                    rt.repair_task_end_date,
                    rt.repair_task_resolution,
                    rt.equipment_assignment_id,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE rt.repair_task_status IS NULL OR rt.repair_task_status != 'Завершено'
            """
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += " ORDER BY rt.repair_task_end_date NULLS LAST, rt.repair_task_creation_date DESC"
            
            cur.execute(query, params)
            rows = cur.fetchall()
            return [self._row_to_dict(row) for row in rows]
    
    def get_by_id(self, repair_task_id):
        """Получить задачу по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    rt.repair_task_id,
                    rt.heading,
                    rt.repair_task_description,
                    rt.repair_task_creation_date,
                    rt.repair_task_status,
                    rt.repair_task_start_date,
                    rt.repair_task_end_date,
                    rt.repair_task_resolution,
                    rt.equipment_assignment_id,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE rt.repair_task_id = %s
            """, (repair_task_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
    def create(self, data):
        """Создать новую задачу на ремонт"""
        with get_db_cursor(commit=True) as cur:
            # Получаем department_id из данных
            department_id = data.get('department_id')
            
            if not department_id:
                raise ValueError('Отдел не указан')
            
            # Ищем существующий equipment_assignment для этого отдела
            # Если нет, создаем новый (можно использовать NULL equipment_id)
            equipment_assignment_id = None
            cur.execute("""
                SELECT equipment_assignment_id 
                FROM equipment_assignment 
                WHERE department_id = %s 
                LIMIT 1
            """, (department_id,))
            result = cur.fetchone()
            if result:
                equipment_assignment_id = result[0]
            else:
                # Создаем новый equipment_assignment для отдела
                cur.execute("""
                    INSERT INTO equipment_assignment (department_id, equipment_status)
                    VALUES (%s, 'В работе')
                    RETURNING equipment_assignment_id
                """, (department_id,))
                equipment_assignment_id = cur.fetchone()[0]
            
            # Создаем задачу
            end_date = data.get('repair_task_end_date')
            if end_date and isinstance(end_date, str):
                # Если дата в формате строки, преобразуем её
                try:
                    from datetime import datetime as dt
                    end_date = dt.strptime(end_date, '%Y-%m-%d').date()
                except ValueError:
                    end_date = None
            
            cur.execute("""
                INSERT INTO repair_task (
                    equipment_assignment_id,
                    heading,
                    repair_task_description,
                    repair_task_creation_date,
                    repair_task_status,
                    repair_task_end_date
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING repair_task_id
            """, (
                equipment_assignment_id,
                data.get('heading', '').strip(),
                data.get('repair_task_description', '').strip(),
                datetime.now().date(),
                'В процессе',
                end_date
            ))
            new_id = cur.fetchone()[0]
            return self.get_by_id(new_id)
    
    def update_status(self, repair_task_id, status):
        """Обновить статус задачи"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("""
                UPDATE repair_task 
                SET repair_task_status = %s
                WHERE repair_task_id = %s
            """, (status, repair_task_id))
            if cur.rowcount == 0:
                raise ValueError('Задача не найдена')
    
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
    
    def get_facilities(self):
        """Получить список предприятий"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT facility_id, facility_name
                FROM facility
                ORDER BY facility_name
            """)
            return [
                {
                    'id': row[0],
                    'name': row[1]
                }
                for row in cur.fetchall()
            ]
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        return {
            'id': row[0],
            'heading': row[1],
            'description': row[2],
            'creation_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
            'status': row[4] or 'В процессе',
            'start_date': row[5].strftime('%Y-%m-%d') if row[5] else None,
            'end_date': row[6].strftime('%Y-%m-%d') if row[6] else None,
            'resolution': row[7],
            'equipment_assignment_id': row[8],
            'department_id': row[9],
            'department_name': row[10],
            'facility_id': row[11],
            'facility_name': row[12]
        }

