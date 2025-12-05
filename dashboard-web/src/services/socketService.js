// src/services/socketService.js
import { io } from 'socket.io-client';

// Lee la URL del backend desde las variables de entorno (recomendado)
// o usa un valor por defecto. Asegúrate que VITE_API_URL_SOCKET apunte
// directamente a la base de tu servidor (ej. http://localhost:3000)
const URL = import.meta.env.VITE_API_URL_SOCKET || 'http://localhost:3000';

/**
 * Clase SocketService: Servicio singleton para gestionar conexiones WebSocket en tiempo real.
 * Utiliza Socket.IO para conectar al backend, manejar autenticación JWT,
 * unirse/salir de salas de chat, enviar/recibir mensajes, y gestionar eventos.
 * 
 * Funcionalidades principales:
 * - Conexión autenticada con token JWT.
 * - Gestión de salas para chats de reportes.
 * - Envío y recepción de mensajes en tiempo real.
 * - Listeners para eventos del servidor (conexión, errores, autenticación).
 * - Desconexión y limpieza de listeners.
 * 
 * Uso típico: Importar la instancia singleton y llamar métodos como connect(), joinRoom(), etc.
 */
class SocketService {
  socket = null; // Instancia del socket de Socket.IO
  isAuthenticated = false; // Flag para indicar si el backend confirmó la autenticación

  /**
   * Conecta (o reconecta) al servidor WebSocket, pasando el token JWT para autenticación inmediata.
   * Si ya hay un socket conectado y autenticado, no hace nada.
   * 
   * @param {string} token - El token JWT del administrador para autenticar la conexión.
   */
  connect(token) {
    // Si ya existe un socket y está conectado, no hagas nada
    if (this.socket && this.socket.connected) {
      console.log('SocketService: Ya conectado.');
      // Si ya está autenticado, no necesita volver a hacerlo
      if (this.isAuthenticated) {
         console.log('SocketService: Ya autenticado.');
         return;
      }
      // Si está conectado pero no autenticado (raro, pero posible), intenta autenticar de nuevo
    }

    // Si hay un socket viejo, desconéctalo antes de crear uno nuevo
    if (this.socket) {
      console.log('SocketService: Desconectando socket existente...');
      this.socket.disconnect();
      this.socket = null;
      this.isAuthenticated = false;
    }

    // Asegura que haya un token
    if (!token) {
      console.error('SocketService: No se proporcionó token para la conexión.');
      return;
    }

    console.log(`SocketService: Intentando conectar a ${URL}...`);
    this.isAuthenticated = false; // Resetear flag

    // Crea la instancia del socket, pasando el token en la query
    // El backend (index.js modificado) leerá esto en io.on('connection')
    this.socket = io(URL, {
      transports: ['websocket'], // Forzar WebSocket si es posible
      autoConnect: true,        // Intentar conectar automáticamente
      query: { token }          // Envía el token aquí
      // Puedes añadir más opciones si las necesitas, ej. reconnectionAttempts
    });

    // Configurar listeners básicos una sola vez
    this._setupBaseListeners();
  }

  /**
   * Configura los listeners esenciales para la conexión, errores y autenticación.
   * Estos listeners se configuran una vez por instancia de socket.
   */
  _setupBaseListeners() {
    if (!this.socket) return;

    // Se dispara cuando la conexión física se establece
    this.socket.on('connect', () => {
      console.log('✅ SocketService: Conectado al servidor WebSocket con ID:', this.socket?.id);
      // OJO: La conexión está establecida, pero aún esperamos la confirmación
      // de autenticación del backend.
    });

    // Se dispara si hay un error DURANTE la conexión inicial
    this.socket.on('connect_error', (err) => {
      console.error('❌ SocketService: Error de conexión WebSocket:', err.message);
      // Aquí podrías notificar a la UI o intentar reconectar manualmente si autoConnect falla
      this.isAuthenticated = false; // Asegura que no quede como autenticado
    });

    // Se dispara cuando el backend confirma la autenticación (evento emitido por index.js)
    this.socket.on('authenticated', () => {
      console.log('🛡️ SocketService: Conexión WebSocket autenticada por el servidor.');
      this.isAuthenticated = true;
      // Aquí es seguro empezar a unirse a salas o emitir eventos que requieran auth.
    });

    // Se dispara si el backend rechaza la autenticación (token inválido/expirado)
    this.socket.on('unauthorized', (data) => {
      console.error('🚫 SocketService: WebSocket no autorizado:', data.message);
      this.isAuthenticated = false;
      // Es crucial desconectar aquí para evitar reintentos con token inválido
      this.disconnect();
      // Considera llamar a una función global de logout si esto ocurre
      // Ejemplo: import { logout } from '../auth'; logout();
    });

    // Se dispara cuando el socket se desconecta (intencional o por error)
    this.socket.on('disconnect', (reason) => {
      console.log(`🔌 SocketService: Desconectado del servidor WebSocket. Razón: ${reason}`);
      this.isAuthenticated = false;
      // Podrías intentar reconectar aquí si `reason` es 'io server disconnect' o 'transport error'
      // if (reason === 'io server disconnect' || reason === 'transport error') {
      //   // Intenta reconectar después de un delay, o notifica a la UI
      // }
      // Nota: socket.io-client intenta reconectar automáticamente por defecto
    });

     // Listener genérico para errores después de la conexión
     this.socket.on('error', (error) => {
       console.error('❌ SocketService: Error general de Socket:', error);
     });

     // Listener para errores específicos del servidor (ej. al enviar mensaje)
     this.socket.on('message-error', (data) => {
        console.error('❌ SocketService: Error reportado por el servidor:', data.message);
        // Podrías mostrar este mensaje al usuario en el chat modal
     });
  }

  /**
   * Desconecta el socket actual y resetea el estado.
   */
  disconnect() {
    if (this.socket) {
      console.log('SocketService: Desconectando...');
      this.socket.disconnect();
      this.socket = null; // Libera la instancia
      this.isAuthenticated = false;
    }
  }

  /**
   * Emite un evento al servidor si el socket está conectado y autenticado.
   * Si no está listo, registra una advertencia en consola.
   * 
   * @param {string} eventName - El nombre del evento a emitir.
   * @param {object} data - Los datos a enviar con el evento.
   */
  emit(eventName, data) {
    // Verifica conexión Y autenticación antes de emitir
    if (this.socket && this.socket.connected && this.isAuthenticated) {
      this.socket.emit(eventName, data);
    } else {
        console.warn(`SocketService: No se pudo emitir [${eventName}]. Conectado: ${this.socket?.connected}, Autenticado: ${this.isAuthenticated}`);
        // Considera mostrar un error o reintentar si es crítico
    }
  }

  /**
   * Se une a una sala de chat específica (usualmente para un reporte).
   * Emite 'join-chat-room' al servidor.
   * 
   * @param {string|number} roomId - El ID de la sala (e.g., ID del reporte).
   */
  joinRoom(roomId) {
    if(roomId) {
      console.log(`SocketService: Uniendo a la sala de chat: ${roomId}`);
      // 'emit' ya verifica conexión/autenticación
      this.emit('join-chat-room', roomId.toString());
    } else {
      console.warn("SocketService: No se puede unir a la sala - no se proporcionó roomId");
    }
  }

  /**
   * Sale de una sala de chat específica.
   * Emite 'leave-chat-room' al servidor.
   * 
   * @param {string|number} roomId - El ID de la sala.
   */
  leaveRoom(roomId) {
    if (roomId) {
      console.log(`SocketService: Saliendo de la sala de chat: ${roomId}`);
      // Emitir incluso si no está autenticado (backend debería manejarlo)
      // O usa this.emit si quieres asegurar auth antes de salir
      if (this.socket && this.socket.connected) {
         this.socket.emit('leave-chat-room', roomId.toString());
      }
    } else {
      console.warn("SocketService: No se puede salir de la sala - no se proporcionó roomId");
    }
  }

  /**
   * Envía un mensaje de chat al servidor.
   * Emite 'send-message' con los datos del mensaje.
   * 
   * @param {object} messageData - Datos del mensaje (e.g., { id_reporte, message_text }).
   */
  sendMessage(messageData) {
      console.log(`SocketService: Mensaje enviado:`, messageData);
      // 'emit' ya verifica conexión/autenticación
      this.emit('send-message', messageData);
  }

  /**
   * Registra un listener para un evento del servidor.
   * Remueve listeners anteriores para el mismo evento y callback para evitar duplicados.
   * 
   * @param {string} eventName - El nombre del evento a escuchar.
   * @param {Function} callback - La función a ejecutar cuando se reciba el evento.
   */
  on(eventName, callback) {
    if (this.socket) {
      // Quitar listener anterior para evitar duplicados si se llama múltiples veces
      this.socket.off(eventName, callback);
      // Añadir el nuevo listener
      this.socket.on(eventName, callback);
      console.log(`SocketService: Escuchando evento [${eventName}]`);
    } else {
      console.warn(`SocketService: Socket no inicializado. No se puede escuchar [${eventName}]`);
    }
  }

  /**
   * Elimina un listener para un evento del servidor.
   * Si no se proporciona callback, elimina todos los listeners para ese evento.
   * 
   * @param {string} eventName - El nombre del evento.
   * @param {Function} [callback] - La función específica a eliminar (opcional).
   */
  off(eventName, callback) {
    if (this.socket) {
      console.log(`SocketService: Dejando de escuchar evento [${eventName}]`);
      this.socket.off(eventName, callback);
    }
  }
}

// Exportamos una única instancia (Singleton) para usar en toda la app
const socketService = new SocketService();
export default socketService;
