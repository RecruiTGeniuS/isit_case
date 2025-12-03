--
-- PostgreSQL database dump
--

\restrict g01h9zX1WfBqlPQSz4OfCHq2Qe7oobzU8mZRm6Q0waSU8L6MCGubhl8CnIyKEqr

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
    maintenance_frequency integer,
    guarantee_date date,
    equipment_type character varying(255),
    equipment_name character varying(255),
    characteristics text,
    image_path character varying(255)
);


ALTER TABLE public.equipment OWNER TO "user";

--
-- Name: equipment_assignment; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.equipment_assignment (
    equipment_assignment_id integer NOT NULL,
    equipment_id integer,
    department_id integer,
    acquisition_date date,
    location character varying(255),
    equipment_status character varying(50)
);


ALTER TABLE public.equipment_assignment OWNER TO "user";

--
-- Name: equipment_assignment_equipment_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.equipment_assignment_equipment_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipment_assignment_equipment_assignment_id_seq OWNER TO "user";

--
-- Name: equipment_assignment_equipment_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.equipment_assignment_equipment_assignment_id_seq OWNED BY public.equipment_assignment.equipment_assignment_id;


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
    equipment_assignment_id integer,
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
-- Name: maintenace_employee; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.maintenace_employee (
    employee_id integer,
    maintenante_plan_id integer
);


ALTER TABLE public.maintenace_employee OWNER TO "user";

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
-- Name: part_stock_quantity; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.part_stock_quantity (
    part_stock_quantity_id integer NOT NULL,
    warehouse_id integer,
    spare_part_id integer,
    quantity integer
);


ALTER TABLE public.part_stock_quantity OWNER TO "user";

--
-- Name: part_stock_quantity_part_stock_quantity_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.part_stock_quantity_part_stock_quantity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.part_stock_quantity_part_stock_quantity_id_seq OWNER TO "user";

--
-- Name: part_stock_quantity_part_stock_quantity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.part_stock_quantity_part_stock_quantity_id_seq OWNED BY public.part_stock_quantity.part_stock_quantity_id;


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
    equipment_assignment_id integer,
    epmloyee integer,
    heading character varying(255),
    repair_task_description text,
    repair_task_creation_date date,
    repair_task_status character varying(50),
    repair_task_start_date date,
    repair_task_end_date date,
    repair_task_resolution text
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
    equipment_id integer,
    spare_part_type character varying(255),
    spare_part_name character varying(255)
);


ALTER TABLE public.spare_part OWNER TO "user";

--
-- Name: spare_part_spare_part_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.spare_part_spare_part_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spare_part_spare_part_id_seq OWNER TO "user";

--
-- Name: spare_part_spare_part_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.spare_part_spare_part_id_seq OWNED BY public.spare_part.spare_part_id;


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
-- Name: equipment_assignment equipment_assignment_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_assignment ALTER COLUMN equipment_assignment_id SET DEFAULT nextval('public.equipment_assignment_equipment_assignment_id_seq'::regclass);


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
-- Name: part_stock_quantity part_stock_quantity_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.part_stock_quantity ALTER COLUMN part_stock_quantity_id SET DEFAULT nextval('public.part_stock_quantity_part_stock_quantity_id_seq'::regclass);


--
-- Name: repair_task repair_task_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task ALTER COLUMN repair_task_id SET DEFAULT nextval('public.repair_task_repair_task_id_seq'::regclass);


--
-- Name: spare_part spare_part_id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part ALTER COLUMN spare_part_id SET DEFAULT nextval('public.spare_part_spare_part_id_seq'::regclass);


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

INSERT INTO public.department VALUES (7, 1, 'Горный участок');
INSERT INTO public.department VALUES (8, 1, 'Буровзрывной участок');
INSERT INTO public.department VALUES (9, 1, 'Обогатительная фабрика');
INSERT INTO public.department VALUES (10, 1, 'Транспортный участок');
INSERT INTO public.department VALUES (11, 1, 'Служба энергетики');
INSERT INTO public.department VALUES (12, 1, 'Ремонтная служба');
INSERT INTO public.department VALUES (13, 1, 'Склад №1');
INSERT INTO public.department VALUES (14, 1, 'Склад №2');
INSERT INTO public.department VALUES (15, 1, 'Склад №3');
INSERT INTO public.department VALUES (16, 1, 'Склад №4');
INSERT INTO public.department VALUES (17, 1, 'Склад №5');
INSERT INTO public.department VALUES (18, 2, 'Участок добычи');
INSERT INTO public.department VALUES (19, 2, 'Проходческий участок');
INSERT INTO public.department VALUES (20, 2, 'Отдел вентиляции и пылегазового контроля');
INSERT INTO public.department VALUES (21, 2, 'Транспортный участок');
INSERT INTO public.department VALUES (22, 2, 'Ремонтная служба');
INSERT INTO public.department VALUES (23, 2, 'Склад №1');
INSERT INTO public.department VALUES (24, 2, 'Склад №2');
INSERT INTO public.department VALUES (25, 2, 'Склад №3');
INSERT INTO public.department VALUES (26, 3, 'Горный участок');
INSERT INTO public.department VALUES (27, 3, 'Буровзрывной участок');
INSERT INTO public.department VALUES (28, 3, 'Обогатительная фабрика');
INSERT INTO public.department VALUES (29, 3, 'Транспортный участок');
INSERT INTO public.department VALUES (30, 3, 'Служба энергетики');
INSERT INTO public.department VALUES (31, 3, 'Ремонтная служба');
INSERT INTO public.department VALUES (32, 3, 'Склад №1');
INSERT INTO public.department VALUES (33, 3, 'Склад №2');
INSERT INTO public.department VALUES (34, 3, 'Склад №3');
INSERT INTO public.department VALUES (35, 4, 'Плавильный цех');
INSERT INTO public.department VALUES (36, 4, 'Прокатный цех');
INSERT INTO public.department VALUES (37, 4, 'Лаборатория контроля качества');
INSERT INTO public.department VALUES (38, 4, 'Технологический отдел');
INSERT INTO public.department VALUES (39, 4, 'Ремонтная служба');
INSERT INTO public.department VALUES (40, 4, 'Склад №1');
INSERT INTO public.department VALUES (41, 4, 'Склад №2');
INSERT INTO public.department VALUES (42, 4, 'Склад №3');
INSERT INTO public.department VALUES (43, 5, 'Обогатительный цех');
INSERT INTO public.department VALUES (44, 5, 'Цех фильтрации и сушки');
INSERT INTO public.department VALUES (45, 5, 'Лаборатория технического контроля');
INSERT INTO public.department VALUES (46, 5, 'Технологический отдел');
INSERT INTO public.department VALUES (47, 5, 'Ремонтная служба');
INSERT INTO public.department VALUES (48, 5, 'Склад №1');
INSERT INTO public.department VALUES (49, 5, 'Склад №2');
INSERT INTO public.department VALUES (50, 5, 'Склад №3');
INSERT INTO public.department VALUES (51, 6, 'Администраиция ТОиР');
INSERT INTO public.department VALUES (52, 6, 'Аналитический отдел');
INSERT INTO public.department VALUES (53, 6, 'Департамент закупок');
INSERT INTO public.department VALUES (54, 6, 'Финансовый департамент');


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.employee VALUES (55, 51, 'Администратор ТОиР', 'Смирнов', 'Иван', 'Викторович', '+7 (911) 101-01-01', 'smirnov@nmz.ru', 'maintenance_admin', 'smirnov', 'pass001', NULL);
INSERT INTO public.employee VALUES (56, 8, 'Начальник горного участка', 'Петров', 'Алексей', 'Сергеевич', '+7 (911) 101-01-02', 'apetrov@nmz.ru', 'dept_head', 'apetrov', 'pass002', NULL);
INSERT INTO public.employee VALUES (57, 9, 'Начальник обогатительной фабрики', 'Васильев', 'Дмитрий', 'Андреевич', '+7 (911) 101-01-03', 'dvasiliev@nmz.ru', 'dept_head', 'dvasiliev', 'pass003', NULL);
INSERT INTO public.employee VALUES (58, 10, 'Начальник транспортного участка', 'Кузнецов', 'Михаил', 'Иванович', '+7 (911) 101-01-04', 'mkuznetsov@nmz.ru', 'dept_head', 'mkuznetsov', 'pass004', NULL);
INSERT INTO public.employee VALUES (59, 11, 'Начальник службы энергетики', 'Морозов', 'Николай', 'Петрович', '+7 (911) 101-01-05', 'nmorozov@nmz.ru', 'dept_head', 'nmorozov', 'pass005', NULL);
INSERT INTO public.employee VALUES (60, 12, 'Начальник ремонтной службы', 'Соколов', 'Андрей', 'Дмитриевич', '+7 (911) 101-01-06', 'asokolov@nmz.ru', 'repair_head', 'asokolov', 'pass006', NULL);
INSERT INTO public.employee VALUES (61, 12, 'Сотрудник ремонтной службы', 'Иванова', 'Марина', 'Сергеевна', '+7 (911) 101-01-07', 'mivanova@nmz.ru', 'repair_worker', 'mivanova', 'pass007', NULL);
INSERT INTO public.employee VALUES (62, 12, 'Сотрудник ремонтной службы', 'Федоров', 'Сергей', 'Николаевич', '+7 (911) 101-01-08', 'sfedorov@nmz.ru', 'repair_worker', 'sfedorov', 'pass008', NULL);
INSERT INTO public.employee VALUES (63, 12, 'Сотрудник ремонтной службы', 'Егоров', 'Владимир', 'Павлович', '+7 (911) 101-01-09', 'vegorov@nmz.ru', 'repair_worker', 'vegorov', 'pass009', NULL);
INSERT INTO public.employee VALUES (64, 12, 'Сотрудник ремонтной службы', 'Никитин', 'Евгений', 'Александрович', '+7 (911) 101-01-10', 'enikitin@nmz.ru', 'repair_worker', 'enikitin', 'pass010', NULL);
INSERT INTO public.employee VALUES (65, 12, 'Сотрудник ремонтной службы', 'Павлова', 'Ольга', 'Викторовна', '+7 (911) 101-01-11', 'opavlova@nmz.ru', 'repair_worker', 'opavlova', 'pass011', NULL);
INSERT INTO public.employee VALUES (66, 12, 'Сотрудник ремонтной службы', 'Семёнов', 'Александр', 'Юрьевич', '+7 (911) 101-01-12', 'asem@nmz.ru', 'repair_worker', 'asem', 'pass012', NULL);
INSERT INTO public.employee VALUES (67, 12, 'Сотрудник ремонтной службы', 'Григорьев', 'Илья', 'Валерьевич', '+7 (911) 101-01-13', 'igrigorev@nmz.ru', 'repair_worker', 'igrigorev', 'pass013', NULL);
INSERT INTO public.employee VALUES (68, 13, 'Заведующий складом', 'Крылов', 'Константин', 'Олегович', '+7 (911) 101-01-14', 'kkrylov@nmz.ru', 'store_keeper', 'kkrylov', 'pass014', NULL);
INSERT INTO public.employee VALUES (69, 14, 'Заведующий складом', 'Лебедев', 'Алексей', 'Сергеевич', '+7 (911) 101-01-15', 'alebedev@nmz.ru', 'store_keeper', 'alebedev', 'pass015', NULL);
INSERT INTO public.employee VALUES (70, 15, 'Заведующий складом', 'Фролова', 'Наталья', 'Викторовна', '+7 (911) 101-01-16', 'nfrolova@nmz.ru', 'store_keeper', 'nfrolova', 'pass016', NULL);
INSERT INTO public.employee VALUES (71, 16, 'Заведующий складом', 'Орлов', 'Дмитрий', 'Сергеевич', '+7 (911) 101-01-17', 'dorlov@nmz.ru', 'store_keeper', 'dorlov', 'pass017', NULL);
INSERT INTO public.employee VALUES (72, 17, 'Заведующий складом', 'Беляев', 'Игорь', 'Павлович', '+7 (911) 101-01-18', 'ibelyaev@nmz.ru', 'store_keeper', 'ibelyaev', 'pass018', NULL);
INSERT INTO public.employee VALUES (73, 18, 'Начальник добывающего участка', 'Козлов', 'Владимир', 'Александрович', '+7 (911) 101-01-19', 'vkozlov@nmz.ru', 'dept_head', 'vkozlov', 'pass019', NULL);
INSERT INTO public.employee VALUES (74, 19, 'Начальник проходческого участка', 'Михайлов', 'Андрей', 'Олегович', '+7 (911) 101-01-20', 'amikhailov@nmz.ru', 'dept_head', 'amikhailov', 'pass020', NULL);
INSERT INTO public.employee VALUES (75, 20, 'Начальник отдела вентиляции и пылегазового контроля', 'Сидоров', 'Николай', 'Иванович', '+7 (911) 101-01-21', 'nsidorov@nmz.ru', 'dept_head', 'nsidorov', 'pass021', NULL);
INSERT INTO public.employee VALUES (76, 21, 'Начальник транспортного участка', 'Тихонов', 'Павел', 'Сергеевич', '+7 (911) 101-01-22', 'ptikhonov@nmz.ru', 'dept_head', 'ptikhonov', 'pass022', NULL);
INSERT INTO public.employee VALUES (77, 22, 'Начальник ремонтной службы', 'Матвеев', 'Алексей', 'Викторович', '+7 (911) 101-01-23', 'amatveev@nmz.ru', 'repair_head', 'amatveev', 'pass023', NULL);
INSERT INTO public.employee VALUES (78, 22, 'Сотрудник ремонтной службы', 'Герасимов', 'Дмитрий', 'Александрович', '+7 (911) 101-01-24', 'dgerasimov@nmz.ru', 'repair_worker', 'dgerasimov', 'pass024', NULL);
INSERT INTO public.employee VALUES (79, 22, 'Сотрудник ремонтной службы', 'Савельев', 'Илья', 'Николаевич', '+7 (911) 101-01-25', 'isavelyev@nmz.ru', 'repair_worker', 'isavelyev', 'pass025', NULL);
INSERT INTO public.employee VALUES (80, 22, 'Сотрудник ремонтной службы', 'Макаров', 'Владимир', 'Павлович', '+7 (911) 101-01-26', 'vmakarov@nmz.ru', 'repair_worker', 'vmakarov', 'pass026', NULL);
INSERT INTO public.employee VALUES (81, 22, 'Сотрудник ремонтной службы', 'Фомин', 'Олег', 'Сергеевич', '+7 (911) 101-01-27', 'ofomin@nmz.ru', 'repair_worker', 'ofomin', 'pass027', NULL);
INSERT INTO public.employee VALUES (82, 23, 'Заведующий складом', 'Кононов', 'Сергей', 'Александрович', '+7 (911) 101-01-28', 'skononov@nmz.ru', 'store_keeper', 'skononov', 'pass028', NULL);
INSERT INTO public.employee VALUES (83, 24, 'Заведующий складом', 'Морозова', 'Елена', 'Викторовна', '+7 (911) 101-01-29', 'emorozova@nmz.ru', 'store_keeper', 'emorozova', 'pass029', NULL);
INSERT INTO public.employee VALUES (84, 25, 'Заведующий складом', 'Алексеев', 'Игорь', 'Дмитриевич', '+7 (911) 101-01-30', 'ialekseev@nmz.ru', 'store_keeper', 'ialekseev', 'pass030', NULL);
INSERT INTO public.employee VALUES (85, 26, 'Начальник горного участка', 'Борисов', 'Владимир', 'Иванович', '+7 (911) 101-01-31', 'vborisov@nmz.ru', 'dept_head', 'vborisov', 'pass031', NULL);
INSERT INTO public.employee VALUES (86, 27, 'Начальник буровзрывного участка', 'Денисов', 'Алексей', 'Сергеевич', '+7 (911) 101-01-32', 'adenisov@nmz.ru', 'dept_head', 'adenisov', 'pass032', NULL);
INSERT INTO public.employee VALUES (87, 28, 'Начальник обогатительной фабрики', 'Захаров', 'Дмитрий', 'Павлович', '+7 (911) 101-01-33', 'dzakharov@nmz.ru', 'dept_head', 'dzakharov', 'pass033', NULL);
INSERT INTO public.employee VALUES (88, 29, 'Начальник транспортного участка', 'Иванов', 'Сергей', 'Олегович', '+7 (911) 101-01-34', 'sivanov@nmz.ru', 'dept_head', 'sivanov', 'pass034', NULL);
INSERT INTO public.employee VALUES (89, 30, 'Начальник службы энергетики', 'Киселев', 'Николай', 'Викторович', '+7 (911) 101-01-35', 'nkiselev@nmz.ru', 'dept_head', 'nkiselev', 'pass035', NULL);
INSERT INTO public.employee VALUES (90, 31, 'Начальник ремонтной службы', 'Ларионов', 'Андрей', 'Сергеевич', '+7 (911) 101-01-36', 'alarionov@nmz.ru', 'repair_head', 'alarionov', 'pass036', NULL);
INSERT INTO public.employee VALUES (91, 31, 'Сотрудник ремонтной службы', 'Николаев', 'Павел', 'Александрович', '+7 (911) 101-01-37', 'pn@nmz.ru', 'repair_worker', 'pn', 'pass037', NULL);


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.equipment VALUES (140, 90, '2026-08-14', 'Погрузочно-доставочная машина', 'ПД-2Э', 'Тип: Электрическая ПДМ для подземных горных работ\nГрузоподъёмность: 2000 кг\nОбъём ковша: 1,0 м³\nДвигатель: Электродвигатель 75 кВт, напряжение 1140 В\nСкорость движения: 0–14 км/ч\nГабариты (Д×Ш×В): 6450 × 1760 × 1850 мм\nМасса эксплуатационная: 12300 кг\nРадиус разворота: 3,4 м\nСистема торможения: Гидравлическая дисковая тормозная система HBD-75\nСистема пожаротушения: Автоматическая система порошкового тушения APS-200\nСистема контроля перегрузки: Электронный датчик нагрузки LCS-500\nФильтры тонкой очистки воздуха: Фильтровальная установка AFC-12', NULL);
INSERT INTO public.equipment VALUES (141, 60, '2025-05-22', 'Компрессорное оборудование', 'КГ-5/7', 'Тип компрессора: Винтовой\nПроизводительность: 5,0 м³/мин\nРабочее давление: 7 бар\nДвигатель: Дизельный 48 кВт\nРасход топлива: 9,5 л/ч\nОбъём масляной системы: 19 л\nТемпература рабочей среды: −20…+45 °C\nГабариты: 2950 × 1450 × 1650 мм\nМасса: 1280 кг\nАвтоматический регулятор давления: ARD-700\nЗащита от перегрева: Термодатчик OverheatGuard TG-12\nШумоизоляционный кожух: SHC-5', NULL);
INSERT INTO public.equipment VALUES (142, 180, '2027-03-10', 'Буровое оборудование', 'СБУ-100', 'Назначение: бурение шпуров и скважин\nГлубина бурения: до 100 м\nДиаметр бурения: 76–120 мм\nТип подачи: Гидравлическая, усилие подачи до 24 кН\nЧастота вращения шпинделя: 80–230 об/мин\nМощность гидростанции: 18 кВт\nРасход рабочей жидкости: 38 л/мин\nДавление в системе: 12–16 МПа\nГабариты: 3200 × 1200 × 1500 мм\nМасса: 1950 кг\nСистема контроля нагрузки: Датчик гидронагрузки HLS-24\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 100', NULL);
INSERT INTO public.equipment VALUES (143, 45, '2025-12-05', 'Конвейерное оборудование', 'КЛШ-800', 'Ширина ленты: 800 мм\nПроизводительность: до 350 т/ч\nСкорость ленты: 2,5 м/с\nМощность привода: 22 кВт\nДлина конвейера: 30–120 м\nНатяжное устройство: винтовое, диапазон 600 мм\nТип ленты: прорезиненная, шахтного исполнения\nДиаметр барабанов: 500 мм\nСистема контроля схода ленты: Датчик положения ленты BCS-800\nДатчики обрыва и натяжения: SensorLine TensionPro', NULL);
INSERT INTO public.equipment VALUES (144, 365, '2029-02-01', 'Проветривательное оборудование', 'ВМП-4М', 'Тип установки: центробежный вентилятор\nПроизводительность воздуха: до 450 м³/с\nПолное давление: 3600 Па\nДвигатель: 250 кВт, 6 кВ\nЧастота вращения: 740 об/мин\nКПД: 0,86\nУровень вибрации: ≤ 7 мм/с\nСистема контроля вибрации и температуры подшипников: VibeTemp Monitor VT-4M\nМасса агрегата: 9800 кг\nРазмеры: 4200 × 2250 × 2600 мм\nНазначение: обеспечение проветривания подземных горизонтов\nСистема аварийного отключения: Emergency Stop Unit ESU-600', NULL);
INSERT INTO public.equipment VALUES (145, 45, '2027-06-07', 'Буровое оборудование', 'DrillMaster 310H', 'Назначение: Бурение скважин под взрывные работы\nГлубина бурения: до 210 м\nДиаметр бурения: 64–152 мм\nМощность гидросистемы: 250 кВт\nРабочее давление: 26 МПа\nЧастота ударов перфоратора: 2400 уд/мин\nТип буровой штанги: стальная, шестигранная\nСкорость подъёма/опускания: 35 м/мин\nЕмкость бака масла: 280 л\nМаксимальный угол наклона: 90°\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 150\nСистема контроля вибрации: VibeSensor Pro VS-310\nСистема аварийного отключения: Emergency Stop Unit ESU-310', NULL);
INSERT INTO public.equipment VALUES (146, 60, '2026-09-12', 'Взрывное оборудование', 'ExploCrack 2000', 'Назначение: Закладка и инициирование взрывных зарядов\nМощность привода: 120 кВт\nСкорость подачи зарядов: до 15 шт/ч\nЕмкость бункера: 500 кг\nМаксимальная длина шланга подачи: 25 м\nСистема безопасности: Контроль перегрузки и аварийного отключения SafetyControl EX-2000\nДатчики температуры и давления: TempPress Monitor TPM-2\nСистема автоматического заземления: GroundSafe 200', NULL);
INSERT INTO public.equipment VALUES (147, 30, '2025-11-18', 'Конвейерное оборудование', 'LTV-500', 'Ширина ленты: 500 мм\nПроизводительность: до 200 т/ч\nСкорость ленты: 1,8 м/с\nДлина конвейера: 25–80 м\nТип ленты: антистатическая, огнестойкая\nМощность привода: 18 кВт\nСистема контроля схода ленты: BeltGuard LTV\nДатчики натяжения: TensionSensor 500\nСистема аварийной остановки: Emergency Stop Unit ESU-LTV\nМатериал роликов: Сталь с покрытием против искрения', NULL);
INSERT INTO public.equipment VALUES (148, 90, '2027-01-20', 'Дозирующее оборудование', 'BlastMeter 100', 'Назначение: точное дозирование взрывчатых смесей\nОбъём дозатора: 100 кг\nПогрешность дозирования: ±0,5 %\nСкорость подачи: до 50 кг/мин\nМощность привода: 12 кВт\nСистема контроля перегрузки: LoadMonitor LM-100\nДатчики температуры и влажности: TempHum Sensor TH-100\nСистема аварийного отключения: Emergency Stop Unit ESU-BM100\nМатериал ёмкости: Нержавеющая сталь', NULL);
INSERT INTO public.equipment VALUES (149, 60, '2026-08-30', 'Сортировочное оборудование', 'VibeSort 400', 'Производительность: до 250 т/ч\nРазмер ячеек: 20–150 мм\nМощность вибратора: 18 кВт\nЧастота вибрации: 1500 об/мин\nМатериал решета: Сталь повышенной прочности\nДлина грохота: 6 м\nСистема контроля вибрации: VibeSensor VS-400\nСистема аварийного отключения: Emergency Stop Unit ESU-VS400\nГабариты (Д×Ш×В): 6000 × 2200 × 2000 мм\nМасса: 2800 кг', NULL);
INSERT INTO public.equipment VALUES (150, 60, '2026-10-15', 'Дробильное оборудование', 'JCB-500', 'Тип: Щековая дробилка\nПроизводительность: до 250 т/ч\nМаксимальный размер куска: 500 мм\nМощность привода: 132 кВт\nЧастота вращения вала: 250 об/мин\nМатериал рабочих органов: сталь повышенной прочности\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 120\nСистема контроля перегрузки: LoadMonitor LM-500\nСистема аварийного отключения: Emergency Stop Unit ESU-JCB500', NULL);
INSERT INTO public.equipment VALUES (151, 45, '2025-12-05', 'Конвейерное оборудование', 'KL-1000', 'Ширина ленты: 1000 мм\nПроизводительность: до 400 т/ч\nСкорость ленты: 2,0 м/с\nДлина конвейера: 50–200 м\nТип ленты: прорезиненная, антистатическая\nМощность привода: 30 кВт\nСистема контроля схода ленты: BeltGuard KL-1000\nДатчики натяжения: TensionSensor 1000\nСистема аварийного отключения: Emergency Stop Unit ESU-KL1000', NULL);
INSERT INTO public.equipment VALUES (152, 60, '2026-09-10', 'Сортировочное оборудование', 'VibeScreen 600', 'Производительность: до 300 т/ч\nРазмер ячеек: 10–100 мм\nМощность вибратора: 22 кВт\nЧастота вибрации: 1400 об/мин\nМатериал решета: сталь повышенной прочности\nСистема контроля вибрации: VibeSensor VS-600\nСистема аварийного отключения: Emergency Stop Unit ESU-VS600\nГабариты (Д×Ш×В): 4800 × 1800 × 1600 мм\nМасса: 2500 кг', NULL);
INSERT INTO public.equipment VALUES (153, 90, '2027-03-20', 'Флотационное оборудование', 'FloatMaster F-12', 'Тип: Флотационная машина\nОбъём бака: 12 м³\nПроизводительность: до 150 т/ч\nМощность привода: 75 кВт\nЧастота вращения лопастей: 18 об/мин\nМатериал бака: нержавеющая сталь\nСистема контроля перегрузки: LoadMonitor LM-F12\nСистема аварийного отключения: Emergency Stop Unit ESU-F12\nСистема аэрации: AirFlow Pro AF-12', NULL);
INSERT INTO public.equipment VALUES (154, 120, '2028-01-15', 'Сепарационное оборудование', 'MagSep 800', 'Производительность: до 200 т/ч\nМагнитная индукция: 1,2 Тл\nТип барабана: сухой, вращающийся\nМощность привода: 18 кВт\nМатериал барабана: сталь с ферромагнитным покрытием\nСистема контроля перегрузки: LoadMonitor LM-MS800\nСистема аварийного отключения: Emergency Stop Unit ESU-MS800\nГабариты (Д×Ш×В): 4000 × 1500 × 1800 мм\nМасса: 2200 кг', NULL);
INSERT INTO public.equipment VALUES (155, 30, '2025-11-30', 'Насосное оборудование', 'PumpMaster P-200', 'Тип: Пульпоподающий насос\nПроизводительность: 200 м³/ч\nНапор: до 25 м\nМощность привода: 55 кВт\nМатериал корпуса: износостойкая сталь\nСистема контроля перегрузки: PumpLoad Monitor PLM-200\nСистема аварийного отключения: Emergency Stop Unit ESU-P200\nСистема фильтрации: FineFilter FF-200', NULL);
INSERT INTO public.equipment VALUES (156, 30, '2026-07-12', 'Карьерный транспорт', 'KAMAZ-6520', 'Тип: Самосвал\nГрузоподъёмность: 20 т\nОбъём кузова: 12 м³\nДвигатель: Дизельный, 240 кВт\nТрансмиссия: Механическая, 10 передач\nСистема торможения: Дисковая гидравлическая тормозная система HBD-240\nСистема контроля перегрузки: LoadMonitor LM-6520\nСистема пожаротушения: Автоматическая порошковая система APS-100\nМаксимальная скорость: 65 км/ч\nГабариты (Д×Ш×В): 7800 × 2500 × 3200 мм\nМасса эксплуатационная: 16 500 кг', NULL);
INSERT INTO public.equipment VALUES (157, 45, '2027-02-20', 'Конвейерное оборудование', 'ПП-800', 'Ширина ленты: 800 мм\nПроизводительноть: до 350 т/ч\nДлина конвейера: 30–80 м\nСкорость ленты: 2,2 м/с\nТип ленты: Прорезиненная, шахтного исполнения\nМощность привода: 18 кВт\nСистема контроля схода ленты: BeltGuard PP-800\nДатчики натяжения: TensionSensor 800\nСистема аварийного отключения: Emergency Stop Unit ESU-PP800\nМатериал роликов: Сталь с покрытием против искрения', NULL);
INSERT INTO public.equipment VALUES (158, 60, '2026-11-15', 'Шахтный транспорт', 'ЭЛ-150', 'Тип: Электровоз для подземных рудников\nМощность двигатея: 150 кВт\nМаксимальная скорость: 25 км/ч\nТяговое усилие: 40 кН\nВес: 12 500 кг\nГабариты (Д×Ш×В): 4800 × 1200 × 1800 мм\nСистема торможения: Электрогидравлическая тормозная система EHB-150\nСистема контроля перегрузки: LoadControl LCS-150\nСистема пожаротушения: Автоматическая порошковая система APS-150\nСистема аварийного отключения: Emergency Stop Unit ESU-EL150', NULL);
INSERT INTO public.equipment VALUES (159, 30, '2025-12-10', 'Погрузочно-транспортное оборудование', 'F-350', 'Тип: Фронтальный погрузчик\nГрузоподъёмность: 3,5 т\nОбъём ковша: 2,0 м³\nДвигатель: Дизельный 110 кВт\nСкорость движения: 0–20 км/ч\nГабариты (Д×Ш×В): 6500 × 2100 × 3200 мм\nСистема торможения: Гидравлическая дисковая тормозная система HBD-110\nСистема контроля перегрузки: LoadMonitor LM-F350\nСистема пожаротушения: Автоматическая порошковая система APS-350\nСистема управления ковшом: Электрогидравлическая HCU-350', NULL);
INSERT INTO public.equipment VALUES (160, 90, '2026-09-30', 'Электроэнергетическое оборудование', 'ДГ-500', 'Тип: Дизель-генератор\nМощность: 500 кВт\nНапряжение: 6 кВ\nЧастота: 50 Гц\nДвигатель: Дизельный, 750 кВт\nСистема автоматического запуска: AutoStart AS-500\nСистема защиты: Защита от перегрузки и короткого замыкания ProtecGuard 500\nСистема пожаротушения: Автоматическая порошковая система APS-500\nМасса: 6800 кг\nГабариты (Д×Ш×В): 4200 × 1800 × 2100 мм', NULL);
INSERT INTO public.equipment VALUES (161, 180, '2028-01-15', 'Электроэнергетическое оборудование', 'ТМГ-630/10', 'Тип: Масляный силовой трансформатор\nМощность: 630 кВА\nНапряжение: 10/0,4 кВ\nЧастота: 50 Гц\nМатериал обмоток: Медная проволока\nСистема охлаждения: Масляное охлаждение ONAN\nСистема защиты: Релейная защита трансформатора RelayGuard TMG-630\nСистема мониторинга температуры: TempMonitor TMG-630\nГабариты (Д×Ш×В): 2600 × 1500 × 1800 мм\nМасса: 2500 кг', NULL);
INSERT INTO public.equipment VALUES (162, 60, '2025-12-20', 'Электроэнергетическое оборудование', 'РЩ-1000', 'Тип: Распределительный щит\nНоминальный ток: 1000 А\nНапряжение: 0,4 кВ\nКоличество линий: 12\nСистема защиты: Автоматические выключатели ABB и защитные реле ProGuard RЩ-1000\nСистема аварийного отключения: Emergency Stop Unit ESU-RЩ1000\nМатериал корпуса: Сталь с порошковым покрытием\nГабариты (Д×Ш×В): 2200 × 1000 × 2000 мм\nМасса: 850 кг', NULL);
INSERT INTO public.equipment VALUES (163, 90, '2026-11-05', 'Электроэнергетическое оборудование', 'SN-500', 'Тип: Стабилизатор напряжения\nНоминальная мощность: 500 кВА\nНапряжение входное: 6 кВ\nНапряжение выходное: 0,4 кВ\nЧастота: 50 Гц\nТочность стабилизации: ±1 %\nСистема контроля: VoltageMonitor VM-500\nСистема защиты: Защита от перегрузки и короткого замыкания ProtecGuard 500\nСистема аварийного отключения: Emergency Stop Unit ESU-SN500\nГабариты (Д×Ш×В): 3000 × 1400 × 1800 мм\nМасса: 3200 кг', NULL);
INSERT INTO public.equipment VALUES (164, 60, '2025-10-28', 'Вентиляционное оборудование', 'VE-15', 'Тип: Вентилятор осевой\nПроизводительность: 15 000 м³/ч\nМощность двигателя: 15 кВт\nНапряжение: 380 В\nЧастота вращения: 950 об/мин\nСистема контроля вибрации: VibeSensor VS-15\nСистема аварийного отключения: Emergency Stop Unit ESU-VE15\nМатериал корпуса: Сталь с антикоррозийным покрытием\nГабариты (Д×Ш×В): 1800 × 1200 × 1400 мм\nМасса: 550 кг', NULL);
INSERT INTO public.equipment VALUES (165, 60, '2026-08-20', 'Добычное оборудование', 'EH-200', 'Тип: Гидравлический экскаватор для открытых разработок\nОбъём ковша: 1,5 м³\nГрузоподъёмность: 2000 кг\nДвигатель: Дизельный, 150 кВт\nСкорость поворота платформы: 12 об/мин\nМаксимальная высота разгрузки: 5,2 м\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 200\nСистема контроля перегрузки: LoadMonitor LM-200\nСистема пожаротушения: Автоматическая порошковая система APS-200', NULL);
INSERT INTO public.equipment VALUES (166, 30, '2025-12-12', 'Погрузочно-транспортное оборудование', 'FL-350', 'Тип: Фронтальный погрузчик\nГрузоподъёмность: 3,5 т\nОбъём ковша: 2,0 м³\nДвигатель: Дизельный 110 кВт\nСкорость движения: 0–20 км/ч\nСистема торможения: Гидравлическая дисковая тормозная система HBD-110\nСистема контроля перегрузки: LoadMonitor LM-F350\nСистема пожаротушения: Автоматическая порошковая система APS-350\nСистема управления ковшом: Электрогидравлическая HCU-350', NULL);
INSERT INTO public.equipment VALUES (167, 90, '2027-03-18', 'Буровое оборудование', 'BPU-150', 'Назначение: Бурение шпуров и скважин для взрывных работ\nГлубина бурения: до 150 м\nДиаметр шпура: 76–120 мм\nДвигатель: Дизельный, 120 кВт\nЧастота вращения шпинделя: 80–200 об/мин\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 150\nСистема контроля нагрузки: Датчик гидронагрузки HLS-150\nСистема пожаротушения: Автоматическая порошковая система APS-150', NULL);
INSERT INTO public.equipment VALUES (168, 60, '2026-10-25', 'Подземная добычная техника', 'ПД-1Э', 'Тип: Электрическая ПДМ для подземных горных работ\nГрузоподъёмность: 1500 кг\nОбъём ковша: 0,8 м³\nДвигатель: Электродвигатель 55 кВт, напряжение 1140 В\nСкорость движения: 0–12 км/ч\nГабариты (Д×Ш×В): 5800 × 1600 × 1700 мм\nМасса эксплуатационная: 9500 кг\nСистема торможения: Гидравлическая дисковая тормозная система HBD-55\nСистема пожаротушения: Автоматическая порошковая система APS-150\nСистема контроля перегрузки: Электронный датчик нагрузки LCS-150', NULL);
INSERT INTO public.equipment VALUES (169, 90, '2026-11-12', 'Проходческое оборудование', 'ПК-200', 'Тип: Шахтный проходческий комбайн\nПроизводительность: до 80 м³/ч\nШирина проходки: 2,0 м\nДвигатель: Электродвигатель 160 кВт\nСкорость продвижения: 0–8 м/мин\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 200\nСистема контроля перегрузки: LoadMonitor LM-200\nСистема пожаротушения: Автоматическая порошковая система APS-200', NULL);
INSERT INTO public.equipment VALUES (170, 60, '2025-12-18', 'Буровое оборудование', 'СБУ-80', 'Назначение: Бурение шпуров и скважин под взрывные работы\nГлубина бурения: до 80 м\nДиаметр бурения: 64–110 мм\nДвигатель: Электродвигатель 75 кВт\nЧастота вращения шпинделя: 70–180 об/мин\nСистема смазки узлов: Автоматическая смазочная установка LubeMaster 80\nСистема контроля нагрузки: Датчик гидронагрузки HLS-80\nСистема пожаротушения: Автоматическая порошковая система APS-80', NULL);
INSERT INTO public.equipment VALUES (192, 60, '2026-11-25', 'Обогатительное оборудование', 'DR-500', 'Тип: Щековая дробилка\nПроизводительность: до 500 т/ч\nРазмер куска на входе: до 600 мм\nРазмер куска на выходе: 50–150 мм\nДвигатель: Электродвигатель 200 кВт\nСистема контроля перегрузки: OverloadSensor OS-500\nСистема аварийного отключения: Emergency Stop Unit ESU-DR500\nМатериал корпуса: Сталь', NULL);
INSERT INTO public.equipment VALUES (171, 60, '2026-10-30', 'Подземная добычная техника', 'ПД-1Э', 'Тип: Электрическая ПДМ для подземных горных работ\nГрузоподъёмность: 1500 кг\nОбъём ковша: 0,8 м³\nДвигатель: Электродвигатель 55 кВт, напряжение 1140 В\nСкорость движения: 0–12 км/ч\nГабариты (Д×Ш×В): 5800 × 1600 × 1700 мм\nМасса эксплуатационная: 9500 кг\nСистема торможения: Гидравлическая дисковая тормозная система HBD-55\nСистема пожаротушения: Автоматическая порошковая система APS-150\nСистема контроля перегрузки: Электронный датчик нагрузки LCS-150', NULL);
INSERT INTO public.equipment VALUES (172, 45, '2025-11-20', 'Конвейерное оборудование', 'КЛШ-600', 'Ширина ленты: 600 мм\nПроизводительность: до 300 т/ч\nДлина конвейера: 20–100 м\nСкорость ленты: 2,0 м/с\nТип ленты: прорезиненная, шахтного исполнения\nМощность привода: 15 кВт\nСистема контроля схода ленты: BeltGuard KLS-600\nДатчики натяжения: TensionSensor 600\nСистема аварийного отключения: Emergency Stop Unit ESU-KLS600\nМатериал роликов: Сталь с покрытием против искрения', NULL);
INSERT INTO public.equipment VALUES (173, 30, '2026-09-15', 'Газоизмерительное оборудование', 'GA-500', 'Тип: Портативный газоанализатор\nИзмеряемые газы: CH₄, CO, O₂\nДиапазон измерений: 0–100 % LEL для CH₄, 0–500 ppm CO, 0–25 % O₂\nТочность: ±2 %\nВремя отклика: ≤ 10 с\nИсточник питания: Аккумулятор Li-Ion, 12 ч работы\nСистема аварийного оповещения: Звуковой и световой сигнал\nТемпературный диапазон: -20…+50 °C\nКорпус: Взрывозащищенный, IP67', NULL);
INSERT INTO public.equipment VALUES (174, 60, '2027-01-20', 'Вентиляционное оборудование', 'ВШ-1500', 'Тип: Осевой шахтный вентилятор\nПроизводительность: до 1500 м³/с\nПолное давление: 2500 Па\nДвигатель: Электродвигатель 90 кВт, 6 кВ\nЧастота вращения: 720 об/мин\nСистема контроля вибрации: VibeSensor VS-1500\nСистема аварийного отключения: Emergency Stop Unit ESU-VSH1500\nМатериал корпуса: Сталь с антикоррозийным покрытием\nГабариты (Д×Ш×В): 4200 × 2000 × 2300 мм\nМасса: 5200 кг', NULL);
INSERT INTO public.equipment VALUES (175, 90, '2026-12-05', 'Пылеулавливающее оборудование', 'DustControl DC-800', 'Тип: Пылеулавливающая система циклонного типа\nПроизводительность: до 800 м³/ч\nФильтрация: до 99,5 % частиц ≥ 5 мкм\nМощность вентилятора: 15 кВт\nДавление на входе: до 1500 Па\nМатериал корпуса: Сталь с антикоррозийным покрытием\nСистема аварийного отключения: Emergency Stop Unit ESU-DC800\nСистема контроля пылевой нагрузки: DustMonitor DM-800\nГабариты (Д×Ш×В): 2800 × 1200 × 1500 мм\nМасса: 950 кг', NULL);
INSERT INTO public.equipment VALUES (176, 120, '2027-06-15', 'Автоматизированное оборудование', 'VControl 300', 'Тип: Автоматизированный контроллер шахтной вентиляции\nКоличество каналов: до 16 вентиляторов\nПодключение датчиков: Газ, температура, влажность, скорость потока\nСистема аварийного отключения: Emergency Stop Unit ESU-VC300\nИнтерфейс управления: Сенсорный экран, удалённый мониторинг SCADA\nИсточник питания: 220 В, 50 Гц\nМатериал корпуса: Сталь с порошковым покрытием, IP54\nПрограммное обеспечение: Контроль потоков воздуха, сигнализация аварийных ситуаций', NULL);
INSERT INTO public.equipment VALUES (177, 90, '2026-10-20', 'Плавильное оборудование', 'EP-5', 'Тип: Индукционная печь\nЁмкость плавильной ванны: 5 т\nМощность индуктора: 1200 кВт\nТемпература плавки: до 1600 °C\nСистема контроля температуры: TempMonitor TM-EP5\nСистема аварийного отключения: Emergency Stop Unit ESU-EP5\nМатериал ванны: Сталь с огнеупорным покрытием\nГабариты (Д×Ш×В): 4500 × 2200 × 1800 мм\nМасса: 7200 кг', NULL);
INSERT INTO public.equipment VALUES (178, 60, '2027-02-15', 'Разливочное оборудование', 'CR-1000', 'Тип: Ковш для непрерывного разлива металла\nОбъём: 1 т\nТемпература рабочей массы: до 1500 °C\nМатериал ковша: Сталь с огнеупорной футеровкой\nСистема управления разливом: AutoPour AP-1000\nСистема аварийного отключения: Emergency Stop Unit ESU-CR1000\nГабариты (Д×Ш×В): 2000 × 1200 × 1500 мм\nМасса: 1800 кг', NULL);
INSERT INTO public.equipment VALUES (179, 30, '2025-12-28', 'Лабораторное оборудование', 'LP-50', 'Тип: Электропечь лабораторная\nЁмкость плавильной ванны: 50 кг\nТемпература плавки: до 1600 °C\nМощность нагревателя: 50 кВт\nСистема контроля температуры: TempControl TC-LP50\nСистема аварийного отключения: Emergency Stop Unit ESU-LP50\nМатериал ванны: Сталь с огнеупорным покрытием\nГабариты (Д×Ш×В): 1500 × 900 × 1200 мм\nМасса: 550 кг', NULL);
INSERT INTO public.equipment VALUES (180, 365, '2029-01-10', 'Вентиляционное оборудование', 'VFC-800', 'Тип: Центробежный вентилятор для удаления дымов и газов\nПроизводительность: до 800 м³/с\nПолное давление: 2500 Па\nДвигатель: Электродвигатель 75 кВт, 380 В\nЧастота вращения: 950 об/мин\nСистема контроля вибрации: VibeSensor VS-800\nСистема аварийного отключения: Emergency Stop Unit ESU-VFC800\nМатериал корпуса: Сталь с антикоррозийным покрытием\nГабариты (Д×Ш×В): 2800 × 1500 × 1800 мм\nМасса: 1200 кг', NULL);
INSERT INTO public.equipment VALUES (193, 90, '2027-02-10', 'Обогатительное оборудование', 'PT-500', 'Тип: Печь термообработки металлов\nЁмкость загрузки: 500 кг\nТемпература: до 1200 °C\nДвигатель конвектора: 7,5 кВт\nСистема контроля температуры: TempControl TC-PT500\nСистема аварийного отключения: Emergency Stop Unit ESU-PT500\nМатериал ванны: Сталь с огнеупорной футеровкой\nГабариты (Д×Ш×В): 2200 × 1200 × 1600 мм\nМасса: 1200 кг', NULL);
INSERT INTO public.equipment VALUES (181, 90, '2026-09-25', 'Плавильное и нагревательное оборудование', 'PR-10', 'Тип: Роликовая печь разогрева заготовок\nЁмкость: до 10 т заготовок\nТемпература нагрева: до 1250 °C\nДлина печи: 12 м\nДвигатель роликов: Электродвигатель 45 кВт\nСистема контроля температуры: TempControl TC-PR10\nСистема аварийного отключения: Emergency Stop Unit ESU-PR10\nМатериал корпуса: Сталь с огнеупорной футеровкой\nГабариты (Д×Ш×В): 12000 × 3000 × 4000 мм\nМасса: 12 500 кг', NULL);
INSERT INTO public.equipment VALUES (182, 60, '2027-03-12', 'Прокатное оборудование', 'RS-4', 'Тип: Горячекатаный роликовый стан\nКоличество валков: 4\nДиапазон толщины проката: 5–50 мм\nСкорость проката: 0–15 м/с\nДвигатели привода валков: 4 × 90 кВт\nСистема контроля температуры заготовки: TempMonitor TM-RS4\nСистема аварийного отключения: Emergency Stop Unit ESU-RS4\nГабариты (Д×Ш×В): 8000 × 2500 × 3200 мм\nМасса: 14 200 кг', NULL);
INSERT INTO public.equipment VALUES (183, 60, '2026-12-05', 'Прокатное оборудование', 'VM-200', 'Тип: Холодновальцовочная машина\nДиаметр валков: 200 мм\nСкорость валков: до 5 м/с\nТолщина обрабатываемого листа: 0,5–6 мм\nДвигатель привода: 55 кВт\nСистема контроля толщины проката: ThicknessControl TC-200\nСистема аварийного отключения: Emergency Stop Unit ESU-VM200\nМатериал валков: Сталь закалённая\nГабариты (Д×Ш×В): 4200 × 1500 × 1800 мм\nМасса: 4200 кг', NULL);
INSERT INTO public.equipment VALUES (184, 45, '2027-01-18', 'Обрабатывающее оборудование', 'LPS-6', 'Тип: Листоправильный стан\nМаксимальая ширина листа: 2000 мм\nТолщина листа: 0,5–10 мм\nСкорость обработки: до 8 м/мин\nДвигатели: 2 × 18 кВт\nСистема контроля кривизны листа: StraightMonitor SM-LPS6\nСистема аварийного отключения: Emergency Stop Unit ESU-LPS6\nГабариты (Д×Ш×В): 6000 × 2200 × 2000 мм\nМасса: 5800 кг', NULL);
INSERT INTO public.equipment VALUES (185, 365, '2029-03-05', 'Вентиляционное оборудование', 'VRC-1200', 'Тип: Центробежный вентилятор для удаления газов и дыма\nПроизводительность: до 1200 м³/с\nПолное давление: 2800 Па\nДвигатель: Электродвигатель 75 кВт, 380 В\nЧастота вращения: 950 об/мин\nСистема контроля вибрации: VibeSensor VS-1200\nСистема аварийного отключения: Emergency Stop Unit ESU-VRC1200\nМатериал корпуса: Сталь с антикоррозийным покрытием\nГабариты (Д×Ш×В): 3200 × 1600 × 1800 мм\nМасса: 1500 кг', NULL);
INSERT INTO public.equipment VALUES (186, 90, '2026-11-10', 'Лабораторное оборудование', 'SO-500', 'Тип: Оптический спектрометр для анализа металлов\nДиапазон измерений: 0–100 % компонентов сплава\nРазрешение: 0,01 %\nМетод анализа: Оптическая эмиссия с индуктивно-связанной плазмой\nВремя анализа образца: 1–2 мин\nИсточник питания: 220 В, 50 Гц\nСистема калибровки: Автоматическая\nГабариты (Д×Ш×В): 1200 × 800 × 1600 мм\nМасса: 250 кг', NULL);
INSERT INTO public.equipment VALUES (187, 60, '2027-02-05', 'Испытательное оборудование', 'IP-100', 'Тип: Универсальный испытательный пресс\nМаксимальная сила сжатия: 1000 кН\nМаксимальная сила растяжения: 800 кН\nСкорость нагружения: 0,1–50 мм/мин\nСистема измерения деформации: Электронные тензодатчики\nКонтроллер управления: DigitalControl DC-IP100\nСистема аварийного отключения: Emergency Stop Unit ESU-IP100\nГабариты (Д×Ш×В): 2500 × 1200 × 2200 мм\nМасса: 1800 кг', NULL);
INSERT INTO public.equipment VALUES (188, 120, '2027-06-12', 'Лабораторное оборудование', 'AC-300', 'Тип: Анализатор химического состава металлов\nМетоды анализа: Спектрометрия, титриметрия, химические реакции\nДиапазон измерений: 0–100 % основных компонентов\nТочность: ±0,05 %\nИсточник питания: 220 В, 50 Гц\nИнтерфейс: ПК с ПО QC-Analyzer\nСистема аварийного отключения: Emergency Stop Unit ESU-AC300\nГабариты (Д×Ш×В): 1400 × 900 × 1600 мм\nМасса: 320 кг', NULL);
INSERT INTO public.equipment VALUES (189, 60, '2026-12-20', 'Технологическое оборудование', 'SM-300', 'Тип: Шнековый смеситель для металлургической шихты\nЁмкость: 300 кг\nСкорость вращения шнека: 20–60 об/мин\nМатериал корпуса: Сталь с огнеупорной футеровкой\nПривод: Электродвигатель 15 кВт\nСистема контроля температуры: TempMonitor TM-SM300\nСистема аварийного отключения: Emergency Stop Unit ESU-SM300\nГабариты (Д×Ш×В): 1800 × 1200 × 1500 мм\nМасса: 650 кг', NULL);
INSERT INTO public.equipment VALUES (190, 45, '2027-01-15', 'Технологическое оборудование', 'DZ-150', 'Тип: Автоматический дозатор порошковых добавок\nПроизводительность: до 150 кг/ч\nТочность дозирования: ±0,5 %\nИсточник питания: 220 В, 50 Гц\nПривод: Электродвигатель 5,5 кВт\nСистема контроля дозирования: AutoDose AD-150\nСистема аварийного отключения: Emergency Stop Unit ESU-DZ150\nМатериал корпуса: Нержавеющая сталь\nГабариты (Д×Ш×В): 1200 × 800 × 1600 мм\nМасса: 320 кг', NULL);
INSERT INTO public.equipment VALUES (191, 90, '2027-05-10', 'Технологическое оборудование', 'PT-500', 'Тип: Печь термообработки металлов\nЁмкость загрузки: 500 кг\nТемпература: до 1200 °C\nДвигатель конвектора: 7,5 кВт\nСистема контроля температуры: TempControl TC-PT500\nСистема аварийного отключения: Emergency Stop Unit ESU-PT500\nМатериал ванны: Сталь с огнеупорной футеровкой\nГабариты (Д×Ш×В): 2200 × 1200 × 1600 мм\nМасса: 1200 кг', NULL);
INSERT INTO public.equipment VALUES (194, 45, '2026-12-18', 'Обогатительное оборудование', 'FM-150', 'Тип: Флотационная машина\nОбъем камеры: 150 л\nПроизводительность: до 120 т/ч\nМощность привода: 22 кВт\nСистема контроля пенсиобразования: FramControl FC-150\nСистема аварийного отключения: Emergency Stop Unit ESU-TM150\nМатериал камеры: Нержавеющая сталь', NULL);
INSERT INTO public.equipment VALUES (195, 60, '2027-03-05', 'Обогатительное оборудование', 'MS-300', 'Тип: Магнитный сепаратор\nПроизводительность: до 300 т/ч\nИнтенсивность магнитного поля: до 1200 Гс\nДлина рабочей зоны: 3 м\nДвигатель привода: 15 кВт\nСистема контроля магнитного поля: MagMonitor MM-300\nСистема аварийного отключения: Emergency Stop Unit ESU-MS200\nМатериал корпуса: Сталь с антикоррозийным покрытием', NULL);
INSERT INTO public.equipment VALUES (196, 60, '2026-12-22', 'Фильтрационное оборудование', 'FP-100', 'Тип: Фильтр-пресс\nПлощадь фильтрации: 100 м²\nПроизводительность: до 50 т/ч\nДавление прессования: до 16 бар\nДвигатель привода: 22 кВт\nСистема контроля давления: PressureMonitor PM-FP100\nСистема аварийного отключения: Emergency Stop Unit ESU-FP100\nМатериал плит: Чугун/сталь', NULL);
INSERT INTO public.equipment VALUES (197, 90, '2027-01-10', 'Сушильное оборудование', 'DRY-200', 'Тип: Барабанная сушилка\nПроизводительность: до 200 т/ч\nТемпература: до 250 °C\nДлина барабана: 6 м\nДвигатель: 30 кВт\nСистема контроля температуры: TempMonitor TM-DRT200\nСистема аварийного отключения: Emergency Stop Unit ESU-DRY200\nМатериал корпуса: Сталь с огнеупорным покрытием', NULL);
INSERT INTO public.equipment VALUES (198, 385, '2029-03-15', 'Вентиляционное оборудование', 'VDC-500', 'Тип: Центробежный вентилятор\nПроизводительность: до 500 м³/с\nДавление: 2000 Па\nДвигатель: Электродвигатель: 55 кВт, 380 В\nЧастота вращения: 960 об/мин\nСистема контроля вибрации: VibeSensor VS-500\nСистема аварийного отключения: Emergency Stop Unit ESU-VDC600\nМатериал корпуса: Сталь с антикоррозийным покрытием', NULL);
INSERT INTO public.equipment VALUES (199, 60, '2027-04-05', 'Лабораторное оборудование', 'ST-100', 'Тип: Универсальный испытательный стенд\nМаксимальная нагрузка: 1000 кН\nКонтролируемые параметры: сила, деформация, температура\nСистема измерения: Электронные датчики\nСистема аварийного отключения: Emergency Stop Unit ESU-ST100\nИсточник питания: 220 В\nГабариты (Д×Ш×В): 2500 × 1200 × 2000 мм\nМасса: 1800 кг', NULL);
INSERT INTO public.equipment VALUES (200, 120, '2027-06-18', 'Лабораторное оборудование', 'MM-290', 'Тип: Оптический металлографический микроскоп\nУвеличение: 50–200x\nМетоды наблюдения: Светлое поле, темное поле, поляризация\nИсточник света: LED, регулируемая интенсивность\nСистема фотодокументации: Фотокамера с ПК\nСистема аварийного отключения: Emergency Stop Unit ESU-MM200\nГабариты (Д×Ш×В): 800 × 600 × 1400 мм\nМасса: 120 кг', NULL);


--
-- Data for Name: equipment_assignment; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.equipment_assignment VALUES (1, 140, 7, '2023-03-15', 'Шахта №1 уровень -150м', NULL);
INSERT INTO public.equipment_assignment VALUES (2, 141, 7, '2023-05-22', 'Шахта №2 уровень -200м', NULL);
INSERT INTO public.equipment_assignment VALUES (3, 142, 7, '2023-08-10', 'Вентиляционная выработка', NULL);
INSERT INTO public.equipment_assignment VALUES (4, 143, 7, '2023-11-05', 'Транспортная галерея', NULL);
INSERT INTO public.equipment_assignment VALUES (5, 144, 7, '2024-01-20', 'Шахта №3 уровень -100м', NULL);
INSERT INTO public.equipment_assignment VALUES (6, 142, 8, '2023-06-20', 'Буровая площадка №1', NULL);
INSERT INTO public.equipment_assignment VALUES (7, 145, 8, '2023-09-12', 'Буровая площадка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (8, 146, 8, '2023-12-18', 'Зона подготовки зарядов', NULL);
INSERT INTO public.equipment_assignment VALUES (9, 148, 8, '2024-02-10', 'Контрольный пункт', NULL);
INSERT INTO public.equipment_assignment VALUES (10, 149, 8, '2024-04-25', 'Склад ВВ', NULL);
INSERT INTO public.equipment_assignment VALUES (11, 143, 9, '2023-07-15', 'Цех дробления', NULL);
INSERT INTO public.equipment_assignment VALUES (12, 150, 9, '2023-10-20', 'Цех измельчения', NULL);
INSERT INTO public.equipment_assignment VALUES (13, 151, 9, '2024-01-15', 'Флотация секция А', NULL);
INSERT INTO public.equipment_assignment VALUES (14, 152, 9, '2024-03-20', 'Склад концентрата', NULL);
INSERT INTO public.equipment_assignment VALUES (15, 153, 9, '2024-05-10', 'Флотация секция Б', NULL);
INSERT INTO public.equipment_assignment VALUES (16, 147, 10, '2023-08-25', 'Транспортный цех', NULL);
INSERT INTO public.equipment_assignment VALUES (17, 154, 10, '2023-11-18', 'Ремонтная зона', NULL);
INSERT INTO public.equipment_assignment VALUES (18, 155, 10, '2024-02-05', 'Погрузочная площадка', NULL);
INSERT INTO public.equipment_assignment VALUES (19, 156, 10, '2024-04-15', 'Сортировочная станция', NULL);
INSERT INTO public.equipment_assignment VALUES (20, 144, 11, '2023-09-10', 'Подстанция №1', NULL);
INSERT INTO public.equipment_assignment VALUES (21, 157, 11, '2023-12-01', 'Подстанция №2', NULL);
INSERT INTO public.equipment_assignment VALUES (22, 158, 11, '2024-03-15', 'Дизельная электростанция', NULL);
INSERT INTO public.equipment_assignment VALUES (23, 159, 11, '2024-06-20', 'Распределительный щит', NULL);
INSERT INTO public.equipment_assignment VALUES (24, 140, 18, '2023-05-10', 'Карьер сектор А', NULL);
INSERT INTO public.equipment_assignment VALUES (25, 142, 18, '2023-08-20', 'Карьер сектор Б', NULL);
INSERT INTO public.equipment_assignment VALUES (26, 145, 18, '2023-11-30', 'Погрузочная площадка', NULL);
INSERT INTO public.equipment_assignment VALUES (27, 150, 18, '2024-03-10', 'Дробильный комплекс', NULL);
INSERT INTO public.equipment_assignment VALUES (28, 160, 18, '2024-06-05', 'Склад руды', NULL);
INSERT INTO public.equipment_assignment VALUES (29, 140, 19, '2023-06-15', 'Штольня №1', NULL);
INSERT INTO public.equipment_assignment VALUES (30, 141, 19, '2023-09-25', 'Штольня №2', NULL);
INSERT INTO public.equipment_assignment VALUES (31, 142, 19, '2023-12-10', 'Вентиляционная выработка', NULL);
INSERT INTO public.equipment_assignment VALUES (32, 144, 19, '2024-02-20', 'Транспортная галерея', NULL);
INSERT INTO public.equipment_assignment VALUES (33, 161, 19, '2024-05-15', 'Контрольный пункт', NULL);
INSERT INTO public.equipment_assignment VALUES (34, 144, 20, '2023-07-20', 'Вентиляционная камера №1', NULL);
INSERT INTO public.equipment_assignment VALUES (35, 162, 20, '2023-10-30', 'Вентиляционная камера №2', NULL);
INSERT INTO public.equipment_assignment VALUES (36, 163, 20, '2024-01-20', 'Пылеулавливающая установка', NULL);
INSERT INTO public.equipment_assignment VALUES (37, 164, 20, '2024-04-10', 'Лаборатория', NULL);
INSERT INTO public.equipment_assignment VALUES (38, 147, 21, '2023-08-05', 'Автопарк', NULL);
INSERT INTO public.equipment_assignment VALUES (39, 149, 21, '2023-11-15', 'Ремонтная зона', NULL);
INSERT INTO public.equipment_assignment VALUES (40, 154, 21, '2024-02-28', 'Сортировочная станция', NULL);
INSERT INTO public.equipment_assignment VALUES (41, 165, 21, '2024-05-20', 'Гараж спецтехники', NULL);
INSERT INTO public.equipment_assignment VALUES (42, 140, 26, '2023-04-15', 'Шахта №1 уровень -150м', NULL);
INSERT INTO public.equipment_assignment VALUES (43, 141, 26, '2023-07-25', 'Шахта №3 уровень -100м', NULL);
INSERT INTO public.equipment_assignment VALUES (44, 142, 26, '2023-10-10', 'Вентиляционная выработка', NULL);
INSERT INTO public.equipment_assignment VALUES (45, 144, 26, '2024-01-30', 'Транспортная галерея', NULL);
INSERT INTO public.equipment_assignment VALUES (46, 166, 26, '2024-04-25', 'Контрольный пункт', NULL);
INSERT INTO public.equipment_assignment VALUES (47, 142, 27, '2023-06-30', 'Буровая площадка №1', NULL);
INSERT INTO public.equipment_assignment VALUES (48, 145, 27, '2023-10-15', 'Буровая площадка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (49, 146, 27, '2024-01-10', 'Склад ВВ', NULL);
INSERT INTO public.equipment_assignment VALUES (50, 167, 27, '2024-04-05', 'Зона подготовки зарядов', NULL);
INSERT INTO public.equipment_assignment VALUES (51, 143, 28, '2023-08-10', 'Цех дробления', NULL);
INSERT INTO public.equipment_assignment VALUES (52, 151, 28, '2023-11-25', 'Цех измельчения', NULL);
INSERT INTO public.equipment_assignment VALUES (53, 152, 28, '2024-02-15', 'Флотация секция Б', NULL);
INSERT INTO public.equipment_assignment VALUES (54, 153, 28, '2024-05-20', 'Сгуститель', NULL);
INSERT INTO public.equipment_assignment VALUES (55, 168, 28, '2024-08-10', 'Склад концентрата', NULL);
INSERT INTO public.equipment_assignment VALUES (56, 147, 29, '2023-09-20', 'Транспортная база', NULL);
INSERT INTO public.equipment_assignment VALUES (57, 149, 29, '2023-12-30', 'Погрузочная площадка', NULL);
INSERT INTO public.equipment_assignment VALUES (58, 154, 29, '2024-03-25', 'Гараж спецтехники', NULL);
INSERT INTO public.equipment_assignment VALUES (59, 169, 29, '2024-06-15', 'Ремонтная зона', NULL);
INSERT INTO public.equipment_assignment VALUES (60, 144, 30, '2023-10-05', 'Подстанция №1', NULL);
INSERT INTO public.equipment_assignment VALUES (61, 157, 30, '2024-01-20', 'Распределительный щит', NULL);
INSERT INTO public.equipment_assignment VALUES (62, 158, 30, '2024-04-10', 'Кабельная галерея', NULL);
INSERT INTO public.equipment_assignment VALUES (63, 170, 30, '2024-07-25', 'Дизельная электростанция', NULL);
INSERT INTO public.equipment_assignment VALUES (64, 155, 35, '2023-11-10', 'Печь №1', NULL);
INSERT INTO public.equipment_assignment VALUES (65, 156, 35, '2024-02-20', 'Печь №2', NULL);
INSERT INTO public.equipment_assignment VALUES (66, 171, 35, '2024-05-15', 'Разливочная машина', NULL);
INSERT INTO public.equipment_assignment VALUES (67, 172, 35, '2024-08-20', 'Склад шихты', NULL);
INSERT INTO public.equipment_assignment VALUES (68, 156, 36, '2023-12-05', 'Прокатный стан №1', NULL);
INSERT INTO public.equipment_assignment VALUES (69, 157, 36, '2024-03-15', 'Прокатный стан №2', NULL);
INSERT INTO public.equipment_assignment VALUES (70, 173, 36, '2024-06-10', 'Печь нагрева', NULL);
INSERT INTO public.equipment_assignment VALUES (71, 174, 36, '2024-09-15', 'Склад заготовок', NULL);
INSERT INTO public.equipment_assignment VALUES (72, 157, 37, '2024-01-10', 'Лаборатория химического анализа', NULL);
INSERT INTO public.equipment_assignment VALUES (73, 158, 37, '2024-04-20', 'Лаборатория физических испытаний', NULL);
INSERT INTO public.equipment_assignment VALUES (74, 159, 37, '2024-07-15', 'Измерительная комната', NULL);
INSERT INTO public.equipment_assignment VALUES (75, 175, 37, '2024-10-20', 'Склад образцов', NULL);
INSERT INTO public.equipment_assignment VALUES (76, 158, 38, '2024-02-15', 'Офисное помещение кабинет 101', NULL);
INSERT INTO public.equipment_assignment VALUES (77, 159, 38, '2024-05-25', 'Конференц-зал', NULL);
INSERT INTO public.equipment_assignment VALUES (78, 160, 38, '2024-08-10', 'Серверная', NULL);
INSERT INTO public.equipment_assignment VALUES (79, 176, 38, '2024-11-15', 'Архив документации', NULL);
INSERT INTO public.equipment_assignment VALUES (80, 151, 43, '2023-10-15', 'Дробильное отделение', NULL);
INSERT INTO public.equipment_assignment VALUES (81, 152, 43, '2024-01-25', 'Флотационное отделение', NULL);
INSERT INTO public.equipment_assignment VALUES (82, 153, 43, '2024-04-10', 'Сгуститель', NULL);
INSERT INTO public.equipment_assignment VALUES (83, 177, 43, '2024-07-20', 'Фильтр-пресс', NULL);
INSERT INTO public.equipment_assignment VALUES (84, 154, 44, '2023-11-20', 'Фильтр-пресс №1', NULL);
INSERT INTO public.equipment_assignment VALUES (85, 155, 44, '2024-02-28', 'Фильтр-пресс №2', NULL);
INSERT INTO public.equipment_assignment VALUES (86, 178, 44, '2024-06-15', 'Сушильная печь', NULL);
INSERT INTO public.equipment_assignment VALUES (87, 179, 44, '2024-09-20', 'Склад готовой продукции', NULL);
INSERT INTO public.equipment_assignment VALUES (88, 157, 45, '2024-01-05', 'Лаборатория №1', NULL);
INSERT INTO public.equipment_assignment VALUES (89, 158, 45, '2024-04-15', 'Лаборатория №2', NULL);
INSERT INTO public.equipment_assignment VALUES (90, 159, 45, '2024-07-20', 'Измерительная комната', NULL);
INSERT INTO public.equipment_assignment VALUES (91, 180, 45, '2024-10-25', 'Архив результатов', NULL);
INSERT INTO public.equipment_assignment VALUES (92, 158, 46, '2024-02-10', 'Офисное помещение кабинет 102', NULL);
INSERT INTO public.equipment_assignment VALUES (93, 159, 46, '2024-05-20', 'Архив документации', NULL);
INSERT INTO public.equipment_assignment VALUES (94, 160, 46, '2024-08-05', 'Серверная', NULL);
INSERT INTO public.equipment_assignment VALUES (95, 181, 46, '2024-11-10', 'Конференц-зал', NULL);
INSERT INTO public.equipment_assignment VALUES (96, 182, 7, '2024-01-15', 'Контрольный пункт', NULL);
INSERT INTO public.equipment_assignment VALUES (97, 183, 7, '2024-04-20', 'Вентиляционная выработка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (98, 184, 8, '2024-03-10', 'Буровая площадка №3', NULL);
INSERT INTO public.equipment_assignment VALUES (99, 185, 8, '2024-06-15', 'Контрольный пункт №2', NULL);
INSERT INTO public.equipment_assignment VALUES (100, 186, 9, '2024-02-25', 'Цех дробления линия 2', NULL);
INSERT INTO public.equipment_assignment VALUES (101, 187, 9, '2024-05-30', 'Флотация секция В', NULL);
INSERT INTO public.equipment_assignment VALUES (102, 188, 10, '2024-03-20', 'Транспортный цех секция 2', NULL);
INSERT INTO public.equipment_assignment VALUES (103, 189, 10, '2024-06-25', 'Погрузочная площадка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (104, 190, 11, '2024-04-15', 'Подстанция №3', NULL);
INSERT INTO public.equipment_assignment VALUES (105, 191, 11, '2024-07-20', 'Кабельная галерея №2', NULL);
INSERT INTO public.equipment_assignment VALUES (106, 192, 18, '2024-05-10', 'Карьер сектор В', NULL);
INSERT INTO public.equipment_assignment VALUES (107, 193, 18, '2024-08-15', 'Дробильный комплекс №2', NULL);
INSERT INTO public.equipment_assignment VALUES (108, 194, 19, '2024-06-20', 'Штольня №3', NULL);
INSERT INTO public.equipment_assignment VALUES (109, 195, 19, '2024-09-25', 'Вентиляционная выработка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (110, 196, 20, '2024-07-10', 'Вентиляционная камера №3', NULL);
INSERT INTO public.equipment_assignment VALUES (111, 197, 20, '2024-10-15', 'Пылеулавливающая установка №2', NULL);
INSERT INTO public.equipment_assignment VALUES (112, 198, 21, '2024-08-20', 'Автопарк секция 2', NULL);
INSERT INTO public.equipment_assignment VALUES (113, 199, 21, '2024-11-25', 'Сортировочная станция №2', NULL);
INSERT INTO public.equipment_assignment VALUES (114, 200, 26, '2024-09-10', 'Шахта №4 уровень -250м', NULL);


--
-- Data for Name: equipment_movement; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: facility; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.facility VALUES (1, 'АО "Серверный Горнорудный Комбинат"', 'Добывающее предприятие', 'Мурманская область', 'г. Кировск, ул. Промышленная, 14');
INSERT INTO public.facility VALUES (2, 'АО "Полярный Рудник"', 'Добывающее предприятие', 'Республика Коми', 'г. Воркута, ул. Шахтёрская, 7');
INSERT INTO public.facility VALUES (3, 'АО "АрктикМинерал"', 'Добывающее предприятие', 'Ямало-Ненецкий автономный округ', 'г. Надым, ул. Геологоразведочная, 21');
INSERT INTO public.facility VALUES (4, 'ООО «Металлургический Завод ВолгаМет»', 'Перерабатывающий завод', 'Нижегородская область', 'г. Дзержинск, ул. Индустриальная, 3');
INSERT INTO public.facility VALUES (5, 'ООО «Центральный Обогатительный Комбинат»', 'Перерабатывающий завод', 'Тульская область', 'г. Новомосковск, ул. Заводская, 52');
INSERT INTO public.facility VALUES (6, 'ООО «Управляющая Компания СеверМет Групп»', 'Центральный офис', 'Санкт-Петербург', 'Невский пр-т, 140');


--
-- Data for Name: maintenace_employee; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: maintenance_plan; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: maintenance_spare_part; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: part_stock_quantity; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.part_stock_quantity VALUES (1, 123, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (2, 123, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (3, 123, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (4, 123, 204, 15);
INSERT INTO public.part_stock_quantity VALUES (5, 123, 205, 45);
INSERT INTO public.part_stock_quantity VALUES (6, 123, 206, 18);
INSERT INTO public.part_stock_quantity VALUES (7, 123, 207, 12);
INSERT INTO public.part_stock_quantity VALUES (8, 123, 208, 14);
INSERT INTO public.part_stock_quantity VALUES (9, 123, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (10, 123, 210, 38);
INSERT INTO public.part_stock_quantity VALUES (11, 123, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (12, 123, 212, 20);
INSERT INTO public.part_stock_quantity VALUES (13, 123, 213, 22);
INSERT INTO public.part_stock_quantity VALUES (14, 123, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (15, 123, 215, 16);
INSERT INTO public.part_stock_quantity VALUES (16, 123, 216, 42);
INSERT INTO public.part_stock_quantity VALUES (17, 123, 217, 35);
INSERT INTO public.part_stock_quantity VALUES (18, 123, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (19, 123, 219, 40);
INSERT INTO public.part_stock_quantity VALUES (20, 123, 220, 28);
INSERT INTO public.part_stock_quantity VALUES (21, 123, 221, 24);
INSERT INTO public.part_stock_quantity VALUES (22, 123, 222, 19);
INSERT INTO public.part_stock_quantity VALUES (23, 123, 223, 17);
INSERT INTO public.part_stock_quantity VALUES (24, 123, 224, 15);
INSERT INTO public.part_stock_quantity VALUES (25, 123, 225, 13);
INSERT INTO public.part_stock_quantity VALUES (26, 123, 226, 11);
INSERT INTO public.part_stock_quantity VALUES (27, 123, 227, 9);
INSERT INTO public.part_stock_quantity VALUES (28, 123, 228, 7);
INSERT INTO public.part_stock_quantity VALUES (29, 123, 229, 5);
INSERT INTO public.part_stock_quantity VALUES (30, 123, 230, 3);
INSERT INTO public.part_stock_quantity VALUES (31, 124, 201, 2);
INSERT INTO public.part_stock_quantity VALUES (32, 124, 205, 52);
INSERT INTO public.part_stock_quantity VALUES (33, 124, 210, 48);
INSERT INTO public.part_stock_quantity VALUES (34, 124, 216, 55);
INSERT INTO public.part_stock_quantity VALUES (35, 124, 217, 50);
INSERT INTO public.part_stock_quantity VALUES (36, 124, 219, 58);
INSERT INTO public.part_stock_quantity VALUES (37, 124, 220, 45);
INSERT INTO public.part_stock_quantity VALUES (38, 124, 221, 42);
INSERT INTO public.part_stock_quantity VALUES (39, 124, 222, 38);
INSERT INTO public.part_stock_quantity VALUES (40, 124, 223, 35);
INSERT INTO public.part_stock_quantity VALUES (41, 124, 224, 32);
INSERT INTO public.part_stock_quantity VALUES (42, 124, 225, 28);
INSERT INTO public.part_stock_quantity VALUES (43, 124, 226, 25);
INSERT INTO public.part_stock_quantity VALUES (44, 124, 227, 22);
INSERT INTO public.part_stock_quantity VALUES (45, 124, 228, 18);
INSERT INTO public.part_stock_quantity VALUES (46, 124, 229, 15);
INSERT INTO public.part_stock_quantity VALUES (47, 124, 230, 12);
INSERT INTO public.part_stock_quantity VALUES (48, 124, 231, 10);
INSERT INTO public.part_stock_quantity VALUES (49, 124, 232, 8);
INSERT INTO public.part_stock_quantity VALUES (50, 124, 233, 6);
INSERT INTO public.part_stock_quantity VALUES (51, 124, 234, 4);
INSERT INTO public.part_stock_quantity VALUES (52, 124, 235, 3);
INSERT INTO public.part_stock_quantity VALUES (53, 124, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (54, 124, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (55, 124, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (56, 125, 201, 4);
INSERT INTO public.part_stock_quantity VALUES (57, 125, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (58, 125, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (59, 125, 204, 20);
INSERT INTO public.part_stock_quantity VALUES (60, 125, 205, 40);
INSERT INTO public.part_stock_quantity VALUES (61, 125, 206, 22);
INSERT INTO public.part_stock_quantity VALUES (62, 125, 207, 15);
INSERT INTO public.part_stock_quantity VALUES (63, 125, 208, 18);
INSERT INTO public.part_stock_quantity VALUES (64, 125, 209, 5);
INSERT INTO public.part_stock_quantity VALUES (65, 125, 210, 35);
INSERT INTO public.part_stock_quantity VALUES (66, 125, 211, 4);
INSERT INTO public.part_stock_quantity VALUES (67, 125, 212, 25);
INSERT INTO public.part_stock_quantity VALUES (68, 125, 213, 28);
INSERT INTO public.part_stock_quantity VALUES (69, 125, 214, 5);
INSERT INTO public.part_stock_quantity VALUES (70, 125, 215, 20);
INSERT INTO public.part_stock_quantity VALUES (71, 125, 216, 45);
INSERT INTO public.part_stock_quantity VALUES (72, 125, 217, 38);
INSERT INTO public.part_stock_quantity VALUES (73, 125, 218, 5);
INSERT INTO public.part_stock_quantity VALUES (74, 125, 219, 42);
INSERT INTO public.part_stock_quantity VALUES (75, 125, 220, 30);
INSERT INTO public.part_stock_quantity VALUES (76, 125, 221, 26);
INSERT INTO public.part_stock_quantity VALUES (77, 125, 222, 22);
INSERT INTO public.part_stock_quantity VALUES (78, 125, 223, 20);
INSERT INTO public.part_stock_quantity VALUES (79, 125, 224, 18);
INSERT INTO public.part_stock_quantity VALUES (80, 125, 225, 16);
INSERT INTO public.part_stock_quantity VALUES (81, 125, 226, 14);
INSERT INTO public.part_stock_quantity VALUES (82, 125, 227, 12);
INSERT INTO public.part_stock_quantity VALUES (83, 125, 228, 10);
INSERT INTO public.part_stock_quantity VALUES (84, 125, 229, 8);
INSERT INTO public.part_stock_quantity VALUES (85, 125, 230, 6);
INSERT INTO public.part_stock_quantity VALUES (86, 125, 231, 4);
INSERT INTO public.part_stock_quantity VALUES (87, 125, 232, 3);
INSERT INTO public.part_stock_quantity VALUES (88, 125, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (89, 125, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (90, 125, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (91, 126, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (92, 126, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (93, 126, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (94, 126, 204, 18);
INSERT INTO public.part_stock_quantity VALUES (95, 126, 205, 48);
INSERT INTO public.part_stock_quantity VALUES (96, 126, 206, 20);
INSERT INTO public.part_stock_quantity VALUES (97, 126, 207, 13);
INSERT INTO public.part_stock_quantity VALUES (98, 126, 208, 16);
INSERT INTO public.part_stock_quantity VALUES (99, 126, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (100, 126, 210, 40);
INSERT INTO public.part_stock_quantity VALUES (101, 126, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (102, 126, 212, 22);
INSERT INTO public.part_stock_quantity VALUES (103, 126, 213, 25);
INSERT INTO public.part_stock_quantity VALUES (104, 126, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (105, 126, 215, 18);
INSERT INTO public.part_stock_quantity VALUES (106, 126, 216, 50);
INSERT INTO public.part_stock_quantity VALUES (107, 126, 217, 42);
INSERT INTO public.part_stock_quantity VALUES (108, 126, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (109, 126, 219, 45);
INSERT INTO public.part_stock_quantity VALUES (110, 126, 220, 32);
INSERT INTO public.part_stock_quantity VALUES (111, 126, 221, 28);
INSERT INTO public.part_stock_quantity VALUES (112, 126, 222, 24);
INSERT INTO public.part_stock_quantity VALUES (113, 126, 223, 21);
INSERT INTO public.part_stock_quantity VALUES (114, 126, 224, 19);
INSERT INTO public.part_stock_quantity VALUES (115, 126, 225, 17);
INSERT INTO public.part_stock_quantity VALUES (116, 126, 226, 15);
INSERT INTO public.part_stock_quantity VALUES (117, 126, 227, 13);
INSERT INTO public.part_stock_quantity VALUES (118, 126, 228, 11);
INSERT INTO public.part_stock_quantity VALUES (119, 126, 229, 9);
INSERT INTO public.part_stock_quantity VALUES (120, 126, 230, 7);
INSERT INTO public.part_stock_quantity VALUES (121, 126, 231, 5);
INSERT INTO public.part_stock_quantity VALUES (122, 126, 232, 4);
INSERT INTO public.part_stock_quantity VALUES (123, 126, 233, 3);
INSERT INTO public.part_stock_quantity VALUES (124, 126, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (125, 126, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (126, 127, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (127, 127, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (128, 127, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (129, 127, 204, 4);
INSERT INTO public.part_stock_quantity VALUES (130, 127, 206, 4);
INSERT INTO public.part_stock_quantity VALUES (131, 127, 209, 3);
INSERT INTO public.part_stock_quantity VALUES (132, 127, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (133, 127, 214, 3);
INSERT INTO public.part_stock_quantity VALUES (134, 127, 218, 3);
INSERT INTO public.part_stock_quantity VALUES (135, 127, 240, 4);
INSERT INTO public.part_stock_quantity VALUES (136, 127, 241, 3);
INSERT INTO public.part_stock_quantity VALUES (137, 127, 242, 4);
INSERT INTO public.part_stock_quantity VALUES (138, 127, 243, 3);
INSERT INTO public.part_stock_quantity VALUES (139, 127, 244, 4);
INSERT INTO public.part_stock_quantity VALUES (140, 127, 245, 3);
INSERT INTO public.part_stock_quantity VALUES (141, 127, 246, 4);
INSERT INTO public.part_stock_quantity VALUES (142, 127, 247, 3);
INSERT INTO public.part_stock_quantity VALUES (143, 127, 248, 4);
INSERT INTO public.part_stock_quantity VALUES (144, 127, 249, 3);
INSERT INTO public.part_stock_quantity VALUES (145, 127, 250, 4);
INSERT INTO public.part_stock_quantity VALUES (146, 127, 251, 3);
INSERT INTO public.part_stock_quantity VALUES (147, 127, 252, 4);
INSERT INTO public.part_stock_quantity VALUES (148, 127, 253, 3);
INSERT INTO public.part_stock_quantity VALUES (149, 127, 254, 4);
INSERT INTO public.part_stock_quantity VALUES (150, 127, 255, 3);
INSERT INTO public.part_stock_quantity VALUES (151, 127, 256, 4);
INSERT INTO public.part_stock_quantity VALUES (152, 127, 257, 3);
INSERT INTO public.part_stock_quantity VALUES (153, 127, 258, 4);
INSERT INTO public.part_stock_quantity VALUES (154, 127, 259, 3);
INSERT INTO public.part_stock_quantity VALUES (155, 127, 260, 4);
INSERT INTO public.part_stock_quantity VALUES (156, 127, 261, 3);
INSERT INTO public.part_stock_quantity VALUES (157, 127, 262, 4);
INSERT INTO public.part_stock_quantity VALUES (158, 127, 263, 3);
INSERT INTO public.part_stock_quantity VALUES (159, 127, 264, 4);
INSERT INTO public.part_stock_quantity VALUES (160, 127, 265, 3);
INSERT INTO public.part_stock_quantity VALUES (161, 127, 266, 4);
INSERT INTO public.part_stock_quantity VALUES (162, 127, 267, 3);
INSERT INTO public.part_stock_quantity VALUES (163, 127, 268, 4);
INSERT INTO public.part_stock_quantity VALUES (164, 127, 269, 3);
INSERT INTO public.part_stock_quantity VALUES (165, 127, 270, 4);
INSERT INTO public.part_stock_quantity VALUES (166, 127, 271, 3);
INSERT INTO public.part_stock_quantity VALUES (167, 127, 272, 4);
INSERT INTO public.part_stock_quantity VALUES (168, 127, 273, 3);
INSERT INTO public.part_stock_quantity VALUES (169, 127, 274, 4);
INSERT INTO public.part_stock_quantity VALUES (170, 127, 275, 3);
INSERT INTO public.part_stock_quantity VALUES (171, 127, 276, 4);
INSERT INTO public.part_stock_quantity VALUES (172, 127, 277, 3);
INSERT INTO public.part_stock_quantity VALUES (173, 127, 278, 4);
INSERT INTO public.part_stock_quantity VALUES (174, 127, 279, 3);
INSERT INTO public.part_stock_quantity VALUES (175, 127, 280, 4);
INSERT INTO public.part_stock_quantity VALUES (176, 127, 281, 3);
INSERT INTO public.part_stock_quantity VALUES (177, 127, 282, 4);
INSERT INTO public.part_stock_quantity VALUES (178, 127, 283, 3);
INSERT INTO public.part_stock_quantity VALUES (179, 127, 284, 4);
INSERT INTO public.part_stock_quantity VALUES (180, 127, 285, 3);
INSERT INTO public.part_stock_quantity VALUES (181, 127, 286, 4);
INSERT INTO public.part_stock_quantity VALUES (182, 127, 287, 3);
INSERT INTO public.part_stock_quantity VALUES (183, 127, 288, 4);
INSERT INTO public.part_stock_quantity VALUES (184, 127, 289, 3);
INSERT INTO public.part_stock_quantity VALUES (185, 127, 290, 4);
INSERT INTO public.part_stock_quantity VALUES (186, 127, 291, 3);
INSERT INTO public.part_stock_quantity VALUES (187, 127, 292, 4);
INSERT INTO public.part_stock_quantity VALUES (188, 127, 293, 3);
INSERT INTO public.part_stock_quantity VALUES (189, 127, 294, 4);
INSERT INTO public.part_stock_quantity VALUES (190, 127, 295, 3);
INSERT INTO public.part_stock_quantity VALUES (191, 127, 296, 4);
INSERT INTO public.part_stock_quantity VALUES (192, 127, 297, 3);
INSERT INTO public.part_stock_quantity VALUES (193, 127, 298, 4);
INSERT INTO public.part_stock_quantity VALUES (194, 127, 299, 3);
INSERT INTO public.part_stock_quantity VALUES (195, 127, 300, 4);
INSERT INTO public.part_stock_quantity VALUES (196, 127, 301, 3);
INSERT INTO public.part_stock_quantity VALUES (197, 127, 302, 4);
INSERT INTO public.part_stock_quantity VALUES (198, 127, 303, 3);
INSERT INTO public.part_stock_quantity VALUES (199, 127, 304, 4);
INSERT INTO public.part_stock_quantity VALUES (200, 127, 305, 3);
INSERT INTO public.part_stock_quantity VALUES (201, 127, 306, 4);
INSERT INTO public.part_stock_quantity VALUES (202, 127, 307, 3);
INSERT INTO public.part_stock_quantity VALUES (203, 127, 308, 4);
INSERT INTO public.part_stock_quantity VALUES (204, 127, 309, 3);
INSERT INTO public.part_stock_quantity VALUES (205, 127, 310, 4);
INSERT INTO public.part_stock_quantity VALUES (206, 127, 311, 3);
INSERT INTO public.part_stock_quantity VALUES (207, 127, 312, 4);
INSERT INTO public.part_stock_quantity VALUES (208, 127, 313, 3);
INSERT INTO public.part_stock_quantity VALUES (209, 127, 314, 4);
INSERT INTO public.part_stock_quantity VALUES (210, 127, 315, 3);
INSERT INTO public.part_stock_quantity VALUES (211, 127, 316, 4);
INSERT INTO public.part_stock_quantity VALUES (212, 127, 317, 3);
INSERT INTO public.part_stock_quantity VALUES (213, 127, 318, 4);
INSERT INTO public.part_stock_quantity VALUES (214, 127, 319, 3);
INSERT INTO public.part_stock_quantity VALUES (215, 127, 320, 4);
INSERT INTO public.part_stock_quantity VALUES (216, 127, 321, 3);
INSERT INTO public.part_stock_quantity VALUES (217, 127, 322, 4);
INSERT INTO public.part_stock_quantity VALUES (218, 127, 323, 3);
INSERT INTO public.part_stock_quantity VALUES (219, 127, 324, 4);
INSERT INTO public.part_stock_quantity VALUES (220, 127, 325, 3);
INSERT INTO public.part_stock_quantity VALUES (221, 127, 326, 4);
INSERT INTO public.part_stock_quantity VALUES (222, 127, 327, 3);
INSERT INTO public.part_stock_quantity VALUES (223, 128, 201, 2);
INSERT INTO public.part_stock_quantity VALUES (224, 128, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (225, 128, 203, 2);
INSERT INTO public.part_stock_quantity VALUES (226, 128, 204, 3);
INSERT INTO public.part_stock_quantity VALUES (227, 128, 206, 3);
INSERT INTO public.part_stock_quantity VALUES (228, 128, 209, 2);
INSERT INTO public.part_stock_quantity VALUES (229, 128, 211, 2);
INSERT INTO public.part_stock_quantity VALUES (230, 128, 214, 2);
INSERT INTO public.part_stock_quantity VALUES (231, 128, 218, 2);
INSERT INTO public.part_stock_quantity VALUES (232, 128, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (233, 128, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (234, 128, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (235, 128, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (236, 128, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (237, 128, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (238, 128, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (239, 128, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (240, 128, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (241, 128, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (242, 128, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (243, 128, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (244, 128, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (245, 128, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (246, 128, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (247, 128, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (248, 128, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (249, 128, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (250, 128, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (251, 128, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (252, 128, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (253, 128, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (254, 128, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (255, 128, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (256, 128, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (257, 128, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (258, 128, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (259, 128, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (260, 128, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (261, 128, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (262, 128, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (263, 128, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (264, 128, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (265, 128, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (266, 128, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (267, 128, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (268, 128, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (269, 128, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (270, 128, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (271, 128, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (272, 128, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (273, 128, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (274, 128, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (275, 128, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (276, 128, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (277, 128, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (278, 128, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (279, 128, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (280, 128, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (281, 128, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (282, 128, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (283, 128, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (284, 128, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (285, 128, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (286, 128, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (287, 128, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (288, 128, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (289, 128, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (290, 128, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (291, 128, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (292, 128, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (293, 128, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (294, 128, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (295, 128, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (296, 128, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (297, 128, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (298, 128, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (299, 128, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (300, 128, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (301, 128, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (302, 128, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (303, 128, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (304, 128, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (305, 128, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (306, 128, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (307, 128, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (308, 128, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (309, 128, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (310, 128, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (311, 128, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (312, 128, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (313, 128, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (314, 128, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (315, 128, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (316, 128, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (317, 128, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (318, 128, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (319, 128, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (320, 129, 201, 4);
INSERT INTO public.part_stock_quantity VALUES (321, 129, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (322, 129, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (323, 129, 204, 19);
INSERT INTO public.part_stock_quantity VALUES (324, 129, 205, 46);
INSERT INTO public.part_stock_quantity VALUES (325, 129, 206, 21);
INSERT INTO public.part_stock_quantity VALUES (326, 129, 207, 14);
INSERT INTO public.part_stock_quantity VALUES (327, 129, 208, 17);
INSERT INTO public.part_stock_quantity VALUES (328, 129, 209, 5);
INSERT INTO public.part_stock_quantity VALUES (329, 129, 210, 39);
INSERT INTO public.part_stock_quantity VALUES (330, 129, 211, 4);
INSERT INTO public.part_stock_quantity VALUES (331, 129, 212, 23);
INSERT INTO public.part_stock_quantity VALUES (332, 129, 213, 26);
INSERT INTO public.part_stock_quantity VALUES (333, 129, 214, 5);
INSERT INTO public.part_stock_quantity VALUES (334, 129, 215, 19);
INSERT INTO public.part_stock_quantity VALUES (335, 129, 216, 48);
INSERT INTO public.part_stock_quantity VALUES (336, 129, 217, 40);
INSERT INTO public.part_stock_quantity VALUES (337, 129, 218, 5);
INSERT INTO public.part_stock_quantity VALUES (338, 129, 219, 44);
INSERT INTO public.part_stock_quantity VALUES (339, 129, 220, 31);
INSERT INTO public.part_stock_quantity VALUES (340, 129, 221, 27);
INSERT INTO public.part_stock_quantity VALUES (341, 129, 222, 23);
INSERT INTO public.part_stock_quantity VALUES (342, 129, 223, 21);
INSERT INTO public.part_stock_quantity VALUES (343, 129, 224, 19);
INSERT INTO public.part_stock_quantity VALUES (344, 129, 225, 17);
INSERT INTO public.part_stock_quantity VALUES (345, 129, 226, 15);
INSERT INTO public.part_stock_quantity VALUES (346, 129, 227, 13);
INSERT INTO public.part_stock_quantity VALUES (347, 129, 228, 11);
INSERT INTO public.part_stock_quantity VALUES (348, 129, 229, 9);
INSERT INTO public.part_stock_quantity VALUES (349, 129, 230, 7);
INSERT INTO public.part_stock_quantity VALUES (350, 129, 231, 5);
INSERT INTO public.part_stock_quantity VALUES (351, 129, 232, 4);
INSERT INTO public.part_stock_quantity VALUES (352, 129, 233, 3);
INSERT INTO public.part_stock_quantity VALUES (353, 129, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (354, 129, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (355, 129, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (356, 129, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (357, 129, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (358, 129, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (359, 129, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (360, 129, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (361, 129, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (362, 129, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (363, 129, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (364, 129, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (365, 129, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (366, 129, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (367, 129, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (368, 129, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (369, 129, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (370, 129, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (371, 129, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (372, 129, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (373, 129, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (374, 129, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (375, 129, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (376, 129, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (377, 129, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (378, 129, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (379, 129, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (380, 129, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (381, 129, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (382, 129, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (383, 129, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (384, 129, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (385, 129, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (386, 129, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (387, 129, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (388, 129, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (389, 129, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (390, 129, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (391, 129, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (392, 129, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (393, 129, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (394, 129, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (395, 129, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (396, 129, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (397, 129, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (398, 129, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (399, 129, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (400, 129, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (401, 129, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (402, 129, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (403, 129, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (404, 129, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (405, 129, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (406, 129, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (407, 129, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (408, 129, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (409, 129, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (410, 129, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (411, 129, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (412, 129, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (413, 129, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (414, 129, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (415, 129, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (416, 129, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (417, 129, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (418, 129, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (419, 129, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (420, 129, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (421, 129, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (422, 129, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (423, 129, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (424, 129, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (425, 129, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (426, 129, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (427, 129, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (428, 129, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (429, 129, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (430, 129, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (431, 129, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (432, 129, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (433, 129, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (434, 129, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (435, 129, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (436, 129, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (437, 129, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (438, 129, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (439, 129, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (440, 129, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (441, 129, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (442, 129, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (443, 129, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (444, 129, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (445, 129, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (446, 129, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (447, 130, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (448, 130, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (449, 130, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (450, 130, 204, 17);
INSERT INTO public.part_stock_quantity VALUES (451, 130, 205, 43);
INSERT INTO public.part_stock_quantity VALUES (452, 130, 206, 19);
INSERT INTO public.part_stock_quantity VALUES (453, 130, 207, 12);
INSERT INTO public.part_stock_quantity VALUES (454, 130, 208, 15);
INSERT INTO public.part_stock_quantity VALUES (455, 130, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (456, 130, 210, 37);
INSERT INTO public.part_stock_quantity VALUES (457, 130, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (458, 130, 212, 21);
INSERT INTO public.part_stock_quantity VALUES (459, 130, 213, 24);
INSERT INTO public.part_stock_quantity VALUES (460, 130, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (461, 130, 215, 17);
INSERT INTO public.part_stock_quantity VALUES (462, 130, 216, 46);
INSERT INTO public.part_stock_quantity VALUES (463, 130, 217, 39);
INSERT INTO public.part_stock_quantity VALUES (464, 130, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (465, 130, 219, 43);
INSERT INTO public.part_stock_quantity VALUES (466, 130, 220, 29);
INSERT INTO public.part_stock_quantity VALUES (467, 130, 221, 25);
INSERT INTO public.part_stock_quantity VALUES (468, 130, 222, 21);
INSERT INTO public.part_stock_quantity VALUES (469, 130, 223, 19);
INSERT INTO public.part_stock_quantity VALUES (470, 130, 224, 17);
INSERT INTO public.part_stock_quantity VALUES (471, 130, 225, 15);
INSERT INTO public.part_stock_quantity VALUES (472, 130, 226, 13);
INSERT INTO public.part_stock_quantity VALUES (473, 130, 227, 11);
INSERT INTO public.part_stock_quantity VALUES (474, 130, 228, 9);
INSERT INTO public.part_stock_quantity VALUES (475, 130, 229, 7);
INSERT INTO public.part_stock_quantity VALUES (476, 130, 230, 5);
INSERT INTO public.part_stock_quantity VALUES (477, 130, 231, 4);
INSERT INTO public.part_stock_quantity VALUES (478, 130, 232, 3);
INSERT INTO public.part_stock_quantity VALUES (479, 130, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (480, 130, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (481, 130, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (482, 130, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (483, 130, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (484, 130, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (485, 130, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (486, 130, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (487, 130, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (488, 130, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (489, 130, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (490, 130, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (491, 130, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (492, 130, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (493, 130, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (494, 130, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (495, 130, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (496, 130, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (497, 130, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (498, 130, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (499, 130, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (500, 130, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (501, 130, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (502, 130, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (503, 130, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (504, 130, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (505, 130, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (506, 130, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (507, 130, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (508, 130, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (509, 130, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (510, 130, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (511, 130, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (512, 130, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (513, 130, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (514, 130, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (515, 130, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (516, 130, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (517, 130, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (518, 130, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (519, 130, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (520, 130, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (521, 130, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (522, 130, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (523, 130, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (524, 130, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (525, 130, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (526, 130, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (527, 130, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (528, 130, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (529, 130, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (530, 130, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (531, 130, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (532, 130, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (533, 130, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (534, 130, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (535, 130, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (536, 130, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (537, 130, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (538, 130, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (539, 130, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (540, 130, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (541, 130, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (542, 130, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (543, 130, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (544, 130, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (545, 130, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (546, 130, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (547, 130, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (548, 130, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (549, 130, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (550, 130, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (551, 130, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (552, 130, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (553, 130, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (554, 130, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (555, 130, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (556, 130, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (557, 130, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (558, 130, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (559, 130, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (560, 130, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (561, 130, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (562, 130, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (563, 130, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (564, 130, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (565, 130, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (566, 130, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (567, 130, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (568, 130, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (569, 130, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (570, 130, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (571, 130, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (572, 130, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (573, 130, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (574, 131, 201, 4);
INSERT INTO public.part_stock_quantity VALUES (575, 131, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (576, 131, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (577, 131, 204, 18);
INSERT INTO public.part_stock_quantity VALUES (578, 131, 205, 44);
INSERT INTO public.part_stock_quantity VALUES (579, 131, 206, 20);
INSERT INTO public.part_stock_quantity VALUES (580, 131, 207, 13);
INSERT INTO public.part_stock_quantity VALUES (581, 131, 208, 16);
INSERT INTO public.part_stock_quantity VALUES (582, 131, 209, 5);
INSERT INTO public.part_stock_quantity VALUES (583, 131, 210, 38);
INSERT INTO public.part_stock_quantity VALUES (584, 131, 211, 4);
INSERT INTO public.part_stock_quantity VALUES (585, 131, 212, 22);
INSERT INTO public.part_stock_quantity VALUES (586, 131, 213, 25);
INSERT INTO public.part_stock_quantity VALUES (587, 131, 214, 5);
INSERT INTO public.part_stock_quantity VALUES (588, 131, 215, 18);
INSERT INTO public.part_stock_quantity VALUES (589, 131, 216, 47);
INSERT INTO public.part_stock_quantity VALUES (590, 131, 217, 40);
INSERT INTO public.part_stock_quantity VALUES (591, 131, 218, 5);
INSERT INTO public.part_stock_quantity VALUES (592, 131, 219, 44);
INSERT INTO public.part_stock_quantity VALUES (593, 131, 220, 30);
INSERT INTO public.part_stock_quantity VALUES (594, 131, 221, 26);
INSERT INTO public.part_stock_quantity VALUES (595, 131, 222, 22);
INSERT INTO public.part_stock_quantity VALUES (596, 131, 223, 20);
INSERT INTO public.part_stock_quantity VALUES (597, 131, 224, 18);
INSERT INTO public.part_stock_quantity VALUES (598, 131, 225, 16);
INSERT INTO public.part_stock_quantity VALUES (599, 131, 226, 14);
INSERT INTO public.part_stock_quantity VALUES (600, 131, 227, 12);
INSERT INTO public.part_stock_quantity VALUES (601, 131, 228, 10);
INSERT INTO public.part_stock_quantity VALUES (602, 131, 229, 8);
INSERT INTO public.part_stock_quantity VALUES (603, 131, 230, 6);
INSERT INTO public.part_stock_quantity VALUES (604, 131, 231, 4);
INSERT INTO public.part_stock_quantity VALUES (605, 131, 232, 3);
INSERT INTO public.part_stock_quantity VALUES (606, 131, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (607, 131, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (608, 131, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (609, 131, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (610, 131, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (611, 131, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (612, 131, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (613, 131, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (614, 131, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (615, 131, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (616, 131, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (617, 131, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (618, 131, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (619, 131, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (620, 131, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (621, 131, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (622, 131, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (623, 131, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (624, 131, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (625, 131, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (626, 131, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (627, 131, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (628, 131, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (629, 131, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (630, 131, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (631, 131, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (632, 131, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (633, 131, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (634, 131, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (635, 131, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (636, 131, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (637, 131, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (638, 131, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (639, 131, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (640, 131, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (641, 131, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (642, 131, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (643, 131, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (644, 131, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (645, 131, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (646, 131, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (647, 131, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (648, 131, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (649, 131, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (650, 131, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (651, 131, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (652, 131, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (653, 131, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (654, 131, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (655, 131, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (656, 131, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (657, 131, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (658, 131, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (659, 131, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (660, 131, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (661, 131, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (662, 131, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (663, 131, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (664, 131, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (665, 131, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (666, 131, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (667, 131, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (668, 131, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (669, 131, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (670, 131, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (671, 131, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (672, 131, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (673, 131, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (674, 131, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (675, 131, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (676, 131, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (677, 131, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (678, 131, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (679, 131, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (680, 131, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (681, 131, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (682, 131, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (683, 131, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (684, 131, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (685, 131, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (686, 131, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (687, 131, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (688, 131, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (689, 131, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (690, 131, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (691, 131, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (692, 131, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (693, 131, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (694, 131, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (695, 131, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (696, 131, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (697, 131, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (698, 131, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (699, 131, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (700, 131, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (701, 132, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (702, 132, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (703, 132, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (704, 132, 204, 16);
INSERT INTO public.part_stock_quantity VALUES (705, 132, 205, 42);
INSERT INTO public.part_stock_quantity VALUES (706, 132, 206, 18);
INSERT INTO public.part_stock_quantity VALUES (707, 132, 207, 11);
INSERT INTO public.part_stock_quantity VALUES (708, 132, 208, 14);
INSERT INTO public.part_stock_quantity VALUES (709, 132, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (710, 132, 210, 36);
INSERT INTO public.part_stock_quantity VALUES (711, 132, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (712, 132, 212, 20);
INSERT INTO public.part_stock_quantity VALUES (713, 132, 213, 23);
INSERT INTO public.part_stock_quantity VALUES (714, 132, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (715, 132, 215, 16);
INSERT INTO public.part_stock_quantity VALUES (716, 132, 216, 45);
INSERT INTO public.part_stock_quantity VALUES (717, 132, 217, 38);
INSERT INTO public.part_stock_quantity VALUES (718, 132, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (719, 132, 219, 42);
INSERT INTO public.part_stock_quantity VALUES (720, 132, 220, 28);
INSERT INTO public.part_stock_quantity VALUES (721, 132, 221, 24);
INSERT INTO public.part_stock_quantity VALUES (722, 132, 222, 20);
INSERT INTO public.part_stock_quantity VALUES (723, 132, 223, 18);
INSERT INTO public.part_stock_quantity VALUES (724, 132, 224, 16);
INSERT INTO public.part_stock_quantity VALUES (725, 132, 225, 14);
INSERT INTO public.part_stock_quantity VALUES (726, 132, 226, 12);
INSERT INTO public.part_stock_quantity VALUES (727, 132, 227, 10);
INSERT INTO public.part_stock_quantity VALUES (728, 132, 228, 8);
INSERT INTO public.part_stock_quantity VALUES (729, 132, 229, 6);
INSERT INTO public.part_stock_quantity VALUES (730, 132, 230, 4);
INSERT INTO public.part_stock_quantity VALUES (731, 132, 231, 3);
INSERT INTO public.part_stock_quantity VALUES (732, 132, 232, 2);
INSERT INTO public.part_stock_quantity VALUES (733, 132, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (734, 132, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (735, 132, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (736, 132, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (737, 132, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (738, 132, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (739, 132, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (740, 132, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (741, 132, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (742, 132, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (743, 132, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (744, 132, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (745, 132, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (746, 132, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (747, 132, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (748, 132, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (749, 132, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (750, 132, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (751, 132, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (752, 132, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (753, 132, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (754, 132, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (755, 132, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (756, 132, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (757, 132, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (758, 132, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (759, 132, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (760, 132, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (761, 132, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (762, 132, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (763, 132, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (764, 132, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (765, 132, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (766, 132, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (767, 132, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (768, 132, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (769, 132, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (770, 132, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (771, 132, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (772, 132, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (773, 132, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (774, 132, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (775, 132, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (776, 132, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (777, 132, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (778, 132, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (779, 132, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (780, 132, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (781, 132, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (782, 132, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (783, 132, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (784, 132, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (785, 132, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (786, 132, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (787, 132, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (788, 132, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (789, 132, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (790, 132, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (791, 132, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (792, 132, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (793, 132, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (794, 132, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (795, 132, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (796, 132, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (797, 132, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (798, 132, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (799, 132, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (800, 132, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (801, 132, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (802, 132, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (803, 132, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (804, 132, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (805, 132, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (806, 132, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (807, 132, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (808, 132, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (809, 132, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (810, 132, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (811, 132, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (812, 132, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (813, 132, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (814, 132, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (815, 132, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (816, 132, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (817, 132, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (818, 132, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (819, 132, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (820, 132, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (821, 132, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (822, 132, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (823, 132, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (824, 132, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (825, 132, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (826, 132, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (827, 132, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (828, 133, 201, 2);
INSERT INTO public.part_stock_quantity VALUES (829, 133, 205, 50);
INSERT INTO public.part_stock_quantity VALUES (830, 133, 210, 46);
INSERT INTO public.part_stock_quantity VALUES (831, 133, 216, 53);
INSERT INTO public.part_stock_quantity VALUES (832, 133, 217, 48);
INSERT INTO public.part_stock_quantity VALUES (833, 133, 219, 56);
INSERT INTO public.part_stock_quantity VALUES (834, 133, 220, 43);
INSERT INTO public.part_stock_quantity VALUES (835, 133, 221, 40);
INSERT INTO public.part_stock_quantity VALUES (836, 133, 222, 36);
INSERT INTO public.part_stock_quantity VALUES (837, 133, 223, 33);
INSERT INTO public.part_stock_quantity VALUES (838, 133, 224, 30);
INSERT INTO public.part_stock_quantity VALUES (839, 133, 225, 26);
INSERT INTO public.part_stock_quantity VALUES (840, 133, 226, 23);
INSERT INTO public.part_stock_quantity VALUES (841, 133, 227, 20);
INSERT INTO public.part_stock_quantity VALUES (842, 133, 228, 16);
INSERT INTO public.part_stock_quantity VALUES (843, 133, 229, 13);
INSERT INTO public.part_stock_quantity VALUES (844, 133, 230, 10);
INSERT INTO public.part_stock_quantity VALUES (845, 133, 231, 8);
INSERT INTO public.part_stock_quantity VALUES (846, 133, 232, 6);
INSERT INTO public.part_stock_quantity VALUES (847, 133, 233, 4);
INSERT INTO public.part_stock_quantity VALUES (848, 133, 234, 3);
INSERT INTO public.part_stock_quantity VALUES (849, 133, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (850, 133, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (851, 133, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (852, 133, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (853, 133, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (854, 133, 240, 2);
INSERT INTO public.part_stock_quantity VALUES (855, 133, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (856, 133, 242, 2);
INSERT INTO public.part_stock_quantity VALUES (857, 133, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (858, 133, 244, 2);
INSERT INTO public.part_stock_quantity VALUES (859, 133, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (860, 133, 246, 2);
INSERT INTO public.part_stock_quantity VALUES (861, 133, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (862, 133, 248, 2);
INSERT INTO public.part_stock_quantity VALUES (863, 133, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (864, 133, 250, 2);
INSERT INTO public.part_stock_quantity VALUES (865, 133, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (866, 133, 252, 2);
INSERT INTO public.part_stock_quantity VALUES (867, 133, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (868, 133, 254, 2);
INSERT INTO public.part_stock_quantity VALUES (869, 133, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (870, 133, 256, 2);
INSERT INTO public.part_stock_quantity VALUES (871, 133, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (872, 133, 258, 2);
INSERT INTO public.part_stock_quantity VALUES (873, 133, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (874, 133, 260, 2);
INSERT INTO public.part_stock_quantity VALUES (875, 133, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (876, 133, 262, 2);
INSERT INTO public.part_stock_quantity VALUES (877, 133, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (878, 133, 264, 2);
INSERT INTO public.part_stock_quantity VALUES (879, 133, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (880, 133, 266, 2);
INSERT INTO public.part_stock_quantity VALUES (881, 133, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (882, 133, 268, 2);
INSERT INTO public.part_stock_quantity VALUES (883, 133, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (884, 133, 270, 2);
INSERT INTO public.part_stock_quantity VALUES (885, 133, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (886, 133, 272, 2);
INSERT INTO public.part_stock_quantity VALUES (887, 133, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (888, 133, 274, 2);
INSERT INTO public.part_stock_quantity VALUES (889, 133, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (890, 133, 276, 2);
INSERT INTO public.part_stock_quantity VALUES (891, 133, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (892, 133, 278, 2);
INSERT INTO public.part_stock_quantity VALUES (893, 133, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (894, 133, 280, 2);
INSERT INTO public.part_stock_quantity VALUES (895, 133, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (896, 133, 282, 2);
INSERT INTO public.part_stock_quantity VALUES (897, 133, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (898, 133, 284, 2);
INSERT INTO public.part_stock_quantity VALUES (899, 133, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (900, 133, 286, 2);
INSERT INTO public.part_stock_quantity VALUES (901, 133, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (902, 133, 288, 2);
INSERT INTO public.part_stock_quantity VALUES (903, 133, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (904, 133, 290, 2);
INSERT INTO public.part_stock_quantity VALUES (905, 133, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (906, 133, 292, 2);
INSERT INTO public.part_stock_quantity VALUES (907, 133, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (908, 133, 294, 2);
INSERT INTO public.part_stock_quantity VALUES (909, 133, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (910, 133, 296, 2);
INSERT INTO public.part_stock_quantity VALUES (911, 133, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (912, 133, 298, 2);
INSERT INTO public.part_stock_quantity VALUES (913, 133, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (914, 133, 300, 2);
INSERT INTO public.part_stock_quantity VALUES (915, 133, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (916, 133, 302, 2);
INSERT INTO public.part_stock_quantity VALUES (917, 133, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (918, 133, 304, 2);
INSERT INTO public.part_stock_quantity VALUES (919, 133, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (920, 133, 306, 2);
INSERT INTO public.part_stock_quantity VALUES (921, 133, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (922, 133, 308, 2);
INSERT INTO public.part_stock_quantity VALUES (923, 133, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (924, 133, 310, 2);
INSERT INTO public.part_stock_quantity VALUES (925, 133, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (926, 133, 312, 2);
INSERT INTO public.part_stock_quantity VALUES (927, 133, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (928, 133, 314, 2);
INSERT INTO public.part_stock_quantity VALUES (929, 133, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (930, 133, 316, 2);
INSERT INTO public.part_stock_quantity VALUES (931, 133, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (932, 133, 318, 2);
INSERT INTO public.part_stock_quantity VALUES (933, 133, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (934, 133, 320, 2);
INSERT INTO public.part_stock_quantity VALUES (935, 133, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (936, 133, 322, 2);
INSERT INTO public.part_stock_quantity VALUES (937, 133, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (938, 133, 324, 2);
INSERT INTO public.part_stock_quantity VALUES (939, 133, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (940, 133, 326, 2);
INSERT INTO public.part_stock_quantity VALUES (941, 133, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (942, 134, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (943, 134, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (944, 134, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (945, 134, 204, 17);
INSERT INTO public.part_stock_quantity VALUES (946, 134, 205, 41);
INSERT INTO public.part_stock_quantity VALUES (947, 134, 206, 19);
INSERT INTO public.part_stock_quantity VALUES (948, 134, 207, 12);
INSERT INTO public.part_stock_quantity VALUES (949, 134, 208, 15);
INSERT INTO public.part_stock_quantity VALUES (950, 134, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (951, 134, 210, 35);
INSERT INTO public.part_stock_quantity VALUES (952, 134, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (953, 134, 212, 21);
INSERT INTO public.part_stock_quantity VALUES (954, 134, 213, 24);
INSERT INTO public.part_stock_quantity VALUES (955, 134, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (956, 134, 215, 17);
INSERT INTO public.part_stock_quantity VALUES (957, 134, 216, 44);
INSERT INTO public.part_stock_quantity VALUES (958, 134, 217, 37);
INSERT INTO public.part_stock_quantity VALUES (959, 134, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (960, 134, 219, 41);
INSERT INTO public.part_stock_quantity VALUES (961, 134, 220, 27);
INSERT INTO public.part_stock_quantity VALUES (962, 134, 221, 23);
INSERT INTO public.part_stock_quantity VALUES (963, 134, 222, 19);
INSERT INTO public.part_stock_quantity VALUES (964, 134, 223, 17);
INSERT INTO public.part_stock_quantity VALUES (965, 134, 224, 15);
INSERT INTO public.part_stock_quantity VALUES (966, 134, 225, 13);
INSERT INTO public.part_stock_quantity VALUES (967, 134, 226, 11);
INSERT INTO public.part_stock_quantity VALUES (968, 134, 227, 9);
INSERT INTO public.part_stock_quantity VALUES (969, 134, 228, 7);
INSERT INTO public.part_stock_quantity VALUES (970, 134, 229, 5);
INSERT INTO public.part_stock_quantity VALUES (971, 134, 230, 4);
INSERT INTO public.part_stock_quantity VALUES (972, 134, 231, 3);
INSERT INTO public.part_stock_quantity VALUES (973, 134, 232, 2);
INSERT INTO public.part_stock_quantity VALUES (974, 134, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (975, 134, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (976, 134, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (977, 134, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (978, 134, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (979, 134, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (980, 134, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (981, 134, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (982, 134, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (983, 134, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (984, 134, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (985, 134, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (986, 134, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (987, 134, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (988, 134, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (989, 134, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (990, 134, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (991, 134, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (992, 134, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (993, 134, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (994, 134, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (995, 134, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (996, 134, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (997, 134, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (998, 134, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (999, 134, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (1000, 134, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (1001, 134, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (1002, 134, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (1003, 134, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (1004, 134, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (1005, 134, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (1006, 134, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (1007, 134, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (1008, 134, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (1009, 134, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (1010, 134, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (1011, 134, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (1012, 134, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (1013, 134, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (1014, 134, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (1015, 134, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (1016, 134, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (1017, 134, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (1018, 134, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (1019, 134, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (1020, 134, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (1021, 134, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (1022, 134, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (1023, 134, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (1024, 134, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (1025, 134, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (1026, 134, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (1027, 134, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (1028, 134, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (1029, 134, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (1030, 134, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (1031, 134, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (1032, 134, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (1033, 134, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (1034, 134, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (1035, 134, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (1036, 134, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (1037, 134, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (1038, 134, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (1039, 134, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (1040, 134, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (1041, 134, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (1042, 134, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (1043, 134, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (1044, 134, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (1045, 134, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (1046, 134, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (1047, 134, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (1048, 134, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (1049, 134, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (1050, 134, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (1051, 134, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (1052, 134, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (1053, 134, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (1054, 134, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (1055, 134, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (1056, 134, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (1057, 134, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (1058, 134, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (1059, 134, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (1060, 134, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (1061, 134, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (1062, 134, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (1063, 134, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (1064, 134, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (1065, 134, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (1066, 134, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (1067, 134, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (1068, 134, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (1069, 135, 201, 4);
INSERT INTO public.part_stock_quantity VALUES (1070, 135, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (1071, 135, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (1072, 135, 204, 19);
INSERT INTO public.part_stock_quantity VALUES (1073, 135, 205, 45);
INSERT INTO public.part_stock_quantity VALUES (1074, 135, 206, 21);
INSERT INTO public.part_stock_quantity VALUES (1075, 135, 207, 14);
INSERT INTO public.part_stock_quantity VALUES (1076, 135, 208, 17);
INSERT INTO public.part_stock_quantity VALUES (1077, 135, 209, 5);
INSERT INTO public.part_stock_quantity VALUES (1078, 135, 210, 39);
INSERT INTO public.part_stock_quantity VALUES (1079, 135, 211, 4);
INSERT INTO public.part_stock_quantity VALUES (1080, 135, 212, 23);
INSERT INTO public.part_stock_quantity VALUES (1081, 135, 213, 26);
INSERT INTO public.part_stock_quantity VALUES (1082, 135, 214, 5);
INSERT INTO public.part_stock_quantity VALUES (1083, 135, 215, 19);
INSERT INTO public.part_stock_quantity VALUES (1084, 135, 216, 47);
INSERT INTO public.part_stock_quantity VALUES (1085, 135, 217, 40);
INSERT INTO public.part_stock_quantity VALUES (1086, 135, 218, 5);
INSERT INTO public.part_stock_quantity VALUES (1087, 135, 219, 43);
INSERT INTO public.part_stock_quantity VALUES (1088, 135, 220, 31);
INSERT INTO public.part_stock_quantity VALUES (1089, 135, 221, 27);
INSERT INTO public.part_stock_quantity VALUES (1090, 135, 222, 23);
INSERT INTO public.part_stock_quantity VALUES (1091, 135, 223, 21);
INSERT INTO public.part_stock_quantity VALUES (1092, 135, 224, 19);
INSERT INTO public.part_stock_quantity VALUES (1093, 135, 225, 17);
INSERT INTO public.part_stock_quantity VALUES (1094, 135, 226, 15);
INSERT INTO public.part_stock_quantity VALUES (1095, 135, 227, 13);
INSERT INTO public.part_stock_quantity VALUES (1096, 135, 228, 11);
INSERT INTO public.part_stock_quantity VALUES (1097, 135, 229, 9);
INSERT INTO public.part_stock_quantity VALUES (1098, 135, 230, 7);
INSERT INTO public.part_stock_quantity VALUES (1099, 135, 231, 5);
INSERT INTO public.part_stock_quantity VALUES (1100, 135, 232, 4);
INSERT INTO public.part_stock_quantity VALUES (1101, 135, 233, 3);
INSERT INTO public.part_stock_quantity VALUES (1102, 135, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (1103, 135, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (1104, 135, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (1105, 135, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (1106, 135, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (1107, 135, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (1108, 135, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (1109, 135, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (1110, 135, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (1111, 135, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (1112, 135, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (1113, 135, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (1114, 135, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (1115, 135, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (1116, 135, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (1117, 135, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (1118, 135, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (1119, 135, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (1120, 135, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (1121, 135, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (1122, 135, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (1123, 135, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (1124, 135, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (1125, 135, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (1126, 135, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (1127, 135, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (1128, 135, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (1129, 135, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (1130, 135, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (1131, 135, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (1132, 135, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (1133, 135, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (1134, 135, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (1135, 135, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (1136, 135, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (1137, 135, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (1138, 135, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (1139, 135, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (1140, 135, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (1141, 135, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (1142, 135, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (1143, 135, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (1144, 135, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (1145, 135, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (1146, 135, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (1147, 135, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (1148, 135, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (1149, 135, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (1150, 135, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (1151, 135, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (1152, 135, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (1153, 135, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (1154, 135, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (1155, 135, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (1156, 135, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (1157, 135, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (1158, 135, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (1159, 135, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (1160, 135, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (1161, 135, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (1162, 135, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (1163, 135, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (1164, 135, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (1165, 135, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (1166, 135, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (1167, 135, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (1168, 135, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (1169, 135, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (1170, 135, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (1171, 135, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (1172, 135, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (1173, 135, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (1174, 135, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (1175, 135, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (1176, 135, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (1177, 135, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (1178, 135, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (1179, 135, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (1180, 135, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (1181, 135, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (1182, 135, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (1183, 135, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (1184, 135, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (1185, 135, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (1186, 135, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (1187, 135, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (1188, 135, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (1189, 135, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (1190, 135, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (1191, 135, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (1192, 135, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (1193, 135, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (1194, 135, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (1195, 135, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (1196, 136, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (1197, 136, 202, 3);
INSERT INTO public.part_stock_quantity VALUES (1198, 136, 203, 4);
INSERT INTO public.part_stock_quantity VALUES (1199, 136, 204, 4);
INSERT INTO public.part_stock_quantity VALUES (1200, 136, 206, 4);
INSERT INTO public.part_stock_quantity VALUES (1201, 136, 209, 3);
INSERT INTO public.part_stock_quantity VALUES (1202, 136, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (1203, 136, 214, 3);
INSERT INTO public.part_stock_quantity VALUES (1204, 136, 218, 3);
INSERT INTO public.part_stock_quantity VALUES (1205, 136, 240, 4);
INSERT INTO public.part_stock_quantity VALUES (1206, 136, 241, 3);
INSERT INTO public.part_stock_quantity VALUES (1207, 136, 242, 4);
INSERT INTO public.part_stock_quantity VALUES (1208, 136, 243, 3);
INSERT INTO public.part_stock_quantity VALUES (1209, 136, 244, 4);
INSERT INTO public.part_stock_quantity VALUES (1210, 136, 245, 3);
INSERT INTO public.part_stock_quantity VALUES (1211, 136, 246, 4);
INSERT INTO public.part_stock_quantity VALUES (1212, 136, 247, 3);
INSERT INTO public.part_stock_quantity VALUES (1213, 136, 248, 4);
INSERT INTO public.part_stock_quantity VALUES (1214, 136, 249, 3);
INSERT INTO public.part_stock_quantity VALUES (1215, 136, 250, 4);
INSERT INTO public.part_stock_quantity VALUES (1216, 136, 251, 3);
INSERT INTO public.part_stock_quantity VALUES (1217, 136, 252, 4);
INSERT INTO public.part_stock_quantity VALUES (1218, 136, 253, 3);
INSERT INTO public.part_stock_quantity VALUES (1219, 136, 254, 4);
INSERT INTO public.part_stock_quantity VALUES (1220, 136, 255, 3);
INSERT INTO public.part_stock_quantity VALUES (1221, 136, 256, 4);
INSERT INTO public.part_stock_quantity VALUES (1222, 136, 257, 3);
INSERT INTO public.part_stock_quantity VALUES (1223, 136, 258, 4);
INSERT INTO public.part_stock_quantity VALUES (1224, 136, 259, 3);
INSERT INTO public.part_stock_quantity VALUES (1225, 136, 260, 4);
INSERT INTO public.part_stock_quantity VALUES (1226, 136, 261, 3);
INSERT INTO public.part_stock_quantity VALUES (1227, 136, 262, 4);
INSERT INTO public.part_stock_quantity VALUES (1228, 136, 263, 3);
INSERT INTO public.part_stock_quantity VALUES (1229, 136, 264, 4);
INSERT INTO public.part_stock_quantity VALUES (1230, 136, 265, 3);
INSERT INTO public.part_stock_quantity VALUES (1231, 136, 266, 4);
INSERT INTO public.part_stock_quantity VALUES (1232, 136, 267, 3);
INSERT INTO public.part_stock_quantity VALUES (1233, 136, 268, 4);
INSERT INTO public.part_stock_quantity VALUES (1234, 136, 269, 3);
INSERT INTO public.part_stock_quantity VALUES (1235, 136, 270, 4);
INSERT INTO public.part_stock_quantity VALUES (1236, 136, 271, 3);
INSERT INTO public.part_stock_quantity VALUES (1237, 136, 272, 4);
INSERT INTO public.part_stock_quantity VALUES (1238, 136, 273, 3);
INSERT INTO public.part_stock_quantity VALUES (1239, 136, 274, 4);
INSERT INTO public.part_stock_quantity VALUES (1240, 136, 275, 3);
INSERT INTO public.part_stock_quantity VALUES (1241, 136, 276, 4);
INSERT INTO public.part_stock_quantity VALUES (1242, 136, 277, 3);
INSERT INTO public.part_stock_quantity VALUES (1243, 136, 278, 4);
INSERT INTO public.part_stock_quantity VALUES (1244, 136, 279, 3);
INSERT INTO public.part_stock_quantity VALUES (1245, 136, 280, 4);
INSERT INTO public.part_stock_quantity VALUES (1246, 136, 281, 3);
INSERT INTO public.part_stock_quantity VALUES (1247, 136, 282, 4);
INSERT INTO public.part_stock_quantity VALUES (1248, 136, 283, 3);
INSERT INTO public.part_stock_quantity VALUES (1249, 136, 284, 4);
INSERT INTO public.part_stock_quantity VALUES (1250, 136, 285, 3);
INSERT INTO public.part_stock_quantity VALUES (1251, 136, 286, 4);
INSERT INTO public.part_stock_quantity VALUES (1252, 136, 287, 3);
INSERT INTO public.part_stock_quantity VALUES (1253, 136, 288, 4);
INSERT INTO public.part_stock_quantity VALUES (1254, 136, 289, 3);
INSERT INTO public.part_stock_quantity VALUES (1255, 136, 290, 4);
INSERT INTO public.part_stock_quantity VALUES (1256, 136, 291, 3);
INSERT INTO public.part_stock_quantity VALUES (1257, 136, 292, 4);
INSERT INTO public.part_stock_quantity VALUES (1258, 136, 293, 3);
INSERT INTO public.part_stock_quantity VALUES (1259, 136, 294, 4);
INSERT INTO public.part_stock_quantity VALUES (1260, 136, 295, 3);
INSERT INTO public.part_stock_quantity VALUES (1261, 136, 296, 4);
INSERT INTO public.part_stock_quantity VALUES (1262, 136, 297, 3);
INSERT INTO public.part_stock_quantity VALUES (1263, 136, 298, 4);
INSERT INTO public.part_stock_quantity VALUES (1264, 136, 299, 3);
INSERT INTO public.part_stock_quantity VALUES (1265, 136, 300, 4);
INSERT INTO public.part_stock_quantity VALUES (1266, 136, 301, 3);
INSERT INTO public.part_stock_quantity VALUES (1267, 136, 302, 4);
INSERT INTO public.part_stock_quantity VALUES (1268, 136, 303, 3);
INSERT INTO public.part_stock_quantity VALUES (1269, 136, 304, 4);
INSERT INTO public.part_stock_quantity VALUES (1270, 136, 305, 3);
INSERT INTO public.part_stock_quantity VALUES (1271, 136, 306, 4);
INSERT INTO public.part_stock_quantity VALUES (1272, 136, 307, 3);
INSERT INTO public.part_stock_quantity VALUES (1273, 136, 308, 4);
INSERT INTO public.part_stock_quantity VALUES (1274, 136, 309, 3);
INSERT INTO public.part_stock_quantity VALUES (1275, 136, 310, 4);
INSERT INTO public.part_stock_quantity VALUES (1276, 136, 311, 3);
INSERT INTO public.part_stock_quantity VALUES (1277, 136, 312, 4);
INSERT INTO public.part_stock_quantity VALUES (1278, 136, 313, 3);
INSERT INTO public.part_stock_quantity VALUES (1279, 136, 314, 4);
INSERT INTO public.part_stock_quantity VALUES (1280, 136, 315, 3);
INSERT INTO public.part_stock_quantity VALUES (1281, 136, 316, 4);
INSERT INTO public.part_stock_quantity VALUES (1282, 136, 317, 3);
INSERT INTO public.part_stock_quantity VALUES (1283, 136, 318, 4);
INSERT INTO public.part_stock_quantity VALUES (1284, 136, 319, 3);
INSERT INTO public.part_stock_quantity VALUES (1285, 136, 320, 4);
INSERT INTO public.part_stock_quantity VALUES (1286, 136, 321, 3);
INSERT INTO public.part_stock_quantity VALUES (1287, 136, 322, 4);
INSERT INTO public.part_stock_quantity VALUES (1288, 136, 323, 3);
INSERT INTO public.part_stock_quantity VALUES (1289, 136, 324, 4);
INSERT INTO public.part_stock_quantity VALUES (1290, 136, 325, 3);
INSERT INTO public.part_stock_quantity VALUES (1291, 136, 326, 4);
INSERT INTO public.part_stock_quantity VALUES (1292, 136, 327, 3);
INSERT INTO public.part_stock_quantity VALUES (1293, 137, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (1294, 137, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (1295, 137, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (1296, 137, 204, 16);
INSERT INTO public.part_stock_quantity VALUES (1297, 137, 205, 42);
INSERT INTO public.part_stock_quantity VALUES (1298, 137, 206, 18);
INSERT INTO public.part_stock_quantity VALUES (1299, 137, 207, 11);
INSERT INTO public.part_stock_quantity VALUES (1300, 137, 208, 14);
INSERT INTO public.part_stock_quantity VALUES (1301, 137, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (1302, 137, 210, 36);
INSERT INTO public.part_stock_quantity VALUES (1303, 137, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (1304, 137, 212, 20);
INSERT INTO public.part_stock_quantity VALUES (1305, 137, 213, 23);
INSERT INTO public.part_stock_quantity VALUES (1306, 137, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (1307, 137, 215, 16);
INSERT INTO public.part_stock_quantity VALUES (1308, 137, 216, 45);
INSERT INTO public.part_stock_quantity VALUES (1309, 137, 217, 38);
INSERT INTO public.part_stock_quantity VALUES (1310, 137, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (1311, 137, 219, 42);
INSERT INTO public.part_stock_quantity VALUES (1312, 137, 220, 28);
INSERT INTO public.part_stock_quantity VALUES (1313, 137, 221, 24);
INSERT INTO public.part_stock_quantity VALUES (1314, 137, 222, 20);
INSERT INTO public.part_stock_quantity VALUES (1315, 137, 223, 18);
INSERT INTO public.part_stock_quantity VALUES (1316, 137, 224, 16);
INSERT INTO public.part_stock_quantity VALUES (1317, 137, 225, 14);
INSERT INTO public.part_stock_quantity VALUES (1318, 137, 226, 12);
INSERT INTO public.part_stock_quantity VALUES (1319, 137, 227, 10);
INSERT INTO public.part_stock_quantity VALUES (1320, 137, 228, 8);
INSERT INTO public.part_stock_quantity VALUES (1321, 137, 229, 6);
INSERT INTO public.part_stock_quantity VALUES (1322, 137, 230, 4);
INSERT INTO public.part_stock_quantity VALUES (1323, 137, 231, 3);
INSERT INTO public.part_stock_quantity VALUES (1324, 137, 232, 2);
INSERT INTO public.part_stock_quantity VALUES (1325, 137, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (1326, 137, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (1327, 137, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (1328, 137, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (1329, 137, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (1330, 137, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (1331, 137, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (1332, 137, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (1333, 137, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (1334, 137, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (1335, 137, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (1336, 137, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (1337, 137, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (1338, 137, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (1339, 137, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (1340, 137, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (1341, 137, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (1342, 137, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (1343, 137, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (1344, 137, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (1345, 137, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (1346, 137, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (1347, 137, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (1348, 137, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (1349, 137, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (1350, 137, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (1351, 137, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (1352, 137, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (1353, 137, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (1354, 137, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (1355, 137, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (1356, 137, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (1357, 137, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (1358, 137, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (1359, 137, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (1360, 137, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (1361, 137, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (1362, 137, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (1363, 137, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (1364, 137, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (1365, 137, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (1366, 137, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (1367, 137, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (1368, 137, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (1369, 137, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (1370, 137, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (1371, 137, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (1372, 137, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (1373, 137, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (1374, 137, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (1375, 137, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (1376, 137, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (1377, 137, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (1378, 137, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (1379, 137, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (1380, 137, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (1381, 137, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (1382, 137, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (1383, 137, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (1384, 137, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (1385, 137, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (1386, 137, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (1387, 137, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (1388, 137, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (1389, 137, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (1390, 137, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (1391, 137, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (1392, 137, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (1393, 137, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (1394, 137, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (1395, 137, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (1396, 137, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (1397, 137, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (1398, 137, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (1399, 137, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (1400, 137, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (1401, 137, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (1402, 137, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (1403, 137, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (1404, 137, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (1405, 137, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (1406, 137, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (1407, 137, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (1408, 137, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (1409, 137, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (1410, 137, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (1411, 137, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (1412, 137, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (1413, 137, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (1414, 137, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (1415, 137, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (1416, 137, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (1417, 137, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (1418, 137, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (1419, 137, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (1420, 138, 205, 51);
INSERT INTO public.part_stock_quantity VALUES (1421, 138, 210, 47);
INSERT INTO public.part_stock_quantity VALUES (1422, 138, 216, 54);
INSERT INTO public.part_stock_quantity VALUES (1423, 138, 217, 49);
INSERT INTO public.part_stock_quantity VALUES (1424, 138, 219, 57);
INSERT INTO public.part_stock_quantity VALUES (1425, 138, 220, 44);
INSERT INTO public.part_stock_quantity VALUES (1426, 138, 221, 41);
INSERT INTO public.part_stock_quantity VALUES (1427, 138, 222, 37);
INSERT INTO public.part_stock_quantity VALUES (1428, 138, 223, 34);
INSERT INTO public.part_stock_quantity VALUES (1429, 138, 224, 31);
INSERT INTO public.part_stock_quantity VALUES (1430, 138, 225, 27);
INSERT INTO public.part_stock_quantity VALUES (1431, 138, 226, 24);
INSERT INTO public.part_stock_quantity VALUES (1432, 138, 227, 21);
INSERT INTO public.part_stock_quantity VALUES (1433, 138, 228, 17);
INSERT INTO public.part_stock_quantity VALUES (1434, 138, 229, 14);
INSERT INTO public.part_stock_quantity VALUES (1435, 138, 230, 11);
INSERT INTO public.part_stock_quantity VALUES (1436, 138, 231, 9);
INSERT INTO public.part_stock_quantity VALUES (1437, 138, 232, 7);
INSERT INTO public.part_stock_quantity VALUES (1438, 138, 233, 5);
INSERT INTO public.part_stock_quantity VALUES (1439, 138, 234, 4);
INSERT INTO public.part_stock_quantity VALUES (1440, 138, 235, 3);
INSERT INTO public.part_stock_quantity VALUES (1441, 138, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (1442, 138, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (1443, 138, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (1444, 138, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (1445, 138, 240, 2);
INSERT INTO public.part_stock_quantity VALUES (1446, 138, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (1447, 138, 242, 2);
INSERT INTO public.part_stock_quantity VALUES (1448, 138, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (1449, 138, 244, 2);
INSERT INTO public.part_stock_quantity VALUES (1450, 138, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (1451, 138, 246, 2);
INSERT INTO public.part_stock_quantity VALUES (1452, 138, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (1453, 138, 248, 2);
INSERT INTO public.part_stock_quantity VALUES (1454, 138, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (1455, 138, 250, 2);
INSERT INTO public.part_stock_quantity VALUES (1456, 138, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (1457, 138, 252, 2);
INSERT INTO public.part_stock_quantity VALUES (1458, 138, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (1459, 138, 254, 2);
INSERT INTO public.part_stock_quantity VALUES (1460, 138, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (1461, 138, 256, 2);
INSERT INTO public.part_stock_quantity VALUES (1462, 138, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (1463, 138, 258, 2);
INSERT INTO public.part_stock_quantity VALUES (1464, 138, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (1465, 138, 260, 2);
INSERT INTO public.part_stock_quantity VALUES (1466, 138, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (1467, 138, 262, 2);
INSERT INTO public.part_stock_quantity VALUES (1468, 138, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (1469, 138, 264, 2);
INSERT INTO public.part_stock_quantity VALUES (1470, 138, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (1471, 138, 266, 2);
INSERT INTO public.part_stock_quantity VALUES (1472, 138, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (1473, 138, 268, 2);
INSERT INTO public.part_stock_quantity VALUES (1474, 138, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (1475, 138, 270, 2);
INSERT INTO public.part_stock_quantity VALUES (1476, 138, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (1477, 138, 272, 2);
INSERT INTO public.part_stock_quantity VALUES (1478, 138, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (1479, 138, 274, 2);
INSERT INTO public.part_stock_quantity VALUES (1480, 138, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (1481, 138, 276, 2);
INSERT INTO public.part_stock_quantity VALUES (1482, 138, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (1483, 138, 278, 2);
INSERT INTO public.part_stock_quantity VALUES (1484, 138, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (1485, 138, 280, 2);
INSERT INTO public.part_stock_quantity VALUES (1486, 138, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (1487, 138, 282, 2);
INSERT INTO public.part_stock_quantity VALUES (1488, 138, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (1489, 138, 284, 2);
INSERT INTO public.part_stock_quantity VALUES (1490, 138, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (1491, 138, 286, 2);
INSERT INTO public.part_stock_quantity VALUES (1492, 138, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (1493, 138, 288, 2);
INSERT INTO public.part_stock_quantity VALUES (1494, 138, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (1495, 138, 290, 2);
INSERT INTO public.part_stock_quantity VALUES (1496, 138, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (1497, 138, 292, 2);
INSERT INTO public.part_stock_quantity VALUES (1498, 138, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (1499, 138, 294, 2);
INSERT INTO public.part_stock_quantity VALUES (1500, 138, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (1501, 138, 296, 2);
INSERT INTO public.part_stock_quantity VALUES (1502, 138, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (1503, 138, 298, 2);
INSERT INTO public.part_stock_quantity VALUES (1504, 138, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (1505, 138, 300, 2);
INSERT INTO public.part_stock_quantity VALUES (1506, 138, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (1507, 138, 302, 2);
INSERT INTO public.part_stock_quantity VALUES (1508, 138, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (1509, 138, 304, 2);
INSERT INTO public.part_stock_quantity VALUES (1510, 138, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (1511, 138, 306, 2);
INSERT INTO public.part_stock_quantity VALUES (1512, 138, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (1513, 138, 308, 2);
INSERT INTO public.part_stock_quantity VALUES (1514, 138, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (1515, 138, 310, 2);
INSERT INTO public.part_stock_quantity VALUES (1516, 138, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (1517, 138, 312, 2);
INSERT INTO public.part_stock_quantity VALUES (1518, 138, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (1519, 138, 314, 2);
INSERT INTO public.part_stock_quantity VALUES (1520, 138, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (1521, 138, 316, 2);
INSERT INTO public.part_stock_quantity VALUES (1522, 138, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (1523, 138, 318, 2);
INSERT INTO public.part_stock_quantity VALUES (1524, 138, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (1525, 138, 320, 2);
INSERT INTO public.part_stock_quantity VALUES (1526, 138, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (1527, 138, 322, 2);
INSERT INTO public.part_stock_quantity VALUES (1528, 138, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (1529, 138, 324, 2);
INSERT INTO public.part_stock_quantity VALUES (1530, 138, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (1531, 138, 326, 2);
INSERT INTO public.part_stock_quantity VALUES (1532, 138, 327, 2);
INSERT INTO public.part_stock_quantity VALUES (1533, 139, 201, 3);
INSERT INTO public.part_stock_quantity VALUES (1534, 139, 202, 4);
INSERT INTO public.part_stock_quantity VALUES (1535, 139, 203, 3);
INSERT INTO public.part_stock_quantity VALUES (1536, 139, 204, 17);
INSERT INTO public.part_stock_quantity VALUES (1537, 139, 205, 41);
INSERT INTO public.part_stock_quantity VALUES (1538, 139, 206, 19);
INSERT INTO public.part_stock_quantity VALUES (1539, 139, 207, 12);
INSERT INTO public.part_stock_quantity VALUES (1540, 139, 208, 15);
INSERT INTO public.part_stock_quantity VALUES (1541, 139, 209, 4);
INSERT INTO public.part_stock_quantity VALUES (1542, 139, 210, 35);
INSERT INTO public.part_stock_quantity VALUES (1543, 139, 211, 3);
INSERT INTO public.part_stock_quantity VALUES (1544, 139, 212, 21);
INSERT INTO public.part_stock_quantity VALUES (1545, 139, 213, 24);
INSERT INTO public.part_stock_quantity VALUES (1546, 139, 214, 4);
INSERT INTO public.part_stock_quantity VALUES (1547, 139, 215, 17);
INSERT INTO public.part_stock_quantity VALUES (1548, 139, 216, 44);
INSERT INTO public.part_stock_quantity VALUES (1549, 139, 217, 37);
INSERT INTO public.part_stock_quantity VALUES (1550, 139, 218, 4);
INSERT INTO public.part_stock_quantity VALUES (1551, 139, 219, 41);
INSERT INTO public.part_stock_quantity VALUES (1552, 139, 220, 27);
INSERT INTO public.part_stock_quantity VALUES (1553, 139, 221, 23);
INSERT INTO public.part_stock_quantity VALUES (1554, 139, 222, 19);
INSERT INTO public.part_stock_quantity VALUES (1555, 139, 223, 17);
INSERT INTO public.part_stock_quantity VALUES (1556, 139, 224, 15);
INSERT INTO public.part_stock_quantity VALUES (1557, 139, 225, 13);
INSERT INTO public.part_stock_quantity VALUES (1558, 139, 226, 11);
INSERT INTO public.part_stock_quantity VALUES (1559, 139, 227, 9);
INSERT INTO public.part_stock_quantity VALUES (1560, 139, 228, 7);
INSERT INTO public.part_stock_quantity VALUES (1561, 139, 229, 5);
INSERT INTO public.part_stock_quantity VALUES (1562, 139, 230, 4);
INSERT INTO public.part_stock_quantity VALUES (1563, 139, 231, 3);
INSERT INTO public.part_stock_quantity VALUES (1564, 139, 232, 2);
INSERT INTO public.part_stock_quantity VALUES (1565, 139, 233, 2);
INSERT INTO public.part_stock_quantity VALUES (1566, 139, 234, 2);
INSERT INTO public.part_stock_quantity VALUES (1567, 139, 235, 2);
INSERT INTO public.part_stock_quantity VALUES (1568, 139, 236, 2);
INSERT INTO public.part_stock_quantity VALUES (1569, 139, 237, 2);
INSERT INTO public.part_stock_quantity VALUES (1570, 139, 238, 2);
INSERT INTO public.part_stock_quantity VALUES (1571, 139, 239, 2);
INSERT INTO public.part_stock_quantity VALUES (1572, 139, 240, 3);
INSERT INTO public.part_stock_quantity VALUES (1573, 139, 241, 2);
INSERT INTO public.part_stock_quantity VALUES (1574, 139, 242, 3);
INSERT INTO public.part_stock_quantity VALUES (1575, 139, 243, 2);
INSERT INTO public.part_stock_quantity VALUES (1576, 139, 244, 3);
INSERT INTO public.part_stock_quantity VALUES (1577, 139, 245, 2);
INSERT INTO public.part_stock_quantity VALUES (1578, 139, 246, 3);
INSERT INTO public.part_stock_quantity VALUES (1579, 139, 247, 2);
INSERT INTO public.part_stock_quantity VALUES (1580, 139, 248, 3);
INSERT INTO public.part_stock_quantity VALUES (1581, 139, 249, 2);
INSERT INTO public.part_stock_quantity VALUES (1582, 139, 250, 3);
INSERT INTO public.part_stock_quantity VALUES (1583, 139, 251, 2);
INSERT INTO public.part_stock_quantity VALUES (1584, 139, 252, 3);
INSERT INTO public.part_stock_quantity VALUES (1585, 139, 253, 2);
INSERT INTO public.part_stock_quantity VALUES (1586, 139, 254, 3);
INSERT INTO public.part_stock_quantity VALUES (1587, 139, 255, 2);
INSERT INTO public.part_stock_quantity VALUES (1588, 139, 256, 3);
INSERT INTO public.part_stock_quantity VALUES (1589, 139, 257, 2);
INSERT INTO public.part_stock_quantity VALUES (1590, 139, 258, 3);
INSERT INTO public.part_stock_quantity VALUES (1591, 139, 259, 2);
INSERT INTO public.part_stock_quantity VALUES (1592, 139, 260, 3);
INSERT INTO public.part_stock_quantity VALUES (1593, 139, 261, 2);
INSERT INTO public.part_stock_quantity VALUES (1594, 139, 262, 3);
INSERT INTO public.part_stock_quantity VALUES (1595, 139, 263, 2);
INSERT INTO public.part_stock_quantity VALUES (1596, 139, 264, 3);
INSERT INTO public.part_stock_quantity VALUES (1597, 139, 265, 2);
INSERT INTO public.part_stock_quantity VALUES (1598, 139, 266, 3);
INSERT INTO public.part_stock_quantity VALUES (1599, 139, 267, 2);
INSERT INTO public.part_stock_quantity VALUES (1600, 139, 268, 3);
INSERT INTO public.part_stock_quantity VALUES (1601, 139, 269, 2);
INSERT INTO public.part_stock_quantity VALUES (1602, 139, 270, 3);
INSERT INTO public.part_stock_quantity VALUES (1603, 139, 271, 2);
INSERT INTO public.part_stock_quantity VALUES (1604, 139, 272, 3);
INSERT INTO public.part_stock_quantity VALUES (1605, 139, 273, 2);
INSERT INTO public.part_stock_quantity VALUES (1606, 139, 274, 3);
INSERT INTO public.part_stock_quantity VALUES (1607, 139, 275, 2);
INSERT INTO public.part_stock_quantity VALUES (1608, 139, 276, 3);
INSERT INTO public.part_stock_quantity VALUES (1609, 139, 277, 2);
INSERT INTO public.part_stock_quantity VALUES (1610, 139, 278, 3);
INSERT INTO public.part_stock_quantity VALUES (1611, 139, 279, 2);
INSERT INTO public.part_stock_quantity VALUES (1612, 139, 280, 3);
INSERT INTO public.part_stock_quantity VALUES (1613, 139, 281, 2);
INSERT INTO public.part_stock_quantity VALUES (1614, 139, 282, 3);
INSERT INTO public.part_stock_quantity VALUES (1615, 139, 283, 2);
INSERT INTO public.part_stock_quantity VALUES (1616, 139, 284, 3);
INSERT INTO public.part_stock_quantity VALUES (1617, 139, 285, 2);
INSERT INTO public.part_stock_quantity VALUES (1618, 139, 286, 3);
INSERT INTO public.part_stock_quantity VALUES (1619, 139, 287, 2);
INSERT INTO public.part_stock_quantity VALUES (1620, 139, 288, 3);
INSERT INTO public.part_stock_quantity VALUES (1621, 139, 289, 2);
INSERT INTO public.part_stock_quantity VALUES (1622, 139, 290, 3);
INSERT INTO public.part_stock_quantity VALUES (1623, 139, 291, 2);
INSERT INTO public.part_stock_quantity VALUES (1624, 139, 292, 3);
INSERT INTO public.part_stock_quantity VALUES (1625, 139, 293, 2);
INSERT INTO public.part_stock_quantity VALUES (1626, 139, 294, 3);
INSERT INTO public.part_stock_quantity VALUES (1627, 139, 295, 2);
INSERT INTO public.part_stock_quantity VALUES (1628, 139, 296, 3);
INSERT INTO public.part_stock_quantity VALUES (1629, 139, 297, 2);
INSERT INTO public.part_stock_quantity VALUES (1630, 139, 298, 3);
INSERT INTO public.part_stock_quantity VALUES (1631, 139, 299, 2);
INSERT INTO public.part_stock_quantity VALUES (1632, 139, 300, 3);
INSERT INTO public.part_stock_quantity VALUES (1633, 139, 301, 2);
INSERT INTO public.part_stock_quantity VALUES (1634, 139, 302, 3);
INSERT INTO public.part_stock_quantity VALUES (1635, 139, 303, 2);
INSERT INTO public.part_stock_quantity VALUES (1636, 139, 304, 3);
INSERT INTO public.part_stock_quantity VALUES (1637, 139, 305, 2);
INSERT INTO public.part_stock_quantity VALUES (1638, 139, 306, 3);
INSERT INTO public.part_stock_quantity VALUES (1639, 139, 307, 2);
INSERT INTO public.part_stock_quantity VALUES (1640, 139, 308, 3);
INSERT INTO public.part_stock_quantity VALUES (1641, 139, 309, 2);
INSERT INTO public.part_stock_quantity VALUES (1642, 139, 310, 3);
INSERT INTO public.part_stock_quantity VALUES (1643, 139, 311, 2);
INSERT INTO public.part_stock_quantity VALUES (1644, 139, 312, 3);
INSERT INTO public.part_stock_quantity VALUES (1645, 139, 313, 2);
INSERT INTO public.part_stock_quantity VALUES (1646, 139, 314, 3);
INSERT INTO public.part_stock_quantity VALUES (1647, 139, 315, 2);
INSERT INTO public.part_stock_quantity VALUES (1648, 139, 316, 3);
INSERT INTO public.part_stock_quantity VALUES (1649, 139, 317, 2);
INSERT INTO public.part_stock_quantity VALUES (1650, 139, 318, 3);
INSERT INTO public.part_stock_quantity VALUES (1651, 139, 319, 2);
INSERT INTO public.part_stock_quantity VALUES (1652, 139, 320, 3);
INSERT INTO public.part_stock_quantity VALUES (1653, 139, 321, 2);
INSERT INTO public.part_stock_quantity VALUES (1654, 139, 322, 3);
INSERT INTO public.part_stock_quantity VALUES (1655, 139, 323, 2);
INSERT INTO public.part_stock_quantity VALUES (1656, 139, 324, 3);
INSERT INTO public.part_stock_quantity VALUES (1657, 139, 325, 2);
INSERT INTO public.part_stock_quantity VALUES (1658, 139, 326, 3);
INSERT INTO public.part_stock_quantity VALUES (1659, 139, 327, 2);


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

INSERT INTO public.spare_part VALUES (201, 140, 'Электрооборудование', 'Электродвигатель тяговый ЭД-45У');
INSERT INTO public.spare_part VALUES (202, 140, 'Гидравлическая система', 'Гидрораспределитель секционный ГРС-10П');
INSERT INTO public.spare_part VALUES (203, 140, 'Трансмиссия', 'Редуктор приводной РП-2Э');
INSERT INTO public.spare_part VALUES (204, 141, 'Винтовая пара', 'Блок винтовой компрессии ВП-57');
INSERT INTO public.spare_part VALUES (205, 141, 'Фильтрующий элемент', 'Масляный сепаратор СМ-5/7');
INSERT INTO public.spare_part VALUES (206, 142, 'Гидравлический узел', 'Гидрораспределитель ГР-100');
INSERT INTO public.spare_part VALUES (207, 142, 'Буровой инструмент', 'Штанга буровая ШБ-32×1200');
INSERT INTO public.spare_part VALUES (208, 142, 'Пневмосистема', 'ибропневмоударник ВПУ-100');
INSERT INTO public.spare_part VALUES (209, 143, 'Приводной узел', 'Приводной барабан ПБ-800');
INSERT INTO public.spare_part VALUES (210, 143, 'Лента конвейерная', 'Лента резинотканевая ЛК-800-4PR');
INSERT INTO public.spare_part VALUES (211, 144, 'Электрооборудование', 'Электродвигатель вентиляторный ЭД-7,5');
INSERT INTO public.spare_part VALUES (212, 144, 'Вентиляторный узел', 'Рабочее колесо центробежное РК-4М');
INSERT INTO public.spare_part VALUES (213, 144, 'Система контроля', 'Датчик вибрации ВД-4М');
INSERT INTO public.spare_part VALUES (214, 145, 'Буровой инструмент', 'Буровое долото BD-310');
INSERT INTO public.spare_part VALUES (215, 145, 'Гидравлический узел', 'Гидроцилиндр подачи ГЦ-310');
INSERT INTO public.spare_part VALUES (216, 146, 'Электрическая цепь инициирования', 'Электродетонатор ЭД‑2000');
INSERT INTO public.spare_part VALUES (217, 146, 'Зарядный модуль', 'Подающий картридж ПК‑2000');
INSERT INTO public.spare_part VALUES (218, 147, 'Приводной узел', 'Приводной барабан ПБ-500');
INSERT INTO public.spare_part VALUES (219, 147, 'Лента конвейерная', 'Лента резинотканевая ЛК-500-3PR');
INSERT INTO public.spare_part VALUES (220, 148, 'Дозирующий модуль', 'Узел прецизионного дозирования DM-100');
INSERT INTO public.spare_part VALUES (221, 148, 'Контрольный сенсор', 'Датчик массового потока CF-10');
INSERT INTO public.spare_part VALUES (222, 149, 'Сито вибрационное', 'Комплект сито‑панелей VibeMesh‑400');
INSERT INTO public.spare_part VALUES (223, 149, 'Вибропривод', 'Электровибратор VibeDrive‑18kN');
INSERT INTO public.spare_part VALUES (224, 150, 'Щековой узел', 'Щека подвижная JP-500');
INSERT INTO public.spare_part VALUES (225, 150, 'Приводной механизм', 'Редуктор щековой дробилки RJD-500');
INSERT INTO public.spare_part VALUES (226, 151, 'Приводной узел', 'Приводной барабан ПБ-1000');
INSERT INTO public.spare_part VALUES (227, 151, 'Лента конвейерная', 'Лента резинотканевая ЛК-1000-5PR');
INSERT INTO public.spare_part VALUES (228, 152, 'Сито вибрационное', 'Комплект сито‑панелей VibeMesh‑600');
INSERT INTO public.spare_part VALUES (229, 152, 'Вибропривод', 'Электровибратор VibeDrive‑25kN');
INSERT INTO public.spare_part VALUES (230, 153, 'Флотационный узел', 'Ротор флотационной машины FM-R12');
INSERT INTO public.spare_part VALUES (231, 153, 'Приводной механизм', 'Электродвигатель привода ED-F12');
INSERT INTO public.spare_part VALUES (232, 154, 'Магнитный сепаратор', 'Рабочий барабан MS-800');
INSERT INTO public.spare_part VALUES (233, 154, 'Приводной механизм', 'Электродвигатель привода ED-MS800');
INSERT INTO public.spare_part VALUES (234, 155, 'Насосный узел', 'Рабочее колесо P-200');
INSERT INTO public.spare_part VALUES (235, 155, 'Приводной механизм', 'Электродвигатель ED-P200');
INSERT INTO public.spare_part VALUES (236, 155, 'Герметизирующая система', 'Манжета уплотнительная MU-P200');
INSERT INTO public.spare_part VALUES (237, 156, 'Карьерный узел', 'Двигатель тяговый DT-K6520');
INSERT INTO public.spare_part VALUES (238, 156, 'Трансмиссия', 'Редуктор заднего моста RZ-K6520');
INSERT INTO public.spare_part VALUES (239, 156, 'Гидравлическая система', 'Цилиндр подъёма кузова CP-K6520');
INSERT INTO public.spare_part VALUES (240, 157, 'Приводной узел', 'Приводной барабан ПП-800');
INSERT INTO public.spare_part VALUES (241, 157, 'Лента конвейерная', 'Лента резинотканевая ЛК-ПП800-4PR');
INSERT INTO public.spare_part VALUES (242, 158, 'Электрооборудование', 'Электровозный тяговый двигатель ЭД-150');
INSERT INTO public.spare_part VALUES (243, 158, 'Тормозная система', 'Тормозной модуль TM-150');
INSERT INTO public.spare_part VALUES (244, 159, 'Гидравлическая система', 'Основной гидроцилиндр HC-F350');
INSERT INTO public.spare_part VALUES (245, 159, 'Трансмиссия', 'Коробка передач КП-F350');
INSERT INTO public.spare_part VALUES (246, 160, 'Электроэнергетическая система', 'Дизель-генераторный блок DG-500');
INSERT INTO public.spare_part VALUES (247, 160, 'Система контроля', 'Панель управления PU-DG500');
INSERT INTO public.spare_part VALUES (248, 161, 'Трансформаторная установка', 'Масляный силовой трансформатор TMG-630/10');
INSERT INTO public.spare_part VALUES (249, 161, 'Система охлаждения', 'Радиатор охлаждения RC-TMG630');
INSERT INTO public.spare_part VALUES (250, 162, 'Электрощит', 'Распределительный щит РЩ-1000');
INSERT INTO public.spare_part VALUES (251, 162, 'Панель контроля', 'Контрольная панель КП-РЩ1000');
INSERT INTO public.spare_part VALUES (252, 163, 'Электроэнергетическая система', 'Стабилизатор напряжения SN-500');
INSERT INTO public.spare_part VALUES (253, 163, 'Панель управления', 'Панель мониторинга PM-SN500');
INSERT INTO public.spare_part VALUES (254, 164, 'Вентиляционный узел', 'Вентилятор осевой VE-15');
INSERT INTO public.spare_part VALUES (255, 164, 'Электродвигатель', 'Электродвигатель ED-VE15');
INSERT INTO public.spare_part VALUES (256, 165, 'Гидравлическая система', 'Основной гидроцилиндр HE-200');
INSERT INTO public.spare_part VALUES (257, 165, 'Приводной механизм', 'Редуктор HE-200');
INSERT INTO public.spare_part VALUES (258, 166, 'Гидравлическая система', 'Основной гидроцилиндр FL-350');
INSERT INTO public.spare_part VALUES (259, 166, 'Трансмиссия', 'Коробка передач КП-FL350');
INSERT INTO public.spare_part VALUES (260, 167, 'Буровой инструмент', 'Штанга буровая ШБ-PBU150');
INSERT INTO public.spare_part VALUES (261, 167, 'Гидравлический узел', 'Гидроцилиндр подачи ГЦ-PBU150');
INSERT INTO public.spare_part VALUES (262, 168, 'Электрооборудование', 'Электродвигатель тяговый ЭД-1Э');
INSERT INTO public.spare_part VALUES (263, 168, 'Гидравлическая система', 'Гидрораспределитель секционный ГРС-1Э');
INSERT INTO public.spare_part VALUES (264, 169, 'Проходческий узел', 'Ротор проходческого комбайна ПК-200');
INSERT INTO public.spare_part VALUES (265, 169, 'Гидравлическая система', 'Гидроцилиндр подачи ПК-200');
INSERT INTO public.spare_part VALUES (266, 170, 'Буровой инструмент', 'Буровое долото СБУ-80');
INSERT INTO public.spare_part VALUES (267, 170, 'Гидравлический узел', 'Гидроцилиндр подачи СБУ-80');
INSERT INTO public.spare_part VALUES (268, 171, 'Электрооборудование', 'Электродвигатель тяговый ЭД-1Э');
INSERT INTO public.spare_part VALUES (269, 171, 'Гидравлическая система', 'Гидрораспределитель секционный ГРС-1Э');
INSERT INTO public.spare_part VALUES (270, 172, 'Приводной узел', 'Приводной барабан ПБ-600');
INSERT INTO public.spare_part VALUES (271, 172, 'Лента конвейерная', 'Лента резинотканевая ЛК-600-4PR');
INSERT INTO public.spare_part VALUES (272, 173, 'Датчик газов', 'Сенсор измерения CO/CH4 GA-500');
INSERT INTO public.spare_part VALUES (273, 173, 'Контроллер', 'Электронный блок управления GA-500');
INSERT INTO public.spare_part VALUES (274, 174, 'Вентиляторный узел', 'Ротор осевого вентилятора ВШ-1500');
INSERT INTO public.spare_part VALUES (275, 174, 'Приводной механизм', 'Электродвигатель ED-ВШ1500');
INSERT INTO public.spare_part VALUES (276, 175, 'Циклонный модуль', 'Циклон DC-800');
INSERT INTO public.spare_part VALUES (277, 175, 'Фильтрующий элемент', 'Фильтр HEPA DC-800');
INSERT INTO public.spare_part VALUES (278, 176, 'Контроллер', 'Блок управления VControl-300');
INSERT INTO public.spare_part VALUES (279, 176, 'Датчик', 'Датчик температуры и давления VControl-300');
INSERT INTO public.spare_part VALUES (280, 177, 'Индукционная катушка', 'Катушка нагрева EP-5');
INSERT INTO public.spare_part VALUES (281, 177, 'Система охлаждения', 'Водяной контур охлаждения EP-5');
INSERT INTO public.spare_part VALUES (282, 178, 'Ковш', 'Ковш разливочный CR-1000');
INSERT INTO public.spare_part VALUES (283, 178, 'Приводной механизм', 'Механизм наклона ковша CR-1000');
INSERT INTO public.spare_part VALUES (284, 179, 'Нагревательный элемент', 'ТЭН LP-50');
INSERT INTO public.spare_part VALUES (285, 179, 'Терморегулятор', 'Контроллер температуры LP-50');
INSERT INTO public.spare_part VALUES (286, 180, 'Вентиляторный узел', 'Ротор центробежного вентилятора VFC-800');
INSERT INTO public.spare_part VALUES (287, 180, 'Приводной механизм', 'Электродвигатель ED-VFC800');
INSERT INTO public.spare_part VALUES (288, 181, 'Роликовый модуль', 'Ролики печи PR-10');
INSERT INTO public.spare_part VALUES (289, 181, 'Нагревательный элемент', 'ТЭН нагрева PR-10');
INSERT INTO public.spare_part VALUES (290, 182, 'Вальцы', 'Валы прокатного стана RS-4');
INSERT INTO public.spare_part VALUES (291, 182, 'Приводной механизм', 'Редуктор привода RS-4');
INSERT INTO public.spare_part VALUES (292, 183, 'Вальцы', 'Валы холодновальцовочной машины VM-200');
INSERT INTO public.spare_part VALUES (293, 183, 'Приводной механизм', 'Электродвигатель ED-VM200');
INSERT INTO public.spare_part VALUES (294, 184, 'Вальцы', 'Валы листоправильного стана LPS-6');
INSERT INTO public.spare_part VALUES (295, 184, 'Приводной механизм', 'Электродвигатель ED-LPS6');
INSERT INTO public.spare_part VALUES (296, 185, 'Вентиляторный узел', 'Ротор центробежного вентилятора VRC-1200');
INSERT INTO public.spare_part VALUES (297, 185, 'Приводной механизм', 'Электродвигатель ED-VRC1200');
INSERT INTO public.spare_part VALUES (298, 186, 'Оптическая система', 'Лазерный модуль SO-500');
INSERT INTO public.spare_part VALUES (299, 186, 'Электронный блок', 'Блок обработки сигналов SO-500');
INSERT INTO public.spare_part VALUES (300, 187, 'Пресс-узел', 'Гидравлический цилиндр IP-100');
INSERT INTO public.spare_part VALUES (301, 187, 'Контроллер', 'Электронный блок управления IP-100');
INSERT INTO public.spare_part VALUES (302, 188, 'Сенсорный модуль', 'Датчик химического анализа AC-300');
INSERT INTO public.spare_part VALUES (303, 188, 'Электронный блок', 'Блок обработки данных AC-300');
INSERT INTO public.spare_part VALUES (304, 189, 'Шнек', 'Шнековая пара SM-300');
INSERT INTO public.spare_part VALUES (305, 189, 'Приводной механизм', 'Электродвигатель ED-SM300');
INSERT INTO public.spare_part VALUES (306, 190, 'Дозирующий узел', 'Шиберный клапан DZ-150');
INSERT INTO public.spare_part VALUES (307, 190, 'Контроллер', 'Электронный блок DZ-150');
INSERT INTO public.spare_part VALUES (308, 191, 'Нагревательный элемент', 'ТЭН PT-500');
INSERT INTO public.spare_part VALUES (309, 191, 'Контроллер', 'Блок управления температурой PT-500');
INSERT INTO public.spare_part VALUES (310, 192, 'Дробильный узел', 'Щёки дробилки DR-500');
INSERT INTO public.spare_part VALUES (311, 192, 'Приводной механизм', 'Электродвигатель ED-DR500');
INSERT INTO public.spare_part VALUES (312, 193, 'Концентрационный узел', 'Горизонтальная гравитационная плита GC-200');
INSERT INTO public.spare_part VALUES (313, 193, 'Приводной механизм', 'Электродвигатель ED-GC200');
INSERT INTO public.spare_part VALUES (314, 194, 'Флотационный узел', 'Ротор флотационной машины FM-150');
INSERT INTO public.spare_part VALUES (315, 194, 'Приводной механизм', 'Электродвигатель ED-FM150');
INSERT INTO public.spare_part VALUES (316, 195, 'Магнитная система', 'Магнитный барабан MS-300');
INSERT INTO public.spare_part VALUES (317, 195, 'Приводной механизм', 'Электродвигатель ED-MS300');
INSERT INTO public.spare_part VALUES (318, 196, 'Фильтрующий элемент', 'Пластина фильтр-пресса FP-100');
INSERT INTO public.spare_part VALUES (319, 196, 'Приводной механизм', 'Гидроцилиндр прессования FP-100');
INSERT INTO public.spare_part VALUES (320, 197, 'Барабан', 'Барабан сушилки DRY-200');
INSERT INTO public.spare_part VALUES (321, 197, 'Приводной механизм', 'Электродвигатель ED-DRY200');
INSERT INTO public.spare_part VALUES (322, 198, 'Вентиляторный узел', 'Ротор центробежного вентилятора VDC-500');
INSERT INTO public.spare_part VALUES (323, 198, 'Приводной механизм', 'Электродвигатель ED-VDC500');
INSERT INTO public.spare_part VALUES (324, 199, 'Испытательный узел', 'Прессовая установка ST-100');
INSERT INTO public.spare_part VALUES (325, 199, 'Контроллер', 'Электронный блок управления ST-100');
INSERT INTO public.spare_part VALUES (326, 200, 'Оптический узел', 'Объектив металлографического микроскопа MM-200');
INSERT INTO public.spare_part VALUES (327, 200, 'Контроллер', 'Электронный блок MM-200');


--
-- Data for Name: user_token; Type: TABLE DATA; Schema: public; Owner: user
--



--
-- Data for Name: warehouse; Type: TABLE DATA; Schema: public; Owner: user
--

INSERT INTO public.warehouse VALUES (123, 13, 'Склад запасных частей', 'г. Кировск, ул. Промышленная, 14, стр. 1');
INSERT INTO public.warehouse VALUES (124, 14, 'Склад расходных материалов', 'г. Кировск, ул. Промышленная, 14, стр. 2');
INSERT INTO public.warehouse VALUES (125, 15, 'Склад общего назначения', 'г. Кировск, ул. Промышленная, 14, стр. 3');
INSERT INTO public.warehouse VALUES (126, 16, 'Склад запасных частей', 'г. Кировск, ул. Промышленная, 14, стр. 4');
INSERT INTO public.warehouse VALUES (127, 17, 'Склад крупногабаритных запчастей', 'г. Кировск, ул. Промышленная, 14, стр. 5');
INSERT INTO public.warehouse VALUES (128, 23, 'Склад крупногабаритных запчастей', 'г. Воркута, ул. Шахтёрская, 7, корп. 1');
INSERT INTO public.warehouse VALUES (129, 24, 'Склад запасных частей', 'г. Воркута, ул. Шахтёрская, 7, корп. 2');
INSERT INTO public.warehouse VALUES (130, 25, 'Склад общего назначения', 'г. Воркута, ул. Шахтёрская, 7, корп. 3');
INSERT INTO public.warehouse VALUES (131, 32, 'Склад общего назначения', 'г. Надым, ул. Геологоразведочная, 21, стр. А');
INSERT INTO public.warehouse VALUES (132, 33, 'Склад запасных частей', 'г. Надым, ул. Геологоразведочная, 21, стр. Б');
INSERT INTO public.warehouse VALUES (133, 34, 'Склад расходных материалов', 'г. Надым, ул. Геологоразведочная, 21, стр. В');
INSERT INTO public.warehouse VALUES (134, 40, 'Склад общего назначения', 'г. Дзержинск, ул. Индустриальная, 3, корп. 1');
INSERT INTO public.warehouse VALUES (135, 41, 'Склад запасных частей', 'г. Дзержинск, ул. Индустриальная, 3, корп. 2');
INSERT INTO public.warehouse VALUES (136, 42, 'Склад крупногабаритных запчастей', 'г. Дзержинск, ул. Индустриальная, 3, корп. 3');
INSERT INTO public.warehouse VALUES (137, 48, 'Склад запасных частей', 'г. Новомосковск, ул. Заводская, 52, стр. 1');
INSERT INTO public.warehouse VALUES (138, 49, 'Склад расходных материалов', 'г. Новомосковск, ул. Заводская, 52, стр. 2');
INSERT INTO public.warehouse VALUES (139, 50, 'Склад общего назначения', 'г. Новомосковск, ул. Заводская, 52, стр. 3');


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.department_department_id_seq', 48, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.employee_employee_id_seq', 1, false);


--
-- Name: equipment_assignment_equipment_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.equipment_assignment_equipment_assignment_id_seq', 114, true);


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
-- Name: part_stock_quantity_part_stock_quantity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.part_stock_quantity_part_stock_quantity_id_seq', 1659, true);


--
-- Name: repair_task_repair_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.repair_task_repair_task_id_seq', 1, false);


--
-- Name: spare_part_spare_part_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.spare_part_spare_part_id_seq', 1, false);


--
-- Name: user_token_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.user_token_token_id_seq', 1, false);


--
-- Name: warehouse_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.warehouse_warehouse_id_seq', 1, false);


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
-- Name: equipment_assignment equipment_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_assignment
    ADD CONSTRAINT equipment_assignment_pkey PRIMARY KEY (equipment_assignment_id);


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
-- Name: part_stock_quantity part_stock_quantity_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.part_stock_quantity
    ADD CONSTRAINT part_stock_quantity_pkey PRIMARY KEY (part_stock_quantity_id);


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
-- Name: equipment_assignment equipment_assignment_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_assignment
    ADD CONSTRAINT equipment_assignment_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- Name: equipment_assignment equipment_assignment_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_assignment
    ADD CONSTRAINT equipment_assignment_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


--
-- Name: equipment_movement equipment_movement_equipment_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.equipment_movement
    ADD CONSTRAINT equipment_movement_equipment_assignment_id_fkey FOREIGN KEY (equipment_assignment_id) REFERENCES public.equipment_assignment(equipment_assignment_id);


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
-- Name: maintenace_employee maintenace_employee_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenace_employee
    ADD CONSTRAINT maintenace_employee_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- Name: maintenace_employee maintenace_employee_maintenante_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.maintenace_employee
    ADD CONSTRAINT maintenace_employee_maintenante_plan_id_fkey FOREIGN KEY (maintenante_plan_id) REFERENCES public.maintenance_plan(maintenance_plan_id);


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
-- Name: part_stock_quantity part_stock_quantity_spare_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.part_stock_quantity
    ADD CONSTRAINT part_stock_quantity_spare_part_id_fkey FOREIGN KEY (spare_part_id) REFERENCES public.spare_part(spare_part_id);


--
-- Name: part_stock_quantity part_stock_quantity_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.part_stock_quantity
    ADD CONSTRAINT part_stock_quantity_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(warehouse_id);


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
-- Name: repair_task repair_task_epmloyee_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.repair_task
    ADD CONSTRAINT repair_task_epmloyee_fkey FOREIGN KEY (epmloyee) REFERENCES public.employee(employee_id);


--
-- Name: spare_part spare_part_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.spare_part
    ADD CONSTRAINT spare_part_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id);


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

\unrestrict g01h9zX1WfBqlPQSz4OfCHq2Qe7oobzU8mZRm6Q0waSU8L6MCGubhl8CnIyKEqr

