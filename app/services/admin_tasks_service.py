"""Сервис для работы с задачами на ремонт (админ-панель)"""
from core.database import get_db_cursor
from datetime import datetime

class AdminTasksService:
    """Сервис для работы с задачами на ремонт"""
    
    def get_all(self, user_role=None, department_id=None, include_completed=False):
        """Получить все задачи на ремонт"""
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
                    f.facility_name,
                    e.equipment_id,
                    e.equipment_name,
                    COALESCE(employee_counts.assigned_count, 0) as assigned_employees_count
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN equipment e ON ea.equipment_id = e.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                LEFT JOIN (
                    SELECT repair_task_id, COUNT(employee_id) as assigned_count
                    FROM repair_task_employee
                    GROUP BY repair_task_id
                ) employee_counts ON rt.repair_task_id = employee_counts.repair_task_id
                WHERE 1=1
            """
            params = []
            
            # Фильтрация по статусу
            if not include_completed:
                query += " AND (rt.repair_task_status IS NULL OR rt.repair_task_status != 'Завершено')"
            
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
                    f.facility_name,
                    e.equipment_id,
                    e.equipment_name,
                    COALESCE(employee_counts.assigned_count, 0) as assigned_employees_count
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN equipment e ON ea.equipment_id = e.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                LEFT JOIN (
                    SELECT repair_task_id, COUNT(employee_id) as assigned_count
                    FROM repair_task_employee
                    GROUP BY repair_task_id
                ) employee_counts ON rt.repair_task_id = employee_counts.repair_task_id
                WHERE rt.repair_task_id = %s
            """, (repair_task_id,))
            row = cur.fetchone()
            return self._row_to_dict(row) if row else None
    
    def create(self, data):
        """Создать новую задачу на ремонт"""
        print(f"AdminTasksService.create вызван с данными: {data}")
        with get_db_cursor(commit=True) as cur:
            # Получаем equipment_assignment_id из данных (если создается из контекстного меню оборудования)
            equipment_assignment_id = data.get('equipment_assignment_id')
            department_id = data.get('department_id')
            
            print(f"equipment_assignment_id: {equipment_assignment_id}, department_id: {department_id}")
            
            # Если equipment_assignment_id не указан, ищем или создаем его
            if not equipment_assignment_id:
                if not department_id:
                    raise ValueError('Отдел не указан')
                
                # Ищем существующий equipment_assignment для этого отдела
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
            else:
                # Если equipment_assignment_id указан, проверяем его существование и обновляем статус оборудования на "В ремонте"
                print(f"Проверка существования equipment_assignment_id {equipment_assignment_id}")
                cur.execute("""
                    SELECT equipment_assignment_id 
                    FROM equipment_assignment 
                    WHERE equipment_assignment_id = %s
                """, (equipment_assignment_id,))
                if not cur.fetchone():
                    raise ValueError(f'Оборудование с ID {equipment_assignment_id} не найдено в БД')
                
                print(f"Обновление статуса оборудования {equipment_assignment_id} на 'В ремонте'")
                cur.execute("""
                    UPDATE equipment_assignment 
                    SET equipment_status = 'В ремонте'
                    WHERE equipment_assignment_id = %s
                """, (equipment_assignment_id,))
                if cur.rowcount == 0:
                    print(f"Предупреждение: equipment_assignment_id {equipment_assignment_id} не найден в БД при обновлении")
            
            # Создаем задачу
            heading = data.get('heading', '').strip()
            description = data.get('repair_task_description', '').strip()
            creation_date = datetime.now().date()
            status = 'В процессе'
            
            print(f"Создание задачи: equipment_assignment_id={equipment_assignment_id}, heading={heading}, description={description[:50] if description else ''}...")
            
            try:
                print(f"Выполнение INSERT в repair_task с данными: equipment_assignment_id={equipment_assignment_id}, heading={heading}, description={description[:50] if description else ''}, creation_date={creation_date}, status={status}")
                cur.execute("""
                    INSERT INTO repair_task (
                        equipment_assignment_id,
                        heading,
                        repair_task_description,
                        repair_task_creation_date,
                        repair_task_status
                    )
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING repair_task_id
                """, (
                    equipment_assignment_id,
                    heading,
                    description,
                    creation_date,
                    status
                ))
                result = cur.fetchone()
                if not result:
                    raise ValueError('Не удалось создать задачу: не получен ID новой задачи')
                new_id = result[0]
                print(f"Задача создана с ID: {new_id}")
                
                # Получаем полные данные задачи с JOIN'ами в текущей транзакции
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
                        f.facility_name,
                        e.equipment_name
                    FROM repair_task rt
                    LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                    LEFT JOIN equipment e ON ea.equipment_id = e.equipment_id
                    LEFT JOIN department d ON ea.department_id = d.department_id
                    LEFT JOIN facility f ON d.facility_id = f.facility_id
                    WHERE rt.repair_task_id = %s
                """, (new_id,))
                row = cur.fetchone()
                if not row:
                    raise ValueError(f'Задача с ID {new_id} не найдена в БД после создания')
                
                print(f"Проверка БД: задача найдена - ID={row[0]}, heading={row[1]}, status={row[4]}")
                
                # Транзакция будет закоммичена автоматически через get_db_cursor(commit=True)
                print("Транзакция будет закоммичена")
                
                # Преобразуем строку БД в словарь
                task = self._row_to_dict(row)
                print(f"Созданная задача (данные): {task}")
                return task
            except Exception as e:
                print(f"Ошибка при выполнении INSERT: {e}")
                import traceback
                print(traceback.format_exc())
                raise
    
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
    
    def delete(self, repair_task_id):
        """Удалить задачу"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("DELETE FROM repair_task WHERE repair_task_id = %s", (repair_task_id,))
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
    
    def get_equipment_by_department(self, department_id):
        """Получить список оборудования по отделу"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    ea.equipment_assignment_id,
                    e.equipment_id,
                    e.equipment_name,
                    e.equipment_type,
                    ea.location,
                    ea.equipment_status
                FROM equipment_assignment ea
                JOIN equipment e ON ea.equipment_id = e.equipment_id
                WHERE ea.department_id = %s
                AND e.equipment_name IS NOT NULL 
                AND e.equipment_name != ''
                ORDER BY e.equipment_name
            """, (department_id,))
            return [
                {
                    'equipment_assignment_id': row[0],
                    'equipment_id': row[1],
                    'equipment_name': row[2],
                    'equipment_type': row[3],
                    'location': row[4],
                    'equipment_status': row[5]
                }
                for row in cur.fetchall()
            ]
    
    def get_employees_by_facility(self, facility_id):
        """Получить список сотрудников ремонтной службы по предприятию"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.employee_id,
                    e.last_name,
                    e.first_name,
                    e.patronymic,
                    e.employee_post,
                    e.user_role,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM employee e
                LEFT JOIN department d ON e.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE f.facility_id = %s
                AND e.user_role IN ('repair_head', 'repair_worker')
                ORDER BY e.last_name, e.first_name
            """, (facility_id,))
            return [
                {
                    'id': row[0],
                    'last_name': row[1],
                    'first_name': row[2],
                    'patronymic': row[3],
                    'post': row[4],
                    'role': row[5],
                    'department_id': row[6],
                    'department_name': row[7],
                    'facility_id': row[8],
                    'facility_name': row[9],
                    'full_name': f"{row[1] or ''} {row[2] or ''} {row[3] or ''}".strip()
                }
                for row in cur.fetchall()
            ]
    
    def get_task_employees(self, repair_task_id):
        """Получить список сотрудников, назначенных на задачу"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    e.employee_id,
                    e.last_name,
                    e.first_name,
                    e.patronymic,
                    e.employee_post,
                    e.user_role,
                    d.department_id,
                    d.department_name,
                    f.facility_id,
                    f.facility_name
                FROM repair_task_employee rte
                JOIN employee e ON rte.employee_id = e.employee_id
                LEFT JOIN department d ON e.department_id = d.department_id
                LEFT JOIN facility f ON d.facility_id = f.facility_id
                WHERE rte.repair_task_id = %s
                ORDER BY e.last_name, e.first_name
            """, (repair_task_id,))
            return [
                {
                    'id': row[0],
                    'last_name': row[1],
                    'first_name': row[2],
                    'patronymic': row[3],
                    'post': row[4],
                    'role': row[5],
                    'department_id': row[6],
                    'department_name': row[7],
                    'facility_id': row[8],
                    'facility_name': row[9],
                    'full_name': f"{row[1] or ''} {row[2] or ''} {row[3] or ''}".strip()
                }
                for row in cur.fetchall()
            ]
    
    def assign_employees(self, repair_task_id, employee_ids):
        """Назначить сотрудников на задачу"""
        with get_db_cursor(commit=True) as cur:
            # Удаляем существующие назначения
            cur.execute("""
                DELETE FROM repair_task_employee 
                WHERE repair_task_id = %s
            """, (repair_task_id,))
            
            # Добавляем новые назначения
            if employee_ids:
                for employee_id in employee_ids:
                    cur.execute("""
                        INSERT INTO repair_task_employee (repair_task_id, employee_id)
                        VALUES (%s, %s)
                    """, (repair_task_id, employee_id))
                
                # Обновляем дату начала ремонта, если она еще не установлена
                cur.execute("""
                    UPDATE repair_task 
                    SET repair_task_start_date = CURRENT_DATE 
                    WHERE repair_task_id = %s 
                    AND repair_task_start_date IS NULL
                """, (repair_task_id,))
    
    def get_spare_parts_for_equipment(self, equipment_id, facility_id):
        """Получить список запчастей для оборудования со склада предприятия"""
        with get_db_cursor() as cur:
            cur.execute("""
                SELECT 
                    sp.spare_part_id,
                    sp.spare_part_name,
                    sp.spare_part_type,
                    COALESCE(SUM(psq.quantity), 0) as total_quantity,
                    CASE WHEN sp.equipment_id = %s THEN 0 ELSE 1 END as sort_priority
                FROM spare_part sp
                INNER JOIN part_stock_quantity psq ON sp.spare_part_id = psq.spare_part_id
                INNER JOIN warehouse w ON psq.warehouse_id = w.warehouse_id
                INNER JOIN department d ON w.department_id = d.department_id
                WHERE d.facility_id = %s
                AND psq.quantity > 0
                AND (sp.equipment_id = %s OR sp.equipment_id IS NULL)
                GROUP BY sp.spare_part_id, sp.spare_part_name, sp.spare_part_type, sp.equipment_id
                ORDER BY sort_priority, sp.spare_part_name
            """, (equipment_id, facility_id, equipment_id))
            return [
                {
                    'id': row[0],
                    'name': row[1] or '—',
                    'type': row[2] or '—',
                    'quantity': row[3] or 0
                }
                for row in cur.fetchall()
            ]
    
    def complete_task(self, repair_task_id, resolution, spare_part_quantities):
        """Завершить задачу: обновить статус, дату завершения, описание и добавить запчасти"""
        with get_db_cursor(commit=True) as cur:
            # Обновляем задачу
            cur.execute("""
                UPDATE repair_task 
                SET repair_task_status = 'Завершено',
                    repair_task_end_date = CURRENT_DATE,
                    repair_task_resolution = %s
                WHERE repair_task_id = %s
            """, (resolution, repair_task_id))
            
            # Удаляем старые связи с запчастями
            cur.execute("""
                DELETE FROM repair_spare_part 
                WHERE repair_task_id = %s
            """, (repair_task_id,))
            
            # Добавляем новые запчасти и списываем их со склада
            if spare_part_quantities:
                for spare_part_id, quantity in spare_part_quantities.items():
                    if quantity <= 0:
                        continue
                    
                    # Добавляем связь запчасти с задачей (quantity раз)
                    for _ in range(quantity):
                        cur.execute("""
                            INSERT INTO repair_spare_part (repair_task_id, spare_part_id)
                            VALUES (%s, %s)
                        """, (repair_task_id, spare_part_id))
                    
                    # Списываем quantity единиц запчасти со склада
                    remaining_quantity = quantity
                    while remaining_quantity > 0:
                        # Находим склад с доступным количеством
                        cur.execute("""
                            SELECT part_stock_quantity_id, quantity
                            FROM part_stock_quantity
                            WHERE spare_part_id = %s
                            AND quantity > 0
                            ORDER BY part_stock_quantity_id
                            LIMIT 1
                            FOR UPDATE
                        """, (spare_part_id,))
                        stock_row = cur.fetchone()
                        
                        if not stock_row:
                            raise ValueError(f'Недостаточно запчастей на складе (ID: {spare_part_id})')
                        
                        stock_id, available_quantity = stock_row
                        quantity_to_deduct = min(remaining_quantity, available_quantity)
                        
                        cur.execute("""
                            UPDATE part_stock_quantity
                            SET quantity = quantity - %s
                            WHERE part_stock_quantity_id = %s
                        """, (quantity_to_deduct, stock_id))
                        
                        remaining_quantity -= quantity_to_deduct
            
            # Обновляем статус оборудования обратно на "В работе"
            cur.execute("""
                UPDATE equipment_assignment
                SET equipment_status = 'В работе'
                WHERE equipment_assignment_id = (
                    SELECT equipment_assignment_id
                    FROM repair_task
                    WHERE repair_task_id = %s
                )
            """, (repair_task_id,))
    
    def _row_to_dict(self, row):
        """Преобразование строки БД в словарь"""
        # Проверяем длину row для обратной совместимости
        if len(row) >= 16:  # Теперь 16 полей (добавлен equipment_id)
            assigned_count = row[15] or 0
            # Определяем статус: если нет назначенных сотрудников и статус не "Завершено", то "Ожидает назначения"
            original_status = row[4] or 'В процессе'
            if assigned_count == 0 and original_status != 'Завершено':
                display_status = 'Ожидает назначения'
            else:
                display_status = original_status
            
            return {
                'id': row[0],
                'heading': row[1],
                'description': row[2],
                'creation_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
                'status': display_status,
                'original_status': original_status,
                'start_date': row[5].strftime('%Y-%m-%d') if row[5] else None,
                'end_date': row[6].strftime('%Y-%m-%d') if row[6] else None,
                'resolution': row[7],
                'equipment_assignment_id': row[8],
                'department_id': row[9],
                'department_name': row[10],
                'facility_id': row[11],
                'facility_name': row[12],
                'equipment_id': row[13],
                'equipment_name': row[14] or '—',
                'assigned_employees_count': assigned_count
            }
        elif len(row) >= 15:  # Старая версия без equipment_id
            assigned_count = row[14] or 0
            original_status = row[4] or 'В процессе'
            if assigned_count == 0 and original_status != 'Завершено':
                display_status = 'Ожидает назначения'
            else:
                display_status = original_status
            
            return {
                'id': row[0],
                'heading': row[1],
                'description': row[2],
                'creation_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
                'status': display_status,
                'original_status': original_status,
                'start_date': row[5].strftime('%Y-%m-%d') if row[5] else None,
                'end_date': row[6].strftime('%Y-%m-%d') if row[6] else None,
                'resolution': row[7],
                'equipment_assignment_id': row[8],
                'department_id': row[9],
                'department_name': row[10],
                'facility_id': row[11],
                'facility_name': row[12],
                'equipment_id': None,
                'equipment_id': row[13],
                'equipment_name': row[14] or '—',
                'assigned_employees_count': assigned_count
            }
        elif len(row) >= 15:  # Старая версия без equipment_id
            assigned_count = row[14] or 0
            original_status = row[4] or 'В процессе'
            if assigned_count == 0 and original_status != 'Завершено':
                display_status = 'Ожидает назначения'
            else:
                display_status = original_status
            
            return {
                'id': row[0],
                'heading': row[1],
                'description': row[2],
                'creation_date': row[3].strftime('%Y-%m-%d') if row[3] else None,
                'status': display_status,
                'original_status': original_status,
                'start_date': row[5].strftime('%Y-%m-%d') if row[5] else None,
                'end_date': row[6].strftime('%Y-%m-%d') if row[6] else None,
                'resolution': row[7],
                'equipment_assignment_id': row[8],
                'department_id': row[9],
                'department_name': row[10],
                'facility_id': row[11],
                'facility_name': row[12],
                'equipment_id': None,
                'equipment_name': row[13] or '—',
                'assigned_employees_count': assigned_count
            }
        else:
            # Обратная совместимость для старых запросов
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
                'facility_name': row[12],
                'equipment_id': None,
                'equipment_name': '—',
                'assigned_employees_count': 0
            }

