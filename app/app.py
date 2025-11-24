from flask import Flask, render_template, request, redirect, url_for, session, send_from_directory, jsonify
import psycopg2
from config import Config
import os
import werkzeug.utils

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'  # Для сессий
app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(__file__), 'static', 'images', 'workers')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Создаем папку для аватарок, если её нет
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

def get_db_connection():
    conn = psycopg2.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        dbname=Config.DB_NAME
    )
    return conn

def get_role_translation(role):
    """Перевод ролей на русский"""
    translations = {
        'dept_head': 'Начальник отдела',
        'repair_head': 'Начальник ремонтной службы',
        'store_keeper': 'Заведующий складом',
        'geology_head': 'Начальник геологоразведочного отдела',
        'workshop_head': 'Начальник цеха',
        'repair_worker': 'Сотрудник ремонтной службы',
        'maintenance_admin': 'Администратор ТОиР',
        'procurement_analyst': 'Производственный аналитик',
        'operations_manager': 'Управляющий производством',
        'spare_buyer': 'Закупщик деталей на склад'
    }
    return translations.get(role, role)


def format_phone(phone):
    if not phone:
        return None
    digits = ''.join(filter(str.isdigit, phone))
    if len(digits) == 11 and digits.startswith('7'):
        return f"+7 ({digits[1:4]}) {digits[4:7]}-{digits[7:9]}-{digits[9:11]}"
    if len(digits) == 10:
        return f"+7 ({digits[0:3]}) {digits[3:6]}-{digits[6:8]}-{digits[8:10]}"
    return phone

@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        login_name = request.form.get("login")
        password = request.form.get("password")
        remember = request.form.get("remember")
        
        # Проверяем логин и пароль в БД
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "SELECT employee_id, login, password, last_name, first_name, patronymic, employee_post, user_role, avatar_path FROM employee WHERE login = %s",
            (login_name,)
        )
        user = cur.fetchone()
        cur.close()
        conn.close()
        
        if user and user[2] == password:  # user[2] - это password
            # Сохраняем данные пользователя в сессии
            session['user_id'] = user[0]
            session['login'] = user[1]
            session['last_name'] = user[3]
            session['first_name'] = user[4]
            session['patronymic'] = user[5]
            session['post'] = user[6]
            session['role'] = user[7]
            session['avatar_path'] = user[8]
            session['password'] = user[2]
            
            # Редирект на страницу администратора
            return redirect(url_for("admin_dashboard"))
        else:
            # Неверный логин или пароль
            return render_template("login.html", error="Неверный логин или пароль")
    
    # Проверяем, не авторизован ли уже пользователь
    if 'user_id' in session:
        return redirect(url_for("admin_dashboard"))
    
    return render_template("login.html")

@app.route("/admin")
def admin_dashboard():
    if 'user_id' not in session:
        return redirect(url_for("login"))
    
    section = request.args.get('section', 'employees')
    
    # Получаем данные о сотрудниках
    employees = []
    if section == 'employees':
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            SELECT e.employee_id, e.last_name, e.first_name, e.patronymic,
                   e.employee_post, e.phone_number, e.email, e.login, e.password, e.user_role,
                   d.department_name, f.facility_name
            FROM employee e
            LEFT JOIN department d ON e.department_id = d.department_id
            LEFT JOIN facility f ON d.facility_id = f.facility_id
            ORDER BY e.last_name, e.first_name
        """)
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        for row in rows:
            employees.append({
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
            })
    
    role_options = sorted({emp['role'] for emp in employees if emp.get('role')})
    department_options = sorted({emp['department'] for emp in employees if emp.get('department')})
    facility_options = sorted({emp['facility'] for emp in employees if emp.get('facility')})
    role_labels = {role: get_role_translation(role) for role in role_options}
    
    # Доступные отделы / предприятия для формы добавления сотрудника
    department_choices = []
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT d.department_id, d.department_name, f.facility_id, f.facility_name
        FROM department d
        LEFT JOIN facility f ON d.facility_id = f.facility_id
        ORDER BY f.facility_name NULLS LAST, d.department_name
    """)
    for row in cur.fetchall():
        department_choices.append({
            'id': row[0],
            'name': row[1],
            'facility_id': row[2],
            'facility_name': row[3]
        })
    cur.close()
    conn.close()

    facility_choices = []
    seen_facilities = set()
    for dept in department_choices:
        facility_id = dept.get('facility_id')
        facility_name = dept.get('facility_name')
        if facility_id and facility_id not in seen_facilities:
            seen_facilities.add(facility_id)
            facility_choices.append({
                'id': facility_id,
                'name': facility_name
            })
    facility_choices.sort(key=lambda item: (item['name'] or '').lower())
    
    return render_template("admin.html", 
                         section=section,
                         employees=employees,
                         user=session,
                         get_role_translation=get_role_translation,
                         format_phone=format_phone,
                         role_options=role_options,
                         department_options=department_options,
                         facility_options=facility_options,
                         role_labels=role_labels,
                         department_choices=department_choices,
                         facility_choices=facility_choices)

@app.route("/admin/employees", methods=["POST"])
def create_employee():
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
    
    data = request.get_json(silent=True) or {}
    required_fields = ['last_name', 'first_name', 'post', 'role', 'login', 'password', 'department_id']
    missing = [field for field in required_fields if not str(data.get(field, '')).strip()]
    if missing:
        return jsonify({'success': False, 'message': 'Заполните обязательные поля.'}), 400
    
    try:
        department_id = int(data.get('department_id'))
    except (TypeError, ValueError):
        return jsonify({'success': False, 'message': 'Некорректный отдел.'}), 400
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO employee (
                department_id, employee_post, last_name, first_name, patronymic,
                phone_number, email, user_role, login, password
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING employee_id
        """, (
            department_id,
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
        conn.commit()
    except Exception:
        conn.rollback()
        cur.close()
        conn.close()
        return jsonify({'success': False, 'message': 'Не удалось добавить сотрудника.'}), 500
    
    cur.execute("""
        SELECT e.employee_id, e.last_name, e.first_name, e.patronymic,
               e.employee_post, e.phone_number, e.email, e.login, e.password,
               e.user_role, d.department_name, f.facility_name
        FROM employee e
        LEFT JOIN department d ON e.department_id = d.department_id
        LEFT JOIN facility f ON d.facility_id = f.facility_id
        WHERE e.employee_id = %s
    """, (new_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    
    employee = {
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
    
    return jsonify({'success': True, 'employee': employee})

@app.route("/admin/employees/<int:employee_id>", methods=["PATCH"])
def update_employee_field(employee_id):
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Не авторизовано'}), 401
    
    payload = request.get_json(silent=True) or {}
    field = payload.get('field')
    value = payload.get('value', '')
    
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
        return jsonify({'success': False, 'message': 'Поле недоступно для редактирования.'}), 400
    
    column = editable_fields[field]
    db_value = value.strip() if isinstance(value, str) else value
    db_value = db_value if db_value != '' else None
    
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute(f"UPDATE employee SET {column} = %s WHERE employee_id = %s", (db_value, employee_id))
        if cur.rowcount == 0:
            conn.rollback()
            return jsonify({'success': False, 'message': 'Сотрудник не найден.'}), 404
        conn.commit()
    except Exception as exc:
        conn.rollback()
        return jsonify({'success': False, 'message': 'Не удалось сохранить изменения.'}), 500
    finally:
        cur.close()
        conn.close()
    
    display_value = db_value or ''
    if field == 'phone' and display_value:
        display_value = format_phone(display_value)
    
    return jsonify({'success': True, 'value': display_value})

@app.route("/admin/upload-avatar", methods=["POST"])
def upload_avatar():
    if 'user_id' not in session:
        return redirect(url_for("login"))
    
    if 'avatar' not in request.files:
        return redirect(url_for("admin_dashboard"))
    
    file = request.files['avatar']
    if file.filename == '':
        return redirect(url_for("admin_dashboard"))
    
    if file:
        # Генерируем безопасное имя файла
        filename = f"avatar_{session['user_id']}_{werkzeug.utils.secure_filename(file.filename)}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        # Сохраняем путь в БД (относительный путь для Flask)
        relative_path = f"images/workers/{filename}"
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "UPDATE employee SET avatar_path = %s WHERE employee_id = %s",
            (relative_path, session['user_id'])
        )
        conn.commit()
        cur.close()
        conn.close()
        
        # Обновляем сессию
        session['avatar_path'] = relative_path
    
    return redirect(url_for("admin_dashboard"))

@app.route("/admin/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/static/<path:filename>")
def static_files(filename):
    return send_from_directory('static', filename)

@app.route("/home")
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT facility_name FROM facility LIMIT 5;")
    facilities = [row[0] for row in cur.fetchall()]
    cur.close()
    conn.close()
    return render_template("index.html", facilities=facilities)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
