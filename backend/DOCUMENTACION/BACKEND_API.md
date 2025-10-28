# Documentación de la API - Backend Reporta Piura

Esta documentación describe todos los endpoints de la API REST y los eventos de WebSocket expuestos por el backend de Node.js.

## Middlewares de Autenticación

* **Público:** No requiere autenticación.
* **auth:** Requiere un token JWT válido de usuario (`auth.middleware.js`).
* **premium:** Requiere un token `auth` Y que el usuario tenga un plan de suscripción activo o sea rol 'reportero' o 'admin' (`premium.middleware.js`).
* **admin:** Requiere un token `auth` Y que el usuario tenga el rol 'admin' (`admin.middleware.js`).

---

## Endpoints de la API REST

###  Autenticación (`/api/auth`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `POST` | `/register` | Público | Registra un nuevo usuario 'ciudadano'. |
| `POST` | `/login` | Público | Autentica un usuario y devuelve un token JWT. |
| `GET` | `/refresh-token` | auth | Devuelve un nuevo token JWT con los datos más recientes del usuario (rol, plan). |
| `POST` | `/verify-password` | auth | Verifica la contraseña actual del usuario. |

### Reportes (`/api/reportes`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | Público | Obtiene una lista de reportes (filtrados, por defecto 'verificado'). |
| `GET` | `/:id` | Público | Obtiene los detalles completos de un reporte (incluyendo comentarios). |
| `GET` | `/riesgo-zona` | Público | Calcula un puntaje de riesgo para una lat/lon y radio. |
| `GET` | `/mapa-calor` | Público | Obtiene las coordenadas de reportes verificados para el heatmap. |
| `POST` | `/` | auth | Crea un nuevo reporte. Usa `multipart/form-data` para subir `foto`. |
| `POST` | `/:id/apoyar` | auth | Da o quita "apoyo" (like) a un reporte verificado. |
| `POST` | `/:id/unirse_pendiente` | auth | Permite a un usuario "unirse" a un reporte pendiente, sumando +1 al contador. |
| `DELETE` | `/:id/unirse_pendiente` | auth | Permite al usuario quitar su apoyo de un reporte pendiente. |
| `DELETE` | `/:id` | auth | Permite al *autor* eliminar su propio reporte si aún está 'pendiente'. |
| `GET` | `/v1/cercanos` | auth | **[App Móvil]** Obtiene reportes (verificados y pendientes) cercanos a una lat/lon. |
| `GET` | `/:id/chat` | auth | Obtiene el historial de chat de un reporte. |

### Comentarios (`/api/comentarios`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `POST` | `/` | auth | Publica un nuevo comentario en un reporte (definido en el *body*). |
| `PUT` | `/:id` | auth | Edita un comentario (solo el autor). |
| `DELETE`| `/:id` | auth | Elimina un comentario (autor o moderador). |
| `POST` | `/:id/reportar` | auth | Reporta un comentario para revisión de un líder. |
| `POST` | `/:id/apoyar` | auth | Da o quita "apoyo" (like) a un comentario. |

### Perfil de Usuario (`/api/perfil`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/me` | auth | Obtiene los datos del perfil del usuario autenticado (puntos, insignias, plan). |
| `GET` | `/me/reportes` | auth | Obtiene los reportes creados por el usuario. |
| `GET` | `/me/apoyos` | auth | Obtiene los reportes que el usuario ha apoyado. |
| `GET` | `/me/comentarios` | auth | Obtiene los reportes donde el usuario ha comentado. |
| `GET` | `/me/conversaciones` | auth | Obtiene los chats activos del usuario (para líderes). |
| `GET` | `/me/notificaciones` | auth | Obtiene la lista de notificaciones del usuario. |
| `PUT` | `/me/notificaciones/mark-all-read` | auth | Marca todas las notificaciones como leídas. |
| `PUT` | `/me` | auth | Actualiza datos básicos (nombre, alias, teléfono). |
| `PUT` | `/me/email` | auth | Actualiza el email (requiere contraseña). |
| `PUT` | `/me/password` | auth | Actualiza la contraseña (requiere contraseña actual). |
| `GET` | `/me/payment-history` | auth | Obtiene el historial de transacciones de pago. |
| `GET` | `/me/invoices/:transactionId` | auth | Obtiene el detalle (boleta) de una transacción. |
| `GET` | `/me/zonas-seguras` | auth | Obtiene las zonas seguras creadas por el usuario. |
| `POST` | `/me/zonas-seguras` | auth | Crea una nueva zona segura. |
| `DELETE` | `/me/zonas-seguras/:id` | auth | Elimina una zona segura. |
| `POST` | `/postular-lider` | auth | Envía una solicitud para convertirse en 'lider_vecinal'. |

### Suscripciones y Pagos (`/api/subscriptions`, `/api/metodos-pago`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/subscriptions/plans` | auth | Obtiene la lista de planes de suscripción disponibles. |
| `POST` | `/api/subscriptions/subscribe` | auth | Suscribe al usuario a un plan, procesa el pago y devuelve un *nuevo token*. |
| `PUT` | `/api/subscriptions/cancel` | auth | Cancela la suscripción del usuario. |
| `GET` | `/api/metodos-pago` | auth | Lista los métodos de pago guardados por el usuario. |
| `POST` | `/api/metodos-pago` | auth | Guarda un nuevo método de pago. |
| `PUT` | `/api/metodos-pago/:id/predeterminado` | auth | Marca un método de pago como predeterminado. |
| `DELETE`| `/api/metodos-pago/:id` | auth | Elimina un método de pago. |

### Alerta SOS (`/api/sos`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `POST` | `/activate` | auth, premium | **[Crítico]** Activa una nueva alerta SOS. Registra ubicación inicial, contacto y emite socket. |
| `POST` | `/:alertId/location` | auth | Añade una actualización de ubicación a una alerta SOS activa. |
| `PUT` | `/:alertId/deactivate` | auth | Permite al *usuario* finalizar su propia alerta SOS. |

### Panel de Líder (`/api/lider`)

*Todos los endpoints requieren `auth` y la lógica del controlador valida el rol de 'lider_vecinal' y sus zonas asignadas.*

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/stats/moderacion` | auth | Obtiene contadores para el dashboard del líder. |
| `GET` | `/reportes-pendientes` | auth | Obtiene la lista paginada de reportes por verificar (filtrada por zona). |
| `GET` | `/reportes-moderados` | auth | Obtiene el historial de reportes moderados por el líder. |
| `PUT` | `/reportes/:id/aprobar` | auth | Aprueba un reporte. Dispara notificación al autor y a zonas seguras. |
| `PUT` | `/reportes/:id/rechazar` | auth | Rechaza un reporte. Dispara notificación al autor. |
| `POST` | `/reporte/:id/fusionar` | auth | Fusiona un reporte pendiente con uno original verificado. |
| `POST` | `/reportes/:id/solicitar-revision` | auth | Escala un caso (solicitud de revisión) a un admin. |
| `GET` | `/me/zonas-asignadas` | auth | Obtiene la lista de distritos asignados al líder. |

### Analíticas App Móvil (`/api/analiticas`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `GET` | `/por-categoria` | auth, premium | Obtiene datos para el gráfico de reportes por categoría. |
| `GET` | `/por-distrito` | auth, premium | Obtiene datos para el gráfico de reportes por distrito. |
| `GET` | `/tendencia` | auth, premium | Obtiene datos para el gráfico de tendencia de reportes. |

### Panel de Administración (`/api/admin`)

| Método | Ruta | Middleware | Descripción |
| :--- | :--- | :--- | :--- |
| `POST` | `/login` | Público | Inicia sesión para roles 'admin' o 'reportero'. |
| `GET` | `/stats` | admin | Obtiene todas las estadísticas globales para el dashboard principal. |
| `GET` | `/users` | admin | Obtiene la lista de todos los usuarios. |
| `PUT` | `/users/:id/role` | admin | Cambia el rol de un usuario. |
| `PUT` | `/users/:id/status` | admin | Cambia el estado de un usuario (activo, suspendido). |
| `GET` | `/reports` | admin | Obtiene todos los reportes con filtros avanzados (sin restricción de zona). |
| `PUT` | `/reports/:id/visibility` | admin | Oculta o re-publica un reporte verificado. |
| `DELETE`| `/reports/:id` | admin | Elimina permanentemente un reporte. |
| `GET` | `/sos-dashboard` | admin | Obtiene la lista de todas las alertas SOS (activas e historial). |
| `GET` | `/moderation/comments` | admin | Obtiene la cola de comentarios reportados. |
| `PUT` | `/moderation/comments/:id` | admin | Resuelve un reporte de comentario (ej. ocultar). |

---

## Eventos de WebSocket (Socket.IO)

El servidor escucha y emite eventos para la comunicación en tiempo real.

### Eventos Emitidos por el Cliente (App -> Servidor)

| Evento | Payload | Descripción |
| :--- | :--- | :--- |
| `connection` | `{ query: { token: '...' } }` | Se dispara al conectar. El servidor usa el token para autenticar el socket. |
| `join-chat-room` | `reporteId (string)` | Une al usuario a la sala de chat de un reporte específico. |
| `leave-chat-room` | `reporteId (string)` | Saca al usuario de la sala de chat. |
| `send-message` | `{ id_reporte, message_text }` | Envía un mensaje de chat. El servidor lo guarda y lo retransmite. |

### Eventos Emitidos por el Servidor (Servidor -> App)

| Evento | Payload | Descripción |
| :--- | :--- | :--- |
| `authenticated` | `(ninguno)` | Confirma que el socket se autenticó correctamente con el token. |
| `unauthorized` | `{ message: '...' }` | Notifica que la autenticación del socket falló. |
| `notification` | `{ title, body, payload }` | Envía una notificación push en tiempo real (ej. nuevo comentario, reporte aprobado). |
| `receive-message` | `Objeto ChatMessage` | Retransmite un nuevo mensaje a todos los miembros de una sala de chat. |
| `new-sos-alert` | `Objeto SosAlert` | **(Admin)** Notifica al panel de admin que se activó una nueva alerta SOS. |
| `sos-location-update` | `{ alertId, location }` | **(Admin)** Envía actualizaciones de ubicación en vivo al panel de admin. |
| `stopSos` | `{ alertId, reason }` | Notifica a un usuario específico que su alerta SOS fue finalizada remotamente por un admin. |