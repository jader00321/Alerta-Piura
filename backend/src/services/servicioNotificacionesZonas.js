const db = require('../config/db');
const socketNotificationService = require('./socketNotificationService');

/**
 * Verifica un reporte recién aprobado contra todas las zonas seguras de los usuarios.
 * Si el reporte está dentro de una zona y es de una categoría peligrosa, envía una notificación.
 * @param {object} io - La instancia de Socket.IO.
 * @param {object} reporte - El objeto del reporte que acaba de ser aprobado.
 */
const verificarReporteEnZonas = async (io, reporte) => {
  // Definimos qué categorías consideramos de "alta peligrosidad"
  const categoriasPeligrosas = ['Delito', 'Actividad Sospechosa']; // Puedes expandir esta lista

  if (!categoriasPeligrosas.includes(reporte.categoria) || !reporte.location) {
    // Si el reporte no es de una categoría relevante, no hacemos nada.
    return;
  }

  const lon = reporte.location.coordinates[0];
  const lat = reporte.location.coordinates[1];

  try {
    // Potente consulta de PostGIS: Encuentra todos los usuarios cuyas zonas seguras
    // contienen la ubicación del nuevo reporte.
    const query = `
      SELECT DISTINCT zs.id_usuario
      FROM zonas_seguras zs
      WHERE ST_DWithin(
        zs.centro,
        ST_MakePoint($1, $2)::geography,
        zs.radio_metros
      )
    `;
    const result = await db.query(query, [lon, lat]);

    if (result.rows.length > 0) {
      const usuariosANotificar = result.rows.map(row => row.id_usuario);

      const titulo = 'Alerta en tu Zona Segura';
      const cuerpo = `Se ha verificado un nuevo reporte de '${reporte.categoria}' cerca de tu zona.`;
      const payload = JSON.stringify({ type: 'report_detail', id: reporte.id });

      // Usamos un bucle para enviar una notificación a cada usuario encontrado
      for (const id_usuario of usuariosANotificar) {
        // Evitamos notificar al usuario que creó el reporte (si aplica)
        if (id_usuario !== reporte.id_usuario) {
          await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [id_usuario, titulo, cuerpo, payload]);
          socketNotificationService.sendNotification(io, id_usuario, { title: titulo, body: cuerpo, payload });
        }
      }
    }
  } catch (error) {
    console.error('Error al verificar reporte en zonas seguras:', error);
  }
};

module.exports = {
  verificarReporteEnZonas,
};