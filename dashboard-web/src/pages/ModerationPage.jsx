// dashboard-web/src/pages/ModerationPage.jsx
import React, { useState } from 'react';
import { Box, Paper, Typography, Tabs, Tab, Accordion, AccordionSummary, AccordionDetails } from '@mui/material';
import {
  ExpandMore as ExpandMoreIcon,
  Chat as CommentIcon,
  Person as PersonIcon,
  History as HistoryIcon,
  HelpOutline as HelpIcon // Icono para la guía
} from '@mui/icons-material';

// --- Importar los nuevos paneles ---
import PanelComentariosReportados from '../components/Moderacion/PanelComentariosReportados';
import PanelUsuariosReportados from '../components/Moderacion/PanelUsuariosReportados';
import PanelHistorialModeracion from '../components/Moderacion/PanelHistorialModeracion';

// --- Componente de Panel de Pestaña ---
function TabPanel(props) {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`moderation-tabpanel-${index}`}
      aria-labelledby={`moderation-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ pt: 3 }}> {/* Añadir padding superior */}
          {children}
        </Box>
      )}
    </div>
  );
}


function ModerationPage() {
  const [tabIndex, setTabIndex] = useState(0);
  const handleTabChange = (event, newValue) => setTabIndex(newValue);

  return (
    <Box sx={{ p: 3 }}> {/* Añadir padding general a la página */}
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Panel de Moderación
      </Typography>
      
      {/* Guía de Moderación Mejorada */}
      <Accordion sx={{ mb: 3, bgcolor: 'background.default' }} variant="outlined">
        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
          <HelpIcon color="action" sx={{ mr: 1.5 }} />
          <Typography sx={{ fontWeight: 500 }}>Guía de Procesos de Moderación</Typography>
        </AccordionSummary>
        <AccordionDetails>
          <Typography variant="h6">Pasos para Moderar Comentarios</Typography>
          <Typography variant="body2" paragraph>1. Lee el comentario y el motivo del reporte. 2. Verifica el contexto. 3. Decide si el comentario viola las normas. 4. Toma una acción: Desestimar o Eliminar.</Typography>
          <Typography variant="h6">Pasos para Moderar Usuarios</Typography>
          <Typography variant="body2" paragraph>1. Revisa el motivo del reporte. 2. Considera el historial del usuario. 3. Evalúa la gravedad de la falta. 4. Toma una acción: Desestimar o Suspender.</Typography>
        </AccordionDetails>
      </Accordion>

      {/* Pestañas con Iconos */}
      <Paper variant="outlined">
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabIndex} onChange={handleTabChange} variant="fullWidth">
            <Tab 
              label="Comentarios Reportados" 
              icon={<CommentIcon />} 
              iconPosition="start" 
            />
            <Tab 
              label="Usuarios Reportados" 
              icon={<PersonIcon />} 
              iconPosition="start" 
            />
            <Tab 
              label="Historial de Acciones" 
              icon={<HistoryIcon />} 
              iconPosition="start" 
            />
          </Tabs>
        </Box>
        
        {/* Paneles (ahora se renderizan dentro del Paper) */}
        <Box sx={{ p: 2 }}> {/* Padding interno para los paneles */}
          <TabPanel value={tabIndex} index={0}>
            <PanelComentariosReportados />
          </TabPanel>
          <TabPanel value={tabIndex} index={1}>
            <PanelUsuariosReportados />
          </TabPanel>
          <TabPanel value={tabIndex} index={2}>
            <PanelHistorialModeracion />
          </TabPanel>
        </Box>
      </Paper>
    </Box>
  );
}

export default ModerationPage;