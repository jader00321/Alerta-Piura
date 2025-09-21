import React, { useEffect, useState } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from '@mui/material';
import adminService from '../services/adminService';

function SmsLogPage() {
  const [logs, setLogs] = useState([]);

  useEffect(() => {
    adminService.getSmsLog().then(setLogs);
  }, []);

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Registro de SMS Simulados
      </Typography>
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Fecha de Envío</TableCell>
              <TableCell>Nº Contacto</TableCell>
              <TableCell>Mensaje Enviado</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {logs.map((log) => (
              <TableRow key={log.id}>
                <TableCell>{new Date(log.fecha_envio).toLocaleString()}</TableCell>
                <TableCell>{log.contacto_telefono}</TableCell>
                <TableCell>{log.mensaje}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}

export default SmsLogPage;