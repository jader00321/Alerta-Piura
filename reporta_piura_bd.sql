--
-- PostgreSQL database dump
--

\restrict U2x6fFoYvhJoD6XV2WmPnehQM5FIMqdWb3e8rgI2n7YK4XSehvBmO7S8cx4L91B

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-10-24 10:50:03

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
-- TOC entry 6173 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 21808)
-- Name: apoyos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.apoyos (
    id_reporte integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.apoyos OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 32027)
-- Name: apoyos_pendientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.apoyos_pendientes (
    id_reporte integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.apoyos_pendientes OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 21607)
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    icono_url character varying(255),
    orden integer NOT NULL
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 21606)
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_id_seq OWNER TO postgres;

--
-- TOC entry 6174 (class 0 OID 0)
-- Dependencies: 225
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_id_seq OWNED BY public.categorias.id;


--
-- TOC entry 255 (class 1259 OID 31872)
-- Name: categorias_orden_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_orden_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_orden_seq OWNER TO postgres;

--
-- TOC entry 6175 (class 0 OID 0)
-- Dependencies: 255
-- Name: categorias_orden_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_orden_seq OWNED BY public.categorias.orden;


--
-- TOC entry 254 (class 1259 OID 31850)
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id integer NOT NULL,
    id_reporte integer NOT NULL,
    id_remitente integer NOT NULL,
    remitente_alias character varying(100) NOT NULL,
    mensaje text NOT NULL,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 31849)
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_messages_id_seq OWNER TO postgres;

--
-- TOC entry 6176 (class 0 OID 0)
-- Dependencies: 253
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- TOC entry 244 (class 1259 OID 21961)
-- Name: comentario_apoyos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentario_apoyos (
    id integer NOT NULL,
    id_comentario integer NOT NULL,
    id_usuario integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.comentario_apoyos OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 21960)
-- Name: comentario_apoyos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentario_apoyos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comentario_apoyos_id_seq OWNER TO postgres;

--
-- TOC entry 6177 (class 0 OID 0)
-- Dependencies: 243
-- Name: comentario_apoyos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comentario_apoyos_id_seq OWNED BY public.comentario_apoyos.id;


--
-- TOC entry 236 (class 1259 OID 21888)
-- Name: comentario_reportes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentario_reportes (
    id integer NOT NULL,
    id_comentario integer,
    id_reportador integer,
    motivo character varying(255) NOT NULL,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comentario_reportes OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 21887)
-- Name: comentario_reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentario_reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comentario_reportes_id_seq OWNER TO postgres;

--
-- TOC entry 6178 (class 0 OID 0)
-- Dependencies: 235
-- Name: comentario_reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comentario_reportes_id_seq OWNED BY public.comentario_reportes.id;


--
-- TOC entry 234 (class 1259 OID 21852)
-- Name: comentarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentarios (
    id integer NOT NULL,
    id_reporte integer,
    id_usuario integer,
    comentario text NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.comentarios OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 21851)
-- Name: comentarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comentarios_id_seq OWNER TO postgres;

--
-- TOC entry 6179 (class 0 OID 0)
-- Dependencies: 233
-- Name: comentarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comentarios_id_seq OWNED BY public.comentarios.id;


--
-- TOC entry 231 (class 1259 OID 21825)
-- Name: insignias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.insignias (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    icono_url character varying(255),
    puntos_necesarios integer
);


ALTER TABLE public.insignias OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 21824)
-- Name: insignias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.insignias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.insignias_id_seq OWNER TO postgres;

--
-- TOC entry 6180 (class 0 OID 0)
-- Dependencies: 230
-- Name: insignias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.insignias_id_seq OWNED BY public.insignias.id;


--
-- TOC entry 271 (class 1259 OID 32116)
-- Name: lider_zonas_asignadas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lider_zonas_asignadas (
    id integer NOT NULL,
    id_usuario integer NOT NULL,
    nombre_distrito character varying(100) NOT NULL
);


ALTER TABLE public.lider_zonas_asignadas OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 32115)
-- Name: lider_zonas_asignadas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lider_zonas_asignadas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lider_zonas_asignadas_id_seq OWNER TO postgres;

--
-- TOC entry 6181 (class 0 OID 0)
-- Dependencies: 270
-- Name: lider_zonas_asignadas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lider_zonas_asignadas_id_seq OWNED BY public.lider_zonas_asignadas.id;


--
-- TOC entry 261 (class 1259 OID 31907)
-- Name: metodos_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.metodos_pago (
    id integer NOT NULL,
    id_usuario integer NOT NULL,
    tipo_tarjeta character varying(50),
    ultimos_cuatro_digitos character varying(4) NOT NULL,
    fecha_expiracion character varying(7) NOT NULL,
    token_tarjeta_cifrado text NOT NULL,
    es_predeterminado boolean DEFAULT false NOT NULL
);


ALTER TABLE public.metodos_pago OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 31906)
-- Name: metodos_pago_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.metodos_pago_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.metodos_pago_id_seq OWNER TO postgres;

--
-- TOC entry 6182 (class 0 OID 0)
-- Dependencies: 260
-- Name: metodos_pago_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.metodos_pago_id_seq OWNED BY public.metodos_pago.id;


--
-- TOC entry 257 (class 1259 OID 31880)
-- Name: moderation_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moderation_log (
    id integer NOT NULL,
    id_admin integer,
    admin_alias character varying(100),
    accion character varying(50) NOT NULL,
    entidad_tipo character varying(20),
    id_entidad integer,
    contenido_afectado text,
    motivo_reporte text,
    fecha_accion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.moderation_log OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 31879)
-- Name: moderation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moderation_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moderation_log_id_seq OWNER TO postgres;

--
-- TOC entry 6183 (class 0 OID 0)
-- Dependencies: 256
-- Name: moderation_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moderation_log_id_seq OWNED BY public.moderation_log.id;


--
-- TOC entry 252 (class 1259 OID 31820)
-- Name: notificaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notificaciones (
    id integer NOT NULL,
    id_usuario_receptor integer,
    titulo character varying(255) NOT NULL,
    cuerpo text,
    leido boolean DEFAULT false,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    payload jsonb
);


ALTER TABLE public.notificaciones OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 31819)
-- Name: notificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notificaciones_id_seq OWNER TO postgres;

--
-- TOC entry 6184 (class 0 OID 0)
-- Dependencies: 251
-- Name: notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notificaciones_id_seq OWNED BY public.notificaciones.id;


--
-- TOC entry 242 (class 1259 OID 21953)
-- Name: pgmigrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pgmigrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.pgmigrations OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 21952)
-- Name: pgmigrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pgmigrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pgmigrations_id_seq OWNER TO postgres;

--
-- TOC entry 6185 (class 0 OID 0)
-- Dependencies: 241
-- Name: pgmigrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pgmigrations_id_seq OWNED BY public.pgmigrations.id;


--
-- TOC entry 259 (class 1259 OID 31895)
-- Name: planes_suscripcion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planes_suscripcion (
    id integer NOT NULL,
    identificador_plan character varying(50) NOT NULL,
    nombre_publico character varying(100) NOT NULL,
    descripcion text,
    precio_mensual numeric(10,2) NOT NULL,
    activo boolean DEFAULT true
);


ALTER TABLE public.planes_suscripcion OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 31894)
-- Name: planes_suscripcion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.planes_suscripcion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.planes_suscripcion_id_seq OWNER TO postgres;

--
-- TOC entry 6186 (class 0 OID 0)
-- Dependencies: 258
-- Name: planes_suscripcion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.planes_suscripcion_id_seq OWNED BY public.planes_suscripcion.id;


--
-- TOC entry 228 (class 1259 OID 21616)
-- Name: reportes; Type: TABLE; Schema: public; Owner: postgres
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
    id_lider_verificador integer,
    apoyos_pendientes integer DEFAULT 0,
    id_reporte_original integer,
    reportes_vinculados_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT reportes_estado_check CHECK (((estado)::text = ANY ((ARRAY['pendiente_verificacion'::character varying, 'verificado'::character varying, 'rechazado'::character varying, 'oculto'::character varying, 'fusionado'::character varying])::text[])))
);


ALTER TABLE public.reportes OWNER TO postgres;

--
-- TOC entry 6187 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN reportes.reportes_vinculados_count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.reportes.reportes_vinculados_count IS 'Contador de cuántos otros reportes han sido fusionados EN ESTE reporte (si este es el original).';


--
-- TOC entry 227 (class 1259 OID 21615)
-- Name: reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reportes_id_seq OWNER TO postgres;

--
-- TOC entry 6188 (class 0 OID 0)
-- Dependencies: 227
-- Name: reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reportes_id_seq OWNED BY public.reportes.id;


--
-- TOC entry 263 (class 1259 OID 31945)
-- Name: reportes_prioritarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reportes_prioritarios (
    id_reporte integer NOT NULL,
    id_usuario_premium integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reportes_prioritarios OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 32081)
-- Name: reportes_seguidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reportes_seguidos (
    id_usuario integer NOT NULL,
    id_reporte integer NOT NULL,
    fecha_seguimiento timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reportes_seguidos OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 31805)
-- Name: simulated_sms_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.simulated_sms_log (
    id integer NOT NULL,
    id_usuario_sos integer,
    contacto_nombre character varying(100),
    contacto_telefono character varying(20),
    mensaje text NOT NULL,
    fecha_envio timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.simulated_sms_log OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 31804)
-- Name: simulated_sms_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.simulated_sms_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulated_sms_log_id_seq OWNER TO postgres;

--
-- TOC entry 6189 (class 0 OID 0)
-- Dependencies: 249
-- Name: simulated_sms_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.simulated_sms_log_id_seq OWNED BY public.simulated_sms_log.id;


--
-- TOC entry 240 (class 1259 OID 21930)
-- Name: solicitudes_revision; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.solicitudes_revision (
    id integer NOT NULL,
    id_reporte integer,
    id_lider integer,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_solicitud timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    motivo text
);


ALTER TABLE public.solicitudes_revision OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 21929)
-- Name: solicitudes_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.solicitudes_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.solicitudes_revision_id_seq OWNER TO postgres;

--
-- TOC entry 6190 (class 0 OID 0)
-- Dependencies: 239
-- Name: solicitudes_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.solicitudes_revision_id_seq OWNED BY public.solicitudes_revision.id;


--
-- TOC entry 266 (class 1259 OID 32049)
-- Name: solicitudes_rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.solicitudes_rol (
    id integer NOT NULL,
    id_usuario integer NOT NULL,
    motivos text,
    estado character varying(20) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_solicitud timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    motivacion text,
    zona_propuesta character varying(100)
);


ALTER TABLE public.solicitudes_rol OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 32048)
-- Name: solicitudes_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.solicitudes_rol_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.solicitudes_rol_id_seq OWNER TO postgres;

--
-- TOC entry 6191 (class 0 OID 0)
-- Dependencies: 265
-- Name: solicitudes_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.solicitudes_rol_id_seq OWNED BY public.solicitudes_rol.id;


--
-- TOC entry 246 (class 1259 OID 23384)
-- Name: sos_alerts; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.sos_alerts OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 23383)
-- Name: sos_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sos_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sos_alerts_id_seq OWNER TO postgres;

--
-- TOC entry 6192 (class 0 OID 0)
-- Dependencies: 245
-- Name: sos_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sos_alerts_id_seq OWNED BY public.sos_alerts.id;


--
-- TOC entry 248 (class 1259 OID 23398)
-- Name: sos_location_updates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sos_location_updates (
    id integer NOT NULL,
    id_alerta_sos integer,
    location public.geometry(Point,4326) NOT NULL,
    fecha_registro timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sos_location_updates OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 23397)
-- Name: sos_location_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sos_location_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sos_location_updates_id_seq OWNER TO postgres;

--
-- TOC entry 6193 (class 0 OID 0)
-- Dependencies: 247
-- Name: sos_location_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sos_location_updates_id_seq OWNED BY public.sos_location_updates.id;


--
-- TOC entry 262 (class 1259 OID 31920)
-- Name: transacciones_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transacciones_pago (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_usuario integer NOT NULL,
    id_plan integer NOT NULL,
    id_metodo_pago integer,
    monto_pagado numeric(10,2) NOT NULL,
    fecha_transaccion timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id_transaccion_pasarela character varying(255),
    estado_transaccion character varying(50) NOT NULL
);


ALTER TABLE public.transacciones_pago OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 21835)
-- Name: usuario_insignias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_insignias (
    id_usuario integer NOT NULL,
    id_insignia integer NOT NULL,
    fecha_obtenida timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.usuario_insignias OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 21907)
-- Name: usuario_reportes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_reportes (
    id integer NOT NULL,
    id_usuario_reportado integer,
    id_reportador integer,
    motivo text NOT NULL,
    estado character varying(30) DEFAULT 'pendiente'::character varying NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.usuario_reportes OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 21906)
-- Name: usuario_reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_reportes_id_seq OWNER TO postgres;

--
-- TOC entry 6194 (class 0 OID 0)
-- Dependencies: 237
-- Name: usuario_reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_reportes_id_seq OWNED BY public.usuario_reportes.id;


--
-- TOC entry 224 (class 1259 OID 21591)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
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
    telefono character varying(20),
    id_plan_suscripcion integer,
    fecha_fin_suscripcion timestamp with time zone
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 21590)
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- TOC entry 6195 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- TOC entry 268 (class 1259 OID 32066)
-- Name: zonas_seguras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zonas_seguras (
    id integer NOT NULL,
    id_usuario integer NOT NULL,
    nombre character varying(100) NOT NULL,
    centro public.geometry(Point,4326) NOT NULL,
    radio_metros integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.zonas_seguras OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 32065)
-- Name: zonas_seguras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zonas_seguras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zonas_seguras_id_seq OWNER TO postgres;

--
-- TOC entry 6196 (class 0 OID 0)
-- Dependencies: 267
-- Name: zonas_seguras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zonas_seguras_id_seq OWNED BY public.zonas_seguras.id;


--
-- TOC entry 5784 (class 2604 OID 21610)
-- Name: categorias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id SET DEFAULT nextval('public.categorias_id_seq'::regclass);


--
-- TOC entry 5785 (class 2604 OID 31873)
-- Name: categorias orden; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN orden SET DEFAULT nextval('public.categorias_orden_seq'::regclass);


--
-- TOC entry 5823 (class 2604 OID 31853)
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- TOC entry 5808 (class 2604 OID 21964)
-- Name: comentario_apoyos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_apoyos ALTER COLUMN id SET DEFAULT nextval('public.comentario_apoyos_id_seq'::regclass);


--
-- TOC entry 5798 (class 2604 OID 21891)
-- Name: comentario_reportes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_reportes ALTER COLUMN id SET DEFAULT nextval('public.comentario_reportes_id_seq'::regclass);


--
-- TOC entry 5796 (class 2604 OID 21855)
-- Name: comentarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios ALTER COLUMN id SET DEFAULT nextval('public.comentarios_id_seq'::regclass);


--
-- TOC entry 5794 (class 2604 OID 21828)
-- Name: insignias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.insignias ALTER COLUMN id SET DEFAULT nextval('public.insignias_id_seq'::regclass);


--
-- TOC entry 5841 (class 2604 OID 32119)
-- Name: lider_zonas_asignadas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lider_zonas_asignadas ALTER COLUMN id SET DEFAULT nextval('public.lider_zonas_asignadas_id_seq'::regclass);


--
-- TOC entry 5829 (class 2604 OID 31910)
-- Name: metodos_pago id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodos_pago ALTER COLUMN id SET DEFAULT nextval('public.metodos_pago_id_seq'::regclass);


--
-- TOC entry 5825 (class 2604 OID 31883)
-- Name: moderation_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log ALTER COLUMN id SET DEFAULT nextval('public.moderation_log_id_seq'::regclass);


--
-- TOC entry 5820 (class 2604 OID 31823)
-- Name: notificaciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones ALTER COLUMN id SET DEFAULT nextval('public.notificaciones_id_seq'::regclass);


--
-- TOC entry 5807 (class 2604 OID 21956)
-- Name: pgmigrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pgmigrations ALTER COLUMN id SET DEFAULT nextval('public.pgmigrations_id_seq'::regclass);


--
-- TOC entry 5827 (class 2604 OID 31898)
-- Name: planes_suscripcion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_suscripcion ALTER COLUMN id SET DEFAULT nextval('public.planes_suscripcion_id_seq'::regclass);


--
-- TOC entry 5786 (class 2604 OID 21619)
-- Name: reportes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes ALTER COLUMN id SET DEFAULT nextval('public.reportes_id_seq'::regclass);


--
-- TOC entry 5818 (class 2604 OID 31808)
-- Name: simulated_sms_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulated_sms_log ALTER COLUMN id SET DEFAULT nextval('public.simulated_sms_log_id_seq'::regclass);


--
-- TOC entry 5804 (class 2604 OID 21933)
-- Name: solicitudes_revision id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_revision ALTER COLUMN id SET DEFAULT nextval('public.solicitudes_revision_id_seq'::regclass);


--
-- TOC entry 5835 (class 2604 OID 32052)
-- Name: solicitudes_rol id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_rol ALTER COLUMN id SET DEFAULT nextval('public.solicitudes_rol_id_seq'::regclass);


--
-- TOC entry 5810 (class 2604 OID 23387)
-- Name: sos_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_alerts ALTER COLUMN id SET DEFAULT nextval('public.sos_alerts_id_seq'::regclass);


--
-- TOC entry 5816 (class 2604 OID 23401)
-- Name: sos_location_updates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_location_updates ALTER COLUMN id SET DEFAULT nextval('public.sos_location_updates_id_seq'::regclass);


--
-- TOC entry 5801 (class 2604 OID 21910)
-- Name: usuario_reportes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_reportes ALTER COLUMN id SET DEFAULT nextval('public.usuario_reportes_id_seq'::regclass);


--
-- TOC entry 5779 (class 2604 OID 21594)
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- TOC entry 5838 (class 2604 OID 32069)
-- Name: zonas_seguras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zonas_seguras ALTER COLUMN id SET DEFAULT nextval('public.zonas_seguras_id_seq'::regclass);


--
-- TOC entry 6125 (class 0 OID 21808)
-- Dependencies: 229
-- Data for Name: apoyos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.apoyos (id_reporte, id_usuario, fecha_creacion) FROM stdin;
32	2	2025-10-23 20:06:16.632765-05
60	2	2025-10-23 20:12:40.244677-05
39	2	2025-10-23 21:23:02.174248-05
59	2	2025-10-23 23:16:37.358165-05
\.


--
-- TOC entry 6160 (class 0 OID 32027)
-- Dependencies: 264
-- Data for Name: apoyos_pendientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.apoyos_pendientes (id_reporte, id_usuario, fecha_creacion) FROM stdin;
59	2	2025-10-23 23:15:12.921774-05
\.


--
-- TOC entry 6122 (class 0 OID 21607)
-- Dependencies: 226
-- Data for Name: categorias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorias (id, nombre, icono_url, orden) FROM stdin;
4	Delito	\N	1
12	trafico	\N	2
2	Basura	\N	3
1	Bache	\N	4
3	Falla de Alumbrado	\N	5
13	multas	\N	6
15	zona peligrosa	\N	7
5	Otro	\N	9
\.


--
-- TOC entry 6150 (class 0 OID 31850)
-- Dependencies: 254
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, id_reporte, id_remitente, remitente_alias, mensaje, fecha_envio) FROM stdin;
1	45	5	Administrador	as	2025-09-26 05:02:12.272367-05
2	45	5	Administrador	juu	2025-09-26 05:04:07.457587-05
3	45	5	Administrador	dd	2025-09-26 05:17:34.618354-05
4	41	5	Administrador	ffdfdf	2025-09-26 05:25:53.089321-05
5	62	2	holl	cc	2025-10-23 01:56:39.083643-05
6	62	2	holl	ff	2025-10-23 01:57:19.20106-05
\.


--
-- TOC entry 6140 (class 0 OID 21961)
-- Dependencies: 244
-- Data for Name: comentario_apoyos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comentario_apoyos (id, id_comentario, id_usuario, created_at) FROM stdin;
8	11	2	2025-10-23 20:06:35.275649
\.


--
-- TOC entry 6132 (class 0 OID 21888)
-- Dependencies: 236
-- Data for Name: comentario_reportes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comentario_reportes (id, id_comentario, id_reportador, motivo, estado, fecha_creacion) FROM stdin;
7	12	2	mall	pendiente	2025-09-27 19:49:22.739083-05
\.


--
-- TOC entry 6130 (class 0 OID 21852)
-- Dependencies: 234
-- Data for Name: comentarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comentarios (id, id_reporte, id_usuario, comentario, fecha_creacion) FROM stdin;
12	42	17	holaaaa	2025-09-27 19:47:54.989716-05
13	42	17	no quiero	2025-09-27 19:47:59.727876-05
11	32	2	juliooo	2025-09-22 21:46:52.592687-05
15	32	2	sdsdsdsdsds	2025-10-23 20:06:55.132175-05
16	32	2	asasasas	2025-10-23 20:06:58.259584-05
17	60	2	fffdfffff	2025-10-23 20:12:35.948716-05
18	39	2	yrytythgh	2025-10-23 21:23:11.661128-05
19	36	2	Reporte #AP-2025-00056 (Postes de luz a punto de caerse) fue fusionado con este por un líder vecinal.	2025-10-24 00:27:36.122805-05
\.


--
-- TOC entry 6127 (class 0 OID 21825)
-- Dependencies: 231
-- Data for Name: insignias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.insignias (id, nombre, descripcion, icono_url, puntos_necesarios) FROM stdin;
7	Analista Urbano	Otorgada a usuarios con el plan Reportero / Prensa.	\N	\N
4	Guardián Premium	Otorgada a usuarios con el plan Ciudadano Premium.	premium_shield	0
1	Ciudadano Iniciado	Creaste tu primer reporte verificado	school	10
2	Voz Activa	Creaste 5 reportes verificados	record_voice_over	50
3	Guardián del Barrio	Creaste 10 reportes verificados	security	100
5	Colaborador Activo	Alcanzaste 250 puntos de comunidad.	star_purple500	250
6	Defensor de la Ciudad	Alcanzaste 1000 puntos. ¡Tu impacto es notable!	verified_user	1000
\.


--
-- TOC entry 6167 (class 0 OID 32116)
-- Dependencies: 271
-- Data for Name: lider_zonas_asignadas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lider_zonas_asignadas (id, id_usuario, nombre_distrito) FROM stdin;
300	18	El Tallán
301	18	La Unión
302	18	Piura
303	18	La Arena
199	7	Piura
200	7	Castilla
201	7	La Arena
332	2	*
333	17	*
281	15	El Tallán
282	15	La Arena
283	15	La Unión
\.


--
-- TOC entry 6157 (class 0 OID 31907)
-- Dependencies: 261
-- Data for Name: metodos_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.metodos_pago (id, id_usuario, tipo_tarjeta, ultimos_cuatro_digitos, fecha_expiracion, token_tarjeta_cifrado, es_predeterminado) FROM stdin;
1	18	VISA	3222	12/25	tok_sim_1760555876713	f
2	18	VISA	3333	12/22	tok_sim_1760587662289	f
4	19	VISA	1111	10/26	tok_sim_1760592986506	f
5	2	VISA	1111	11/26	tok_sim_1760601802112	f
6	2	VISA	1111	11/25	tok_sim_1760605160267	f
7	2	VISA	7777	05/26	tok_sim_1760609811261	f
3	2	VISA	3333	10/25	tok_sim_1760591117365	t
\.


--
-- TOC entry 6153 (class 0 OID 31880)
-- Dependencies: 257
-- Data for Name: moderation_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.moderation_log (id, id_admin, admin_alias, accion, entidad_tipo, id_entidad, contenido_afectado, motivo_reporte, fecha_accion) FROM stdin;
1	5	maii	desestimar	usuario	\N	mopep	tty	2025-09-27 19:49:38.162915-05
\.


--
-- TOC entry 6148 (class 0 OID 31820)
-- Dependencies: 252
-- Data for Name: notificaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notificaciones (id, id_usuario_receptor, titulo, cuerpo, leido, fecha_envio, payload) FROM stdin;
2	1	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
4	3	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
5	4	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
6	5	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
7	7	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
8	14	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
9	15	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
10	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-23 22:11:19.8973-05	\N
11	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-27 22:32:40.688268-05	\N
12	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-27 22:32:49.579793-05	\N
13	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-09-27 22:32:59.908477-05	\N
16	3	holaaa	como estas\n	f	2025-09-27 23:30:36.954939-05	\N
1	2	promociones	tememos las mejores promociones en nuestro plan premiun\n	t	2025-09-20 19:18:03.61031-05	\N
3	2	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	t	2025-09-23 22:11:19.8973-05	\N
17	3	holaaa	como estas\n	f	2025-10-20 19:44:58.372331-05	{"type": "generic_notification"}
18	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-10-20 19:45:09.345458-05	{"type": "generic_notification"}
19	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-10-20 19:45:15.969319-05	{"type": "generic_notification"}
20	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-10-20 19:46:40.224354-05	\N
21	16	recomendaciones de uso	se recomienda analizar profundamente cada apartado de la app para que se comprenda su uso	f	2025-10-20 19:47:32.796504-05	{"type": "generic_notification"}
22	19	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
23	18	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
24	17	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
25	16	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
26	15	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
27	14	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
28	7	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
29	5	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
30	4	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
31	3	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
33	1	eee	ee	f	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
34	19	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
35	18	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
36	17	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
37	16	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
38	15	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
39	14	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
40	7	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
41	5	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
42	4	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
43	3	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
45	1	gg	g	f	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
46	16	gg	g	f	2025-10-20 20:56:42.388508-05	{"type": "generic_notification"}
47	16	gg	g	f	2025-10-20 20:57:16.01006-05	{"type": "generic_notification"}
48	3	gg	g	f	2025-10-21 00:08:49.13659-05	{"type": "generic_notification"}
49	3	gg	g	f	2025-10-21 00:31:15.563848-05	{"type": "generic_notification"}
50	19	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
51	18	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
52	17	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
53	16	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
54	15	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
55	14	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
56	7	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
57	5	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
58	4	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
59	3	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
61	1	asa	ss	f	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
64	18	Alerta en tu Zona Segura	Se ha verificado un nuevo reporte de 'Delito' cerca de tu zona.	f	2025-10-21 15:48:59.294034-05	{"id": 45, "type": "report_detail"}
65	19	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
66	18	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
67	17	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
68	16	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
69	15	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
70	14	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
71	7	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
72	5	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
73	4	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
74	3	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
76	1	ff	ff	f	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
77	19	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
78	18	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
79	17	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
80	16	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
81	15	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
82	14	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
83	7	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
84	5	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
85	4	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
86	3	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
88	1	d	dd	f	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
89	16	fgf	fg	f	2025-10-22 16:21:57.850576-05	{"type": "generic_notification"}
90	17	ff	ff	f	2025-10-22 16:39:14.183649-05	{"type": "generic_notification"}
92	15	ddd	dd	f	2025-10-22 20:41:45.289224-05	{"type": "admin_message"}
93	19	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
94	18	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
95	17	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
96	16	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
97	15	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
98	14	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
99	7	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
100	5	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
101	4	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
102	3	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
104	1	dd	dd	f	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
32	2	eee	ee	t	2025-10-20 19:47:47.824648-05	{"type": "generic_notification"}
44	2	gg	g	t	2025-10-20 20:43:02.367086-05	{"type": "generic_notification"}
60	2	asa	ss	t	2025-10-21 05:18:36.43755-05	{"type": "generic_notification"}
63	2	Alerta en tu Zona Segura	Se ha verificado un nuevo reporte de 'Delito' cerca de tu zona.	t	2025-10-21 13:33:39.446979-05	{"id": 59, "type": "report_detail"}
75	2	ff	ff	t	2025-10-21 16:30:04.130513-05	{"type": "generic_notification"}
87	2	d	dd	t	2025-10-22 15:37:32.698787-05	{"type": "generic_notification"}
91	2	Alerta en tu Zona Segura	Se ha verificado un nuevo reporte de 'Delito' cerca de tu zona.	t	2025-10-22 20:41:34.564467-05	{"id": 58, "type": "report_detail"}
103	2	dd	dd	t	2025-10-22 20:41:56.004839-05	{"type": "admin_message"}
105	2	Alerta en tu Zona Segura	Se ha verificado un nuevo reporte de 'Delito' cerca de tu zona.	t	2025-10-22 23:16:33.958289-05	{"id": 59, "type": "report_detail"}
110	14	Nuevo comentario en: "oouue"	holaa ha comentado.	f	2025-10-23 21:23:11.661128-05	{"id": 39, "type": "report_detail"}
113	18	Reporte Aprobado: "rrer"	Tu reporte ha sido verificado y ahora es visible.	f	2025-10-23 23:15:24.605561-05	{"id": 59, "type": "report_detail"}
106	2	Solicitud Aprobada	Tu solicitud de revisión para el reporte #41 fue aprobada. El reporte está nuevamente pendiente.	t	2025-10-23 16:19:48.838411-05	{"type": "verification_panel"}
107	2	Solicitud Desestimada	Tu solicitud de revisión para el reporte #46 fue desestimada.	t	2025-10-23 16:20:00.677063-05	{"type": "moderation_history"}
108	2	Solicitud Desestimada	Tu solicitud de revisión para el reporte #43 fue desestimada.	t	2025-10-23 16:22:50.60485-05	{"type": "moderation_history"}
109	2	Solicitud Desestimada	Tu solicitud de revisión para el reporte #42 fue desestimada.	t	2025-10-23 16:24:31.31038-05	{"type": "moderation_history"}
111	2	Reporte Aprobado: "ggt"	Tu reporte ha sido verificado y ahora es visible.	t	2025-10-23 21:45:46.550728-05	{"id": 33, "type": "report_detail"}
112	2	Reporte Rechazado: "LLL"	Tu reporte ha sido revisado pero no pudo ser verificado.	t	2025-10-23 21:45:59.151914-05	{"type": "my_reports"}
114	2	Solicitud Desestimada	Tu solicitud de revisión para el reporte #59 fue desestimada.	t	2025-10-23 23:17:29.02575-05	{"type": "moderation_history"}
115	2	Solicitud Desestimada	Tu solicitud de revisión para el reporte #33 fue desestimada.	t	2025-10-23 23:17:30.006839-05	{"type": "moderation_history"}
116	2	Solicitud Aprobada	Tu solicitud de revisión para el reporte #41 fue aprobada. El reporte está nuevamente pendiente.	t	2025-10-23 23:17:31.237093-05	{"type": "verification_panel"}
117	2	Solicitud Aprobada	Tu solicitud de revisión para el reporte #43 fue aprobada. El reporte está nuevamente pendiente.	t	2025-10-23 23:17:32.522401-05	{"type": "verification_panel"}
118	2	Solicitud Aprobada	Tu solicitud de revisión para el reporte #42 fue aprobada. El reporte está nuevamente pendiente.	t	2025-10-23 23:17:33.295225-05	{"type": "verification_panel"}
119	2	Solicitud Aprobada	Tu solicitud de revisión para el reporte #46 fue aprobada. El reporte está nuevamente pendiente.	t	2025-10-23 23:17:33.920294-05	{"type": "verification_panel"}
120	2	Reporte Fusionado: "Postes de luz a punto de caerse"	Tu reporte #AP-2025-00056 era similar a otro ya verificado (#AP-2025-00023) y ha sido fusionado.	t	2025-10-24 00:27:36.245509-05	{"id": 36, "type": "report_detail"}
\.


--
-- TOC entry 6138 (class 0 OID 21953)
-- Dependencies: 242
-- Data for Name: pgmigrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pgmigrations (id, name, run_on) FROM stdin;
1	1756596909466_temp-drop-table	2025-08-30 18:35:18.652386
2	20250830120000_create_comentario_apoyos_table	2025-08-30 18:35:18.652386
\.


--
-- TOC entry 6155 (class 0 OID 31895)
-- Dependencies: 259
-- Data for Name: planes_suscripcion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planes_suscripcion (id, identificador_plan, nombre_publico, descripcion, precio_mensual, activo) FROM stdin;
1	ciudadano_premium	Ciudadano Premium	Accede a funciones de seguridad avanzadas y dale prioridad a tus reportes.\\n- Alerta SOS con seguimiento en tiempo real.\\n- Reportes con prioridad visual en el mapa.\\n- Acceso a tus estadísticas personales.	15.00	t
2	reportero_prensa	Reportero / Prensa	Todas las ventajas Premium, más herramientas de análisis de datos en la app.\\n- Panel analítico móvil.\\n- Exportación de informes en PDF a tu correo.\\n- Insignia exclusiva de "Analista Urbano".	35.00	t
\.


--
-- TOC entry 6124 (class 0 OID 21616)
-- Dependencies: 228
-- Data for Name: reportes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reportes (id, id_usuario, id_categoria, titulo, descripcion, foto_url, location, categoria_sugerida, estado, es_anonimo, fecha_creacion, fecha_actualizacion, revision_solicitada, urgencia, hora_incidente, tags, impacto, referencia_ubicacion, distrito, codigo_reporte, id_lider_verificador, apoyos_pendientes, id_reporte_original, reportes_vinculados_count) FROM stdin;
63	2	13	gggggg	eesesfsdf	\N	0101000020E6100000653D10B4DD2854C02CB7B41A12B714C0	\N	pendiente_verificacion	f	2025-10-23 22:01:55.006429-05	\N	f	Media	03:00:00	{niños}	A todo el barrio	\N	El Tallán	AP-2025-00063	\N	0	\N	0
54	2	3	fefefe	fdgddfgdgdf	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	pendiente_verificacion	f	2025-09-27 18:47:41.769173-05	2025-10-23 22:15:41.801649-05	f	Media	23:47:00	\N	A mi calle	dfdfff	Cura Mori	AP-2025-00054	\N	0	\N	0
33	2	3	ggt	asa	\N	0101000020E61000003541D47D002954C0933F733161B714C0	\N	verificado	t	2025-09-22 21:53:33.792679-05	2025-10-23 21:45:46.544426-05	f	Media	02:52:00	{niños,urgente}	Solo a mí	sass	Cura Mori	AP-2025-00020	2	0	\N	0
64	2	13	jjooo		\N	0101000020E6100000653D10B4DD2854C02CB7B41A12B714C0	\N	pendiente_verificacion	t	2025-10-24 02:48:51.098299-05	\N	f	Media	07:48:00	{tráfico}	A mi calle	\N	Veintiséis de Octubre	AP-2025-00064	\N	0	\N	0
56	2	3	Postes de luz a punto de caerse	tiene tiempo roto El poste y cada vez esta mas cerca de caerse	https://res.cloudinary.com/dpcaljmat/image/upload/v1759219684/alerta_piura/eizbdmtsj782fjt2qwlg.jpg	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	t	2025-09-30 03:08:05.252674-05	2025-10-24 01:24:25.03488-05	f	Media	08:05:00	{peligroso,niños,urgente}	A mi calle	\N	Catacaos	AP-2025-00056	5	0	36	0
55	2	2	www		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	rechazado	t	2025-09-29 17:20:42.939501-05	2025-10-23 09:33:06.891467-05	f	Media	22:20:00	\N	A mi calle	\N	Catacaos	AP-2025-00055	\N	0	\N	0
32	2	1	baches en la pista recurrente	mucho desorden y dificil de conducir	https://res.cloudinary.com/dpcaljmat/image/upload/v1758594960/alerta_piura/n5qnmrzcjh6nbh3slc0k.jpg	0101000020E61000003541D47D002954C0933F733161B714C0	\N	verificado	f	2025-09-22 21:36:01.443245-05	2025-09-22 21:46:40.247444-05	f	Media	14:34:00	{tráfico,peligroso}	A mi calle	en ignacio merino	Castilla	AP-2025-00019	\N	0	\N	0
58	18	4	erre	asasasasa	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	t	2025-10-15 14:05:17.808507-05	2025-10-22 20:41:34.409412-05	f	Media	19:04:00	\N	A mi calle	\N	La Arena	AP-2025-00058	5	0	\N	0
45	2	4	tablasss		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	f	2025-09-26 01:13:52.487144-05	2025-10-21 15:48:59.25829-05	f	Baja	06:12:00	{peligroso}	A mi calle	\N	Catacaos	AP-2025-00013	5	0	\N	0
57	2	3	uuu	fdfdfdfdf	https://res.cloudinary.com/dpcaljmat/image/upload/v1760465024/alerta_piura/yctfjveuilrdys9fqhif.jpg	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	f	2025-10-14 13:03:45.594518-05	2025-10-22 20:55:19.660585-05	f	Media	18:03:00	{peligroso}	A mi calle	\N	Catacaos	AP-2025-00057	5	0	\N	0
43	2	3	jjj	gggg	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	pendiente_verificacion	f	2025-09-25 01:45:18.074262-05	2025-10-23 23:17:32.518098-05	f	Media	06:44:00	{peligroso}	A mi calle	\N	Cura Mori	AP-2025-00030	\N	0	\N	0
42	2	2	WWW		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	pendiente_verificacion	t	2025-09-25 01:12:51.253958-05	2025-10-23 23:17:33.291708-05	f	Media	06:12:00	\N	Solo a mí	ZXA	Castilla	AP-2025-00029	\N	0	\N	0
34	2	1	rtt	ffg	\N	0101000020E61000003541D47D002954C0933F733161B714C0	\N	rechazado	f	2025-09-22 22:48:47.639295-05	2025-09-23 01:49:34.839539-05	f	Alta	03:48:00	{tráfico}	A mi calle	wew	Cura Mori	AP-2025-00021	\N	0	\N	0
35	2	1	dssd	fdffd	https://res.cloudinary.com/dpcaljmat/image/upload/v1758606479/alerta_piura/oytnebunh6bmd2nllg59.jpg	0101000020E61000003541D47D002954C0933F733161B714C0	\N	verificado	t	2025-09-23 00:48:01.099859-05	2025-09-23 04:38:59.5026-05	f	Media	05:44:00	\N	A todo el barrio	gfg	Catacaos	AP-2025-00022	\N	0	\N	0
61	2	3	aaaa		\N	0101000020E6100000653D10B4DD2854C02CB7B41A12B714C0	\N	oculto	f	2025-10-18 19:18:15.274445-05	2025-10-22 23:16:19.551247-05	f	Media	00:17:00	\N	A mi calle	\N	Piura	AP-2025-00061	5	0	\N	0
37	2	13	peligroso	ffdd	https://res.cloudinary.com/dpcaljmat/image/upload/v1758773026/alerta_piura/zcnudyp0yd15shq8ztm9.jpg	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	rechazado	f	2025-09-24 23:03:48.346551-05	2025-10-21 15:49:07.873585-05	f	Alta	04:02:00	{tráfico,urgente,peligroso}	Solo a mí	ssds	La Unión	AP-2025-00024	\N	0	\N	0
60	2	1	Bache	Se encontro bache	https://res.cloudinary.com/dpcaljmat/image/upload/v1760618787/alerta_piura/vojrnr1igorcurnddeny.jpg	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	oculto	t	2025-10-16 07:46:28.380045-05	2025-10-22 23:16:27.966468-05	f	Media	12:43:00	{tráfico}	A todo el barrio	serca de la utp	Las Lomas	AP-2025-00060	5	0	\N	0
62	2	4	dd		\N	0101000020E6100000653D10B4DD2854C02CB7B41A12B714C0	\N	pendiente_verificacion	f	2025-10-19 11:01:12.384286-05	2025-10-22 20:55:38.978026-05	f	Media	16:00:00	\N	A mi calle	\N	Cura Mori	AP-2025-00062	5	0	\N	0
46	2	5	zona con poca iluminacion	es una zona con poca seguridad policial y poca iluminada	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	zona peligrosa	pendiente_verificacion	t	2025-09-27 01:05:13.900903-05	2025-10-23 23:17:33.916695-05	f	Media	02:03:00	{peligroso,urgente}	A mi calle	\N	La Arena	AP-2025-00014	\N	0	\N	0
59	18	4	rrer	errer	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	pendiente_verificacion	t	2025-10-15 14:23:40.270005-05	2025-10-23 23:17:50.01054-05	f	Media	19:23:00	\N	A mi calle	\N	Piura	AP-2025-00059	2	1	\N	0
36	2	1	gfgf	ghg	https://res.cloudinary.com/dpcaljmat/image/upload/v1758610152/alerta_piura/czc4fsv6icxx4kaxyd2y.jpg	0101000020E61000003541D47D002954C0933F733161B714C0	\N	verificado	f	2025-09-23 01:49:13.799644-05	2025-09-24 21:43:17.766814-05	f	Alta	06:48:00	{urgente}	A todo el barrio	hhhh	Veintiséis de Octubre	AP-2025-00023	\N	0	\N	1
41	2	12	LLL		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	pendiente_verificacion	f	2025-09-25 01:03:18.154316-05	2025-10-23 23:17:31.234783-05	f	Media	06:02:00	{H,urgente}	A mi calle	\N	Cura Mori	AP-2025-00028	\N	0	\N	0
53	2	2	jj		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	f	2025-09-27 18:40:53.816989-05	2025-09-29 07:57:25.71711-05	f	Media	23:40:00	\N	A mi calle	\N	La Arena	AP-2025-00053	\N	0	\N	0
52	2	12	ddwe		\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	f	2025-09-27 09:44:00.323879-05	2025-09-27 09:45:27.881266-05	f	Media	14:43:00	\N	A mi calle	ss	Catacaos	AP-2025-00052	\N	0	\N	0
39	14	1	oouue	ass	\N	0101000020E61000006312899D042954C05F07CE1951BA14C0	\N	verificado	f	2025-09-25 00:29:20.627017-05	2025-09-27 06:05:04.917173-05	f	Media	05:28:00	{cc,niños}	A mi calle	\N	El Tallán	AP-2025-00026	\N	0	\N	0
\.


--
-- TOC entry 6159 (class 0 OID 31945)
-- Dependencies: 263
-- Data for Name: reportes_prioritarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reportes_prioritarios (id_reporte, id_usuario_premium, fecha_creacion) FROM stdin;
59	18	2025-10-15 14:23:40.270005-05
60	2	2025-10-16 07:46:28.380045-05
61	2	2025-10-18 19:18:15.274445-05
62	2	2025-10-19 11:01:12.384286-05
64	2	2025-10-24 02:48:51.098299-05
\.


--
-- TOC entry 6165 (class 0 OID 32081)
-- Dependencies: 269
-- Data for Name: reportes_seguidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reportes_seguidos (id_usuario, id_reporte, fecha_seguimiento) FROM stdin;
18	58	2025-10-15 14:07:12.781048-05
2	46	2025-10-16 17:52:46.068982-05
2	32	2025-10-23 20:07:11.789518-05
2	59	2025-10-23 23:16:45.656207-05
\.


--
-- TOC entry 6146 (class 0 OID 31805)
-- Dependencies: 250
-- Data for Name: simulated_sms_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.simulated_sms_log (id, id_usuario_sos, contacto_nombre, contacto_telefono, mensaje, fecha_envio) FROM stdin;
1	2	julio	987654321	ALERTA SOS de julio (N/A). Ubicación: http://maps.google.com/?q=-5.1800667,-80.644435. Mensaje: "¡Necesito ayuda urgente!"	2025-09-20 08:19:19.782409-05
2	2	julio	987654321	ALERTA SOS de julio (N/A). Ubicación: http://maps.google.com/?q=-5.1800667,-80.644435. Mensaje: "¡Necesito ayuda urgente!"	2025-09-20 08:29:23.171111-05
3	2	julio	987654321	ALERTA SOS de julio (N/A). Ubicación: http://maps.google.com/?q=-5.1800667,-80.644435. Mensaje: "¡Necesito ayuda urgente!"	2025-09-20 08:45:50.919013-05
4	2	elena 	456789012	ALERTA SOS de julio (987653789). Última ubicación conocida: http://maps.google.com/maps?q=-5.1790817,-80.640655. Mensaje personalizado: "¡Necesito ayuda urgente!"	2025-09-24 03:15:49.841112-05
5	2	Julio	987654321	ALERTA SOS de julio (987653789). Última ubicación conocida: http://maps.google.com/maps?q=-5.18195,-80.6409067. Mensaje personalizado: "¡Necesito ayuda urgente!"	2025-09-30 03:12:49.916241-05
\.


--
-- TOC entry 6136 (class 0 OID 21930)
-- Dependencies: 240
-- Data for Name: solicitudes_revision; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.solicitudes_revision (id, id_reporte, id_lider, estado, fecha_solicitud, motivo) FROM stdin;
50	33	2	pendiente	2025-10-23 23:17:59.86192-05	Reevaluar estado
10	41	2	aprobada	2025-09-26 01:14:23.491061-05	\N
9	43	2	desestimada	2025-09-26 01:14:11.857473-05	\N
11	42	2	desestimada	2025-09-26 02:30:15.079068-05	\N
12	45	2	aprobada	2025-09-27 03:51:34.695349-05	\N
13	45	2	desestimada	2025-09-27 04:17:54.014787-05	\N
14	45	2	desestimada	2025-09-27 04:18:05.473248-05	\N
15	45	2	desestimada	2025-09-27 04:18:28.45572-05	\N
17	43	2	aprobada	2025-09-27 04:45:17.801092-05	\N
16	39	2	desestimada	2025-09-27 04:25:49.53495-05	\N
18	39	2	desestimada	2025-09-27 05:18:05.174086-05	\N
21	37	2	desestimada	2025-09-27 06:02:20.611969-05	\N
22	45	2	desestimada	2025-09-27 06:02:22.023051-05	\N
23	34	2	desestimada	2025-09-27 06:02:33.735137-05	\N
24	33	2	aprobada	2025-09-27 06:02:41.232857-05	\N
25	45	2	aprobada	2025-09-27 06:03:47.366041-05	\N
26	39	2	aprobada	2025-09-27 06:04:19.485702-05	\N
27	46	2	aprobada	2025-09-27 06:46:08.876082-05	\N
28	33	2	aprobada	2025-09-27 09:08:09.313809-05	\N
29	41	2	aprobada	2025-09-27 09:47:09.514701-05	\N
30	56	2	aprobada	2025-10-23 01:58:16.914937-05	\N
31	33	2	desestimada	2025-10-23 02:01:14.893169-05	\N
34	33	2	desestimada	2025-10-23 12:55:39.004232-05	\N
36	33	2	desestimada	2025-10-23 15:25:59.945229-05	Corregir datos
35	43	2	desestimada	2025-10-23 14:27:29.387868-05	\N
33	42	2	desestimada	2025-10-23 12:55:21.240977-05	\N
32	46	2	desestimada	2025-10-23 12:55:06.028892-05	\N
37	33	2	aprobada	2025-10-23 15:26:41.996768-05	Corregir datos
38	41	2	desestimada	2025-10-23 15:27:28.017287-05	Corregir datos
39	41	2	desestimada	2025-10-23 15:46:08.698977-05	Reevaluar estado
40	41	2	aprobada	2025-10-23 15:46:21.120219-05	Reevaluar estado
41	46	2	desestimada	2025-10-23 16:09:19.362769-05	Reevaluar estado
43	43	2	desestimada	2025-10-23 16:21:18.104533-05	Reevaluar estado
42	42	2	desestimada	2025-10-23 16:21:09.977567-05	Reevaluar estado
49	59	2	desestimada	2025-10-23 23:17:01.683853-05	Reevaluar estado
48	33	2	desestimada	2025-10-23 22:02:48.086417-05	Reevaluar estado
47	41	2	aprobada	2025-10-23 21:46:46.644325-05	Reevaluar estado
46	43	2	aprobada	2025-10-23 18:13:19.437969-05	Reevaluar estado
45	42	2	aprobada	2025-10-23 18:13:02.106626-05	Reevaluar estado
44	46	2	aprobada	2025-10-23 16:37:31.0643-05	Reevaluar estado
\.


--
-- TOC entry 6162 (class 0 OID 32049)
-- Dependencies: 266
-- Data for Name: solicitudes_rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.solicitudes_rol (id, id_usuario, motivos, estado, fecha_solicitud, motivacion, zona_propuesta) FROM stdin;
1	18	\N	aprobado	2025-10-14 19:24:54.604297-05	\N	\N
3	19	\N	aprobado	2025-10-16 01:37:40.147948-05	\N	\N
4	2	\N	aprobado	2025-10-23 08:10:23.825111-05	QUIERO AYUDAR	catacaos
5	2	\N	rechazado	2025-10-23 08:11:07.899202-05	hola	Lima
6	2	\N	pendiente	2025-10-23 20:08:03.11903-05	fdfdfdf	sss
\.


--
-- TOC entry 6142 (class 0 OID 23384)
-- Dependencies: 246
-- Data for Name: sos_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sos_alerts (id, id_usuario, estado, fecha_inicio, fecha_fin, revisada, estado_atencion, contacto_emergencia_telefono, contacto_emergencia_mensaje, codigo_alerta, duracion_segundos) FROM stdin;
57	2	finalizado	2025-09-30 03:12:49.907532-05	2025-09-30 03:17:50.05515-05	t	Atendida	987654321	¡Necesito ayuda urgente!	SOS-2025-00040	300
34	2	finalizado	2025-09-24 07:25:14.028139-05	2025-09-24 07:30:18.318939-05	t	En Espera	\N	\N	SOS-2025-00017	300
48	2	finalizado	2025-09-26 06:18:14.375166-05	2025-09-26 06:28:14.472243-05	t	En Espera	\N	\N	SOS-2025-00031	600
24	2	finalizado	2025-09-24 03:36:47.663779-05	2025-09-24 03:41:51.906821-05	t	Atendida	\N	\N	SOS-2025-00007	600
18	2	finalizado	2025-09-24 00:32:39.278687-05	\N	t	Atendida	\N	\N	\N	600
36	2	finalizado	2025-09-24 07:37:39.689917-05	2025-09-24 07:42:44.035153-05	t	En Espera	\N	\N	SOS-2025-00019	300
20	2	finalizado	2025-09-24 03:15:49.820585-05	\N	t	Atendida	456789012	¡Necesito ayuda urgente!	SOS-2025-00003	600
21	2	finalizado	2025-09-24 03:17:09.59166-05	\N	t	Atendida	\N	\N	SOS-2025-00004	600
23	2	finalizado	2025-09-24 03:25:38.269868-05	\N	t	Atendida	\N	\N	SOS-2025-00006	600
25	2	finalizado	2025-09-24 04:16:33.499017-05	2025-09-24 04:21:33.683799-05	t	Atendida	\N	\N	SOS-2025-00008	600
50	2	finalizado	2025-09-26 06:27:29.364189-05	\N	t	En Espera	\N	\N	SOS-2025-00033	300
37	2	finalizado	2025-09-24 08:00:12.38833-05	2025-09-24 08:05:16.656159-05	t	En Espera	\N	\N	SOS-2025-00020	300
26	2	finalizado	2025-09-24 04:20:25.767085-05	\N	t	Atendida	\N	\N	SOS-2025-00009	600
49	2	finalizado	2025-09-26 06:24:46.273438-05	\N	t	En Espera	\N	\N	SOS-2025-00032	300
47	2	finalizado	2025-09-26 06:12:00.666086-05	\N	t	En Espera	\N	\N	SOS-2025-00030	600
27	2	finalizado	2025-09-24 05:00:21.223876-05	2025-09-24 05:05:25.296144-05	t	En Curso	\N	\N	SOS-2025-00010	600
38	2	finalizado	2025-09-24 08:14:30.182646-05	2025-09-24 08:19:34.169316-05	t	En Espera	\N	\N	SOS-2025-00021	300
28	2	finalizado	2025-09-24 05:06:21.402236-05	2025-09-24 05:11:25.652399-05	t	En Espera	\N	\N	SOS-2025-00011	600
19	2	finalizado	2025-09-24 01:11:45.324411-05	\N	t	En Espera	\N	\N	\N	600
44	2	finalizado	2025-09-26 06:09:43.719856-05	\N	t	En Espera	\N	\N	SOS-2025-00027	600
29	2	finalizado	2025-09-24 05:21:23.367717-05	2025-09-24 05:26:24.513969-05	t	En Espera	\N	\N	SOS-2025-00012	600
39	2	finalizado	2025-09-24 08:20:02.166077-05	2025-09-24 08:25:06.361027-05	t	En Espera	\N	\N	SOS-2025-00022	300
30	2	finalizado	2025-09-24 06:02:03.57569-05	2025-09-24 06:07:07.616516-05	t	En Espera	\N	\N	SOS-2025-00013	600
42	2	finalizado	2025-09-26 06:06:53.731814-05	\N	t	En Espera	\N	\N	SOS-2025-00025	600
22	2	finalizado	2025-09-24 03:18:15.343407-05	\N	t	Atendida	\N	\N	SOS-2025-00005	600
31	2	finalizado	2025-09-24 06:11:02.92695-05	2025-09-24 06:16:07.371587-05	t	En Espera	\N	\N	SOS-2025-00014	600
40	2	finalizado	2025-09-24 21:50:51.156915-05	2025-09-24 21:55:51.292755-05	t	En Espera	\N	\N	SOS-2025-00023	300
32	2	finalizado	2025-09-24 06:16:42.183476-05	2025-09-24 06:21:46.490552-05	t	En Espera	\N	\N	SOS-2025-00015	600
41	2	finalizado	2025-09-26 06:06:22.713789-05	\N	t	En Espera	\N	\N	SOS-2025-00024	600
51	2	finalizado	2025-09-26 06:33:59.648486-05	\N	t	En Espera	\N	\N	SOS-2025-00034	300
52	2	finalizado	2025-09-26 06:39:15.741974-05	2025-09-26 06:44:15.837982-05	t	En Espera	\N	\N	SOS-2025-00035	300
53	2	finalizado	2025-09-26 06:41:20.890622-05	2025-09-26 06:46:20.998811-05	t	En Espera	\N	\N	SOS-2025-00036	300
33	2	finalizado	2025-09-24 06:59:33.005972-05	2025-09-24 07:04:36.954283-05	t	En Espera	\N	\N	SOS-2025-00016	300
43	2	finalizado	2025-09-26 06:08:06.680433-05	2025-09-26 06:18:06.797347-05	t	En Espera	\N	\N	SOS-2025-00026	600
35	2	finalizado	2025-09-24 07:31:44.363772-05	2025-09-24 07:36:48.799578-05	t	En Espera	\N	\N	SOS-2025-00018	300
45	2	finalizado	2025-09-26 06:10:04.942256-05	2025-09-26 06:20:05.050215-05	t	En Espera	\N	\N	SOS-2025-00028	600
54	2	finalizado	2025-09-26 06:48:23.143916-05	2025-09-26 06:53:23.224507-05	t	En Espera	\N	\N	SOS-2025-00037	300
46	2	finalizado	2025-09-26 06:10:45.543497-05	\N	t	Atendida	\N	\N	SOS-2025-00029	600
56	2	finalizado	2025-09-30 02:51:01.086795-05	\N	t	Atendida	\N	\N	SOS-2025-00039	600
55	2	finalizado	2025-09-29 17:26:10.397773-05	2025-09-29 17:36:10.611907-05	t	En Curso	\N	\N	SOS-2025-00038	600
\.


--
-- TOC entry 6144 (class 0 OID 23398)
-- Dependencies: 248
-- Data for Name: sos_location_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sos_location_updates (id, id_alerta_sos, location, fecha_registro) FROM stdin;
509	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:32:39.285646-05
510	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:32:58.319997-05
511	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:33:13.339126-05
512	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:33:28.272338-05
513	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:33:43.317438-05
514	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:33:58.43094-05
515	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:34:13.358633-05
516	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:34:28.366188-05
517	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:34:43.301975-05
518	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:34:58.363724-05
519	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:35:13.308184-05
520	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:35:28.333982-05
521	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:35:43.390843-05
522	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:35:58.37841-05
523	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:36:13.401475-05
524	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:36:28.403062-05
525	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:36:43.386168-05
526	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:36:58.468875-05
527	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:37:13.456208-05
528	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:37:28.580911-05
529	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:37:43.473846-05
530	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:37:58.52173-05
531	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:38:13.482746-05
532	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:38:28.506505-05
533	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:38:43.530491-05
534	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:38:58.510274-05
535	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:39:13.470043-05
536	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:39:28.505747-05
537	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:39:43.531275-05
538	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:39:58.551345-05
539	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:40:13.53224-05
540	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:40:28.65718-05
541	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:40:43.838643-05
542	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:40:58.814147-05
543	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:41:13.790784-05
544	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:41:28.725214-05
545	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:41:43.758699-05
546	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:41:58.81011-05
547	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:42:13.906881-05
548	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:42:28.82745-05
549	18	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 00:42:43.981774-05
550	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:11:45.330998-05
551	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:12:04.301337-05
552	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:12:19.492344-05
553	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:12:34.3857-05
554	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:12:49.480795-05
555	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:13:04.446474-05
556	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:13:19.408114-05
557	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:13:34.408208-05
558	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:13:49.511943-05
559	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:14:04.416944-05
560	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:14:19.45517-05
561	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:14:34.425756-05
562	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:14:49.587622-05
563	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:15:04.407359-05
564	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:15:19.461157-05
565	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:15:34.527349-05
566	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:15:49.575482-05
567	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:16:04.505733-05
568	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:16:19.58879-05
569	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:16:34.526784-05
570	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:16:49.521277-05
571	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:17:04.536249-05
572	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:17:19.491305-05
573	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:17:34.540826-05
574	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:17:49.596172-05
575	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:18:04.571173-05
576	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:18:19.585169-05
577	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:18:34.58508-05
578	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:18:49.623043-05
579	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:19:04.663663-05
580	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:19:19.759267-05
581	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:19:34.67136-05
582	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:19:49.724634-05
583	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:20:04.791634-05
584	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:20:19.864058-05
585	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:20:34.901225-05
586	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:20:50.167794-05
587	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:21:05.02595-05
588	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:21:19.0964-05
589	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:21:34.298871-05
590	19	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 01:21:49.182397-05
591	20	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:15:49.828067-05
592	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:17:09.59532-05
593	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:17:28.607253-05
594	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:17:43.627001-05
595	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:17:58.593637-05
596	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:13.552743-05
597	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:15.348357-05
598	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:28.575404-05
599	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:30.409541-05
600	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:43.73877-05
601	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:45.426506-05
602	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:18:58.631026-05
603	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:00.429307-05
604	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:13.755813-05
605	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:15.405166-05
606	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:28.765046-05
607	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:30.461486-05
608	21	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:43.746643-05
609	22	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:19:45.424167-05
610	23	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:25:38.277667-05
611	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:36:47.67051-05
612	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:37:07.918645-05
613	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:37:22.076999-05
614	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:37:37.134182-05
615	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:37:52.245937-05
616	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:38:07.161146-05
617	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:38:22.494494-05
618	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:38:37.269148-05
619	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:38:52.553932-05
620	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:39:07.149679-05
621	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:39:22.216347-05
622	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:39:37.589258-05
623	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:39:52.212639-05
624	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:40:07.169365-05
625	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:40:22.258971-05
626	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:40:37.696028-05
627	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:40:52.344731-05
628	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:41:07.243172-05
629	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:41:21.833412-05
630	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:41:37.780008-05
631	24	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 03:41:51.827916-05
632	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:16:33.503483-05
633	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:16:52.507083-05
634	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:17:07.539684-05
635	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:17:22.559193-05
636	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:17:37.517133-05
637	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:17:52.570608-05
638	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:18:07.537105-05
639	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:18:22.571459-05
640	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:18:37.832475-05
641	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:18:52.593138-05
642	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:19:07.77739-05
643	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:19:22.643042-05
644	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:19:37.825262-05
645	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:19:52.696782-05
646	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:07.826117-05
647	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:22.603206-05
648	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:25.771181-05
649	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:37.664-05
650	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:40.927619-05
651	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:52.688977-05
652	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:20:56.119725-05
653	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:07.661681-05
654	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:14.681804-05
655	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:18.593978-05
656	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:29.744138-05
657	25	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:33.649294-05
658	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:44.790546-05
659	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:21:56.192281-05
660	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:22:12.258075-05
661	26	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 04:22:30.035108-05
662	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:00:21.231169-05
663	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:00:40.685364-05
664	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:00:55.590026-05
665	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:01:10.731541-05
666	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:01:25.575561-05
667	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:01:41.034628-05
668	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:01:55.632098-05
669	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:02:10.584753-05
670	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:02:25.513061-05
671	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:02:40.211944-05
672	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:02:55.098883-05
673	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:03:10.249773-05
674	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:03:25.140717-05
675	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:03:40.274339-05
676	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:03:55.137509-05
677	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:04:10.554711-05
678	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:04:25.119105-05
679	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:04:40.370691-05
680	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:04:55.210662-05
681	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:05:10.288159-05
682	27	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:05:25.227959-05
683	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:06:21.407902-05
684	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:06:40.493684-05
685	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:06:55.337632-05
686	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:07:10.490439-05
687	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:07:25.445878-05
688	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:07:40.524999-05
689	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:07:55.417938-05
690	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:08:10.51238-05
691	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:08:25.479316-05
692	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:08:40.547743-05
693	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:08:55.528172-05
694	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:09:10.597817-05
695	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:09:25.602932-05
696	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:09:40.658487-05
697	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:09:55.647474-05
698	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:10:10.612897-05
699	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:10:25.603817-05
700	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:10:40.667368-05
701	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:10:55.713015-05
702	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:11:10.750674-05
703	28	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:11:25.547738-05
704	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:21:23.374184-05
705	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:21:42.497584-05
706	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:21:57.370452-05
707	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:22:12.424188-05
708	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:22:27.414744-05
709	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:22:42.399428-05
710	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:22:57.431392-05
711	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:23:12.600339-05
712	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:23:27.518106-05
713	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:23:42.486703-05
714	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:23:57.562927-05
715	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:24:12.597977-05
716	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:24:27.57995-05
717	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:24:42.629746-05
718	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:24:57.736151-05
719	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:25:12.648751-05
720	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:25:27.667629-05
721	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:25:42.684845-05
722	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:25:57.647782-05
723	29	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 05:26:12.6936-05
724	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:02:03.582283-05
725	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:02:23.332978-05
726	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:02:38.364273-05
727	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:02:53.396182-05
728	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:03:08.375276-05
729	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:03:23.382615-05
730	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:03:38.332952-05
731	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:03:53.426828-05
732	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:04:08.361797-05
733	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:04:23.376023-05
734	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:04:38.358919-05
735	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:04:53.403394-05
736	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:05:07.416533-05
737	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:05:22.532732-05
738	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:05:37.411445-05
739	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:05:53.459972-05
740	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:06:07.418945-05
741	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:06:22.754623-05
742	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:06:37.484556-05
743	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:06:52.518704-05
744	30	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:07:07.543102-05
745	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:11:02.933523-05
746	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:11:21.826791-05
747	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:11:36.876112-05
748	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:11:52.00919-05
749	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:12:06.900164-05
750	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:12:22.00939-05
751	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:12:37.129596-05
752	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:12:51.926089-05
753	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:13:06.953207-05
754	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:13:22.000803-05
755	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:13:37.226017-05
756	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:13:51.990337-05
757	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:14:07.011944-05
758	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:14:22.09692-05
759	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:14:37.198928-05
760	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:14:52.013111-05
761	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:15:07.151666-05
762	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:15:23.760468-05
763	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:15:37.075802-05
764	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:15:52.104022-05
765	31	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:16:07.271402-05
766	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:16:42.19277-05
767	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:17:01.142307-05
768	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:17:16.309431-05
769	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:17:31.11209-05
770	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:17:46.242397-05
771	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:18:01.189916-05
772	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:18:16.208228-05
773	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:18:31.258939-05
774	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:18:46.200807-05
775	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:19:01.277815-05
776	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:19:16.272835-05
777	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:19:31.219653-05
778	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:19:46.324597-05
779	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:20:01.224317-05
780	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:20:16.296136-05
781	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:20:31.288872-05
782	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:20:46.279835-05
783	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:21:01.247986-05
784	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:21:16.497594-05
785	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:21:31.265971-05
786	32	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:21:46.352688-05
787	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:59:33.012548-05
788	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 06:59:52.819744-05
789	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:00:07.644117-05
790	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:00:22.847917-05
791	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:00:37.776513-05
792	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:00:53.007113-05
793	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:01:07.104905-05
794	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:01:22.917805-05
795	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:01:37.926342-05
796	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:01:52.797942-05
797	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:02:07.059174-05
798	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:02:21.834693-05
799	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:02:36.927396-05
800	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:02:51.848091-05
801	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:03:06.904414-05
802	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:03:21.897678-05
803	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:03:36.930873-05
804	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:03:51.931427-05
805	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:04:07.007914-05
806	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:04:21.96357-05
807	33	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:04:36.899383-05
808	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:25:14.031317-05
809	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:25:33.109833-05
810	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:25:48.114326-05
811	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:26:03.385145-05
812	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:26:18.041131-05
813	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:26:33.132736-05
814	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:26:48.122454-05
815	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:27:03.101725-05
816	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:27:18.329881-05
817	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:27:33.153765-05
818	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:27:48.132342-05
819	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:28:03.253583-05
820	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:28:18.189721-05
821	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:28:33.124785-05
822	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:28:48.224655-05
823	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:29:03.251065-05
824	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:29:18.300603-05
825	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:29:33.279001-05
826	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:29:48.29386-05
827	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:30:03.211916-05
828	34	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:30:18.226423-05
829	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:31:44.373058-05
830	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:32:03.430229-05
831	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:32:19.366731-05
832	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:32:33.456059-05
833	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:32:48.555017-05
834	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:33:03.321805-05
835	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:33:18.361016-05
836	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:33:33.376676-05
837	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:33:48.571941-05
838	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:34:03.395749-05
839	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:34:18.475471-05
840	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:34:33.453325-05
841	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:34:48.770658-05
842	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:35:03.451646-05
843	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:35:18.904275-05
844	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:35:33.620136-05
845	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:35:48.756145-05
846	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:36:03.614657-05
847	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:36:18.892276-05
848	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:36:33.809748-05
849	35	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:36:48.68171-05
850	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:37:39.695278-05
851	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:37:58.816535-05
852	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:38:13.927805-05
853	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:38:28.921394-05
854	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:38:43.759416-05
855	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:38:58.89482-05
856	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:39:13.768641-05
857	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:39:29.026791-05
858	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:39:43.781108-05
859	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:39:59.030568-05
860	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:40:13.92491-05
861	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:40:28.938587-05
862	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:40:43.991683-05
863	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:40:59.141063-05
864	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:41:14.038066-05
865	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:41:29.042422-05
866	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:41:44.002587-05
867	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:41:58.993395-05
868	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:42:13.991339-05
869	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:42:29.040442-05
870	36	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 07:42:43.982156-05
871	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:00:12.395302-05
872	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:00:31.289018-05
873	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:00:46.419521-05
874	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:01:01.413861-05
875	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:01:16.455908-05
876	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:01:31.407503-05
877	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:01:46.476065-05
878	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:02:01.580001-05
879	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:02:16.782719-05
880	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:02:31.480005-05
881	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:02:46.576089-05
882	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:03:01.497792-05
883	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:03:16.71892-05
884	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:03:31.509873-05
885	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:03:46.5862-05
886	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:04:01.565726-05
887	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:04:16.585001-05
888	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:04:31.591452-05
889	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:04:46.689436-05
890	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:05:01.59434-05
891	37	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:05:16.593063-05
892	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:14:30.192295-05
893	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:14:48.987802-05
894	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:15:05.03949-05
895	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:15:18.970289-05
896	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:15:34.997481-05
897	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:15:50.014995-05
898	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:16:04.040116-05
899	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:16:19.04178-05
900	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:16:34.178844-05
901	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:16:48.982034-05
902	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:17:04.101063-05
903	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:17:19.042827-05
904	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:17:34.134608-05
905	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:17:49.046231-05
906	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:18:04.10467-05
907	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:18:19.092876-05
908	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:18:34.102172-05
909	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:18:49.130157-05
910	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:19:04.103409-05
911	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:19:19.096385-05
912	38	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:19:34.09267-05
913	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:20:02.173204-05
914	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:20:21.0694-05
915	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:20:36.430379-05
916	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:20:51.11633-05
917	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:21:06.205631-05
918	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:21:21.248625-05
919	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:21:36.161093-05
920	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:21:51.271496-05
921	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:22:06.19877-05
922	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:22:21.18265-05
923	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:22:36.258906-05
924	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:22:51.223137-05
925	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:23:06.361901-05
926	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:23:21.227967-05
927	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:23:36.279999-05
928	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:23:51.244851-05
929	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:24:06.49213-05
930	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:24:21.277452-05
931	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:24:36.427171-05
932	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:24:51.58984-05
933	39	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 08:25:06.306829-05
934	40	0101000020E61000003541D47D002954C0933F733161B714C0	2025-09-24 21:50:51.163855-05
935	40	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-24 21:54:37.309197-05
936	41	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:06:22.721851-05
937	42	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:06:53.741208-05
938	43	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:08:06.688242-05
939	44	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:09:43.728393-05
940	45	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:10:04.948852-05
941	46	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:10:45.551588-05
942	43	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:11:55.762534-05
943	47	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:12:00.673295-05
944	45	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:13:53.820742-05
945	43	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:15:40.907622-05
946	45	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:17:38.970463-05
947	48	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:18:14.381805-05
948	48	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:22:03.18848-05
949	49	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:24:46.280664-05
950	48	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:25:45.602206-05
951	50	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:27:29.371088-05
952	51	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:33:59.65377-05
953	52	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:39:15.750842-05
954	53	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:41:20.897029-05
955	52	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:43:04.930806-05
956	53	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:45:10.159661-05
957	54	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:48:23.149879-05
958	54	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-26 06:52:12.327056-05
959	55	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-29 17:26:10.410139-05
960	55	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-29 17:29:59.41705-05
961	55	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-29 17:33:44.525746-05
962	56	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-30 02:51:01.098213-05
963	56	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-30 02:54:51.215207-05
964	56	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-30 02:58:35.23128-05
965	57	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-30 03:12:49.911785-05
966	57	0101000020E61000006312899D042954C05F07CE1951BA14C0	2025-09-30 03:16:40.122359-05
\.


--
-- TOC entry 5778 (class 0 OID 20832)
-- Dependencies: 219
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 6158 (class 0 OID 31920)
-- Dependencies: 262
-- Data for Name: transacciones_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transacciones_pago (id, id_usuario, id_plan, id_metodo_pago, monto_pagado, fecha_transaccion, id_transaccion_pasarela, estado_transaccion) FROM stdin;
3d37afb2-13ac-4983-bb83-2053cb397aa7	18	1	1	15.00	2025-10-15 14:17:56.704626-05	sim_txn_1760555876721	APROBADO
b39be029-626b-4759-bd3d-0d4de01ef52d	18	1	2	15.00	2025-10-15 23:07:42.284467-05	sim_txn_1760587662296	APROBADO
ee17b5ec-aa49-44f1-9b31-0507d3c66544	2	2	3	35.00	2025-10-16 00:05:17.360696-05	sim_txn_1760591117373	APROBADO
ab622d16-c5c2-4267-b397-1f4e48c256c1	19	1	4	15.00	2025-10-16 00:36:26.503592-05	sim_txn_1760592986509	APROBADO
ea8f6c92-6baf-40db-9242-9041435ba2cf	2	1	5	15.00	2025-10-16 03:03:22.106096-05	sim_txn_1760601802118	APROBADO
dc727a62-ef9c-482d-88a6-5efc97e6d3a7	2	1	6	15.00	2025-10-16 03:59:20.263901-05	sim_txn_1760605160277	APROBADO
0e9ee97b-21a7-4405-aff9-aeabaefee09a	2	1	5	15.00	2025-10-16 04:39:44.014956-05	sim_txn_1760607584021	APROBADO
a9cb6f05-4c09-48d2-8f03-a6b1a7e54db4	2	2	6	35.00	2025-10-16 04:41:47.560655-05	sim_txn_1760607707562	APROBADO
8338009b-e0af-4c89-aedf-0e00e0988b6f	2	1	7	15.00	2025-10-16 05:17:47.615608-05	sim_txn_1760609867623	APROBADO
acb1ceb0-a5d3-4f5c-9a57-3958baef5c46	2	2	7	35.00	2025-10-16 14:18:37.285534-05	sim_txn_1760642317289	APROBADO
827c5372-16a3-431a-bb64-5b81b6159a29	2	1	7	15.00	2025-10-16 14:36:14.662367-05	sim_txn_1760643374665	APROBADO
068f88af-4bf3-4170-99c5-50b72010257c	2	2	7	35.00	2025-10-16 17:02:49.010711-05	sim_txn_1760652169013	APROBADO
4a9d8004-a03b-4b27-9a9a-c59896585d6b	2	2	3	35.00	2025-10-17 03:46:21.390676-05	sim_txn_1760690781399	APROBADO
ed946863-44a2-42de-a6c5-700421055dc4	2	1	3	15.00	2025-10-24 02:35:31.347289-05	sim_txn_1761291331358	APROBADO
\.


--
-- TOC entry 6128 (class 0 OID 21835)
-- Dependencies: 232
-- Data for Name: usuario_insignias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario_insignias (id_usuario, id_insignia, fecha_obtenida) FROM stdin;
2	1	2025-08-28 05:15:20.65184-05
2	2	2025-08-28 05:15:20.65184-05
2	3	2025-08-28 05:15:20.65184-05
4	1	2025-08-28 20:05:18.861482-05
4	2	2025-08-28 20:05:18.861482-05
14	1	2025-09-24 23:11:32.624077-05
18	1	2025-10-15 14:05:17.808507-05
2	7	2025-10-16 14:18:37.285534-05
2	4	2025-10-24 02:35:31.347289-05
2	5	2025-10-24 02:35:31.347289-05
\.


--
-- TOC entry 6134 (class 0 OID 21907)
-- Dependencies: 238
-- Data for Name: usuario_reportes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario_reportes (id, id_usuario_reportado, id_reportador, motivo, estado, fecha_creacion) FROM stdin;
1	4	2	ff	resuelto	2025-08-27 23:08:32.369518-05
3	17	2	malo	pendiente	2025-09-27 19:49:30.318021-05
2	4	2	tty	resuelto	2025-08-29 02:06:04.874128-05
\.


--
-- TOC entry 6120 (class 0 OID 21591)
-- Dependencies: 224
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombre, alias, email, password_hash, puntos, rol, fecha_registro, status, telefono, id_plan_suscripcion, fecha_fin_suscripcion) FROM stdin;
3	lici	luci	paletadeuva@gmail.com	$2b$10$ajOGTGbpuuBkIuUwuzSIMuTo.9YAqZvABT/1Hha1H95UrOvm5fS7a	10	ciudadano	2025-08-26 22:28:12.740891-05	activo	\N	\N	\N
1	Juan Pérez	juanp	juan@example.com	$2b$10$lFMeFvYUlKzynXqxcDtAGOL9952GdqMVr6yWF1iql4llPWLKpC/eO	0	reportero	2025-08-26 05:30:58.657714-05	activo	\N	\N	\N
5	mari	maii	tt@gmail.com	$2b$10$k5ENO9kq39EjUKL72DhPuelb1wx/IMqw/SaxXh.1CPzsi50L35Ccm	0	admin	2025-08-28 15:06:08.152602-05	activo	\N	\N	\N
16	luz	foko	postrescomer2512@gmail.com	$2b$10$PAvCUW2u7ToOPy/.1dWtEuc1kbYAVBPJ2gl.eN8RcJzNkey85ZsAu	0	ciudadano	2025-09-21 13:23:24.355411-05	activo	987 868 924	\N	\N
14	hola	hol	hola@gmail.com	$2b$10$n3.y2qpxptHHUpmiX8X3luqshz3KeQNSNQRs9LTae2VeF98J7a5jK	20	ciudadano	2025-09-20 02:07:13.128237-05	activo	\N	\N	\N
7	alister	Alin	alistervasquez@gmail.com	$2b$10$0pD/bifQugub.vZZ7gO2KuTuxdNf7IX3nrcciMGAcU32EquUUbzze	0	lider_vecinal	2025-08-29 18:45:49.676967-05	activo	\N	\N	\N
4	angello	mopep	gg@gmail.com	$2b$10$77.RQy9mXylNp7umVxKxI.Kv1aCKKFQWT0gF98Q5naTUImwdcPT3e	80	ciudadano	2025-08-27 00:04:05.05449-05	suspendido	\N	\N	\N
17	juan	juancho	juan@gmail.com	$2b$10$NsLA2eUTwVZgm61Ek77BHe3wP525Bb1bwr/O66A5bOG.Fty3iS8lO	0	lider_vecinal	2025-09-27 19:46:23.381449-05	activo	922836879	\N	\N
19	tomas	tomas	tomas@gmail.com	$2b$10$NaN1DQWJzu04EAj1JWRUHuAavtw0ru1cakX6G3UlzpbRq83L6apzq	0	ciudadano	2025-10-16 00:35:20.723235-05	activo	123456789	1	2025-10-16 01:28:31.335-05
15	adriana	adri	adri@gmail.com	$2b$10$dLTWeRLVN2AIHDn.fVwBzegtCGceknNZupoMWdd3rGUqZTDYYkNia	0	lider_vecinal	2025-09-20 02:26:55.076516-05	activo	922836899	\N	\N
18	hhh	hhh	hhh@gmail.com	$2b$10$y1NQ7CHuyBF7Rq260BaCzuelZo3tWVZMhC3NLck.ssdSmZ/mii6f6	20	lider_vecinal	2025-10-12 06:50:45.8567-05	activo	123456789	1	2025-11-15 23:07:42.293-05
2	julio	holaa	kk@gmail.com	$2b$10$gsdRpBoAaxvZ3fues.Ntm.QkyWe2lrSD.LEN1zL6FkOy7yj6I.qK2	415	lider_vecinal	2025-08-26 05:45:41.63882-05	activo	987653789	1	2025-11-24 02:35:31.348-05
\.


--
-- TOC entry 6164 (class 0 OID 32066)
-- Dependencies: 268
-- Data for Name: zonas_seguras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zonas_seguras (id, id_usuario, nombre, centro, radio_metros, fecha_creacion) FROM stdin;
1	18	Casa	0101000020E610000018769E5D092954C0E1220CCE2BB714C0	100	2025-10-15 14:19:44.691247-05
2	18	oficina	0101000020E6100000FCA2E9FC082954C0BFE4C3A20DB914C0	300	2025-10-15 14:21:50.557241-05
3	2	colegio	0101000020E6100000247E5899B02854C0646CBDE789C114C0	100	2025-10-16 17:55:58.456107-05
4	2	eddd	0101000020E6100000B3A2916C0F2954C045BDC68BCDB814C0	200	2025-10-17 03:53:30.478963-05
\.


--
-- TOC entry 6197 (class 0 OID 0)
-- Dependencies: 225
-- Name: categorias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_id_seq', 24, true);


--
-- TOC entry 6198 (class 0 OID 0)
-- Dependencies: 255
-- Name: categorias_orden_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorias_orden_seq', 18, true);


--
-- TOC entry 6199 (class 0 OID 0)
-- Dependencies: 253
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_messages_id_seq', 6, true);


--
-- TOC entry 6200 (class 0 OID 0)
-- Dependencies: 243
-- Name: comentario_apoyos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentario_apoyos_id_seq', 8, true);


--
-- TOC entry 6201 (class 0 OID 0)
-- Dependencies: 235
-- Name: comentario_reportes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentario_reportes_id_seq', 7, true);


--
-- TOC entry 6202 (class 0 OID 0)
-- Dependencies: 233
-- Name: comentarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentarios_id_seq', 19, true);


--
-- TOC entry 6203 (class 0 OID 0)
-- Dependencies: 230
-- Name: insignias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.insignias_id_seq', 7, true);


--
-- TOC entry 6204 (class 0 OID 0)
-- Dependencies: 270
-- Name: lider_zonas_asignadas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lider_zonas_asignadas_id_seq', 333, true);


--
-- TOC entry 6205 (class 0 OID 0)
-- Dependencies: 260
-- Name: metodos_pago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.metodos_pago_id_seq', 7, true);


--
-- TOC entry 6206 (class 0 OID 0)
-- Dependencies: 256
-- Name: moderation_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.moderation_log_id_seq', 1, true);


--
-- TOC entry 6207 (class 0 OID 0)
-- Dependencies: 251
-- Name: notificaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notificaciones_id_seq', 120, true);


--
-- TOC entry 6208 (class 0 OID 0)
-- Dependencies: 241
-- Name: pgmigrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pgmigrations_id_seq', 2, true);


--
-- TOC entry 6209 (class 0 OID 0)
-- Dependencies: 258
-- Name: planes_suscripcion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.planes_suscripcion_id_seq', 2, true);


--
-- TOC entry 6210 (class 0 OID 0)
-- Dependencies: 227
-- Name: reportes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reportes_id_seq', 64, true);


--
-- TOC entry 6211 (class 0 OID 0)
-- Dependencies: 249
-- Name: simulated_sms_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.simulated_sms_log_id_seq', 5, true);


--
-- TOC entry 6212 (class 0 OID 0)
-- Dependencies: 239
-- Name: solicitudes_revision_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.solicitudes_revision_id_seq', 50, true);


--
-- TOC entry 6213 (class 0 OID 0)
-- Dependencies: 265
-- Name: solicitudes_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.solicitudes_rol_id_seq', 6, true);


--
-- TOC entry 6214 (class 0 OID 0)
-- Dependencies: 245
-- Name: sos_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sos_alerts_id_seq', 57, true);


--
-- TOC entry 6215 (class 0 OID 0)
-- Dependencies: 247
-- Name: sos_location_updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sos_location_updates_id_seq', 966, true);


--
-- TOC entry 6216 (class 0 OID 0)
-- Dependencies: 237
-- Name: usuario_reportes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_reportes_id_seq', 3, true);


--
-- TOC entry 6217 (class 0 OID 0)
-- Dependencies: 223
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 19, true);


--
-- TOC entry 6218 (class 0 OID 0)
-- Dependencies: 267
-- Name: zonas_seguras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zonas_seguras_id_seq', 4, true);


--
-- TOC entry 5916 (class 2606 OID 32032)
-- Name: apoyos_pendientes apoyos_pendientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_pendientes
    ADD CONSTRAINT apoyos_pendientes_pkey PRIMARY KEY (id_reporte, id_usuario);


--
-- TOC entry 5867 (class 2606 OID 21813)
-- Name: apoyos apoyos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_pkey PRIMARY KEY (id_reporte, id_usuario);


--
-- TOC entry 5857 (class 2606 OID 21614)
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5859 (class 2606 OID 21612)
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- TOC entry 5900 (class 2606 OID 31858)
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 5885 (class 2606 OID 21967)
-- Name: comentario_apoyos comentario_apoyos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_pkey PRIMARY KEY (id);


--
-- TOC entry 5887 (class 2606 OID 21979)
-- Name: comentario_apoyos comentario_apoyos_unique_user_comment; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_unique_user_comment UNIQUE (id_comentario, id_usuario);


--
-- TOC entry 5877 (class 2606 OID 21895)
-- Name: comentario_reportes comentario_reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5875 (class 2606 OID 21860)
-- Name: comentarios comentarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5869 (class 2606 OID 21834)
-- Name: insignias insignias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.insignias
    ADD CONSTRAINT insignias_nombre_key UNIQUE (nombre);


--
-- TOC entry 5871 (class 2606 OID 21832)
-- Name: insignias insignias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.insignias
    ADD CONSTRAINT insignias_pkey PRIMARY KEY (id);


--
-- TOC entry 5927 (class 2606 OID 32123)
-- Name: lider_zonas_asignadas lider_zonas_asignadas_id_usuario_nombre_distrito_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lider_zonas_asignadas
    ADD CONSTRAINT lider_zonas_asignadas_id_usuario_nombre_distrito_key UNIQUE (id_usuario, nombre_distrito);


--
-- TOC entry 5929 (class 2606 OID 32121)
-- Name: lider_zonas_asignadas lider_zonas_asignadas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lider_zonas_asignadas
    ADD CONSTRAINT lider_zonas_asignadas_pkey PRIMARY KEY (id);


--
-- TOC entry 5908 (class 2606 OID 31914)
-- Name: metodos_pago metodos_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_pkey PRIMARY KEY (id);


--
-- TOC entry 5902 (class 2606 OID 31888)
-- Name: moderation_log moderation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5898 (class 2606 OID 31829)
-- Name: notificaciones notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_pkey PRIMARY KEY (id);


--
-- TOC entry 5883 (class 2606 OID 21958)
-- Name: pgmigrations pgmigrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pgmigrations
    ADD CONSTRAINT pgmigrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5904 (class 2606 OID 31905)
-- Name: planes_suscripcion planes_suscripcion_identificador_plan_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_suscripcion
    ADD CONSTRAINT planes_suscripcion_identificador_plan_key UNIQUE (identificador_plan);


--
-- TOC entry 5906 (class 2606 OID 31903)
-- Name: planes_suscripcion planes_suscripcion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_suscripcion
    ADD CONSTRAINT planes_suscripcion_pkey PRIMARY KEY (id);


--
-- TOC entry 5863 (class 2606 OID 31836)
-- Name: reportes reportes_codigo_reporte_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_codigo_reporte_key UNIQUE (codigo_reporte);


--
-- TOC entry 5865 (class 2606 OID 21626)
-- Name: reportes reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5914 (class 2606 OID 31950)
-- Name: reportes_prioritarios reportes_prioritarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_prioritarios
    ADD CONSTRAINT reportes_prioritarios_pkey PRIMARY KEY (id_reporte);


--
-- TOC entry 5924 (class 2606 OID 32086)
-- Name: reportes_seguidos reportes_seguidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_seguidos
    ADD CONSTRAINT reportes_seguidos_pkey PRIMARY KEY (id_usuario, id_reporte);


--
-- TOC entry 5896 (class 2606 OID 31813)
-- Name: simulated_sms_log simulated_sms_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulated_sms_log
    ADD CONSTRAINT simulated_sms_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5881 (class 2606 OID 21937)
-- Name: solicitudes_revision solicitudes_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_pkey PRIMARY KEY (id);


--
-- TOC entry 5918 (class 2606 OID 32058)
-- Name: solicitudes_rol solicitudes_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_rol
    ADD CONSTRAINT solicitudes_rol_pkey PRIMARY KEY (id);


--
-- TOC entry 5889 (class 2606 OID 31842)
-- Name: sos_alerts sos_alerts_codigo_alerta_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_codigo_alerta_key UNIQUE (codigo_alerta);


--
-- TOC entry 5891 (class 2606 OID 23391)
-- Name: sos_alerts sos_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_pkey PRIMARY KEY (id);


--
-- TOC entry 5894 (class 2606 OID 23406)
-- Name: sos_location_updates sos_location_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_location_updates
    ADD CONSTRAINT sos_location_updates_pkey PRIMARY KEY (id);


--
-- TOC entry 5910 (class 2606 OID 31928)
-- Name: transacciones_pago transacciones_pago_id_transaccion_pasarela_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones_pago
    ADD CONSTRAINT transacciones_pago_id_transaccion_pasarela_key UNIQUE (id_transaccion_pasarela);


--
-- TOC entry 5912 (class 2606 OID 31926)
-- Name: transacciones_pago transacciones_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones_pago
    ADD CONSTRAINT transacciones_pago_pkey PRIMARY KEY (id);


--
-- TOC entry 5873 (class 2606 OID 21840)
-- Name: usuario_insignias usuario_insignias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_pkey PRIMARY KEY (id_usuario, id_insignia);


--
-- TOC entry 5879 (class 2606 OID 21916)
-- Name: usuario_reportes usuario_reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_pkey PRIMARY KEY (id);


--
-- TOC entry 5847 (class 2606 OID 21603)
-- Name: usuarios usuarios_alias_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_alias_key UNIQUE (alias);


--
-- TOC entry 5849 (class 2606 OID 21949)
-- Name: usuarios usuarios_alias_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_alias_unique UNIQUE (alias);


--
-- TOC entry 5851 (class 2606 OID 21605)
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- TOC entry 5853 (class 2606 OID 21951)
-- Name: usuarios usuarios_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_unique UNIQUE (email);


--
-- TOC entry 5855 (class 2606 OID 21601)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 5922 (class 2606 OID 32074)
-- Name: zonas_seguras zonas_seguras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zonas_seguras
    ADD CONSTRAINT zonas_seguras_pkey PRIMARY KEY (id);


--
-- TOC entry 5925 (class 1259 OID 32129)
-- Name: idx_lider_zonas_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lider_zonas_usuario ON public.lider_zonas_asignadas USING btree (id_usuario);


--
-- TOC entry 5860 (class 1259 OID 32130)
-- Name: idx_reportes_distrito; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reportes_distrito ON public.reportes USING btree (distrito);


--
-- TOC entry 5861 (class 1259 OID 21637)
-- Name: idx_reportes_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reportes_location ON public.reportes USING gist (location);


--
-- TOC entry 5892 (class 1259 OID 23412)
-- Name: idx_sos_location_updates_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sos_location_updates_location ON public.sos_location_updates USING gist (location);


--
-- TOC entry 5920 (class 1259 OID 32080)
-- Name: idx_zonas_seguras_centro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_zonas_seguras_centro ON public.zonas_seguras USING gist (centro);


--
-- TOC entry 5919 (class 1259 OID 32064)
-- Name: uq_usuario_solicitud_pendiente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_usuario_solicitud_pendiente ON public.solicitudes_rol USING btree (id_usuario) WHERE ((estado)::text = 'pendiente'::text);


--
-- TOC entry 5935 (class 2606 OID 21814)
-- Name: apoyos apoyos_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5936 (class 2606 OID 21819)
-- Name: apoyos apoyos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos
    ADD CONSTRAINT apoyos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5962 (class 2606 OID 32033)
-- Name: apoyos_pendientes apoyos_pendientes_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_pendientes
    ADD CONSTRAINT apoyos_pendientes_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5963 (class 2606 OID 32038)
-- Name: apoyos_pendientes apoyos_pendientes_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.apoyos_pendientes
    ADD CONSTRAINT apoyos_pendientes_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5953 (class 2606 OID 31864)
-- Name: chat_messages chat_messages_id_remitente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_id_remitente_fkey FOREIGN KEY (id_remitente) REFERENCES public.usuarios(id);


--
-- TOC entry 5954 (class 2606 OID 31859)
-- Name: chat_messages chat_messages_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5947 (class 2606 OID 21968)
-- Name: comentario_apoyos comentario_apoyos_id_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_id_comentario_fkey FOREIGN KEY (id_comentario) REFERENCES public.comentarios(id) ON DELETE CASCADE;


--
-- TOC entry 5948 (class 2606 OID 21973)
-- Name: comentario_apoyos comentario_apoyos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_apoyos
    ADD CONSTRAINT comentario_apoyos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5941 (class 2606 OID 21896)
-- Name: comentario_reportes comentario_reportes_id_comentario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_id_comentario_fkey FOREIGN KEY (id_comentario) REFERENCES public.comentarios(id) ON DELETE CASCADE;


--
-- TOC entry 5942 (class 2606 OID 21901)
-- Name: comentario_reportes comentario_reportes_id_reportador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario_reportes
    ADD CONSTRAINT comentario_reportes_id_reportador_fkey FOREIGN KEY (id_reportador) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5939 (class 2606 OID 21861)
-- Name: comentarios comentarios_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5940 (class 2606 OID 21866)
-- Name: comentarios comentarios_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentarios
    ADD CONSTRAINT comentarios_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5930 (class 2606 OID 32043)
-- Name: usuarios fk_plan_suscripcion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_plan_suscripcion FOREIGN KEY (id_plan_suscripcion) REFERENCES public.planes_suscripcion(id) ON DELETE SET NULL;


--
-- TOC entry 5968 (class 2606 OID 32124)
-- Name: lider_zonas_asignadas lider_zonas_asignadas_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lider_zonas_asignadas
    ADD CONSTRAINT lider_zonas_asignadas_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5956 (class 2606 OID 31915)
-- Name: metodos_pago metodos_pago_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.metodos_pago
    ADD CONSTRAINT metodos_pago_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5955 (class 2606 OID 31889)
-- Name: moderation_log moderation_log_id_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_id_admin_fkey FOREIGN KEY (id_admin) REFERENCES public.usuarios(id);


--
-- TOC entry 5952 (class 2606 OID 31830)
-- Name: notificaciones notificaciones_id_usuario_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_id_usuario_receptor_fkey FOREIGN KEY (id_usuario_receptor) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5931 (class 2606 OID 21632)
-- Name: reportes reportes_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categorias(id);


--
-- TOC entry 5932 (class 2606 OID 31844)
-- Name: reportes reportes_id_lider_verificador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_lider_verificador_fkey FOREIGN KEY (id_lider_verificador) REFERENCES public.usuarios(id);


--
-- TOC entry 5933 (class 2606 OID 32109)
-- Name: reportes reportes_id_reporte_original_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_reporte_original_fkey FOREIGN KEY (id_reporte_original) REFERENCES public.reportes(id) ON DELETE SET NULL;


--
-- TOC entry 5934 (class 2606 OID 21627)
-- Name: reportes reportes_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id);


--
-- TOC entry 5960 (class 2606 OID 31951)
-- Name: reportes_prioritarios reportes_prioritarios_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_prioritarios
    ADD CONSTRAINT reportes_prioritarios_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5961 (class 2606 OID 31956)
-- Name: reportes_prioritarios reportes_prioritarios_id_usuario_premium_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_prioritarios
    ADD CONSTRAINT reportes_prioritarios_id_usuario_premium_fkey FOREIGN KEY (id_usuario_premium) REFERENCES public.usuarios(id);


--
-- TOC entry 5966 (class 2606 OID 32092)
-- Name: reportes_seguidos reportes_seguidos_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_seguidos
    ADD CONSTRAINT reportes_seguidos_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5967 (class 2606 OID 32087)
-- Name: reportes_seguidos reportes_seguidos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes_seguidos
    ADD CONSTRAINT reportes_seguidos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5951 (class 2606 OID 31814)
-- Name: simulated_sms_log simulated_sms_log_id_usuario_sos_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulated_sms_log
    ADD CONSTRAINT simulated_sms_log_id_usuario_sos_fkey FOREIGN KEY (id_usuario_sos) REFERENCES public.usuarios(id);


--
-- TOC entry 5945 (class 2606 OID 21943)
-- Name: solicitudes_revision solicitudes_revision_id_lider_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_id_lider_fkey FOREIGN KEY (id_lider) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5946 (class 2606 OID 21938)
-- Name: solicitudes_revision solicitudes_revision_id_reporte_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_revision
    ADD CONSTRAINT solicitudes_revision_id_reporte_fkey FOREIGN KEY (id_reporte) REFERENCES public.reportes(id) ON DELETE CASCADE;


--
-- TOC entry 5964 (class 2606 OID 32059)
-- Name: solicitudes_rol solicitudes_rol_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solicitudes_rol
    ADD CONSTRAINT solicitudes_rol_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5949 (class 2606 OID 23392)
-- Name: sos_alerts sos_alerts_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_alerts
    ADD CONSTRAINT sos_alerts_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5950 (class 2606 OID 23407)
-- Name: sos_location_updates sos_location_updates_id_alerta_sos_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sos_location_updates
    ADD CONSTRAINT sos_location_updates_id_alerta_sos_fkey FOREIGN KEY (id_alerta_sos) REFERENCES public.sos_alerts(id) ON DELETE CASCADE;


--
-- TOC entry 5957 (class 2606 OID 31939)
-- Name: transacciones_pago transacciones_pago_id_metodo_pago_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones_pago
    ADD CONSTRAINT transacciones_pago_id_metodo_pago_fkey FOREIGN KEY (id_metodo_pago) REFERENCES public.metodos_pago(id);


--
-- TOC entry 5958 (class 2606 OID 31934)
-- Name: transacciones_pago transacciones_pago_id_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones_pago
    ADD CONSTRAINT transacciones_pago_id_plan_fkey FOREIGN KEY (id_plan) REFERENCES public.planes_suscripcion(id);


--
-- TOC entry 5959 (class 2606 OID 31929)
-- Name: transacciones_pago transacciones_pago_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transacciones_pago
    ADD CONSTRAINT transacciones_pago_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id);


--
-- TOC entry 5937 (class 2606 OID 21846)
-- Name: usuario_insignias usuario_insignias_id_insignia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_id_insignia_fkey FOREIGN KEY (id_insignia) REFERENCES public.insignias(id) ON DELETE CASCADE;


--
-- TOC entry 5938 (class 2606 OID 21841)
-- Name: usuario_insignias usuario_insignias_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_insignias
    ADD CONSTRAINT usuario_insignias_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5943 (class 2606 OID 21922)
-- Name: usuario_reportes usuario_reportes_id_reportador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_id_reportador_fkey FOREIGN KEY (id_reportador) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5944 (class 2606 OID 21917)
-- Name: usuario_reportes usuario_reportes_id_usuario_reportado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_reportes
    ADD CONSTRAINT usuario_reportes_id_usuario_reportado_fkey FOREIGN KEY (id_usuario_reportado) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- TOC entry 5965 (class 2606 OID 32075)
-- Name: zonas_seguras zonas_seguras_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zonas_seguras
    ADD CONSTRAINT zonas_seguras_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id) ON DELETE CASCADE;


-- Completed on 2025-10-24 10:50:03

--
-- PostgreSQL database dump complete
--

\unrestrict U2x6fFoYvhJoD6XV2WmPnehQM5FIMqdWb3e8rgI2n7YK4XSehvBmO7S8cx4L91B

