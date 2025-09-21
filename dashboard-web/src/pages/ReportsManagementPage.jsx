import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Button, IconButton, List, ListItem, ListItemText, Grid, TextField, Select, MenuItem, FormControl, InputLabel, Tooltip, Chip } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import ChatIcon from '@mui/icons-material/Chat';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal'; 

function ReportsManagementPage() {
  const [chatOpen, setChatOpen] = useState(false);
  const [selectedReportForChat, setSelectedReportForChat] = useState(null);
  const [reports, setReports] = useState([]);
  const [reviewRequests, setReviewRequests] = useState([]);
  const [categories, setCategories] = useState([]);
  
  const [filters, setFilters] = useState({ search: '', status: '', categoryId: '' });
  const debouncedSearch = useDebounce(filters.search, 500);

  const fetchReports = useCallback(() => {
    // Create a clean filters object to send only non-empty values
    const activeFilters = Object.entries(filters).reduce((acc, [key, value]) => {
      if (value) acc[key] = value;
      return acc;
    }, { search: debouncedSearch });
    
    adminService.getAllAdminReports(activeFilters).then(setReports).catch(console.error);
  }, [filters, debouncedSearch]);


  const fetchData = useCallback(() => {
    fetchReports();
    adminService.getReviewRequests().then(setReviewRequests).catch(console.error);
  }, [fetchReports]);

  // Effect to load initial, non-changing data
  useEffect(() => {
    adminService.getAllCategories().then(setCategories);
    fetchData();
  }, [fetchData]); // Depends on fetchData, which is memoized by useCallback

  // Effect to re-fetch the main report list ONLY when filters change
  useEffect(() => {
    fetchReports();
  }, [debouncedSearch, filters.status, filters.categoryId, fetchReports]);


  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const handleResolveReview = (id, action) => {
    adminService.resolveReviewRequest(id, action).then(fetchData);
  };
  
  const handleDeleteReport = (id) => {
    if (window.confirm('¿Estás seguro de que quieres eliminar este reporte permanentemente?')) {
      adminService.adminDeleteReport(id).then(fetchData);
    }
  };

  const handleVisibilityChange = (id, currentState) => {
    if (window.confirm('¿Estás seguro de que quieres cambiar la visibilidad de este reporte?')) {
      adminService.updateReportVisibility(id, currentState).then(fetchData);
    }
  };

  const handleOpenChat = (report) => {
    setSelectedReportForChat(report);
    setChatOpen(true);
  };
  
  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Gestión General de Reportes
      </Typography>

      {/* --- Review Requests Section --- */}
      <Typography variant="h6" gutterBottom>Solicitudes de Revisión Pendientes</Typography>
      <Paper sx={{ mb: 4, maxHeight: 220, overflow: 'auto' }}>
        <List>
          {reviewRequests.length > 0 ? reviewRequests.map(req => (
            <ListItem key={req.id} divider
              secondaryAction={
                <>
                  <Button size="small" onClick={() => handleResolveReview(req.id, 'desestimar')}>Desestimar</Button>
                  <Button size="small" variant="contained" color="primary" sx={{ ml: 1 }} onClick={() => handleResolveReview(req.id, 'aprobar')}>
                    Enviar a Pendientes
                  </Button>
                </>
              }
            >
              <ListItemText primary={req.titulo} secondary={`Reporte ID: ${req.id}`} />
            </ListItem>
          )) : <ListItem><ListItemText primary="No hay solicitudes de revisión pendientes." /></ListItem>}
        </List>
      </Paper>

      {/* --- Master Report Table --- */}
      <Typography variant="h6" gutterBottom>Todos los Reportes del Sistema</Typography>
      
      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} sm={6} md={5}> {/* Given more space */}
            <TextField fullWidth size="small" label="Buscar por título o autor" name="search" value={filters.search} onChange={handleFilterChange} />
          </Grid>
          <Grid item xs={6} sm={3} md={2.5}> {/* Adjusted space */}
            <FormControl fullWidth size="small">
              <InputLabel>Estado</InputLabel>
              <Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange}>
                <MenuItem value="">Todos</MenuItem>
                <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
                <MenuItem value="verificado">Verificado</MenuItem>
                <MenuItem value="rechazado">Rechazado</MenuItem>
                <MenuItem value="oculto">Oculto</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={6} sm={3} md={2.5}> {/* Adjusted space */}
            <FormControl fullWidth size="small">
              <InputLabel>Categoría</InputLabel>
              <Select name="categoryId" value={filters.categoryId} label="Categoría" onChange={handleFilterChange}>
                <MenuItem value="">Todas</MenuItem>
                {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
           <Grid item xs={12} sm={12} md={2}> {/* Adjusted space */}
            <Button fullWidth onClick={() => setFilters({ search: '', status: '', categoryId: '' })}>Limpiar Filtros</Button>
          </Grid>
        </Grid>
      </Paper>

      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label="simple table">
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Título</TableCell>
              {/* Hide Description on small screens */}
              <TableCell sx={{ display: { xs: 'none', md: 'table-cell' } }}>Descripción</TableCell> 
              <TableCell>Autor</TableCell>
              {/* Hide Email on small screens */}
              <TableCell sx={{ display: { xs: 'none', lg: 'table-cell' } }}>Email del Autor</TableCell>
              <TableCell>Categoría</TableCell>
              <TableCell>Estado</TableCell>
              <TableCell sx={{ minWidth: 120 }}>Fecha</TableCell> {/* Give more space to Date column */}
              <TableCell align="right">Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {reports.map((report) => (
              <TableRow key={report.id} hover>
                <TableCell>{report.id}</TableCell>
                <TableCell sx={{ fontWeight: 'bold' }}>{report.titulo}</TableCell>
                {/* Hide Description on small screens */}
                <TableCell sx={{ display: { xs: 'none', md: 'table-cell' } }}>
                  <Tooltip title={report.descripcion || ''} arrow>
                    <Typography noWrap sx={{ maxWidth: '150px', fontStyle: 'italic', color: 'text.secondary' }}>
                      {report.descripcion || 'N/A'}
                    </Typography>
                  </Tooltip>
                </TableCell>
                <TableCell>{report.autor_nombre || 'Usuario Eliminado'}</TableCell>
                {/* Hide Email on small screens */}
                <TableCell sx={{ display: { xs: 'none', lg: 'table-cell' } }}>{report.autor_email || 'N/A'}</TableCell>
                <TableCell>{report.categoria}</TableCell>
                <TableCell>
                   <Chip 
                     label={report.estado.replace('_', ' ')}
                     size="small"
                     color={
                       report.estado === 'verificado' ? 'success' :
                       report.estado === 'rechazado' ? 'error' :
                       report.estado === 'pendiente_verificacion' ? 'warning' :
                       'default'
                     }
                   />
                </TableCell>
                <TableCell>{report.fecha}</TableCell>
                <TableCell align="right">
                  <Tooltip title="Contactar Usuario">
                    <IconButton size="small" color="primary" onClick={() => handleOpenChat(report)}>
                      <ChatIcon />
                    </IconButton>
                  </Tooltip>
                  {(report.estado === 'verificado' || report.estado === 'oculto') && (
                    <Tooltip title={report.estado === 'verificado' ? 'Ocultar Reporte' : 'Hacer Público'}>
                      <IconButton size="small" onClick={() => handleVisibilityChange(report.id, report.estado)}>
                        {report.estado === 'verificado' ? <VisibilityOffIcon /> : <VisibilityIcon />}
                      </IconButton>
                    </Tooltip>
                  )}
                  <Tooltip title="Eliminar Reporte">
                    <IconButton size="small" color="error" onClick={() => handleDeleteReport(report.id)}>
                      <DeleteIcon />
                    </IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

       {selectedReportForChat && (
        <ChatModal 
          open={chatOpen}
          onClose={() => setChatOpen(false)}
          report={selectedReportForChat}
        />
      )}
    </Box>
  );
}

export default ReportsManagementPage;