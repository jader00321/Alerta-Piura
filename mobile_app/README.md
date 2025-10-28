# Reporta Piura (Aplicación Móvil)

Aplicación móvil desarrollada en Flutter que sirve como plataforma de reportes ciudadanos y alertas de seguridad para la región de Piura. Permite a los usuarios reportar incidentes, verlos en un mapa, interactuar con otros reportes y solicitar ayuda de emergencia a través de una función SOS.

## 🚀 Características Principales

La aplicación se divide en varias funcionalidades clave para distintos roles de usuario:

### Para Ciudadanos
* **Mapa Interactivo:** Visualización de reportes (verificados y pendientes) en un mapa de la ciudad, con agrupación de marcadores (`flutter_map_marker_cluster`).
* **Creación de Reportes:** Formulario completo para crear nuevos reportes, incluyendo título, descripción, categoría, urgencia, geolocalización y carga de imágenes a Cloudinary.
* **Reportes Cercanos:** Una vista de lista que muestra los reportes más cercanos a la ubicación actual del usuario.
* **Interacción Social:** Capacidad de "apoyar" reportes, "unirse" a reportes pendientes (para darles prioridad) y "seguir" reportes para recibir actualizaciones.
* **Sistema de Comentarios:** Sección de comentarios en cada reporte verificado.
* **Autenticación:** Flujo completo de registro e inicio de sesión con JWT.
* **Perfil de Usuario:** Visualización de puntos, insignias y gestión de datos personales.

### Para Usuarios Premium
* **Alerta SOS:** Botón de pánico que activa un seguimiento en segundo plano (`flutter_background_service`), envía la ubicación en tiempo real al backend y simula notificaciones a contactos de emergencia.
* **Zonas Seguras:** Creación de zonas geográficas personalizadas (ej. "Casa", "Trabajo") para recibir notificaciones proactivas si un reporte peligroso es verificado dentro de esa área.
* **Panel Analítico:** Visualización de gráficos estadísticos sobre la incidencia de reportes en la ciudad.
* **Reportes Prioritarios:** Los reportes creados por usuarios premium se marcan visualmente como prioritarios.

### Para Líderes Vecinales (Moderadores)
* **Panel de Verificación:** Vistas separadas para reportes pendientes, historial de moderación y reportes de contenido (comentarios/usuarios) generados por el líder.
* **Gestión de Reportes:** Acciones para aprobar, rechazar, editar y fusionar reportes duplicados.
* **Chat en Tiempo Real:** Capacidad de chatear (`socket_io_client`) con los autores de reportes pendientes para solicitar más información.
* **Solicitud de Revisión:** Opción para escalar un caso a un administrador.

## 🛠️ Stack Tecnológico (Frontend)

* **Framework:** Flutter (Dart)
* **Gestión de Estado:** Provider
* **Cliente HTTP:** `http`
* **Comunicación Real-Time:** `socket_io_client`
* **Mapas:** `flutter_map`, `flutter_map_marker_cluster`, `latlong2`
* **Geolocalización y Permisos:** `geolocator`, `permission_handler`
* **Tareas en Segundo Plano:** `flutter_background_service`
* **Notificaciones Locales:** `flutter_local_notifications`
* **UI y Componentes:** `intl` (internacionalización), `shimmer` (esqueletos de carga), `image_picker`, `fl_chart` (gráficos), `pdf` (generación de PDFs).

---

## 🚀 Cómo Empezar: Guía de Instalación Completa

Para ejecutar el proyecto completo, necesitas tener el Backend y la Aplicación Móvil corriendo simultáneamente.

### Parte 1: Configurar el Backend (Servidor)

1.  **Navegar al Backend:**
    ```bash
    cd backend
    ```
2.  **Instalar Dependencias:**
    ```bash
    npm install
    ```
3.  **Configurar Base de Datos (PostgreSQL):**
    * Asegúrate de tener PostgreSQL instalado y corriendo.
    * Crea una base de datos (ej. `alerta_piura_db`).
    * **Importante:** Restaura la estructura y datos de la base de datos usando el archivo `reporte_alerta.sql` que me proporcionaste.
        ```bash
        psql -U tu_usuario -d alerta_piura_db < ruta/al/archivo/reporte_alerta.sql
        ```
    * Asegúrate de que la extensión `postgis` esté habilitada en tu base de datos: `CREATE EXTENSION postgis;`

4.  **Configurar Variables de Entorno:**
    * Crea un archivo `.env` en la carpeta `backend/`.
    * Copia y pega el siguiente contenido (basado en tu archivo `.env`) y **ajusta tus credenciales**:

    ```env
    # Variables del Servidor
    PORT=3000

    # Credenciales de tu Base de Datos PostgreSQL
    DB_USER=postgres
    DB_PASSWORD=tu_password_de_postgres
    DB_HOST=localhost
    DB_PORT=5432
    DB_DATABASE=alerta_piura_db

    # Secreto para firmar los JSON Web Tokens (JWT)
    JWT_SECRET=tu-secreto-jwt-super-seguro-aqui

    # Credenciales de Cloudinary (para subida de imágenes)
    CLOUDINARY_CLOUD_NAME=tu_cloud_name
    CLOUDINARY_API_KEY=tu_api_key
    CLOUDINARY_API_SECRET=tu_api_secret
    ```

5.  **Iniciar el Servidor Backend:**
    ```bash
    npm run dev
    ```
    * El servidor ahora debería estar corriendo en `http://localhost:3000`.

### Parte 2: Configurar la Aplicación Móvil (Flutter)

1.  **Navegar a la App Móvil (en otra terminal):**
    ```bash
    cd mobile_app
    ```
2.  **Instalar Dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Configurar la Conexión a la API:**
    * Abre el archivo `lib/utils/api_constants.dart`.
    * **¡ESTE ES EL PASO MÁS IMPORTANTE!** Debes cambiar la IP.
    * Si estás usando un **Emulador de Android**, la IP `10.0.2.2` suele funcionar para conectarse al `localhost` de tu PC:
        ```dart
        static String baseUrl = Platform.isAndroid ? '[http://10.0.2.2:3000](http://10.0.2.2:3000)' : 'http://localhost:3000';
        ```
    * Si estás usando un **Dispositivo Físico (Android o iOS)**, debes usar la IP de tu computadora en la red Wi-Fi (ej. `192.168.1.100`). Encuentra tu IP (con `ipconfig` o `ifconfig`) y ponla:
        ```dart
        // Ejemplo con tu IP proporcionada
        static String baseUrl = '[http://192.168.100.5:3000](http://192.168.100.5:3000)';
        ```

4.  **Ejecutar la Aplicación:**
    ```bash
    flutter run
    ```

¡Si ambos servicios están corriendo, ahora deberías poder registrarte, iniciar sesión y usar la aplicación completa!

---

## 📁 Estructura del Proyecto: app movil.

mobile_app/
├── .flutter-plugins-dependencies  – (Archivo autogenerado) Registra las dependencias nativas.
├── pubspec.lock                     – (Archivo autogenerado) Fija las versiones exactas de todos los paquetes.
├── pubspec.yaml                     – (Archivo clave) Define las dependencias, assets y fuentes de la app.
│
└── lib/
    ├── main.dart                    – (Punto de Entrada) Inicializa la app, servicios (SOS, Notif.), providers y define las rutas.
    ├── navigator_key.dart           – (Utilidad Clave) Clave global para permitir la navegación desde servicios (ej. Notificaciones).
    │
    ├── 📁 api/                       – (Capa de Red) Clases que realizan llamadas HTTP directas al backend.
    │   ├── 📄 analiticas_service.dart    – Obtiene los datos para los gráficos del panel analítico (Premium).
    │   ├── 📄 auth_service.dart         – Maneja las llamadas de /login y /register.
    │   ├── 📄 gamificacion_service.dart – Obtiene los datos de insignias y puntos del usuario.
    │   ├── 📄 lider_service.dart        – Endpoints para el rol de Líder (aprobar, rechazar, fusionar, listas).
    │   ├── 📄 metodo_pago_service.dart  – Maneja el CRUD (Crear, Leer, Eliminar) de las tarjetas de pago.
    │   ├── 📄 perfil_service.dart       – Endpoints para el perfil (mis reportes, mis zonas, postular).
    │   ├── 📄 reporte_service.dart      – El servicio más grande; maneja CRUD de reportes y comentarios.
    │   ├── 📄 seguimiento_service.dart  – Maneja la lógica de "seguir" y "dejar de seguir" un reporte.
    │   ├── 📄 servicio_suscripcion.dart – Obtiene planes, procesa suscripciones y cancelaciones.
    │   └── 📄 sos_service.dart          – Endpoints para activar, actualizar ubicación y desactivar el SOS.
    │
    ├── 📁 dialogs/                   – Widgets que se muestran como diálogos emergentes.
    │   └── 📄 dialogo_detalle_pendiente.dart – (Archivo eliminado/comentado) Solía mostrar un pop-up para reportes pendientes.
    │
    ├── 📁 models/                    – (Capa de Datos) Clases que definen la estructura de los datos.
    │   ├── 📄 boleta_detalle_model.dart     – Define la estructura de una factura/recibo detallado.
    │   ├── 📄 categoria_model.dart        – Define la estructura simple de una Categoría (ID, Nombre).
    │   ├── 📄 chat_message_model.dart   – Define la estructura de un mensaje del chat en tiempo real.
    │   ├── 📄 comentario_model.dart       – Define la estructura de un comentario de usuario en un reporte.
    │   ├── 📄 conversacion_model.dart     – Define el item para la lista "Mis Conversaciones" (Líder).
    │   ├── 📄 estadisticas_model.dart     – Define las estructuras `EstadisticasResumen` y `DatoGrafico`.
    │   ├── 📄 historial_pago_model.dart   – Define el item para la lista "Historial de Pagos".
    │   ├── 📄 insignia_detalle_model.dart – Define la estructura de una insignia y su progreso (`ProgresoInsignias`).
    │   ├── 📄 insignia_model.dart         – Define la estructura de una insignia básica (usado en `Perfil`).
    │   ├── 📄 metodo_pago_model.dart      – Define la estructura de una tarjeta de pago guardada.
    │   ├── 📄 notificacion_model.dart     – Define el item para la lista "Mis Notificaciones".
    │   ├── 📄 perfil_model.dart           – Define la estructura del perfil de usuario (puntos, plan, etc.).
    │   ├── 📄 plan_suscripcion_model.dart – Define la estructura de un plan de suscripción.
    │   ├── 📄 reporte_cercano_model.dart  – Modelo para "Cerca de Ti", incluye `distanciaMetros` y `usuarioActualUnido`.
    │   ├── 📄 reporte_detallado_model.dart – El modelo más grande; para la vista de detalle de un reporte.
    │   ├── 📄 reporte_historial_moderado_model.dart – Modelo para la lista "Historial" del Líder.
    │   ├── 📄 reporte_model.dart          – Modelo básico de reporte para los pines del mapa.
    │   ├── 📄 reporte_moderacion_model.dart – Modelo para reportes *sobre* comentarios o usuarios.
    │   ├── 📄 reporte_pendiente_model.dart – Modelo para la lista "Pendientes" del Líder.
    │   ├── 📄 reporte_resumen_model.dart  – Modelo flexible usado en las listas de "Mi Actividad".
    │   ├── 📄 solicitud_revision_model.dart – Modelo para la lista "Solicitudes de Revisión" del Líder.
    │   └── 📄 zona_segura_model.dart      – Define la estructura de una Zona Segura (Premium).
    │
    ├── 📁 screens/                    – (Capa de Vistas) Pantallas completas, 1 por cada ruta principal.
    │   ├── 📄 chat_screen.dart            – Pantalla del chat en tiempo real (Líder <-> Usuario).
    │   ├── 📄 conversaciones_screen.dart   – Lista de todos los chats de un Líder.
    │   ├── 📄 create_report_screen.dart   – Formulario para crear un nuevo reporte.
    │   ├── 📄 editar_contacto_screen.dart – Formulario para editar el contacto de emergencia del SOS (usa SharedPreferences).
    │   ├── 📄 editar_perfil_screen.dart   – Pantalla que combina `SeccionDatosPersonales` y `SeccionSeguridad`.
    │   ├── 📄 home_screen.dart            – Pantalla principal que contiene la `BottomNavigationBar` y el `PageView` de las 4 pestañas.
    │   ├── 📄 login_screen.dart           – Pantalla de inicio de sesión.
    │   ├── 📄 mapa_view.dart              – La pantalla del mapa interactivo (Pestaña 1).
    │   ├── 📄 mi_actividad_screen.dart    – Pantalla con pestañas de la actividad del usuario (Pestaña 3 - Ciudadano).
    │   ├── 📄 pantalla_agregar_metodo_pago.dart – Formulario para añadir una nueva tarjeta.
    │   ├── 📄 pantalla_alertas.dart       – Muestra la lista de notificaciones (historial).
    │   ├── 📄 pantalla_alertas_personalizadas.dart – (Premium) Muestra la lista de Zonas Seguras.
    │   ├── 📄 pantalla_buscar_reporte_original.dart – (Líder) Buscador de reportes para fusionar.
    │   ├── 📄 pantalla_cerca_de_ti.dart   – Muestra la lista de reportes cercanos (Pestaña 2).
    │   ├── 📄 pantalla_crear_zona.dart    – (Premium) Pantalla con mapa para definir una Zona Segura.
    │   ├── 📄 pantalla_detalle_boleta.dart – Muestra el detalle de una transacción (recibo).
    │   ├── 📄 pantalla_detalle_pendiente_vista.dart – Vista rápida de un reporte pendiente (desde "Cerca de Ti").
    │   ├── 📄 pantalla_editar_reporte_autor.dart – Formulario para que el autor edite un reporte *pendiente*.
    │   ├── 📄 pantalla_editar_reporte_lider.dart – (Líder) Formulario para que el líder edite un reporte *pendiente*.
    │   ├── 📄 pantalla_estadisticas_personales.dart – (Premium) Muestra gráficos de la actividad *propia* del usuario.
    │   ├── 📄 pantalla_gestionar_suscripcion.dart – (Premium) Permite ver el plan actual y cancelar.
    │   ├── 📄 pantalla_historial_pagos.dart – Muestra la lista de transacciones de pago.
    │   ├── 📄 pantalla_informes_guardados.dart – (Premium/Reportero) Muestra los PDFs generados y guardados localmente.
    │   ├── 📄 pantalla_insignias.dart     – Muestra el progreso de puntos e insignias del usuario.
    │   ├── 📄 pantalla_metodos_pago.dart  – Muestra, edita y elimina las tarjetas guardadas.
    │   ├── 📄 pantalla_pago.dart          – Pantalla de checkout para seleccionar/ingresar tarjeta y pagar.
    │   ├── 📄 pantalla_panel_analitico.dart – (Premium/Reportero) Muestra gráficos de analíticas *globales*.
    │   ├── 📄 pantalla_planes_suscripcion.dart – Muestra la lista de planes de suscripción para comprar.
    │   ├── 📄 perfil_screen.dart          – Pantalla de perfil del usuario (Pestaña 4).
    │   ├── 📄 register_screen.dart        – Pantalla de registro de nuevo usuario.
    │   ├── 📄 reporte_detalle_screen.dart – Pantalla de detalle de un reporte (con comentarios, apoyo, etc.).
    │   ├── 📄 settings_screen.dart        – Pantalla de Configuración (Tema, SOS, Notificaciones).
    │   ├── 📄 splash_screen.dart          – Pantalla de carga inicial, verifica el token de sesión.
    │   ├── 📄 verificacion_detalle_screen.dart – (Líder) Pantalla para moderar un reporte (Aprobar, Rechazar, Fusionar).
    │   └── 📄 verificacion_screen.dart    – (Líder) Panel principal con pestañas "Pendientes", "Historial", etc. (Pestaña 3 - Líder).
    │
    ├── 📁 services/                    – (Capa de Lógica) Servicios complejos, de fondo o en tiempo real.
    │   ├── 📄 background_service.dart     – Maneja el Isolate de fondo para el seguimiento GPS del SOS (timers, geolocator).
    │   ├── 📄 notification_service.dart   – Maneja la creación y el "tap" en notificaciones locales (usa `navigator_key`).
    │   ├── 📄 servicio_pdf.dart         – Lógica para generar el archivo PDF de analíticas en el cliente.
    │   └── 📄 socket_service.dart         – Maneja la conexión WebSocket (Socket.IO) para chat y notificaciones.
    │
    ├── 📁 utils/                      – Clases de utilidad y constantes.
    │   └── 📄 api_constants.dart          – Define la `baseUrl` del backend (ej. `http://192...`).
    │
    └── 📁 widgets/                     – (Capa de Componentes) Componentes de UI reutilizables.
        ├── 📁 alertas_personalizadas/    – Widgets para la pantalla de Zonas Seguras.
        │   └── 📄 tarjeta_zona_segura.dart    – Muestra el mini-mapa y nombre de una zona.
        ├── 📁 boletas/                   – Widgets para la pantalla de Detalle de Boleta.
        │   └── 📄 tarjeta_detalle_boleta.dart – Muestra el recibo de pago detallado.
        ├── 📁 cerca_de_ti/               – Widgets para la pantalla "Cerca de Ti".
        │   ├── 📄 panel_filtros_cercanos.dart – El panel deslizable de filtros.
        │   └── 📄 tarjeta_reporte_cercano.dart  – La tarjeta de item de reporte, con lógica de "Unirse".
        ├── 📁 configuracion/             – Widgets para la pantalla de Configuración.
        │   ├── 📄 seccion_apariencia.dart   – Contiene el switch de Modo Oscuro.
        │   ├── 📄 seccion_notificaciones.dart – Contiene el enlace al historial de notificaciones.
        │   └── 📄 seccion_sos.dart          – Contiene el slider de duración y el enlace a "Editar Contacto".
        ├── 📁 crear_reporte/             – Secciones del formulario de creación de reportes.
        │   ├── 📄 seccion_acciones_finales.dart – Contiene los botones de "Anónimo", "Ubicación" y "Enviar".
        │   ├── 📄 seccion_detalles_adicionales.dart – Campos opcionales (descripción, tags, impacto, etc.).
        │   ├── 📄 seccion_detalles_principales.dart – Campos principales (título, categoría, urgencia).
        │   └── 📄 seccion_evidencia.dart    – Contiene el widget para seleccionar/ver la imagen.
        ├── 📁 editar_perfil/             – Secciones del formulario de edición de perfil.
        │   ├── 📄 seccion_datos_personales.dart – Formulario para nombre, alias, email (requiere contraseña).
        │   └── 📄 seccion_seguridad.dart    – Formulario para cambiar la contraseña.
        ├── 📁 esqueletos/                – (UX) Placeholders de carga con efecto "shimmer".
        │   ├── 📄 esqueleto_detalle_boleta.dart  – Placeholder para el detalle de la boleta.
        │   ├── 📄 esqueleto_historial_pagos.dart – Placeholder para la lista de historial de pagos.
        │   ├── 📄 esqueleto_lista_actividad.dart – Placeholder genérico para listas (usado en Mi Actividad, Verificación).
        │   ├── 📄 esqueleto_lista_notificaciones.dart – Placeholder para listas simples (Notificaciones, Métodos de Pago).
        │   ├── 📄 esqueleto_lista_planes.dart  – Placeholder para la lista de planes de suscripción.
        │   ├── 📄 esqueleto_lista_reportes.dart  – Placeholder para la lista "Cerca de Ti".
        │   ├── 📄 esqueleto_mapa.dart         – Placeholder para la pantalla principal del mapa.
        │   ├── 📄 esqueleto_perfil.dart       – Placeholder para la pantalla de perfil.
        │   └── 📄 esqueleto_reporte_detalle.dart – Placeholder para la pantalla de detalle de reporte.
        ├── 📁 historial_pagos/           – Widgets para la lista de historial de pagos.
        │   └── 📄 tarjeta_historial_pago.dart – La tarjeta de item para un pago en la lista.
        ├── 📁 home/                      – Widgets para la `HomeScreen` o `MapaView`.
        │   ├── 📄 bottom_nav_bar.dart       – (Archivo eliminado/sin usar) Un diseño alternativo de la barra de navegación.
        │   └── 📄 top_search_bar.dart       – La barra de búsqueda y el avatar de perfil en el mapa.
        ├── 📁 login/                     – Componentes de la pantalla de Login.
        │   ├── 📄 login_actions.dart        – Contiene el botón "Iniciar Sesión" y el enlace a "Registrarse".
        │   ├── 📄 login_form_fields.dart    – Contiene los campos de Email y Contraseña.
        │   └── 📄 login_header.dart         – Muestra el logo y título en la pantalla de login.
        ├── 📁 mapa/                      – Widgets principales para `MapaView`.
        │   ├── 📄 acciones_mapa.dart        – Agrupa los FABs (Filtro, Ubicación, Reportar, SOS).
        │   ├── 📄 capa_mapa_base.dart       – Renderiza el `FlutterMap` y la capa de marcadores clusterizados.
        │   ├── 📄 indicador_riesgo.dart     – El chip que muestra el nivel de riesgo de la zona.
        │   ├── 📄 panel_filtros_avanzados.dart – El panel deslizable de filtros para el mapa.
        │   ├── 📄 pin_pulsante.dart         – La animación de pin en el centro del mapa.
        │   └── 📄 report_summary_sheet.dart – El modal que se muestra al tocar un pin del mapa.
        ├── 📁 mi_actividad/              – Widgets para la pantalla "Mi Actividad".
        │   ├── 📄 activity_list_view.dart     – Widget reutilizable que renderiza las listas de las pestañas.
        │   ├── 📄 dialogo_postulacion_lider.dart – El diálogo emergente para postular a líder.
        │   ├── 📄 solicitudes_revision_view.dart – La vista de lista para la pestaña "Revisiones" del Líder.
        │   ├── 📄 tarjeta_actividad.dart      – La tarjeta *unificada* y dinámica que se adapta a cada pestaña (Mis Reportes, Apoyos, etc.).
        │   └── 📄 tarjeta_mi_reporte.dart   – (Archivo eliminado/redundante) Versión anterior de `tarjeta_actividad`.
        ├── 📁 pago/                      – Widgets para el flujo de pago.
        │   ├── 📄 formulario_pago.dart      – Componente reutilizable con los campos de tarjeta (sin `Form`).
        │   └── 📄 resumen_pago.dart         – Muestra el resumen del plan seleccionado en el checkout.
        ├── 📁 perfil/                    – Widgets para la pantalla de Perfil.
        │   ├── 📄 insignia_estatus_widget.dart – Muestra el estatus/rol principal (Ej. "Líder Vecinal", "Premium").
        │   ├── 📄 perfil_action_tile.dart   – El `ListTile` reutilizable para las acciones/enlaces del perfil.
        │   └── 📄 perfil_header_card.dart   – La tarjeta superior con el avatar, nombre y puntos.
        ├── 📁 planes/                    – Widgets para la pantalla de Planes.
        │   └── 📄 tarjeta_plan.dart         – Muestra un plan de suscripción, sus características y el botón de "Seleccionar".
        ├── 📁 registro/                  – Componentes de la pantalla de Registro.
        │   ├── 📄 register_actions.dart     – Contiene el botón "Registrarse".
        │   ├── 📄 register_form_fields.dart – Contiene todos los campos del formulario de registro.
        │   └── 📄 register_header.dart      – Muestra el título en la pantalla de registro.
        ├── 📁 reporte_detalle/           – Widgets para la pantalla de Detalle de Reporte.
        │   ├── 📄 campo_comentario.dart     – El campo de texto y botón para enviar un comentario.
        │   ├── 📄 comments_section.dart     – Renderiza la lista de comentarios, con lógica de menú (editar, eliminar, reportar).
        │   ├── 📄 layout_detalle_reporte.dart – El widget de maquetación principal que organiza el detalle.
        │   ├── 📄 merge_notification_card.dart – Tarjeta especial para mostrar comentarios de fusión.
        │   ├── 📄 reporte_actions_bar.dart  – La barra con los botones de "Apoyar" y el contador de comentarios.
        │   ├── 📄 reporte_header.dart       – Muestra la información principal (imagen, título, descripción, etc.).
        │   └── 📄 vistas_estado_reporte.dart – Muestra vistas especiales (ej. "Reporte Fusionado", "Reporte Oculto").
        └── 📁 verificacion/              – Widgets para el panel de moderación del Líder.
            ├── 📄 acciones_moderacion.dart        – La barra inferior con botones (Aprobar, Rechazar, Fusionar).
            ├── 📄 cabezal_detalle_verificacion.dart – (Helper) Construye el AppBar de la pantalla de detalle.
            ├── 📄 cuerpo_detalle_verificacion.dart – (Obsoleto/Redundante) Antigua maquetación, reemplazada por `layout_detalle_verificacion`.
            ├── 📄 dialogo_solicitud_revision.dart – Diálogo para que el líder pida revisión a un admin.
            ├── 📄 filtros_historial.dart      – Los chips de filtro para la pestaña "Historial".
            ├── 📄 filtros_pendientes.dart     – La barra de búsqueda y filtros para la pestaña "Pendientes".
            ├── 📄 layout_detalle_verificacion.dart – La maquetación de la pantalla de detalle (usa `ReporteHeader` y `MapaVerificacion`).
            ├── 📄 lista_reportes_verificacion.dart – Widget con estado clave que maneja la paginación y filtros de "Pendientes" e "Historial".
            ├── 📄 mapa_verificacion.dart      – El mini-mapa (no interactivo) para la pantalla de detalle.
            ├── 📄 mis_reportes_moderacion_view.dart – Widget con estado que maneja la lista de "Mis Reportes" (de contenido).
            ├── 📄 tarjeta_historial_moderado.dart – La tarjeta de item para la lista "Historial".
            ├── 📄 tarjeta_moderacion_reporte.dart – La tarjeta de item para la lista "Mis Reportes" (de contenido).
            └── 📄 tarjeta_verificacion.dart   – La tarjeta de item para la lista "Pendientes".