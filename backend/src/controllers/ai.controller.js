const fetch = require('node-fetch');
// Cargamos las variables de entorno (aunque index.js ya lo hace, es buena práctica confirmar)
require('dotenv').config(); 

/**
 * Mejora la descripción de un reporte ciudadano utilizando Gemini.
 * Convierte lenguaje coloquial en un reporte técnico y formal.
 */
const improveDescription = async (req, res) => {
  const { text } = req.body;

  // LEEMOS LA CLAVE DESDE EL ENTORNO
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    console.error('CRÍTICO: No se ha configurado GEMINI_API_KEY en el archivo .env');
    return res.status(500).json({ message: 'Error de configuración del servidor (API Key faltante).' });
  }

  if (!text || text.length < 5) {
    return res.status(400).json({ message: 'El texto es muy corto para ser mejorado.' });
  }

  try {
    // Prompt de ingeniería para Gemini
    const prompt = `Actúa como un experto en gestión municipal y redacción técnica. 
    Reescribe la siguiente descripción de un reporte ciudadano para que sea formal, clara, objetiva y transmita sentido de urgencia adecuado para las autoridades. 
    Mantén el idioma español. No agregues saludos ni despedidas, ni frases como "Aquí tienes la versión mejorada", solo devuelve el texto del reporte mejorado directamente.
    
    Descripción original: "${text}"`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=${apiKey}`;

    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }]
        })
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error('Gemini API Error:', JSON.stringify(data, null, 2));
      // Manejo específico de errores comunes
      if (response.status === 403) {
          throw new Error('Credenciales de IA inválidas o expiradas.');
      }
      throw new Error('Error al comunicarse con la IA de Google.');
    }

    // Extracción segura de la respuesta
    const enhancedText = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!enhancedText) {
      throw new Error('La IA no devolvió ninguna sugerencia.');
    }

    res.status(200).json({ 
      original: text,
      enhanced: enhancedText.trim() 
    });

  } catch (error) {
    console.error('Error en improveDescription:', error.message);
    res.status(500).json({ message: 'No se pudo mejorar el texto en este momento.' });
  }
};

module.exports = {
  improveDescription
};