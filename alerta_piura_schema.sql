--
-- PostgreSQL database dump
--

\restrict L0N29A6BqxzSGLZJHdx0lWhHbBlm2kcFrnVbAqgZ8domUUslvbMu89XNEGOb9nN

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-09-26 16:16:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 20510)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 6042 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 21808)
-- Name: apoyos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apoyos (
    id_reporte integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 226 (class 1259 OID 21607)
-- Name: categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorias (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    icono_url character varying(255)
);


--
-- TOC entry 225 (class 1259 OID 21606)
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6043 (class 0 OID 0)
-- Dependencies: 225
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorias_id_seq OWNED BY public.categorias.id;


--
-- TOC entry 254 (class 1259 OID 31850)
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_messages (
    id integer NOT NULL,
    id_reporte integer NOT NULL,
    id_remitente integer NOT NULL,
    remitente_alias character varying(100) NOT NULL,
    mensaje text NOT NULL,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 253 (class 1259 OID 31849)
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6044 (class 0 OID 0)
-- Dependencies: 253
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- TOC entry 244 (class 1259 OID 21961)
-- Name: comentario_apoyos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comentario_apoyos (
    id integer NOT NULL,
    id_comentario integer NOT NULL,
    id_usuario integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 243 (class 1259 OID 21960)
-- Name: comentario_apoyos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comentario_apoyos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6045 (class 0 OID 0)
-- Dependencies: 243
-- Name: comentario_apoyos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comentario_apoyos_id_seq OWNED BY public.comentario_apoyos.id;


--
-- TOC entry 236 (class 1259 OID 21888)
-- Name: comentario_reportes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comentario_reportes (
    id integer NOT NULL,
    id_comentario integer,
    id_reportador integer,
    motivo character varying(255) NOT NULL,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 235 (class 1259 OID 21887)
-- Name: comentario_reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comentario_reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6046 (class 0 OID 0)
-- Dependencies: 235
-- Name: comentario_reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comentario_reportes_id_seq OWNED BY public.comentario_reportes.id;


--
-- TOC entry 234 (class 1259 OID 21852)
-- Name: comentarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comentarios (
    id integer NOT NULL,
    id_reporte integer,
    id_usuario integer,
    comentario text NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 233 (class 1259 OID 21851)
-- Name: comentarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comentarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6047 (class 0 OID 0)
-- Dependencies: 233
-- Name: comentarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comentarios_id_seq OWNED BY public.comentarios.id;


--
-- TOC entry 231 (class 1259 OID 21825)
-- Name: insignias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.insignias (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    icono_url character varying(255),
    puntos_necesarios integer
);


--
-- TOC entry 230 (class 1259 OID 21824)
-- Name: insignias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.insignias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6048 (class 0 OID 0)
-- Dependencies: 230
-- Name: insignias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.insignias_id_seq OWNED BY public.insignias.id;


--
-- TOC entry 252 (class 1259 OID 31820)
-- Name: notificaciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notificaciones (
    id integer NOT NULL,
    id_usuario_receptor integer,
    titulo character varying(255) NOT NULL,
    cuerpo text,
    leido boolean DEFAULT false,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 251 (class 1259 OID 31819)
-- Name: notificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6049 (class 0 OID 0)
-- Dependencies: 251
-- Name: notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notificaciones_id_seq OWNED BY public.notificaciones.id;


--
-- TOC entry 242 (class 1259 OID 21953)
-- Name: pgmigrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgmigrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


--
-- TOC entry 241 (class 1259 OID 21952)
-- Name: pgmigrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pgmigrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6050 (class 0 OID 0)
-- Dependencies: 241
-- Name: pgmigrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pgmigrations_id_seq OWNED BY public.pgmigrations.id;


--
-- TOC entry 228 (class 1259 OID 21616)
-- Name: reportes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reportes (
    id integer NOT NULL,
    id_usuario integer,
    id_categoria integer,
    titulo character varying(150),
    descripcion text,
    foto_url character varying(255),
    location public.geometry(Point,4326) NOT NULL,
    categoria_sugerida character varying(100),
    estado character varying(30) DEFAULT 'pendiente_verificacion'::character varying NOT NULL,
    es_anonimo boolean DEFAULT false,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion timestamp with time zone,
    revision_solicitada boolean DEFAULT false,
    urgencia character varying(20),
    hora_incidente time without time zone,
    tags text[],
    impacto character varying(50),
    referencia_ubicacion text,
    distrito character varying(100),
    codigo_reporte character varying(20),
    id_lider_verificador integer
);


--
-- TOC entry 227 (class 1259 OID 21615)
-- Name: reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6051 (class 0 OID 0)
-- Dependencies: 227
-- Name: reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reportes_id_seq OWNED BY public.reportes.id;


--
-- TOC entry 250 (class 1259 OID 31805)
-- Name: simulated_sms_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.simulated_sms_log (
    id integer NOT NULL,
    id_usuario_sos integer,
    contacto_nombre character varying(100),
    contacto_telefono character varying(20),
    mensaje text NOT NULL,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 249 (class 1259 OID 31804)
-- Name: simulated_sms_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.simulated_sms_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6052 (class 0 OID 0)
-- Dependencies: 249
-- Name: simulated_sms_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.simulated_sms_log_id_seq OWNED BY public.simulated_sms_log.id;


--
-- TOC entry 240 (class 1259 OID 21930)
-- Name: solicitudes_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitudes_revision (
    id integer NOT NULL,
    id_reporte integer,
    id_lider integer,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_solicitud timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 239 (class 1259 OID 21929)
-- Name: solicitudes_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solicitudes_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6053 (class 0 OID 0)
-- Dependencies: 239
-- Name: solicitudes_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solicitudes_revision_id_seq OWNED BY public.solicitudes_revision.id;


--
-- TOC entry 246 (class 1259 OID 23384)
-- Name: sos_alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sos_alerts (
    id integer NOT NULL,
    id_usuario integer,
    estado character varying(30) DEFAULT 'activo'::character varying NOT NULL,
    fecha_inicio timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_fin timestamp with time zone,
    revisada boolean DEFAULT false,
    estado_atencion character varying(30) DEFAULT 'En Espera'::character varying,
    contacto_emergencia_telefono character varying(20),
    contacto_emergencia_mensaje text,
    codigo_alerta character varying(20),
    duracion_segundos integer DEFAULT 600
);


--
-- TOC entry 245 (class 1259 OID 23383)
-- Name: sos_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sos_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6054 (class 0 OID 0)
-- Dependencies: 245
-- Name: sos_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sos_alerts_id_seq OWNED BY public.sos_alerts.id;


--
-- TOC entry 248 (class 1259 OID 23398)
-- Name: sos_location_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sos_location_updates (
    id integer NOT NULL,
    id_alerta_sos integer,
    location public.geometry(Point,4326) NOT NULL,
    fecha_registro timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 247 (class 1259 OID 23397)
-- Name: sos_location_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sos_location_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6055 (class 0 OID 0)
-- Dependencies: 247
-- Name: sos_location_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sos_location_updates_id_seq OWNED BY public.sos_location_updates.id;


--
-- TOC entry 232 (class 1259 OID 21835)
-- Name: usuario_insignias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_insignias (
    id_usuario integer NOT NULL,
    id_insignia integer NOT NULL,
    fecha_obtenida timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 238 (class 1259 OID 21907)
-- Name: usuario_reportes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_reportes (
    id integer NOT NULL,
    id_usuario_reportado integer,
    id_reportador integer,
    motivo text NOT NULL,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 237 (class 1259 OID 21906)
-- Name: usuario_reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6056 (class 0 OID 0)
-- Dependencies: 237
-- Name: usuario_reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_reportes_id_seq OWNED BY public.usuario_reportes.id;


--
-- TOC entry 224 (class 1259 OID 21591)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    alias character varying(50),
    email character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    puntos integer DEFAULT 0,
    rol character varying(20) DEFAULT 'ciudadano'::character varying NOT NULL,
    fecha_registro timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'activo'::character varying NOT NULL,
    telefono character varying(20)
);


--
-- TOC entry 223 (class 1259 OID 21590)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 6057 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 5737 (class 2604 OID 21610)
-- Name: categorias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id SET DEFAULT nextval('public.categorias_id_seq'::regclass);


--
-- TOC entry 5773 (class 2604 OID 31853)
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- TOC entry 5758 (class 2604 OID 21964)
-- Name: comentario_apoyos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_apoyos ALTER COLUMN id SET DEFAULT nextval('public.comentario_apoyos_id_seq'::regclass);


--
-- TOC entry 5748 (class 2604 OID 21891)
-- Name: comentario_reportes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_reportes ALTER COLUMN id SET DEFAULT nextval('public.comentario_reportes_id_seq'::regclass);


--
-- TOC entry 5746 (class 2604 OID 21855)
-- Name: comentarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentarios ALTER COLUMN id SET DEFAULT nextval('public.comentarios_id_seq'::regclass);


--
-- TOC entry 5744 (class 2604 OID 21828)
-- Name: insignias id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insignias ALTER COLUMN id SET DEFAULT nextval('public.insignias_id_seq'::regclass);


--
-- TOC entry 5770 (class 2604 OID 31823)
-- Name: notificaciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificaciones ALTER COLUMN id SET DEFAULT nextval('public.notificaciones_id_seq'::regclass);


--
-- TOC entry 5757 (class 2604 OID 21956)
-- Name: pgmigrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgmigrations ALTER COLUMN id SET DEFAULT nextval('public.pgmigrations_id_seq'::regclass);


--
-- TOC entry 5738 (class 2604 OID 21619)
-- Name: reportes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes ALTER COLUMN id SET DEFAULT nextval('public.reportes_id_seq'::regclass);


--
-- TOC entry 5768 (class 2604 OID 31808)
-- Name: simulated_sms_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.simulated_sms_log ALTER COLUMN id SET DEFAULT nextval('public.simulated_sms_log_id_seq'::regclass);


--
-- TOC entry 5754 (class 2604 OID 21933)
-- Name: solicitudes_revision id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes_revision ALTER COLUMN id SET DEFAULT nextval('public.solicitudes_revision_id_seq'::regclass);


--
-- TOC entry 5760 (class 2604 OID 23387)
-- Name: sos_alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_alerts ALTER COLUMN id SET DEFAULT nextval('public.sos_alerts_id_seq'::regclass);


--
-- TOC entry 5766 (class 2604 OID 23401)
-- Name: sos_location_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_location_updates ALTER COLUMN id SET DEFAULT nextval('public.sos_location_updates_id_seq'::regclass);


--
-- TOC entry 5751 (class 2604 OID 21910)
-- Name: usuario_reportes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_reportes ALTER COLUMN id SET DEFAULT nextval('public.usuario_reportes_id_seq'::regclass);


--
-- TOC entry 5732 (class 2604 OID 21594)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 5798 (class 2606 OID 21813)
-- Name: apoyos apoyos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_pkey PRIMARY KEY (id_reporte, id_usuario);


--
-- TOC entry 5789 (class 2606 OID 21614)
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5791 (class 2606 OID 21612)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- TOC entry 5831 (class 2606 OID 31858)
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 5816 (class 2606 OID 21967)
-- Name: comentario_apoyos comentario_apoyos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_pkey PRIMARY KEY (id);


--
-- TOC entry 5818 (class 2606 OID 21979)
-- Name: comentario_apoyos comentario_apoyos_unique_user_comment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_unique_user_comment UNIQUE (id_comentario, id_usuario);


--
-- TOC entry 5808 (class 2606 OID 21895)
-- Name: comentario_reportes comentario_reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5806 (class 2606 OID 21860)
-- Name: comentarios comentarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5800 (class 2606 OID 21834)
-- Name: insignias insignias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insignias
    ADD CONSTRAINT insignias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5802 (class 2606 OID 21832)
-- Name: insignias insignias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.insignias
    ADD CONSTRAINT insignias_pkey PRIMARY KEY (id);


--
-- TOC entry 5829 (class 2606 OID 31829)
-- Name: notificaciones notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 5814 (class 2606 OID 21958)
-- Name: pgmigrations pgmigrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgmigrations
    ADD CONSTRAINT pgmigrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5794 (class 2606 OID 31836)
-- Name: reportes reportes_codigo_reporte_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_codigo_reporte_key UNIQUE (codigo_reporte);


--
-- TOC entry 5796 (class 2606 OID 21626)
-- Name: reportes reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5827 (class 2606 OID 31813)
-- Name: simulated_sms_log simulated_sms_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.simulated_sms_log
    ADD CONSTRAINT simulated_sms_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5812 (class 2606 OID 21937)
-- Name: solicitudes_revision solicitudes_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_pkey PRIMARY KEY (id);


--
-- TOC entry 5820 (class 2606 OID 31842)
-- Name: sos_alerts sos_alerts_codigo_alerta_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_codigo_alerta_key UNIQUE (codigo_alerta);


--
-- TOC entry 5822 (class 2606 OID 23391)
-- Name: sos_alerts sos_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_pkey PRIMARY KEY (id);


--
-- TOC entry 5825 (class 2606 OID 23406)
-- Name: sos_location_updates sos_location_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_location_updates
    ADD CONSTRAINT sos_location_updates_pkey PRIMARY KEY (id);


--
-- TOC entry 5804 (class 2606 OID 21840)
-- Name: usuario_insignias usuario_insignias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_pkey PRIMARY KEY (id_usuario, id_insignia);


--
-- TOC entry 5810 (class 2606 OID 21916)
-- Name: usuario_reportes usuario_reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5779 (class 2606 OID 21603)
-- Name: usuarios usuarios_alias_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_alias_key UNIQUE (alias);


--
-- TOC entry 5781 (class 2606 OID 21949)
-- Name: usuarios usuarios_alias_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_alias_unique UNIQUE (alias);


--
-- TOC entry 5783 (class 2606 OID 21605)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 5785 (class 2606 OID 21951)
-- Name: usuarios usuarios_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_unique UNIQUE (email);


--
-- TOC entry 5787 (class 2606 OID 21601)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5792 (class 1259 OID 21637)
-- Name: idx_reportes_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reportes_location ON public.reportes USING gist (location);


--
-- TOC entry 5823 (class 1259 OID 23412)
-- Name: idx_sos_location_updates_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sos_location_updates_location ON public.sos_location_updates USING gist (location);


--
-- TOC entry 5835 (class 2606 OID 21814)
-- Name: apoyos apoyos_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5836 (class 2606 OID 21819)
-- Name: apoyos apoyos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5853 (class 2606 OID 31864)
-- Name: chat_messages chat_messages_id_remitente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_id_remitente_fkey FOREIGN KEY (id_remitente) REFERENCES public.usuarios(id);


--
-- TOC entry 5854 (class 2606 OID 31859)
-- Name: chat_messages chat_messages_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5847 (class 2606 OID 21968)
-- Name: comentario_apoyos comentario_apoyos_id_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_id_comentario_fkey FOREIGN KEY (id_comentario) REFERENCES public.comentarios(id) ON DELETE CASCADE;


--
-- TOC entry 5848 (class 2606 OID 21973)
-- Name: comentario_apoyos comentario_apoyos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5841 (class 2606 OID 21896)
-- Name: comentario_reportes comentario_reportes_id_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_id_comentario_fkey FOREIGN KEY (id_comentario) REFERENCES public.comentarios(id) ON DELETE CASCADE;


--
-- TOC entry 5842 (class 2606 OID 21901)
-- Name: comentario_reportes comentario_reportes_id_reportador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_id_reportador_fkey FOREIGN KEY (id_reportador) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5839 (class 2606 OID 21861)
-- Name: comentarios comentarios_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5840 (class 2606 OID 21866)
-- Name: comentarios comentarios_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5852 (class 2606 OID 31830)
-- Name: notificaciones notificaciones_id_usuario_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5832 (class 2606 OID 21632)
-- Name: reportes reportes_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categorias(id);


--
-- TOC entry 5833 (class 2606 OID 31844)
-- Name: reportes reportes_id_lider_verificador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_lider_verificador_fkey FOREIGN KEY (id_lider_verificador) REFERENCES public.usuarios(id);


--
-- TOC entry 5834 (class 2606 OID 21627)
-- Name: reportes reportes_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id);


--
-- TOC entry 5851 (class 2606 OID 31814)
-- Name: simulated_sms_log simulated_sms_log_id_usuario_sos_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.simulated_sms_log
    ADD CONSTRAINT simulated_sms_log_id_usuario_sos_fkey FOREIGN KEY (id_usuario_sos) REFERENCES public.usuarios(id);


--
-- TOC entry 5845 (class 2606 OID 21943)
-- Name: solicitudes_revision solicitudes_revision_id_lider_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_id_lider_fkey FOREIGN KEY (id_lider) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5846 (class 2606 OID 21938)
-- Name: solicitudes_revision solicitudes_revision_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5849 (class 2606 OID 23392)
-- Name: sos_alerts sos_alerts_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5850 (class 2606 OID 23407)
-- Name: sos_location_updates sos_location_updates_id_alerta_sos_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sos_location_updates
    ADD CONSTRAINT sos_location_updates_id_alerta_sos_fkey FOREIGN KEY (id_alerta_sos) REFERENCES public.sos_alerts(id) ON DELETE CASCADE;


--
-- TOC entry 5837 (class 2606 OID 21846)
-- Name: usuario_insignias usuario_insignias_id_insignia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_id_insignia_fkey FOREIGN KEY (id_insignia) REFERENCES public.insignias(id) ON DELETE CASCADE;


--
-- TOC entry 5838 (class 2606 OID 21841)
-- Name: usuario_insignias usuario_insignias_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5843 (class 2606 OID 21922)
-- Name: usuario_reportes usuario_reportes_id_reportador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_id_reportador_fkey FOREIGN KEY (id_reportador) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5844 (class 2606 OID 21917)
-- Name: usuario_reportes usuario_reportes_id_usuario_reportado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_id_usuario_reportado_fkey FOREIGN KEY (id_usuario_reportado) REFERENCES public.usuarios(id) ON DELETE CASCADE;


-- Completed on 2025-09-26 16:16:15

--
-- PostgreSQL database dump complete
--

\unrestrict L0N29A6BqxzSGLZJHdx0lWhHbBlm2kcFrnVbAqgZ8domUUslvbMu89XNEGOb9nN

