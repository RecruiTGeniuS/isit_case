"""Сервис для работы с сотрудниками (админ-панель)"""
from core.database import get_db_cursor

class AdminEmployeeService:
    """Сервис для работы с сотрудниками"""
    
    def get_all(self, user_role=None, department_id=None):
        """Получить всех сотрудников"""
        with get_db_cursor() as cur:
            query = """
                SELECT e.employee_id, e.last_name, e.first_name, e.patronymic,
                       e.employee_post, e.phone_number, e.email, e.login, e.password, e.user_role,
                       d.department_name, f.facility_name
                FROM employee e
                LEFT JOIN department d ON e.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE 1=1
            """
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND e.department_id = %s"
                params.append(department_id)
            
            query += " ORDER BY e.last_name, e.first_name"
            
            cur.execute(query, params)
            rows = cur.fetchall()
            return [self._row_to_dict(row) for row in rows]
    
    def get_by_id(self, employee_id):
        """Получить сотрудника по ID"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT e.employee_id, e.last_name, e.first_name, e.patronymic,
                       e.employee_post, e.phone_number, e.email, e.login, e.password,
                       e.user_role, d.department_name, f.facility_name
                FROM employee e
                LEFT JOIN department d ON e.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE e.employee_id = %s
            """, (employee_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
    def create(self, data):
        """Создать нового сотрудника"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("""
                INSERT INTO employee (
                    department_id, employee_post, last_name, first_name, patronymic,
                    phone_number, email, user_role, login, password
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING employee_id
            """, (
                data.get('department_id'),
                data.get('post'),
                data.get('last_name').strip(),
                data.get('first_name').strip(),
                data.get('patronymic', '').strip() or None,
                data.get('phone', '').strip() or None,
                data.get('email', '').strip() or None,
                data.get('role').strip(),
                data.get('login').strip(),
                data.get('password').strip()
            ))
            new_id = cur.fetchone()[0]
            return self.get_by_id(new_id)
    
    def update_field(self, employee_id, field, value):
        """Обновить поле сотрудника"""
        editable_fields = {
            'last_name': 'last_name',
            'first_name': 'first_name',
            'patronymic': 'patronymic',
            'post': 'employee_post',
            'phone': 'phone_number',
            'email': 'email',
            'role': 'user_role',
            'login': 'login',
            'password': 'password'
        }
        
        if field not in editable_fields:
            raise ValueError(f'Поле {field} недоступно для редактирования')
        
        column = editable_fields[field]
        db_value = value.strip() if isinstance(value, str) else value
        db_value = db_value if db_value != '' else None
        
        with get_db_cursor(commit=True) as cur:
            cur.execute(f"UPDATE employee SET {column} = %s WHERE employee_id = %s", 
                       (db_value, employee_id))
            if cur.rowcount == 0:
                raise ValueError('Сотрудник не найден')
    
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
    
    def get_user_department_id(self, user_id):
        """Получить department_id пользователя"""
        with get_db_cursor() as cur:
            cur.execute("SELECT department_id FROM employee WHERE employee_id = %s", 
                       (user_id,))
            result = cur.fetchone()
            return result[0] if result else None
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        return {
            'id': row[0],
            'last_name': row[1],
            'first_name': row[2],
            'patronymic': row[3],
            'post': row[4],
            'phone': row[5],
            'email': row[6],
            'login': row[7],
            'password': row[8],
            'role': row[9],
            'department': row[10],
            'facility': row[11],
        }

