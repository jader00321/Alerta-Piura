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
  socket.on('join-chat-room', (roomId) => {
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
     if (!socket.user) {
        console.warn(`Socket ${socket.id}: Intento de enviar mensaje sin usuario asignado.`);
        return;
     }
     const { id_reporte, message_text } = data;
     const id_sender = socket.user.userId;
     const sender_alias = socket.user.alias || 'Usuario';

     if (!id_reporte || !message_text) {
        console.error("Evento 'send-message' recibido con datos incompletos:", data);
        socket.emit('message-error', { message: 'Datos del mensaje incompletos.' });
        return;
     }
     const roomName = id_reporte.toString();
     try {
       console.log(`💾 Guardando mensaje para sala ${roomName} en DB...`);
       const query = 'INSERT INTO chat_messages (id_reporte, id_remitente, remitente_alias, mensaje) VALUES ($1, $2, $3, $4) RETURNING *, to_char(fecha_envio, \'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"\') as fecha_envio_iso';
       const result = await db.query(query, [id_reporte, id_sender, sender_alias, message_text]);
       if (result.rows.length === 0) throw new Error('No se pudo guardar el mensaje.');
       const newMessage = result.rows[0];
       console.log(`   ✅ Mensaje guardado con ID: ${newMessage.id}`);
       console.log(`✉️ Emitiendo mensaje a sala ${roomName}:`, newMessage);
       io.to(roomName).emit('receive-message', newMessage);
     } catch (error) {
         console.error(`❌ Error procesando 'send-message' para sala ${roomName}:`, error);
         socket.emit('message-error', { message: 'No se pudo enviar o guardar el mensaje.' });
     }
  });

  socket.on('disconnect', (reason) => {
    console.log(`🔌 Cliente desconectado: ${socket.id}. Razón: ${reason}`);
  });
  // --- FIN LISTENERS ---
}); // Fin io.on('connection')


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