// backend/src/index.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require("socket.io");
const jwt = require('jsonwebtoken');
const db = require('./config/db.js');

// Importación de todas las rutas
const authRoutes = require('./routes/auth.routes.js');
const reportesRoutes = require('./routes/reportes.routes.js');
const perfilRoutes = require('./routes/perfil.routes.js');
const liderRoutes = require('./routes/lider.routes.js');
const comentariosRoutes = require('./routes/comentarios.routes.js');
const usuariosRoutes = require('./routes/usuarios.routes.js');
const adminRoutes = require('./routes/admin.routes.js');
const sosRoutes = require('./routes/sos.routes.js');
const subscriptionRoutes = require('./routes/subscription.routes.js');
const seguimientoRoutes = require('./routes/seguimiento.routes.js');
const metodoPagoRoutes = require('./routes/metodoPago.routes.js');
const analiticasRoutes = require('./routes/analiticas.routes.js');
const categoriasRoutes = require('./routes/categorias.routes.js');
const gamificacionRoutes = require('./routes/gamificacion.routes.js');
const aiRoutes = require('./routes/ai.routes');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*", // Restringe en producción
    methods: ["GET", "POST"]
  }
});

app.set('socketio', io);

// --- WebSocket Connection Logic ---
io.on('connection', (socket) => {
  console.log(`🔌 Cliente conectado: ${socket.id}`);

  // --- LÓGICA DE AUTENTICACIÓN INMEDIATA ---
  try {
    const token = socket.handshake.query.token; // Obtener token de la query
    if (!token) {
      console.log(`   ⚠️ Socket ${socket.id}: No se proporcionó token en la conexión.`);
      throw new Error('No se proporcionó token');
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = decoded.user; // { userId, email, alias, rol, planId }

    if (!user || !user.userId) {
      console.log(`   ❌ Socket ${socket.id}: Token inválido (payload incorrecto).`);
      throw new Error('Token inválido');
    }

    // Asignar datos del usuario al objeto socket
    socket.user = user;
    console.log(`   ✅ Socket ${socket.id} autenticado INMEDIATAMENTE como usuario ${user.userId} (${user.alias}, Rol: ${user.rol}).`);

    // Unir a la sala personal inmediatamente
    const userRoom = `user_${user.userId}`;
    socket.join(userRoom);
    console.log(`   🚪 Socket ${socket.id} unido a sala personal ${userRoom}`);

    socket.emit('authenticated'); // Evento de éxito

  } catch (err) {
    console.error(`   ❌ Error de autenticación INMEDIATA en socket ${socket.id}: ${err.message}`);
    socket.emit('unauthorized', { message: 'Token inválido o expirado al conectar' });
    socket.disconnect(true); // Desconectar si falla
    return;
  }
  // --- FIN AUTENTICACIÓN ---


  // --- LISTENERS (join, leave, send-message, disconnect sin cambios) ---
  /*socket.on('join-chat-room', (roomId) => {
    if (!socket.user) {
        console.warn(`Socket ${socket.id}: Intento de unirse a sala ${roomId} sin usuario asignado.`);
        return socket.emit('unauthorized', { message: 'Error de autenticación interna.' });
    }
    const roomName = roomId.toString();
    socket.join(roomName);
    console.log(`💬 Usuario ${socket.user.userId} (Socket ${socket.id}) se unió a la sala de chat ${roomName}`);
  });

  socket.on('leave-chat-room', (roomId) => {
    if (roomId) {
      const roomName = roomId.toString();
      socket.leave(roomName);
      console.log(`🚪 Socket ${socket.id} salió de la sala de chat ${roomName}`);
    }
  });

  socket.on('send-message', async (data) => {
        console.log("Evento 'send-message' recibido:", data);
        
        // --- CORRECCIÓN CRÍTICA DE REFERENCIAS ---
        // 1. Desestructuración de variables directamente desde 'data' para evitar ReferenceError
        const id_reporte = data.id_reporte;
        const mensaje = data.mensaje;
        const id_remitente = data.id_remitente;
        const es_admin = data.es_admin || false;
        const remitente_alias = data.remitente_alias || 'Usuario';
        
        if (!id_reporte || !mensaje || !id_remitente) {
          console.error("❌ Socket: Datos incompletos. Faltan id_reporte, mensaje o id_remitente.", data);
          return; // Detener si faltan datos críticos
        }

        const leido = es_admin ? true : false; 

        try {
            // 2. Guardar en BD (Usando las variables locales explícitamente)
            const query = `
                INSERT INTO chat_messages (id_reporte, id_remitente, mensaje, remitente_alias, es_admin, fecha_envio, leido)
                VALUES ($1, $2, $3, $4, $5, NOW(), $6)
                RETURNING id, id_reporte, id_remitente, mensaje, remitente_alias, es_admin, leido, fecha_envio AS timestamp
            `;
            const result = await db.query(query, [id_reporte, id_remitente, mensaje, remitente_alias, es_admin, leido]);
            const savedMsg = result.rows[0];

            // 3. Emitir a la sala (Esto hace que el mensaje vuelva al remitente para confirmación)
            io.to(`report_${id_reporte}`).emit('receive-message', savedMsg);
            
            // 4. Notificar globalmente si no es admin
            if (!es_admin) {
                io.emit('new_chat_notification'); 
            }

        } catch (err) {
            console.error("Error guardando mensaje socket:", err);
        }
    });

  socket.on('disconnect', (reason) => {
    console.log(`🔌 Cliente desconectado: ${socket.id}. Razón: ${reason}`);
  });*/
  /*socket.on('joinRoom', (room) => {
        socket.join(room);
        console.log(`Socket ${socket.id} se unió a la sala: ${room}`);
    });

    socket.on('leaveRoom', (room) => {
        socket.leave(room);
        console.log(`Socket ${socket.id} salió de la sala: ${room}`);
    });
    // -------------------------------------------

    // --- 2. LÓGICA DE ENVÍO DE MENSAJES ---
    socket.on('send-message', async (data) => {
        console.log("Evento 'send-message' recibido:", data);
        
        // Extracción segura de datos
        const { id_reporte, mensaje, id_remitente, es_admin, remitente_alias } = data;

        // Validación estricta
        if (!id_reporte || !mensaje || !id_remitente) {
          console.error("❌ Socket: Datos incompletos.", data);
          return; 
        }

        const esAdmin = es_admin || false;
        const alias = remitente_alias || 'Usuario';
        const leido = esAdmin ? true : false; // Si lo envía el admin, nace leído (por el admin)

        try {
            // Guardar en BD
            const query = `
                INSERT INTO chat_messages (id_reporte, id_remitente, mensaje, remitente_alias, es_admin, fecha_envio, leido)
                VALUES ($1, $2, $3, $4, $5, NOW(), $6)
                RETURNING id, id_reporte, id_remitente, mensaje, remitente_alias, es_admin, leido, fecha_envio AS timestamp
            `;
            const result = await db.query(query, [id_reporte, id_remitente, mensaje, alias, esAdmin, leido]);
            const savedMsg = result.rows[0];

            // Emitir a la sala específica (ESTO AHORA FUNCIONARÁ PORQUE YA EXISTE joinRoom)
            io.to(`report_${id_reporte}`).emit('receive-message', savedMsg);
            
            // Notificación global de chat nuevo (para el panel web)
            if (!esAdmin) {
                io.emit('new_chat_notification'); 
            }

        } catch (err) {
            console.error("Error guardando mensaje socket:", err);
        }
    });

    socket.on('disconnect', () => {
        console.log('Cliente desconectado:', socket.id);
    });*/
    // --- 1. LÓGICA DE UNIÓN A SALAS (FUSIÓN) ---
    
    // Método usado por la APP MÓVIL
    socket.on('joinRoom', (room) => {
        // La app ya envía "report_70", así que lo usamos directo
        socket.join(room);
        console.log(`📱 App (Socket ${socket.id}) se unió a sala: ${room}`);
    });

    // Método usado por la PÁGINA WEB
    socket.on('join-chat-room', (roomId) => {
        // La web a veces envía solo el número "70" o "report_70". Estandarizamos.
        const roomName = roomId.toString().startsWith('report_') 
            ? roomId 
            : `report_${roomId}`;
            
        socket.join(roomName);
        console.log(`💻 Web (Socket ${socket.id}) se unió a sala: ${roomName}`);
    });

    // --- 2. LÓGICA DE SALIDA DE SALAS (FUSIÓN) ---
    
    socket.on('leaveRoom', (room) => {
        socket.leave(room);
    });

    socket.on('leave-chat-room', (roomId) => {
        const roomName = roomId.toString().startsWith('report_') 
            ? roomId 
            : `report_${roomId}`;
        socket.leave(roomName);
    });

    // --- 3. LÓGICA DE ENVÍO DE MENSAJES (ROBUSTA) ---
    socket.on('send-message', async (data) => {
        console.log("📨 Evento 'send-message' recibido:", data);
        
        const { id_reporte, mensaje, id_remitente, es_admin, remitente_alias } = data;

        // Validación flexible para aceptar diferentes nombres de campos si es necesario
        const senderId = id_remitente || data.id_sender || data.id_usuario;

        if (!id_reporte || !mensaje || !senderId) {
          console.error("❌ Socket: Datos incompletos.", data);
          return; 
        }

        const esAdmin = es_admin === true || es_admin === 'true'; // Asegurar booleano
        const alias = remitente_alias || data.sender_alias || 'Usuario';
        
        // --- CORRECCIÓN DE LÓGICA DE LECTURA ---
        // Un mensaje nuevo SIEMPRE nace como NO LEÍDO por la contraparte.
        // Si lo envía el Admin, el Usuario no lo ha leído.
        // Si lo envía el Usuario, el Admin no lo ha leído.
        const leido = false; 

        try {
            // Guardar en BD
            const query = `
                INSERT INTO chat_messages (id_reporte, id_remitente, mensaje, remitente_alias, es_admin, fecha_envio, leido)
                VALUES ($1, $2, $3, $4, $5, NOW(), $6)
                RETURNING id, id_reporte, id_remitente, mensaje, remitente_alias, es_admin, leido, fecha_envio AS timestamp
            `;
            
            const result = await db.query(query, [id_reporte, senderId, mensaje, alias, esAdmin, leido]);
            const savedMsg = result.rows[0];

            // 1. Emitir a la sala del chat (para que aparezca en la pantalla de chat abierta)
            const roomName = `report_${id_reporte}`;
            io.to(roomName).emit('receive-message', savedMsg);
            
            // 2. Emitir evento GLOBAL de actualización de lista (NUEVO)
            // Esto avisará a la pantalla de "Conversaciones" que debe recargar la lista para reordenar
            io.emit('refresh_conversations_list', { 
                id_reporte, 
                ultimo_mensaje: mensaje, 
                timestamp: savedMsg.timestamp 
            });

            // 3. Notificaciones específicas por rol
            if (!esAdmin) {
                // Si el usuario escribió, avisar al Admin (Web)
                io.emit('new_chat_notification'); 
            } else {
                // Si el Admin escribió, avisar al Usuario (Móvil)
                // Encontrar el ID del usuario dueño del reporte para enviarle notif (opcional si usas salas privadas)
            }

            console.log(`✅ Mensaje guardado y emitido en sala ${roomName}`);

        } catch (err) {
            console.error("Error guardando mensaje socket:", err);
        }
    });

    socket.on('disconnect', () => {
        console.log('Cliente desconectado:', socket.id);
    });
}); 


// --- Express Middlewares & Routes ---
app.use(cors({
    origin: "*", // Restringe en producción
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
    credentials: true,
    allowedHeaders: "Authorization, Content-Type",
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Healthcheck Route
app.get('/api/healthcheck', (req, res) => {
  res.status(200).json({ status: 'success', message: 'Servidor funcionando.' });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/seguimiento', seguimientoRoutes);
app.use('/api/perfil', perfilRoutes);
app.use('/api/lider', liderRoutes);
app.use('/api/comentarios', comentariosRoutes);
app.use('/api/usuarios', usuariosRoutes);
app.use('/api/sos', sosRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/metodos-pago', metodoPagoRoutes);
app.use('/api/analiticas', analiticasRoutes);
app.use('/api/categorias', categoriasRoutes);
app.use('/api/gamificacion', gamificacionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/ai', aiRoutes);

// --- Start Server ---
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Escuchar en todas las interfaces

// --- CORRECCIÓN CLAVE ---
server.listen(PORT, HOST, () => {
  console.log(`🚀 Servidor (con WebSockets) corriendo en http://${HOST}:${PORT}`);
  // También puedes imprimir localhost si quieres para acceso local
  console.log(`   -> También accesible localmente en http://localhost:${PORT}`);
});
// --- FIN CORRECCIÓN ---