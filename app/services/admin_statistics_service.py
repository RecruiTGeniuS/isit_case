"""Сервис для работы со статистикой (админ-панель)"""
from core.database import get_db_cursor
from datetime import datetime, timedelta


class AdminStatisticsService:
    """Сервис для работы со статистикой"""
    
    def get_pto_statistics(self, user_role=None, department_id=None):
        """Статистика по ПТО"""
        with get_db_cursor() as cur:
            # Общая статистика по статусам ПТО
            # Используем подзапрос для правильной группировки
            query = """
                SELECT 
                    status,
                    COUNT(*) as count
                FROM (
                    SELECT 
                        CASE 
                            WHEN mp.maintenance_status IS NULL THEN 'Ожидает ПТО'
                            WHEN LOWER(mp.maintenance_status) LIKE '%выполнено%' 
                                 OR LOWER(mp.maintenance_status) LIKE '%завершено%' 
                                 OR LOWER(mp.maintenance_status) LIKE '%completed%' 
                                 OR LOWER(mp.maintenance_status) LIKE '%success%' THEN 'Выполнено'
                            WHEN LOWER(mp.maintenance_status) LIKE '%в процессе%' 
                                 OR LOWER(mp.maintenance_status) LIKE '%in_progress%' 
                                 OR LOWER(mp.maintenance_status) LIKE '%in process%' THEN 'В процессе'
                            WHEN mp.maintenance_start_date < CURRENT_DATE 
                                 AND (mp.maintenance_status IS NULL 
                                      OR LOWER(mp.maintenance_status) LIKE '%ожидает%') THEN 'Просрочено'
                            ELSE COALESCE(mp.maintenance_status, 'Ожидает ПТО')
                        END as status
                    FROM maintenance_plan mp
                    LEFT JOIN equipment_assignment ea ON mp.equipment_id = ea.equipment_id
                    LEFT JOIN department d ON ea.department_id = d.department_id
                    WHERE 1=1
            """
            params = []
            
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += """
                ) as statuses
                GROUP BY status
                ORDER BY count DESC
            """
            
            cur.execute(query, params)
            status_data = {row[0]: row[1] for row in cur.fetchall()}
            
            # Статистика по месяцам
            month_query = """
                SELECT 
                    TO_CHAR(maintenance_start_date, 'YYYY-MM') as month,
                    COUNT(*) as count
                FROM maintenance_plan mp
                LEFT JOIN equipment_assignment ea ON mp.equipment_id = ea.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE maintenance_start_date >= CURRENT_DATE - INTERVAL '12 months'
            """
            month_params = []
            if user_role == 'repair_head' and department_id:
                month_query += " AND d.department_id = %s"
                month_params.append(department_id)
            month_query += " GROUP BY month ORDER BY month"
            cur.execute(month_query, month_params)
            
            monthly_data = {row[0]: row[1] for row in cur.fetchall()}
            
            return {
                'by_status': status_data,
                'by_month': monthly_data,
                'total': sum(status_data.values())
            }
    
    def get_tasks_statistics(self, user_role=None, department_id=None):
        """Статистика по задачам на ремонт"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    COALESCE(rt.repair_task_status, 'В процессе') as status,
                    COUNT(*) as count
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE 1=1
            """
            params = []
            
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += " GROUP BY status ORDER BY count DESC"
            
            cur.execute(query, params)
            status_data = {row[0]: row[1] for row in cur.fetchall()}
            
            # Статистика по месяцам
            month_query = """
                SELECT 
                    TO_CHAR(repair_task_creation_date, 'YYYY-MM') as month,
                    COUNT(*) as count
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE repair_task_creation_date >= CURRENT_DATE - INTERVAL '12 months'
            """
            month_params = []
            if user_role == 'repair_head' and department_id:
                month_query += " AND d.department_id = %s"
                month_params.append(department_id)
            month_query += " GROUP BY month ORDER BY month"
            cur.execute(month_query, month_params)
            
            monthly_data = {row[0]: row[1] for row in cur.fetchall()}
            
            # Статистика по завершённым задачам
            completed_query = """
                SELECT 
                    TO_CHAR(repair_task_end_date, 'YYYY-MM') as month,
                    COUNT(*) as count
                FROM repair_task rt
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE repair_task_end_date IS NOT NULL
                AND repair_task_end_date >= CURRENT_DATE - INTERVAL '12 months'
            """
            completed_params = []
            if user_role == 'repair_head' and department_id:
                completed_query += " AND d.department_id = %s"
                completed_params.append(department_id)
            completed_query += " GROUP BY month ORDER BY month"
            cur.execute(completed_query, completed_params)
            
            completed_monthly = {row[0]: row[1] for row in cur.fetchall()}
            
            return {
                'by_status': status_data,
                'by_month': monthly_data,
                'completed_by_month': completed_monthly,
                'total': sum(status_data.values())
            }
    
    def get_employees_statistics(self, user_role=None, department_id=None):
        """Статистика по сотрудникам ремонтной службы"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    e.employee_id,
                    e.last_name || ' ' || e.first_name || ' ' || COALESCE(e.patronymic, '') as full_name,
                    COUNT(DISTINCT rte.repair_task_id) as tasks_count,
                    COUNT(DISTINCT CASE WHEN rt.repair_task_status IN ('Завершено', 'Завершена') THEN rte.repair_task_id END) as completed_tasks
                FROM employee e
                LEFT JOIN repair_task_employee rte ON e.employee_id = rte.employee_id
                LEFT JOIN repair_task rt ON rte.repair_task_id = rt.repair_task_id
                LEFT JOIN department d ON e.department_id = d.department_id
                WHERE e.user_role = 'repair_worker'
            """
            params = []
            
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += " GROUP BY e.employee_id, e.last_name, e.first_name, e.patronymic ORDER BY tasks_count DESC LIMIT 10"
            
            cur.execute(query, params)
            top_employees = []
            for row in cur.fetchall():
                if len(row) >= 4:
                    top_employees.append({
                        'id': row[0],
                        'name': (row[1] or '').strip() if row[1] else '',
                        'tasks_count': row[2] or 0,
                        'completed_tasks': row[3] or 0
                    })
            
            # Общая статистика
            total_query = """
                SELECT 
                    COUNT(DISTINCT e.employee_id) as total_employees,
                    COUNT(DISTINCT rte.repair_task_id) as total_tasks,
                    COUNT(DISTINCT CASE WHEN rt.repair_task_status IN ('Завершено', 'Завершена') THEN rte.repair_task_id END) as completed_tasks
                FROM employee e
                LEFT JOIN repair_task_employee rte ON e.employee_id = rte.employee_id
                LEFT JOIN repair_task rt ON rte.repair_task_id = rt.repair_task_id
                LEFT JOIN department d ON e.department_id = d.department_id
                WHERE e.user_role = 'repair_worker'
            """
            total_params = []
            if user_role == 'repair_head' and department_id:
                total_query += " AND d.department_id = %s"
                total_params.append(department_id)
            cur.execute(total_query, total_params)
            
            row = cur.fetchone()
            if row:
                total_stats = {
                    'total_employees': row[0] or 0,
                    'total_tasks': row[1] or 0,
                    'completed_tasks': row[2] or 0
                }
            else:
                total_stats = {
                    'total_employees': 0,
                    'total_tasks': 0,
                    'completed_tasks': 0
                }
            
            return {
                'top_employees': top_employees,
                'total': total_stats
            }
    
    def get_spare_parts_statistics(self, user_role=None, department_id=None):
        """Статистика по запчастям на складе"""
        with get_db_cursor() as cur:
            # Статистика по типам запчастей
            query = """
                SELECT 
                    COALESCE(sp.spare_part_type, 'Без типа') as type,
                    COUNT(DISTINCT sp.spare_part_id) as parts_count,
                    COALESCE(SUM(psq.quantity), 0) as total_quantity
                FROM spare_part sp
                LEFT JOIN part_stock_quantity psq ON sp.spare_part_id = psq.spare_part_id
                LEFT JOIN warehouse w ON psq.warehouse_id = w.warehouse_id
                LEFT JOIN department d ON w.department_id = d.department_id
                WHERE 1=1
            """
            params = []
            
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += " GROUP BY sp.spare_part_type ORDER BY total_quantity DESC"
            
            cur.execute(query, params)
            by_type = []
            for row in cur.fetchall():
                if len(row) >= 3:
                    by_type.append({
                        'type': row[0] or 'Без типа',
                        'parts_count': row[1] or 0,
                        'total_quantity': row[2] or 0
                    })
            
            # Топ запчастей по использованию
            cur.execute("""
                SELECT 
                    sp.spare_part_name,
                    sp.spare_part_type,
                    COUNT(rsp.spare_part_id) as usage_count
                FROM repair_spare_part rsp
                INNER JOIN spare_part sp ON rsp.spare_part_id = sp.spare_part_id
                INNER JOIN repair_task rt ON rsp.repair_task_id = rt.repair_task_id
                LEFT JOIN equipment_assignment ea ON rt.equipment_assignment_id = ea.equipment_assignment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE 1=1
                """ + (" AND d.department_id = %s" if user_role == 'repair_head' and department_id else "") + """
                GROUP BY sp.spare_part_id, sp.spare_part_name, sp.spare_part_type
                ORDER BY usage_count DESC
                LIMIT 10
            """, params if user_role == 'repair_head' and department_id else [])
            
            top_used = []
            for row in cur.fetchall():
                if len(row) >= 3:
                    top_used.append({
                        'name': row[0] or '—',
                        'type': row[1] or '—',
                        'usage_count': row[2] or 0
                    })
            
            # Общая статистика
            total_query = """
                SELECT 
                    COUNT(DISTINCT sp.spare_part_id) as total_parts,
                    COALESCE(SUM(psq.quantity), 0) as total_quantity,
                    COUNT(DISTINCT CASE WHEN psq.quantity = 0 OR psq.quantity IS NULL THEN sp.spare_part_id END) as out_of_stock
                FROM spare_part sp
                LEFT JOIN part_stock_quantity psq ON sp.spare_part_id = psq.spare_part_id
                LEFT JOIN warehouse w ON psq.warehouse_id = w.warehouse_id
                LEFT JOIN department d ON w.department_id = d.department_id
                WHERE 1=1
            """
            total_params = []
            if user_role == 'repair_head' and department_id:
                total_query += " AND d.department_id = %s"
                total_params.append(department_id)
            cur.execute(total_query, total_params)
            
            row = cur.fetchone()
            if row:
                total_stats = {
                    'total_parts': row[0] or 0,
                    'total_quantity': row[1] or 0,
                    'out_of_stock': row[2] or 0
                }
            else:
                total_stats = {
                    'total_parts': 0,
                    'total_quantity': 0,
                    'out_of_stock': 0
                }
            
            return {
                'by_type': by_type,
                'top_used': top_used,
                'total': total_stats
            }
    
    def get_equipment_statistics(self, user_role=None, department_id=None):
        """Статистика по оборудованию"""
        with get_db_cursor() as cur:
            query = """
                SELECT 
                    COALESCE(ea.equipment_status, 'Не указан') as status,
                    COUNT(*) as count
                FROM equipment e
                INNER JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
                LEFT JOIN department d ON ea.department_id = d.department_id
                WHERE e.equipment_name IS NOT NULL AND e.equipment_name != ''
            """
            params = []
            
            if user_role == 'repair_head' and department_id:
                query += " AND d.department_id = %s"
                params.append(department_id)
            
            query += " GROUP BY ea.equipment_status ORDER BY count DESC"
            
            cur.execute(query, params)
            by_status = {row[0]: row[1] for row in cur.fetchall()}
            
            return {
                'by_status': by_status,
                'total': sum(by_status.values())
            }
    
    def get_all_statistics(self, user_role=None, department_id=None):
        """Получить всю статистику"""
        try:
            pto_stats = self.get_pto_statistics(user_role, department_id)
        except Exception as e:
            print(f"Ошибка получения статистики ПТО: {e}")
            pto_stats = {'by_status': {}, 'by_month': {}, 'total': 0}
        
        try:
            tasks_stats = self.get_tasks_statistics(user_role, department_id)
        except Exception as e:
            print(f"Ошибка получения статистики задач: {e}")
            tasks_stats = {'by_status': {}, 'by_month': {}, 'completed_by_month': {}, 'total': 0}
        
        try:
            employees_stats = self.get_employees_statistics(user_role, department_id)
        except Exception as e:
            print(f"Ошибка получения статистики сотрудников: {e}")
            employees_stats = {'top_employees': [], 'total': {'total_employees': 0, 'total_tasks': 0, 'completed_tasks': 0}}
        
        try:
            spare_parts_stats = self.get_spare_parts_statistics(user_role, department_id)
        except Exception as e:
            print(f"Ошибка получения статистики запчастей: {e}")
            spare_parts_stats = {'by_type': [], 'top_used': [], 'total': {'total_parts': 0, 'total_quantity': 0, 'out_of_stock': 0}}
        
        try:
            equipment_stats = self.get_equipment_statistics(user_role, department_id)
        except Exception as e:
            print(f"Ошибка получения статистики оборудования: {e}")
            equipment_stats = {'by_status': {}, 'total': 0}
        
        return {
            'pto': pto_stats,
            'tasks': tasks_stats,
            'employees': employees_stats,
            'spare_parts': spare_parts_stats,
            'equipment': equipment_stats
        }

