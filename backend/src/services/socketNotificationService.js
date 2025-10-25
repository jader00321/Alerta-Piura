const sendNotification = (io, userId, data) => {
  if (!io || !userId || !data) {
    console.error('Faltan datos para enviar la notificación por socket.');
    return;
  }

  // Emite el evento a la sala privada del usuario específico.
  const userRoom = `user_${userId}`;
  io.to(userRoom).emit('notification', data);
  console.log(`Notificación enviada a la sala: ${userRoom}`, data);
};

module.exports = {
  sendNotification,
};