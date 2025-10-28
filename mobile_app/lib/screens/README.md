# Carpeta de Vistas: `screens`

## 🏙️ Descripción General

Esta carpeta contiene todos los **widgets de nivel superior** que representan una "pantalla" o "vista" completa en la aplicación. Cada archivo aquí es un `StatefulWidget` que ocupa toda el área del `Scaffold` y es el destino de una ruta de navegación definida en `main.dart`.

## El Rol de una "Pantalla"

Las pantallas son las **"controladoras de orquesta"** de la UI. Su responsabilidad principal es gestionar el ciclo de vida y el estado de una vista específica. Típicamente, una pantalla:
1.  **Gestiona el Estado:** Mantiene variables (`_isLoading`, `_reportes`, etc.) y `TextEditingController`s.
2.  **Llama a los Servicios:** Usa `initState` o `FutureBuilder` para llamar a los servicios de `lib/api/` (ej. `ReporteService.getReporteById(...)`) y `lib/services/` (ej. `BackgroundService.invoke(...)`).
3.  **Consume Providers:** Escucha (`context.watch`) o lee (`context.read`) los `ChangeNotifier` de `lib/providers/` (especialmente `AuthProvider`).
4.  **Ensambla la UI:** Construye la interfaz visual usando los componentes reutilizables de `lib/widgets/`.

## 🧭 Flujos y Pantallas Principales

A continuación se detallan las pantallas agrupadas por su funcionalidad principal en la aplicación.

### 1. Flujo Central y Autenticación
* **`splash_screen.dart`:** La pantalla de carga inicial. Llama a `authProvider.refreshUserStatus()` para verificar el token y luego navega a `/home`.
* **`home_screen.dart`:** El host principal de la aplicación. Contiene la `BottomNavigationBar` y el `PageView` para las 4 pestañas. Su lógica clave es cambiar la Pestaña 3 (`MiActividadScreen` o `VerificacionScreen`) basándose en el rol del usuario (`authNotifier.isLider`).
* **`login_screen.dart`:** Formulario de inicio de sesión. Llama a `AuthService.login()` y actualiza `AuthNotifier`.
* **`register_screen.dart`:** Formulario de registro. Llama a `AuthService.register()`.

### 2. Pestañas Principales (Contenidas en `HomeScreen`)
* **`mapa_view.dart` (Pestaña 1):** El núcleo de la app. Muestra `CapaMapaBase`. Gestiona los filtros (`PanelFiltrosAvanzados`), la lógica del botón SOS (`AccionesMapa`) y el cálculo de riesgo (`IndicadorRiesgo`).
* **`pantalla_cerca_de_ti.dart` (Pestaña 2):** Usa `geolocator` para obtener la ubicación y llama a `ReporteService.getReportesCercanos`. Muestra una lista de `TarjetaReporteCercano` y permite "unirse" a reportes pendientes.
* **`mi_actividad_screen.dart` (Pestaña 3 - Ciudadano):** Muestra un `TabBarView` con la actividad del usuario (Mis Reportes, Apoyos, Seguimientos, Comentarios). Usa `ActivityListView` y `TarjetaActividad`.
* **`verificacion_screen.dart` (Pestaña 3 - Líder):** El panel de moderación. Muestra un `TabBarView` ("Pendientes", "Historial", "Mis Reportes"). Usa `ListaReportesVerificacion` para cargar y paginar los datos de `LiderService`.
* **`perfil_screen.dart` (Pestaña 4):** El "hub" de la cuenta. Muestra `PerfilHeaderCard` e `InsigniaEstatusWidget`, y una lista de `PerfilActionTile` para navegar a otras pantallas de configuración.

### 3. Flujo de Reportes (Creación y Vista)
* **`create_report_screen.dart`:** El formulario para crear un nuevo reporte. Dividido en secciones (`SeccionEvidencia`, `SeccionDetallesPrincipales`, etc.). Usa `image_picker` para la foto y `geolocator` para la ubicación. Llama a `ReporteService.createReport`.
* **`reporte_detalle_screen.dart`:** Pantalla compleja que muestra el detalle de un reporte. Usa `LayoutDetalleReporte` para la UI. Maneja la lógica para `SeguimientoService`, `ReporteService.apoyarReporte`, y todo el CRUD de comentarios (crear, editar, eliminar, reportar).
* **`pantalla_detalle_pendiente_vista.dart`:** Una vista de detalle *simplificada* para reportes pendientes (usada desde "Cerca de Ti"). Muestra `ReporteHeader`, `MapaVerificacion` y un botón prominente para "Unirse" al reporte.

### 4. Flujo de Verificación (Específico de Líder)
* **`verificacion_detalle_screen.dart`:** La pantalla donde un líder modera un reporte. Muestra `LayoutDetalleVerificacion` y la barra `AccionesModeracion` (Aprobar, Rechazar, Fusionar). Contiene la lógica para llamar a `LiderService`.
* **`pantalla_buscar_reporte_original.dart`:** Pantalla de búsqueda (invocada durante la "fusión") que permite al líder buscar *solo* reportes verificados.
* **`pantalla_editar_reporte_lider.dart`:** Formulario que permite a un líder editar campos de un reporte *antes* de aprobarlo.
* **`pantalla_editar_reporte_autor.dart`:** Formulario que permite al *autor* editar su propio reporte *mientras* está pendiente.
* **`chat_screen.dart`:** La interfaz de chat en tiempo real entre un líder y el autor de un reporte, usando `SocketService`.
* **`conversaciones_screen.dart`:** Muestra la lista de chats de un líder.

### 5. Flujo de Perfil, Pagos y Configuración (Navegación desde `PerfilScreen`)
* **`settings_screen.dart`:** Contiene `SeccionApariencia`, `SeccionNotificaciones` y `SeccionSOS`.
* **`editar_perfil_screen.dart`:** Contiene `SeccionDatosPersonales` y `SeccionSeguridad`.
* **`editar_contacto_screen.dart`:** Formulario para guardar el contacto de emergencia del SOS en `SharedPreferences`.
* **`pantalla_alertas.dart`:** Muestra la lista de notificaciones recibidas (`PerfilService.getMisNotificaciones`).
* **`pantalla_insignias.dart`:** Muestra las insignias y puntos (`GamificacionService.getProgresoInsignias`).
* **`pantalla_planes_suscripcion.dart`:** Muestra `TarjetaPlan` con los planes de `ServicioSuscripcion.getPlanes`.
* **`pantalla_pago.dart`:** Pantalla de checkout que usa `FormularioPago` y llama a `ServicioSuscripcion.suscribirseAlPlan`.
* **`pantalla_gestionar_suscripcion.dart`:** Permite cancelar la suscripción (`ServicioSuscripcion.cancelarSuscripcion`).
* **`pantalla_metodos_pago.dart`:** Gestiona tarjetas guardadas (`MetodoPagoService`).
* **`pantalla_agregar_metodo_pago.dart`:** Formulario simple que usa `FormularioPago`.
* **`pantalla_historial_pagos.dart`:** Muestra `TarjetaHistorialPago` (`PerfilService.getHistorialPagos`).
* **`pantalla_detalle_boleta.dart`:** Muestra `TarjetaDetalleBoleta` (`PerfilService.getDetalleBoleta`).

### 6. Flujo de Funciones Premium (Navegación desde `PerfilScreen`)
* **`pantalla_alertas_personalizadas.dart`:** Muestra `TarjetaZonaSegura` y navega a `pantalla_crear_zona.dart`.
* **`pantalla_crear_zona.dart`:** Mapa interactivo para definir una zona segura.
* **`pantalla_panel_analitico.dart`:** Muestra gráficos (`fl_chart`) con datos de `AnaliticasService`.
* **`pantalla_informes_guardados.dart`:** Lista los PDF generados por `ServicioPdf` y usa `open_file` para abrirlos.
* **`pantalla_estadisticas_personales.dart`:** Muestra gráficos (`fl_chart`) con datos de `PerfilService`.