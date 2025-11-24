--
-- PostgreSQL database dump
--

\restrict YwZNHEHBJfhvdXMmHibzyYi0NV0qmkJRMhabedsv3wWli9avLTo6tTOnUKhH9s2

-- Dumped from database version 16.11 (Debian 16.11-1.pgdg13+1)
-- Dumped by pg_dump version 16.11 (Debian 16.11-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: department; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.department (
    department_id integer NOT NULL,
    facility_id integer,
    department_name character varying(255)
);


ALTER TABLE public.department OWNER TO "user";

--
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.department_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_department_id_seq OWNER TO "user";

--
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.department_department_id_seq OWNED BY public.department.department_id;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    department_id integer,
    employee_post character varying(255),
    last_name character varying(255),
    first_name character varying(255),
    patronymic character varying(255),
    phone_number character varying(20),
    email character varying(255),
    user_role character varying(255),
    login character varying(255),
    password character varying(255),
    avatar_path character varying(255)
);


ALTER TABLE public.employee OWNER TO "user";

--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_employee_id_seq OWNER TO "user";

--
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.employee_employee_id_seq OWNED BY public.employee.employee_id;


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.equipment (
    equipment_id integer NOT NULL,
    department_id integer,
    acquisition_date date,
    guarantee_date date,
    equipment_type character varying(255),
    equipment_name character varying(255),
    location character varying(255),
    equipment_status character varying(50),
    characteristics text,
    image_path character varying(255)
);


ALTER TABLE public.equipment OWNER TO "user";

--
-- Name: equipment_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.equipment_equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_equipment_id_seq OWNER TO "user";

--
-- Name: equipment_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.equipment_equipment_id_seq OWNED BY public.equipment.equipment_id;


--
-- Name: equipment_movement; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.equipment_movement (
    equipment_movement_id integer NOT NULL,
    equipment_id integer,
    from_department_id integer,
    to_department_id integer,
    move_date date
);


ALTER TABLE public.equipment_movement OWNER TO "user";

--
-- Name: equipment_movement_equipment_movement_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.equipment_movement_equipment_movement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_movement_equipment_movement_id_seq OWNER TO "user";

--
-- Name: equipment_movement_equipment_movement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.equipment_movement_equipment_movement_id_seq OWNED BY public.equipment_movement.equipment_movement_id;


--
-- Name: facility; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.facility (
    facility_id integer NOT NULL,
    facility_name character varying(255) NOT NULL,
    facility_type character varying(100) NOT NULL,
    region character varying(100),
    facility_address character varying(255)
);


ALTER TABLE public.facility OWNER TO "user";

--
-- Name: facility_facility_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.facility_facility_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facility_facility_id_seq OWNER TO "user";

--
-- Name: facility_facility_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.facility_facility_id_seq OWNED BY public.facility.facility_id;


--
-- Name: maintenance_employee; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.maintenance_employee (
    employee_id integer,
    maintenance_plan_id integer
);


ALTER TABLE public.maintenance_employee OWNER TO "user";

--
-- Name: maintenance_plan; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.maintenance_plan (
    maintenance_plan_id integer NOT NULL,
    equipment_id integer,
    maintenance_frequency character varying(100),
    maintenance_start_date date,
    maintenance_status character varying(255),
    maintenance_description text
);


ALTER TABLE public.maintenance_plan OWNER TO "user";

--
-- Name: maintenance_plan_maintenance_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.maintenance_plan_maintenance_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maintenance_plan_maintenance_plan_id_seq OWNER TO "user";

--
-- Name: maintenance_plan_maintenance_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.maintenance_plan_maintenance_plan_id_seq OWNED BY public.maintenance_plan.maintenance_plan_id;


--
-- Name: maintenance_spare_part; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.maintenance_spare_part (
    spare_part_id integer,
    maintenance_plan_id integer
);


ALTER TABLE public.maintenance_spare_part OWNER TO "user";

--
-- Name: repair_request; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.repair_request (
    repair_request integer NOT NULL,
    equipment_id integer,
    employee_id integer,
    heading character varying(255),
    request_description text,
    request_sent_date date,
    request_status character varying(50)
);


ALTER TABLE public.repair_request OWNER TO "user";

--
-- Name: repair_request_repair_request_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.repair_request_repair_request_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repair_request_repair_request_seq OWNER TO "user";

--
-- Name: repair_request_repair_request_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.repair_request_repair_request_seq OWNED BY public.repair_request.repair_request;


--
-- Name: repair_spare_part; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.repair_spare_part (
    spare_part_id integer,
    repair_task_id integer
);


ALTER TABLE public.repair_spare_part OWNER TO "user";

--
-- Name: repair_task; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.repair_task (
    repair_task_id integer NOT NULL,
    equipment_id integer,
    repair_task_status character varying(50),
    repair_task_creation_date date,
    repair_task_start_date timestamp without time zone,
    repair_task_end_date timestamp without time zone,
    repair_task_description text
);


ALTER TABLE public.repair_task OWNER TO "user";

--
-- Name: repair_task_employee; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.repair_task_employee (
    employee_id integer,
    repair_task_id integer
);


ALTER TABLE public.repair_task_employee OWNER TO "user";

--
-- Name: repair_task_repair_task_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.repair_task_repair_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repair_task_repair_task_id_seq OWNER TO "user";

--
-- Name: repair_task_repair_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.repair_task_repair_task_id_seq OWNED BY public.repair_task.repair_task_id;


--
-- Name: spare_part; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.spare_part (
    spare_part_id integer NOT NULL,
    facility_id integer,
    equipment_id integer,
    spare_part_type character varying(255),
    spare_part_name character varying(255),
    spare_part_location integer,
    spare_part_status character varying(255)
);


ALTER TABLE public.spare_part OWNER TO "user";

--
-- Name: spare_part_spare_part_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.spare_part_spare_part_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spare_part_spare_part_seq OWNER TO "user";

--
-- Name: spare_part_spare_part_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.spare_part_spare_part_seq OWNED BY public.spare_part.spare_part_id;


--
-- Name: user_token; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.user_token (
    token_id integer NOT NULL,
    employee_id integer,
    token character varying(255),
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_used_at timestamp without time zone
);


ALTER TABLE public.user_token OWNER TO "user";

--
-- Name: user_token_token_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.user_token_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_token_token_id_seq OWNER TO "user";

--
-- Name: user_token_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.user_token_token_id_seq OWNED BY public.user_token.token_id;


--
-- Name: warehouse; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.warehouse (
    warehouse_id integer NOT NULL,
    department_id integer,
    warehouse_type character varying(255),
    warehouse_address character varying(255)
);


ALTER TABLE public.warehouse OWNER TO "user";

--
-- Name: warehouse_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.warehouse_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouse_warehouse_id_seq OWNER TO "user";

--
-- Name: warehouse_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.warehouse_warehouse_id_seq OWNED BY public.warehouse.warehouse_id;


--
-- Name: department department_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.department ALTER COLUMN department_id SET DEFAULT nextval('public.department_department_id_seq'::regclass);


--
-- Name: employee employee_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.employee ALTER COLUMN employee_id SET DEFAULT nextval('public.employee_employee_id_seq'::regclass);


--
-- Name: equipment equipment_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment ALTER COLUMN equipment_id SET DEFAULT nextval('public.equipment_equipment_id_seq'::regclass);


--
-- Name: equipment_movement equipment_movement_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement ALTER COLUMN equipment_movement_id SET DEFAULT nextval('public.equipment_movement_equipment_movement_id_seq'::regclass);


--
-- Name: facility facility_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.facility ALTER COLUMN facility_id SET DEFAULT nextval('public.facility_facility_id_seq'::regclass);


--
-- Name: maintenance_plan maintenance_plan_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_plan ALTER COLUMN maintenance_plan_id SET DEFAULT nextval('public.maintenance_plan_maintenance_plan_id_seq'::regclass);


--
-- Name: repair_request repair_request; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_request ALTER COLUMN repair_request SET DEFAULT nextval('public.repair_request_repair_request_seq'::regclass);


--
-- Name: repair_task repair_task_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task ALTER COLUMN repair_task_id SET DEFAULT nextval('public.repair_task_repair_task_id_seq'::regclass);


--
-- Name: spare_part spare_part_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part ALTER COLUMN spare_part_id SET DEFAULT nextval('public.spare_part_spare_part_seq'::regclass);


--
-- Name: user_token token_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_token ALTER COLUMN token_id SET DEFAULT nextval('public.user_token_token_id_seq'::regclass);


--
-- Name: warehouse warehouse_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.warehouse ALTER COLUMN warehouse_id SET DEFAULT nextval('public.warehouse_warehouse_id_seq'::regclass);


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.department VALUES (61, 1, 'Отдел добычи и разработки');
INSERT INTO public.department VALUES (62, 1, 'Геологоразведочный отдел');
INSERT INTO public.department VALUES (63, 1, 'Технический отдел');
INSERT INTO public.department VALUES (64, 1, 'Вентиляционно-экологический отдел');
INSERT INTO public.department VALUES (65, 1, 'Склад №1');
INSERT INTO public.department VALUES (66, 1, 'Склад №2');
INSERT INTO public.department VALUES (67, 1, 'Ремонтная служба');
INSERT INTO public.department VALUES (68, 2, 'Отдел добычи и разработки');
INSERT INTO public.department VALUES (69, 2, 'Геологоразведочный отдел');
INSERT INTO public.department VALUES (70, 2, 'Технический отдел');
INSERT INTO public.department VALUES (71, 2, 'Вентиляционно-экологический отдел');
INSERT INTO public.department VALUES (72, 2, 'Склад №1');
INSERT INTO public.department VALUES (73, 2, 'Склад №2');
INSERT INTO public.department VALUES (74, 2, 'Ремонтная служба');
INSERT INTO public.department VALUES (75, 3, 'Цех №1');
INSERT INTO public.department VALUES (76, 3, 'Цех №2');
INSERT INTO public.department VALUES (77, 3, 'Цех №3');
INSERT INTO public.department VALUES (78, 3, 'Склад №1');
INSERT INTO public.department VALUES (79, 3, 'Склад №2');
INSERT INTO public.department VALUES (80, 3, 'Ремонтная служба');
INSERT INTO public.department VALUES (81, 4, 'Цех №1');
INSERT INTO public.department VALUES (82, 4, 'Цех №2');
INSERT INTO public.department VALUES (83, 4, 'Цех №3');
INSERT INTO public.department VALUES (84, 4, 'Склад №1');
INSERT INTO public.department VALUES (85, 4, 'Склад №2');
INSERT INTO public.department VALUES (86, 4, 'Ремонтная служба');
INSERT INTO public.department VALUES (87, 6, 'Административный отдел');
INSERT INTO public.department VALUES (88, 6, 'Аналитический отдел');
INSERT INTO public.department VALUES (89, 6, 'Отдел управления предприятиями');
INSERT INTO public.department VALUES (90, 6, 'Отдел складский закупок');


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.employee VALUES (1, 61, 'Начальник отдела добычи и разработки', 'Иванов', 'Иван', 'Иванович', '+79990000001', 'ivanov@example.com', 'dept_head', 'iivan', 'pass1', NULL);
INSERT INTO public.employee VALUES (2, 67, 'Начальник ремонтной службы', 'Петров', 'Пётр', 'Петрович', '+79990000002', 'petrov@example.com', 'repair_head', 'ppet', 'pass2', NULL);
INSERT INTO public.employee VALUES (3, 65, 'Заведующий складом', 'Сидоров', 'Сидор', 'Сидорович', '+79990000003', 'sidorov@example.com', 'store_keeper', 'ssid', 'pass3', NULL);
INSERT INTO public.employee VALUES (4, 69, 'Начальник геологоразведочного отдела', 'Кузнецов', 'Кузьма', 'Кузьмич', '+79990000004', 'kuznetsov@example.com', 'geology_head', 'kkuz', 'pass4', NULL);
INSERT INTO public.employee VALUES (5, 73, 'Заведующий складом', 'Морозов', 'Михаил', 'Михайлович', '+79990000005', 'morozov@example.com', 'store_keeper', 'mmor', 'pass5', NULL);
INSERT INTO public.employee VALUES (6, 74, 'Начальник ремонтной службы', 'Васильев', 'Василий', 'Васильевич', '+79990000006', 'vasiliev@example.com', 'repair_head', 'vvas', 'pass6', NULL);
INSERT INTO public.employee VALUES (7, 75, 'Начальник Цеха', 'Фёдоров', 'Фёдор', 'Фёдорович', '+79990000007', 'fedorov@example.com', 'workshop_head', 'ffed', 'pass7', NULL);
INSERT INTO public.employee VALUES (8, 78, 'Заведующий складом', 'Михайлов', 'Михаил', 'Михайлович', '+79990000008', 'mikhailov@example.com', 'store_keeper', 'mmih', 'pass8', NULL);
INSERT INTO public.employee VALUES (9, 74, 'Сотрудник ремонтной службы', 'Семенов', 'Семен', 'Семенович', '+79990000009', 'semenov@example.com', 'repair_worker', 'ssem', 'pass9', NULL);
INSERT INTO public.employee VALUES (10, 74, 'Сотрудник ремонтной службы', 'Алексеев', 'Алексей', 'Алексеевич', '+79990000010', 'alekseev@example.com', 'repair_worker', 'aalek', 'pass10', NULL);
INSERT INTO public.employee VALUES (11, 67, 'Сотрудник ремонтной службы', 'Николаев', 'Николай', 'Николаевич', '+79990000011', 'nikolaev@example.com', 'repair_worker', 'nnik', 'pass11', NULL);
INSERT INTO public.employee VALUES (12, 67, 'Сотрудник ремонтной службы', 'Громов', 'Григорий', 'Григорьевич', '+79990000012', 'gromov@example.com', 'repair_worker', 'ggro', 'pass12', NULL);
INSERT INTO public.employee VALUES (13, 67, 'Сотрудник ремонтной службы', 'Коновалов', 'Константин', 'Константинович', '+79990000013', 'konovalov@example.com', 'repair_worker', 'kko', 'pass13', NULL);
INSERT INTO public.employee VALUES (14, 86, 'Начальник ремонтной службы', 'Жуков', 'Артур', 'Семёнович', '+79991230018', 'a.zhukov@example.com', 'repair_head', 'azhuk', 'pass14', NULL);
INSERT INTO public.employee VALUES (15, 86, 'Сотрудник ремонтной службы', 'Орлов', 'Евгений', 'Петрович', '+79991230017', 'e.orlov@example.com', 'repair_worker', 'eorl', 'pass15', NULL);
INSERT INTO public.employee VALUES (16, 86, 'Сотрудник ремонтной службы', 'Павлов', 'Павел', 'Павлович', '+79991230016', 'p.pavlov@example.com', 'repair_worker', 'ppav', 'pass16', NULL);
INSERT INTO public.employee VALUES (17, 86, 'Сотрудник ремонтной службы', 'Егоров', 'Егор', 'Егорович', '+79991230015', 'e.egorov@example.com', 'repair_worker', 'eego', 'pass17', NULL);
INSERT INTO public.employee VALUES (18, 86, 'Сотрудник ремонтной службы', 'Воробьёв', 'Владимир', 'Владимирович', '+79991230014', 'v.vorobyev@example.com', 'repair_worker', 'vvor', 'pass18', NULL);
INSERT INTO public.employee VALUES (19, 87, 'Администратор ТОиР', 'Комаров', 'Станислав', 'Романович', '+79991230019', 's.komarov@example.com', 'maintenance_admin', 'skom', 'pass19', NULL);
INSERT INTO public.employee VALUES (20, 88, 'Производственный аналитик', 'Гордеев', 'Тимур', 'Алексеевич', '+79991230020', 't.gordeev@example.com', 'procurement_analyst', 'tgor', 'pass20', NULL);
INSERT INTO public.employee VALUES (21, 89, 'Управляющий производством', 'Чернов', 'Даниил', 'Игоревич', '+79991230021', 'operations_manager@example.com', 'operations_manager', 'dche', 'pass21', NULL);
INSERT INTO public.employee VALUES (22, 90, 'Закупщик деталей на склад', 'Третьяков', 'Леонид', 'Павлович', '+79991230022', 'spare_buyer@example.com', 'spare_buyer', 'ltre', 'pass22', NULL);


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: equipment_movement; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: facility; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.facility VALUES (1, 'Северная шахта №1', 'Добывающее', 'Северный', 'Республика Коми, г. Воркута, ул. Шахтёров, 1');
INSERT INTO public.facility VALUES (2, 'Северная шахта №2', 'Добывающее', 'Северный', 'Мурманская область, г. Мончегорск, ул. Полярная, 10');
INSERT INTO public.facility VALUES (3, 'Северная шахта №3', 'Добывающее', 'Северный', 'Ненецкий АО, г. Нарьян-Мар, ул. Арктическая, 5');
INSERT INTO public.facility VALUES (4, 'Завод переработки №1', 'Перерабатывающее', 'Средняя полоса', 'Тверская область, г. Тверь, ул. Промышленная, 12');
INSERT INTO public.facility VALUES (5, 'Завод переработки №2', 'Перерабатывающее', 'Средняя полоса', 'Ярославская область, г. Ярославль, ул. Заводская, 7');
INSERT INTO public.facility VALUES (6, 'Центральный офис', 'Офис', 'Санкт-Петербург', 'г. Санкт-Петербург, Невский проспект, 100');


--
-- Data for Name: maintenance_employee; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: maintenance_plan; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: maintenance_spare_part; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: repair_request; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: repair_spare_part; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: repair_task; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: repair_task_employee; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: spare_part; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: user_token; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: warehouse; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.warehouse VALUES (7, 65, 'Склад техники', 'Республика Коми, г. Воркута, ул. Шахтёров, строение 3');
INSERT INTO public.warehouse VALUES (8, 66, 'Склад общего назначения', 'Республика Коми, г. Воркута, ул. Шахтёров, строение 5');
INSERT INTO public.warehouse VALUES (9, 72, 'Склад техники', 'Мурманская область, г. Мончегорск, ул. Полярная, строение 12');
INSERT INTO public.warehouse VALUES (10, 73, 'Склад общего назначения', 'Мурманская область, г. Мончегорск, ул. Полярная, строение 14');
INSERT INTO public.warehouse VALUES (11, 78, 'Склад техники', 'Ненецкий АО, г. Нарьян-Мар, ул. Арктическая, строение 7');
INSERT INTO public.warehouse VALUES (12, 79, 'Склад общего назначения', 'Ненецкий АО, г. Нарьян-Мар, ул. Арктическая, строение 9');
INSERT INTO public.warehouse VALUES (13, 84, 'Склад техники', 'Тверская область, г. Тверь, ул. Промышленная, строение 16');
INSERT INTO public.warehouse VALUES (14, 85, 'Склад общего назначения', 'Тверская область, г. Тверь, ул. Промышленная, строение 18');


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.department_department_id_seq', 90, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.employee_employee_id_seq', 22, true);


--
-- Name: equipment_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.equipment_equipment_id_seq', 1, false);


--
-- Name: equipment_movement_equipment_movement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.equipment_movement_equipment_movement_id_seq', 1, false);


--
-- Name: facility_facility_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.facility_facility_id_seq', 6, true);


--
-- Name: maintenance_plan_maintenance_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.maintenance_plan_maintenance_plan_id_seq', 1, false);


--
-- Name: repair_request_repair_request_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.repair_request_repair_request_seq', 1, false);


--
-- Name: repair_task_repair_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.repair_task_repair_task_id_seq', 1, false);


--
-- Name: spare_part_spare_part_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.spare_part_spare_part_seq', 1, false);


--
-- Name: user_token_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.user_token_token_id_seq', 1, false);


--
-- Name: warehouse_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.warehouse_warehouse_id_seq', 14, true);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: equipment_movement equipment_movement_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement
    ADD CONSTRAINT equipment_movement_pkey PRIMARY KEY (equipment_movement_id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (equipment_id);


--
-- Name: facility facility_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.facility
    ADD CONSTRAINT facility_pkey PRIMARY KEY (facility_id);


--
-- Name: maintenance_plan maintenance_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_plan
    ADD CONSTRAINT maintenance_plan_pkey PRIMARY KEY (maintenance_plan_id);


--
-- Name: repair_request repair_request_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_request
    ADD CONSTRAINT repair_request_pkey PRIMARY KEY (repair_request);


--
-- Name: repair_task repair_task_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task
    ADD CONSTRAINT repair_task_pkey PRIMARY KEY (repair_task_id);


--
-- Name: spare_part spare_part_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part
    ADD CONSTRAINT spare_part_pkey PRIMARY KEY (spare_part_id);


--
-- Name: user_token user_token_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT user_token_pkey PRIMARY KEY (token_id);


--
-- Name: warehouse warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (warehouse_id);


--
-- Name: department department_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facility(facility_id);


--
-- Name: employee employee_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: equipment equipment_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: equipment_movement equipment_movement_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement
    ADD CONSTRAINT equipment_movement_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: equipment_movement equipment_movement_from_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement
    ADD CONSTRAINT equipment_movement_from_department_id_fkey FOREIGN KEY (from_department_id) REFERENCES public.department(department_id);


--
-- Name: equipment_movement equipment_movement_to_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement
    ADD CONSTRAINT equipment_movement_to_department_id_fkey FOREIGN KEY (to_department_id) REFERENCES public.department(department_id);


--
-- Name: maintenance_employee maintenance_employee_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_employee
    ADD CONSTRAINT maintenance_employee_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: maintenance_employee maintenance_employee_maintenance_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_employee
    ADD CONSTRAINT maintenance_employee_maintenance_plan_id_fkey FOREIGN KEY (maintenance_plan_id) REFERENCES public.maintenance_plan(maintenance_plan_id);


--
-- Name: maintenance_plan maintenance_plan_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_plan
    ADD CONSTRAINT maintenance_plan_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: maintenance_spare_part maintenance_spare_part_maintenance_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_spare_part
    ADD CONSTRAINT maintenance_spare_part_maintenance_plan_id_fkey FOREIGN KEY (maintenance_plan_id) REFERENCES public.maintenance_plan(maintenance_plan_id);


--
-- Name: maintenance_spare_part maintenance_spare_part_spare_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenance_spare_part
    ADD CONSTRAINT maintenance_spare_part_spare_part_id_fkey FOREIGN KEY (spare_part_id) REFERENCES public.spare_part(spare_part_id);


--
-- Name: repair_request repair_request_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_request
    ADD CONSTRAINT repair_request_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: repair_request repair_request_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_request
    ADD CONSTRAINT repair_request_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: repair_spare_part repair_spare_part_repair_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_spare_part
    ADD CONSTRAINT repair_spare_part_repair_task_id_fkey FOREIGN KEY (repair_task_id) REFERENCES public.repair_task(repair_task_id);


--
-- Name: repair_spare_part repair_spare_part_spare_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_spare_part
    ADD CONSTRAINT repair_spare_part_spare_part_id_fkey FOREIGN KEY (spare_part_id) REFERENCES public.spare_part(spare_part_id);


--
-- Name: repair_task_employee repair_task_employee_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task_employee
    ADD CONSTRAINT repair_task_employee_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: repair_task_employee repair_task_employee_repair_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task_employee
    ADD CONSTRAINT repair_task_employee_repair_task_id_fkey FOREIGN KEY (repair_task_id) REFERENCES public.repair_task(repair_task_id);


--
-- Name: repair_task repair_task_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task
    ADD CONSTRAINT repair_task_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: spare_part spare_part_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part
    ADD CONSTRAINT spare_part_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: spare_part spare_part_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part
    ADD CONSTRAINT spare_part_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facility(facility_id);


--
-- Name: user_token user_token_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.user_token
    ADD CONSTRAINT user_token_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: warehouse warehouse_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- PostgreSQL database dump complete
--

\unrestrict YwZNHEHBJfhvdXMmHibzyYi0NV0qmkJRMhabedsv3wWli9avLTo6tTOnUKhH9s2

