import React from 'react';
import { Paper, Typography, Box, Stack, Divider, Avatar, Link as MuiLink, Chip } from '@mui/material';
import {
    Person as PersonIcon, PhoneForwarded as PhoneIcon,
    CalendarToday as CalendarIcon, Message as MessageIcon,
    LocationOn as LocationIcon, Phone as PhoneUserIcon,
    Email as EmailIcon, AdminPanelSettings as AdminIcon,
    Group as GroupIcon, Mic as MicIcon
} from '@mui/icons-material';

/**
 * Parses an SMS message string robustly for Google Maps URL and personalized message.
 * Tries multiple URL patterns and flexible message extraction.
 * @param {string} message - The full SMS text.
 * @returns {{locationUrl: string|null, messageText: string|null, fullText: string}} Un objeto con las partes parseadas:
 * - `locationUrl`: La URL de Google Maps extraída (limpia) o null.
 * - `messageText`: El mensaje personalizado extraído o null.
 * - `fullText`: El texto original completo del SMS.
 */
const parseSmsMessage = (message) => {
    const fullText = message || '';
    let locationUrl = null;
    let messageText = null;

    // --- 1. Robust URL Extraction ---
    // Pattern 1: Specific ?q= format (seems common in newer messages)
    const urlRegexQ = /(https?:\/\/maps\.google\.com\/\?q=[-0-9.,]+)/i;
    let urlMatch = fullText.match(urlRegexQ);

    // Pattern 2: More general maps URL (handles if ?q= is missing or different)
    const urlRegexGeneral = /(https?:\/\/maps\.google\.com\/.*)/i;
     if (!urlMatch) {
         urlMatch = fullText.match(urlRegexGeneral);
     }

    if (urlMatch && urlMatch[1]) {
        // Clean trailing punctuation (like '.', ',', or whitespace) from the captured URL
        locationUrl = urlMatch[1].replace(/[.,\s]+$/, '').trim();
    }

    // --- 2. Flexible Message Extraction ---
    let textToSearchMessageIn = fullText;
    // Temporarily remove the found URL (if any) to simplify message searching
    if (locationUrl) {
        // Use the original matched string (including potential trailing chars) for accurate removal
        textToSearchMessageIn = textToSearchMessageIn.replace(urlMatch[0], '');
    }

    // Try finding explicit message prefixes
    const msgPrefixRegex = /Mensaje(?: personalizado)?:?\s*"?([^"]*)"?$/i;
    const msgMatch = textToSearchMessageIn.match(msgPrefixRegex);

    if (msgMatch && msgMatch[1]) {
        // Found using prefix, capture group 1 is the message
        messageText = msgMatch[1].trim();
    } else {
        // No explicit prefix found. Clean known prefixes from the remaining text.
        let cleanedText = textToSearchMessageIn
            .replace(/ALERTA SOS de .*?(Ubicación:|conocida:|mensaje:)/i, '') // Remove prefixes up to known keywords
            .replace(/Ubicación:\s*/i, '') // Remove "Ubicación:"
            .replace(/Última ubicación conocida:\s*/i, '') // Remove "Última ubicación conocida:"
            .replace(/Mensaje:\s*/i, '') // Remove "Mensaje:" if it remained
            .replace(/"$/, '') // Remove trailing quote if any
            .replace(/[.,\s]+$/, '') // Remove trailing punctuation
            .trim(); // Trim whitespace

        if (cleanedText) {
            messageText = cleanedText;
        }
    }

    // Final check: Ensure we don't just have empty quotes or punctuation
     if (messageText && messageText.match(/^[".,:\s]*$/)) {
        messageText = null;
     }

    // If parsing failed completely, use the original text as the message fallback
    if (locationUrl === null && messageText === null && fullText) {
         messageText = fullText;
    }


    return { locationUrl, messageText, fullText };
};


/**
 * Componente helper que devuelve un ícono de MUI basado en el rol del usuario.
 * @param {object} props - Propiedades del componente.
 * @param {string} props.rol - El rol del usuario (ej: 'admin', 'lider_vecinal', 'reportero').
 * @returns {JSX.Element} El ícono de MUI correspondiente.
 */
const RolIcon = ({ rol }) => {
    switch (rol) {
        case 'admin': return <AdminIcon fontSize="small" />;
        case 'lider_vecinal': return <GroupIcon fontSize="small" />;
        case 'reportero': return <MicIcon fontSize="small" />;
        default: return <PersonIcon fontSize="small" />;
    }
};

// --- Componente ItemSmsLog ---

/**
 * Renderiza una tarjeta (Paper) individual para un registro (log) de SMS SOS.
 *
 * Muestra una cabecera con la información del "Usuario SOS" (quien envía)
 * y el "Contacto de Emergencia" (quien recibe), junto con la fecha.
 *
 * En el cuerpo, utiliza la función `parseSmsMessage` para mostrar
 * de forma separada la URL de ubicación (si existe) y el mensaje
 * personalizado (si existe) del contenido del SMS.
 *
 * @param {object} props - Propiedades del componente.
 * @param {object} props.log - El objeto de datos del registro de log.
 * @param {string} props.log.mensaje - El contenido crudo del SMS.
 * @param {string} [props.log.usuario_sos_alias] - Alias del usuario SOS.
 * @param {string} [props.log.usuario_sos_rol] - Rol del usuario SOS.
 * @param {string} [props.log.telefono_usuario_sos] - Teléfono del usuario SOS.
 * @param {string} [props.log.usuario_sos_email] - Email del usuario SOS.
 * @param {string} [props.log.contacto_nombre] - Nombre del contacto de emergencia.
 * @param {string} props.log.contacto_telefono - Teléfono del contacto de emergencia.
 * @param {string} props.log.fecha_envio - Fecha de envío (string ISO 8601 o compatible con `new Date()`).
 * @returns {JSX.Element} Un componente Paper que representa el item del log.
 */
function ItemSmsLog({ log }) {
  // Parse the message using the most robust function
  const parts = parseSmsMessage(log.mensaje);

  return (
    <Paper variant="outlined" sx={{ p: 2.5, mb: 2 }}>
      <Stack spacing={2}>
        {/* Cabecera (Usuario SOS, Contacto, Fecha) */}
        <Stack
          direction={{ xs: 'column', md: 'row' }}
          justifyContent="space-between"
          alignItems={{ xs: 'flex-start', md: 'center' }}
          spacing={{ xs: 2, md: 2 }}
          flexWrap="wrap"
        >
          {/* Usuario SOS */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, minWidth: '250px' }}>
            <Avatar sx={{ bgcolor: 'primary.light', color: 'primary.dark', width: 48, height: 48 }}>
              <PersonIcon />
            </Avatar>
            <Box>
              <Typography variant="caption" color="text.secondary">Usuario SOS</Typography>
              <Typography sx={{ fontWeight: 'bold', fontSize: '1.1rem' }}>{log.usuario_sos_alias || 'N/A'}</Typography>
              <Chip icon={<RolIcon rol={log.usuario_sos_rol} />} label={log.usuario_sos_rol || 'N/A'} size="small" variant="outlined" sx={{ mt: 0.5 }}/>
              <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 0.5 }}>
                  <PhoneUserIcon sx={{ fontSize: '1rem' }}/> {log.telefono_usuario_sos || 'Sin Teléfono'}
              </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <EmailIcon sx={{ fontSize: '1rem' }}/> {log.usuario_sos_email || 'Sin Email'}
              </Typography>
            </Box>
          </Box>

          {/* Contacto Emergencia */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, minWidth: '250px' }}>
            <Avatar sx={{ bgcolor: 'secondary.light', color: 'secondary.dark', width: 48, height: 48 }}>
              <PhoneIcon />
            </Avatar>
            <Box>
              <Typography variant="caption" color="text.secondary">Contacto de Emergencia</Typography>
              <Typography sx={{ fontWeight: 'bold', fontSize: '1.1rem' }}>{log.contacto_nombre || 'Contacto'}</Typography>
              <Typography variant="body2" color="text.secondary">{log.contacto_telefono}</Typography>
            </Box>
          </Box>

          {/* Fecha */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, pt: 1, ml: { md: 'auto' } }}>
              <CalendarIcon fontSize="small" color="action"/>
              <Typography variant="caption" color="text.secondary" noWrap>
                  {new Date(log.fecha_envio).toLocaleString('es-PE')} {/* Use locale */}
              </Typography>
          </Box>
        </Stack>

        <Divider />

        {/* Cuerpo del Mensaje (Parseado) */}
        <Box>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
              <MessageIcon fontSize="small"/> Contenido del Mensaje
          </Typography>
          <Paper variant="outlined" sx={{ p: 2, bgcolor: 'background.default' }}>
            <Stack spacing={1.5}>
              {/* Sección Ubicación: Renderizar SIEMPRE que haya URL */}
              {parts.locationUrl ? (
                <Box>
                  <Typography variant="body2" sx={{ fontWeight: 500, display: 'flex', alignItems: 'center', gap: 0.5, mb: 0.5 }}>
                    <LocationIcon fontSize="small" /> Ubicación:
                  </Typography>
                  <MuiLink
                    href={parts.locationUrl} // URL ya limpia
                    target="_blank" rel="noopener noreferrer"
                    sx={{ wordBreak: 'break-all', fontSize: '0.9rem', fontWeight: 500 }}
                  >
                    {parts.locationUrl}
                  </MuiLink>
                </Box>
              ) : (
                 <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                    <LocationIcon fontSize="small" /> Ubicación no incluida en el mensaje.
                 </Typography>
              )}

              {/* Separador sutil si ambos existen y hay contenido en ambos */}
              {parts.locationUrl && parts.messageText && <Divider light sx={{ my: 0.5 }} />}

              {/* Sección Mensaje: Renderizar SIEMPRE que haya texto */}
              {parts.messageText ? (
                 <Box>
                   <Typography variant="body2" sx={{ fontWeight: 500 }}>Mensaje:</Typography>
                   <Typography variant="body2" sx={{ fontStyle: 'italic', fontSize: '1rem', pl: 1, whiteSpace: 'pre-wrap', wordBreak: 'break-word' }}>
                      "{parts.messageText}"
                   </Typography>
                 </Box>
              ) : (
                // Si solo había URL, no mostrar nada extra aquí.
                // Si no había URL ni mensaje, el fullText se habrá puesto en messageText arriba.
                // Si la lógica falló y ambos son null, mostramos el texto original.
                (!parts.locationUrl && !parts.messageText && parts.fullText) ? (
                    <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word', color: 'text.secondary' }}>
                        (Mensaje original: {parts.fullText})
                    </Typography>
                  ) : (
                      // If there's a URL but truly no message text could be extracted
                      parts.locationUrl && !parts.messageText ?
                      <Typography variant="body2" color="text.secondary" sx={{ fontStyle: 'italic' }}>
                           (Sin mensaje adicional)
                      </Typography>
                      : null
                  )
              )}

            </Stack>
          </Paper>
        </Box>
      </Stack>
    </Paper>
  );
}

export default ItemSmsLog;