// src/components/Analisis/TablaRendimientoLideres.jsx
import React from 'react';
import {
    Box, Skeleton, Typography, Paper,
    TableContainer, Table, TableHead, TableRow, TableCell, TableBody,
    useTheme // --- NUEVO ---
} from '@mui/material';
import LeaderboardIcon from '@mui/icons-material/Leaderboard';

function TablaRendimientoLideres({ data, loading }) {
  // --- MODIFICADO: UI con useTheme ---
  const theme = useTheme();

   if (loading) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 300 }} elevation={3}>
              <Skeleton variant="text" width="60%" sx={{ mb: 2 }}/>
              <Skeleton variant="rectangular" width="100%" height={250} />
         </Paper>
     );
  }

   if (!data || data.length === 0) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', minHeight: 300 }} elevation={3}>
              <LeaderboardIcon color="action" sx={{ fontSize: 40, my: 2 }}/>
              <Typography color="text.secondary">No hay datos de rendimiento de líderes para mostrar.</Typography>
         </Paper>
     );
   }

  return (
      <TableContainer sx={{ height: '100%', minHeight: 300, maxHeight: 400 }}>
        <Table stickyHeader>
            <TableHead>
                <TableRow>
                    {/* --- UI Mejorada --- */}
                    <TableCell sx={{ 
                      fontWeight: 'bold', 
                      backgroundColor: theme.palette.background.default, // Fondo del header
                      color: theme.palette.text.primary 
                    }}>
                      Líder Vecinal (Alias)
                    </TableCell>
                    <TableCell 
                      align="right" 
                      sx={{ 
                        fontWeight: 'bold', 
                        backgroundColor: theme.palette.background.default,
                        color: theme.palette.text.primary 
                      }}
                    >
                      Reportes Moderados
                    </TableCell>
                </TableRow>
            </TableHead>
            <TableBody>
                {data.map((leader) => (
                    <TableRow key={leader.name} hover>
                        <TableCell>{leader.name}</TableCell>
                        <TableCell align="right" sx={{ fontWeight: 'bold', fontSize: '1rem' }}>
                            {leader.value}
                        </TableCell>
                    </TableRow>
                ))}
            </TableBody>
        </Table>
      </TableContainer>
  );
}

export default TablaRendimientoLideres;