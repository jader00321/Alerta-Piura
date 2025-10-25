--
-- PostgreSQL database dump
--

\restrict 3PIPrKCaZaGq44JKa849XfG36DxEa593QAge856E7VGqBFRNEZvrpdsJpwQsOl4

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-10-24 10:48:10

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


-- Completed on 2025-10-24 10:48:11

--
-- PostgreSQL database dump complete
--

\unrestrict 3PIPrKCaZaGq44JKa849XfG36DxEa593QAge856E7VGqBFRNEZvrpdsJpwQsOl4

