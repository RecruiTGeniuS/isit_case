# Архитектура проекта ISIT-App

## Обзор

ISIT-App — это веб-приложение на Flask для управления техническим обслуживанием и ремонтом (ТОиР). Проект использует модульную архитектуру, которая обеспечивает изоляцию компонентов, безопасную параллельную разработку и простоту поддержки.

## Структура проекта

```
isit-app/
├── app/                          # Основная директория приложения
│   ├── app.py                    # Точка входа в приложение
│   ├── factory.py                # Фабрика Flask приложения
│   ├── config.py                 # Конфигурация (БД, настройки)
│   ├── requirements.txt          # Python зависимости
│   ├── Dockerfile                # Docker образ приложения
│   │
│   ├── core/                     # Ядро приложения
│   │   ├── __init__.py
│   │   ├── database.py           # Подключение к БД, контекстные менеджеры
│   │   ├── auth.py               # Аутентификация и авторизация
│   │   └── decorators.py         # Декораторы (@login_required)
│   │
│   ├── utils/                    # Утилиты
│   │   ├── __init__.py
│   │   └── formatters.py         # Форматирование данных (телефоны, роли)
│   │
│   ├── services/                 # Бизнес-логика
│   │   ├── __init__.py
│   │   └── admin_employee_service.py  # Логика работы с сотрудниками
│   │
│   ├── routes/                    # Маршруты (Flask Blueprints)
│   │   ├── __init__.py
│   │   ├── auth.py               # /login, /logout
│   │   ├── main.py               # /home, /static
│   │   ├── admin.py              # /admin (главная админки)
│   │   ├── admin_employees.py    # /admin/employees/*
│   │   ├── admin_equipment.py    # /admin/equipment/*
│   │   ├── admin_warehouse.py    # /admin/warehouse/*
│   │   ├── admin_pto.py          # /admin/pto/*
│   │   └── admin_statistics.py   # /admin/statistics/*
│   │
│   ├── templates/                 # HTML шаблоны
│   │   ├── login.html            # Страница входа
│   │   ├── index.html            # Главная страница
│   │   └── admin.html            # Админ-панель
│   │
│   └── static/                    # Статические файлы
│       ├── css/
│       │   ├── main.css          # Главный файл (импорты всех модулей)
│       │   ├── base/
│       │   │   ├── reset.css     # Сброс стилей
│       │   │   └── variables.css # CSS переменные
│       │   ├── components/       # Переиспользуемые компоненты
│       │   │   ├── buttons.css
│       │   │   ├── filter.css
│       │   │   ├── modal.css
│       │   │   ├── navigation.css
│       │   │   └── table.css
│       │   └── pages/            # Стили для конкретных страниц
│       │       ├── auth.css
│       │       ├── employees.css
│       │       ├── equipment.css
│       │       ├── warehouse.css
│       │       ├── pto.css
│       │       └── statistics.css
│       └── images/
│           ├── equipment/
│           └── workers/
│
├── db-init/                      # Инициализация базы данных
│   └── init.sql                  # SQL дамп для первого запуска
│
├── docker-compose.yaml           # Конфигурация Docker контейнеров
├── docker-compose.override.yaml  # Локальные переопределения
└── ARCHITECTURE.md               # Этот файл
```

## Назначение папок и модулей

### `app/core/` — Ядро приложения

**Назначение:** Фундаментальные модули, используемые во всем приложении.

- **`database.py`** — Работа с базой данных PostgreSQL
  - `get_db_connection()` — создание подключения к БД
  - `get_db_cursor()` — контекстный менеджер для работы с курсором (автоматический commit/rollback)
  
- **`auth.py`** — Аутентификация и авторизация
  - `get_current_user()` — получение текущего пользователя из сессии
  - `authenticate_user()` — проверка логина и пароля
  - `save_user_to_session()` — сохранение пользователя в сессию

- **`decorators.py`** — Декораторы для маршрутов
  - `@login_required` — проверка авторизации (опционально, можно проверять вручную)

### `app/utils/` — Утилиты

**Назначение:** Вспомогательные функции для форматирования и валидации данных.

- **`formatters.py`** — Форматирование данных
  - `format_phone()` — форматирование телефонных номеров
  - `get_role_translation()` — перевод ролей на русский язык

### `app/services/` — Бизнес-логика

**Назначение:** Вся бизнес-логика и работа с БД вынесена в сервисы. Маршруты только обрабатывают HTTP запросы и вызывают методы сервисов.

- **`admin_employee_service.py`** — Логика работы с сотрудниками
  - `get_all()` — получение всех сотрудников
  - `get_by_id()` — получение сотрудника по ID
  - `create()` — создание нового сотрудника
  - `update_field()` — обновление поля сотрудника
  - `get_departments()` — получение списка отделов

**Правило:** Каждый модуль админ-панели должен иметь свой сервис (`admin_*_service.py`).

### `app/routes/` — Маршруты (Flask Blueprints)

**Назначение:** Обработка HTTP запросов, валидация входных данных, вызов сервисов, рендеринг шаблонов.

Каждый модуль админ-панели имеет свой Blueprint:
- **`auth.py`** — `/login`, `/logout`
- **`admin_employees.py`** — `/admin/employees/*`
- **`admin_equipment.py`** — `/admin/equipment/*`
- **`admin_warehouse.py`** — `/admin/warehouse/*`
- **`admin_pto.py`** — `/admin/pto/*`
- **`admin_statistics.py`** — `/admin/statistics/*`
- **`admin.py`** — `/admin` (главная страница админки)
- **`main.py`** — `/home`, `/static/*`

**Правило:** Каждый Blueprint изолирован и не должен напрямую обращаться к другим Blueprints. Общая логика выносится в сервисы или утилиты.

### `app/templates/` — HTML шаблоны

**Назначение:** Шаблоны для рендеринга страниц.

- Используется Jinja2 (встроенный в Flask)
- Общие компоненты можно выносить в отдельные файлы и подключать через `{% include %}`

### `app/static/` — Статические файлы

**Назначение:** CSS, JavaScript, изображения.

**Структура CSS:**
- **`main.css`** — главный файл, импортирует все модули
- **`base/`** — базовые стили (reset, переменные)
- **`components/`** — переиспользуемые компоненты (таблицы, кнопки, модальные окна)
- **`pages/`** — стили для конкретных страниц

**Правило:** Каждая страница имеет свой CSS файл в `pages/`. Общие стили выносятся в `components/`.

## Принципы архитектуры

### 1. Изоляция модулей

Каждый модуль (employees, equipment, warehouse и т.д.) изолирован:
- Свой Blueprint в `routes/`
- Свой сервис в `services/` (если нужна бизнес-логика)
- Свой CSS файл в `static/css/pages/`
- Свой шаблон в `templates/` (если нужен)

**Преимущества:**
- Изменения в одном модуле не влияют на другие
- Безопасная параллельная разработка
- Легко найти код, связанный с конкретной функциональностью

### 2. Разделение ответственности

- **Routes** — только обработка HTTP запросов, валидация, рендеринг
- **Services** — вся бизнес-логика и работа с БД
- **Core** — фундаментальные функции (БД, аутентификация)
- **Utils** — вспомогательные функции

### 3. Переиспользование кода

- Общие функции в `core/` и `utils/`
- Общие компоненты в `templates/components/`
- Общие стили в `static/css/components/`

## Как добавить новый функционал

### Пример: Добавление модуля "Склад" (warehouse)

#### Шаг 1: Создать Service (если нужна бизнес-логика)

**Файл:** `app/services/admin_warehouse_service.py`

```python
"""Сервис для работы со складом"""
from core.database import get_db_cursor

class AdminWarehouseService:
    def get_all_parts(self, user_role=None, department_id=None):
        """Получить все запчасти с учетом прав доступа"""
        with get_db_cursor() as cur:
            query = "SELECT * FROM warehouse_parts WHERE 1=1"
            params = []
            
            # Фильтрация по отделу для начальника ремонтной службы
            if user_role == 'repair_head' and department_id:
                query += " AND department_id = %s"
                params.append(department_id)
            
            cur.execute(query, params)
            return [self._row_to_dict(row) for row in cur.fetchall()]
    
    def create_part(self, data):
        """Создать новую запчасть"""
        with get_db_cursor(commit=True) as cur:
            cur.execute("""
                INSERT INTO warehouse_parts (part_name, quantity)
                VALUES (%s, %s)
                RETURNING part_id
            """, (data.get('part_name'), data.get('quantity')))
            return cur.fetchone()[0]
```

#### Шаг 2: Создать Route (Blueprint)

**Файл:** `app/routes/admin_warehouse.py`

```python
"""Маршруты для работы со складом"""
from flask import Blueprint, render_template, request, jsonify, session, redirect, url_for
from core.auth import get_current_user
from services.admin_warehouse_service import AdminWarehouseService

bp = Blueprint('admin_warehouse', __name__, url_prefix='/admin/warehouse')

@bp.route('', methods=['GET'])
def list_warehouse():
    """Список склада"""
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    user = get_current_user()
    service = AdminWarehouseService()
    
    # Получаем данные с учетом прав доступа
    parts = service.get_all_parts(
        user_role=user['role'],
        department_id=user.get('department_id')
    )
    
    return render_template('admin.html',
                         section='warehouse',
                         user=user,
                         parts=parts)
```

#### Шаг 3: Зарегистрировать Blueprint

**Файл:** `app/factory.py`

```python
from routes import admin_warehouse  # Добавить импорт

def create_app():
    # ...
    app.register_blueprint(admin_warehouse.bp)  # Добавить регистрацию
    # ...
```

#### Шаг 4: Создать CSS (если нужны специфичные стили)

**Файл:** `app/static/css/pages/warehouse.css`

```css
/* Стили для страницы склада */
.warehouse-container {
    /* ... */
}
```

**Файл:** `app/static/css/main.css`

```css
/* Добавить импорт */
@import 'pages/warehouse.css';
```

#### Шаг 5: Обновить навигацию (если нужно)

**Файл:** `app/templates/admin.html` (или где находится sidebar)

```html
<a href="{{ url_for('admin_warehouse.list_warehouse') }}" 
   class="nav-item {% if section == 'warehouse' %}active{% endif %}">
    Склад
</a>
```

### Чеклист при добавлении нового функционала

- [ ] Создан Service в `services/admin_*.py` (если нужна бизнес-логика)
- [ ] Создан Blueprint в `routes/admin_*.py`
- [ ] Blueprint зарегистрирован в `app/factory.py`
- [ ] Создан CSS файл в `static/css/pages/*.css` (если нужны специфичные стили)
- [ ] Добавлен импорт CSS в `static/css/main.css`
- [ ] Добавлена ссылка в навигацию (если нужно)
- [ ] Реализована проверка прав доступа
- [ ] Протестирована функциональность

## Работа с базой данных

### Использование контекстного менеджера

**Всегда используйте `get_db_cursor()` для работы с БД:**

```python
from core.database import get_db_cursor

# Для SELECT запросов (автоматический rollback)
with get_db_cursor() as cur:
    cur.execute("SELECT * FROM employee")
    rows = cur.fetchall()

# Для INSERT/UPDATE/DELETE (автоматический commit)
with get_db_cursor(commit=True) as cur:
    cur.execute("INSERT INTO employee (name) VALUES (%s)", ('Иван',))
```

### Правила работы с БД

1. **Всегда используйте параметризованные запросы** для защиты от SQL-инъекций:
   ```python
   # ✅ Правильно
   cur.execute("SELECT * FROM employee WHERE id = %s", (employee_id,))
   
   # ❌ Неправильно
   cur.execute(f"SELECT * FROM employee WHERE id = {employee_id}")
   ```

2. **Используйте транзакции** через `get_db_cursor(commit=True)` для операций изменения данных

3. **Закрывайте соединения** — контекстный менеджер делает это автоматически

## Аутентификация и авторизация

### Проверка авторизации

**Вариант 1: Вручную (рекомендуется для простых случаев)**

```python
@bp.route('', methods=['GET'])
def list_employees():
    if 'user_id' not in session:
        return redirect(url_for('auth.login'))
    
    user = get_current_user()
    # ...
```

**Вариант 2: Декоратор (если много маршрутов)**

```python
from core.decorators import login_required

@bp.route('', methods=['GET'])
@login_required
def list_employees():
    user = get_current_user()
    # ...
```

### Получение текущего пользователя

```python
from core.auth import get_current_user

user = get_current_user()
# user = {
#     'user_id': 1,
#     'login': 'ivanov',
#     'last_name': 'Иванов',
#     'role': 'maintenance_admin',
#     ...
# }
```

## Роли и права доступа

### Основные роли

- **`maintenance_admin`** — Администратор ТОиР (полный доступ ко всем функциям)
- **`executive`** — Руководство (видит всё как администратор, но без возможности редактирования/добавления)
- **`procurement_analyst`** — Аналитик (видит статистику и некоторые таблицы без возможности редактирования)
- **`repair_head`** — Начальник ремонтной службы (видит только свой отдел)
- **`store_keeper`** — Заведующий складом (управление складом)
- **`dept_head`** — Начальник отдела (видит свой отдел)
- **`repair_worker`** — Сотрудник ремонтной службы (ограниченный доступ)

### Проверка прав доступа

**В Routes:**

```python
def check_permission(user_role, required_permissions):
    """Проверка прав доступа"""
    if user_role not in required_permissions:
        if request.is_json:
            return jsonify({'success': False, 'message': 'Недостаточно прав'}), 403
        return redirect(url_for('admin.dashboard'))
    return None

@bp.route('', methods=['POST'])
def create_employee():
    user = get_current_user()
    
    # Только администратор может создавать сотрудников
    perm_check = check_permission(user['role'], ['maintenance_admin'])
    if perm_check:
        return perm_check
    
    # ...
```

**В Services (фильтрация данных):**

```python
def get_all_employees(self, user_role=None, department_id=None):
    query = "SELECT * FROM employee WHERE 1=1"
    params = []
    
    # Начальник ремонтной службы видит только свой отдел
    if user_role == 'repair_head' and department_id:
        query += " AND department_id = %s"
        params.append(department_id)
    
    # ...
```

**Пример: Роли только для просмотра**

```python
# Роли, которые могут только просматривать (без редактирования)
READ_ONLY_ROLES = ['executive', 'procurement_analyst']

# Роли, которые могут видеть статистику
STATISTICS_ROLES = ['maintenance_admin', 'executive', 'procurement_analyst']

@bp.route('', methods=['GET'])
def list_employees():
    user = get_current_user()
    
    # Определяем права доступа
    can_view = True  # Все авторизованные могут просматривать
    can_edit = user['role'] == 'maintenance_admin'
    can_add = user['role'] == 'maintenance_admin'
    can_delete = user['role'] == 'maintenance_admin'
    
    # Руководство и аналитик видят всё, но не могут редактировать
    if user['role'] in ['executive', 'procurement_analyst']:
        can_edit = False
        can_add = False
        can_delete = False
    
    return render_template('admin/employees.html',
                         employees=employees,
                         can_view=can_view,
                         can_edit=can_edit,
                         can_add=can_add,
                         can_delete=can_delete)

@bp.route('/statistics', methods=['GET'])
def view_statistics():
    user = get_current_user()
    
    # Только администратор, руководство и аналитик могут видеть статистику
    if user['role'] not in ['maintenance_admin', 'executive', 'procurement_analyst']:
        return redirect(url_for('admin.dashboard'))
    
    # ...
```

**В Templates:**

```html
{% if user.role == 'maintenance_admin' %}
    <button onclick="addEmployee()">Добавить сотрудника</button>
{% endif %}

{% if user.role in ['maintenance_admin', 'executive', 'procurement_analyst'] %}
    <a href="{{ url_for('admin_statistics.view') }}">Статистика</a>
{% endif %}

{% if user.role in ['maintenance_admin', 'executive'] %}
    <!-- Руководство и администратор видят все данные -->
    <div class="full-data-view">
        <!-- ... -->
    </div>
{% elif user.role == 'procurement_analyst' %}
    <!-- Аналитик видит только определенные таблицы -->
    <div class="analytics-view">
        <!-- ... -->
    </div>
{% endif %}
```

### Детальное описание ролей

#### Администратор ТОиР (`maintenance_admin`)
- **Права:** Полный доступ ко всем функциям
- **Может:** Добавлять, редактировать, удалять любые данные
- **Видит:** Все отделы и предприятия
- **Использование:** Полный контроль над системой

#### Руководство (`executive`)
- **Права:** Просмотр всех данных без возможности редактирования
- **Может:** Просматривать все разделы, статистику, отчеты
- **Не может:** Добавлять, редактировать, удалять данные
- **Видит:** Все отделы и предприятия (как администратор)
- **Использование:** Для руководящего состава, которому нужен полный обзор без возможности изменений

#### Аналитик (`procurement_analyst`)
- **Права:** Просмотр статистики и определенных таблиц без возможности редактирования
- **Может:** Просматривать статистику, аналитические отчеты, некоторые таблицы
- **Не может:** Добавлять, редактировать, удалять данные
- **Видит:** Ограниченный набор данных, необходимый для аналитики
- **Использование:** Для аналитиков, которым нужен доступ к данным для анализа, но не нужны права на редактирование

#### Начальник ремонтной службы (`repair_head`)
- **Права:** Управление своим отделом
- **Может:** Назначать задачи, менять статусы запчастей
- **Видит:** Только свой отдел
- **Не может:** Добавлять/редактировать сотрудников

#### Заведующий складом (`store_keeper`)
- **Права:** Управление складом
- **Может:** Добавлять, редактировать запчасти, менять статусы
- **Видит:** Все данные склада

#### Начальник отдела (`dept_head`)
- **Права:** Просмотр своего отдела
- **Может:** Просматривать отчеты по отделу
- **Видит:** Только свой отдел

#### Сотрудник ремонтной службы (`repair_worker`)
- **Права:** Ограниченный доступ
- **Может:** Просматривать назначенные задачи, обновлять статус своих задач
- **Видит:** Только свои задачи

### Константы ролей (рекомендуется)

Для удобства работы с ролями рекомендуется создать файл `app/core/roles.py`:

```python
"""Константы ролей пользователей"""

# Роли с полным доступом (могут редактировать)
ADMIN_ROLES = ['maintenance_admin']

# Роли только для просмотра (не могут редактировать)
READ_ONLY_ROLES = ['executive', 'procurement_analyst']

# Роли с доступом к статистике
STATISTICS_ROLES = ['maintenance_admin', 'executive', 'procurement_analyst']

# Роли с доступом к управлению складом
WAREHOUSE_ROLES = ['store_keeper', 'maintenance_admin']

# Роли с доступом к назначению задач
TASK_ASSIGNMENT_ROLES = ['repair_head', 'maintenance_admin']

# Роли с ограниченным доступом (только свой отдел)
DEPARTMENT_LIMITED_ROLES = ['repair_head', 'dept_head']

# Роли, которые видят все данные (без фильтрации по отделу)
FULL_ACCESS_VIEW_ROLES = ['maintenance_admin', 'executive']

def has_permission(user_role, required_roles):
    """Проверка, есть ли у пользователя нужные права"""
    return user_role in required_roles

def can_edit(user_role):
    """Проверка, может ли пользователь редактировать данные"""
    return user_role in ADMIN_ROLES

def can_view_statistics(user_role):
    """Проверка, может ли пользователь видеть статистику"""
    return user_role in STATISTICS_ROLES
```

**Использование:**

```python
from core.roles import ADMIN_ROLES, READ_ONLY_ROLES, STATISTICS_ROLES, can_edit, can_view_statistics

@bp.route('', methods=['GET'])
def list_employees():
    user = get_current_user()
    
    # Определяем права доступа
    can_edit_data = can_edit(user['role'])
    can_add = user['role'] in ADMIN_ROLES
    can_view_stats = can_view_statistics(user['role'])
    
    # Руководство и аналитик видят всё, но не могут редактировать
    if user['role'] in READ_ONLY_ROLES:
        can_edit_data = False
        can_add = False
    
    return render_template('admin/employees.html',
                         employees=employees,
                         can_edit=can_edit_data,
                         can_add=can_add,
                         can_view_stats=can_view_stats)
```

### Важные правила

1. **Всегда проверяйте права на сервере** — не полагайтесь только на скрытие элементов в UI
2. **Фильтруйте данные в сервисах** — не передавайте лишние данные клиенту
3. **Документируйте права** — в комментариях указывайте, какие роли имеют доступ
4. **Разделяйте роли просмотра и редактирования** — используйте отдельные флаги `can_view`, `can_edit`, `can_add`, `can_delete`
5. **Используйте константы ролей** — создайте `core/roles.py` для централизованного управления правами

## CSS архитектура

### Структура

- **`base/`** — базовые стили (reset, переменные)
- **`components/`** — переиспользуемые компоненты (таблицы, кнопки, модальные окна)
- **`pages/`** — стили для конкретных страниц

### Правила именования

- **Общие компоненты:** `.data-table`, `.modal-window`, `.btn-primary`
- **Специфичные для страницы:** `.employees-table`, `.warehouse-special-button`
- **Используйте префикс** по названию страницы для уникальности

### Добавление стилей для новой страницы

1. Создайте файл `static/css/pages/new-page.css`
2. Добавьте импорт в `static/css/main.css`:
   ```css
   @import 'pages/new-page.css';
   ```

## Docker и развёртывание

### Запуск проекта

```bash
# Запустить контейнеры
docker-compose up -d

# Посмотреть логи
docker-compose logs -f app

# Остановить контейнеры
docker-compose down
```

### Структура Docker

- **`docker-compose.yaml`** — основная конфигурация (PostgreSQL + Flask)
- **`docker-compose.override.yaml`** — локальные переопределения (не коммитится)
- **`app/Dockerfile`** — образ Flask приложения
- **`db-init/init.sql`** — инициализация БД при первом запуске

### Важные моменты

1. **`db-init/init.sql`** выполняется только при первом создании БД
2. Данные БД сохраняются в Docker volume `pgdata`
3. PostgreSQL доступен на порту 5433 (чтобы избежать конфликтов с локальной БД)

### Обновление базы данных

Если нужно добавить новые таблицы:

1. Обновить `db-init/init.sql` с новыми таблицами
2. Для существующих БД создать миграцию вручную:
   ```sql
   CREATE TABLE IF NOT EXISTS new_table (...);
   ```

## Правила работы в команде

### Безопасная параллельная разработка

1. **Один разработчик = один модуль**
   - Работайте только в своем модуле (например, `routes/admin_equipment.py`)
   - Не изменяйте общие файлы без согласования

2. **Общие файлы (требуют согласования)**
   - `core/` — ядро приложения
   - `utils/` — утилиты
   - `static/css/components/` — общие компоненты CSS
   - `static/css/base/` — базовые стили

3. **Изолированные файлы (можно изменять свободно)**
   - `routes/admin_equipment.py` — только для разработчика оборудования
   - `routes/admin_employees.py` — только для разработчика сотрудников
   - `static/css/pages/equipment.css` — только для разработчика оборудования
   - `services/admin_equipment_service.py` — только для разработчика оборудования

### Workflow

```bash
# Создать ветку для нового функционала
git checkout -b feature/equipment-module

# Работать только с изолированными файлами своего модуля
# - routes/admin_equipment.py
# - services/admin_equipment_service.py
# - static/css/pages/equipment.css

# После завершения — создать Pull Request
```

### Чеклист перед мержем

- [ ] Код работает локально
- [ ] Нет конфликтов с другими модулями
- [ ] Обновлена документация (если нужно)
- [ ] Протестированы все функции модуля
- [ ] Не затронуты общие файлы (или согласованы изменения)

## Конфигурация

### Переменные окружения

Настройки задаются через переменные окружения в `docker-compose.yaml`:

- `DATABASE_HOST` — хост БД (по умолчанию: `db`)
- `DATABASE_PORT` — порт БД (по умолчанию: `5432`)
- `DATABASE_USER` — пользователь БД (по умолчанию: `user`)
- `DATABASE_PASSWORD` — пароль БД (по умолчанию: `1234`)
- `DATABASE_NAME` — имя БД (по умолчанию: `isitdb`)
- `SECRET_KEY` — секретный ключ Flask (по умолчанию: `your-secret-key-here`)

Для продакшена создайте `.env` файл или используйте секреты Docker.

## FAQ

**Q: Что делать, если нужно изменить общий файл?**
A: Создайте issue/задачу, обсудите с командой, создайте отдельную ветку для общих изменений.

**Q: Можно ли использовать код из другого модуля?**
A: Да, через импорты. Например, `from services.admin_employee_service import AdminEmployeeService` в модуле оборудования.

**Q: Как добавить новую страницу?**
A: Создайте новый Blueprint в `routes/`, новый сервис в `services/` (если нужна бизнес-логика), новый CSS файл в `static/css/pages/`, зарегистрируйте Blueprint в `app/factory.py`.

**Q: Нужно ли создавать сервис для каждого модуля?**
A: Не обязательно. Если логика простая (только SELECT запрос), можно работать с БД напрямую в Route. Но для сложной логики лучше вынести в сервис.

**Q: Как правильно обрабатывать ошибки?**
A: В Routes возвращайте JSON с `{'success': False, 'message': '...'}` для AJAX запросов или редирект для обычных запросов. В Services выбрасывайте исключения, которые обрабатываются в Routes.

## Полезные ссылки

- [Flask Blueprints](https://flask.palletsprojects.com/en/2.3.x/blueprints/)
- [Flask Templates](https://flask.palletsprojects.com/en/2.3.x/templating/)
- [PostgreSQL Python Driver](https://www.psycopg.org/docs/)

---

**Последнее обновление:** 2025

