require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require("socket.io");
const db = require('./config/db.js');

const authRoutes = require('./routes/auth.routes.js');
const reportesRoutes = require('./routes/reportes.routes.js');
const perfilRoutes = require('./routes/perfil.routes.js');
const liderRoutes = require('./routes/lider.routes.js');
const comentariosRoutes = require('./routes/comentarios.routes.js');
const usuariosRoutes = require('./routes/usuarios.routes.js');
const adminRoutes = require('./routes/admin.routes.js');
const sosRoutes = require('./routes/sos.routes.js');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "http://localhost:5173",
    methods: ["GET", "POST"]
  }
});

app.set('socketio', io);

io.on('connection', (socket) => {
  console.log('A client connected:', socket.id);

  // Event for a user to join a specific chat room
  socket.on('join-chat-room', (reportId) => {
    socket.join(reportId);
    console.log(`Client ${socket.id} joined room ${reportId}`);
  });

  // Event for when a new message is sent
  socket.on('send-message', async (data) => {
    const { id_reporte, id_sender, message_text, sender_alias } = data;
    
    // 1. Save the message to the database
    const query = 'INSERT INTO chat_messages (id_reporte, id_sender, message_text) VALUES ($1, $2, $3) RETURNING *';
    const result = await db.query(query, [id_reporte, id_sender, message_text]);
    
    // 2. Broadcast the new message to everyone in the specific room
    const newMessage = {
        ...result.rows[0],
        sender_alias: sender_alias
    };
    io.to(id_reporte).emit('receive-message', newMessage);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const corsOptions = {
  origin: "http://localhost:5173",
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  credentials: true,
  allowedHeaders: "Authorization, Content-Type",
};
app.use(cors(corsOptions));

app.use(express.urlencoded({ extended: true }));

app.get('/api/healthcheck', (req, res) => {
  res.status(200).json({ status: 'success', message: 'Servidor funcionando.' });
});

app.use('/api/auth', authRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/perfil', perfilRoutes);
app.use('/api/lider', liderRoutes);
app.use('/api/comentarios', comentariosRoutes);
app.use('/api/usuarios', usuariosRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/sos', sosRoutes);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Servidor (con WebSockets) corriendo en http://localhost:${PORT}`);
});