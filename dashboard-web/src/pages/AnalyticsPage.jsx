import React, { useEffect, useState, useRef } from 'react';
import { Box, Paper, Typography, CircularProgress, Grid, Button, ButtonGroup, Dialog, DialogTitle, DialogContent, DialogActions, FormGroup, FormControlLabel, Checkbox, TableContainer, Table, TableHead, TableRow, TableCell, TableBody, Divider, Modal } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line } from 'recharts';
import { CSVLink } from 'react-csv';
import adminService from '../services/adminService';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';
import DatePicker from 'react-datepicker';
import "react-datepicker/dist/react-datepicker.css";
import { startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#AF19FF'];

// --- Componentes (sin cambios) ---
const AnalyticsSection = ({ title, description, children, csvData, csvHeaders, elementRef }) => (
  <Paper ref={elementRef} sx={{ p: 3, mb: 4, borderRadius: '12px', height: '100%' }} elevation={3}>
    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
      <Box>
        <Typography variant="h6" gutterBottom>{title}</Typography>
        <Typography variant="body2" color="text.secondary">{description}</Typography>
      </Box>
      {csvData && csvData.length > 0 && (
        <Button variant="outlined" size="small">
          <CSVLink data={csvData} headers={csvHeaders} filename={`${title.replace(/\s+/g, '_')}.csv`} style={{ textDecoration: 'none', color: 'inherit' }}>
            Exportar a CSV
          </CSVLink>
        </Button>
      )}
    </Box>
    {children}
  </Paper>
);

const StatMetricCard = ({ title, value, description }) => (
    <Paper sx={{ p: 3, borderRadius: '12px', height: '100%' }} elevation={3}>
        <Typography color="text.secondary">{title}</Typography>
        <Typography variant="h4" color="primary" sx={{ fontWeight: 'bold', my: 1 }}>{value}</Typography>
        <Typography variant="body2" color="text.secondary">{description}</Typography>
    </Paper>
);

// --- Componente Principal ---
function AnalyticsPage() {
  const [loading, setLoading] = useState(true); // Para la carga inicial de datos
  // SOLUCIÓN: Nuevo estado para controlar el overlay de carga del PDF
  const [isGeneratingPdf, setIsGeneratingPdf] = useState(false);
  const [analyticsData, setAnalyticsData] = useState(null);
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedCharts, setSelectedCharts] = useState({
    byCategory: true, byStatus: true, leaderPerformance: true, byDistrict: true, byHour: true, usersByStatus: true, avgTimeCard: true, byMonth: true
  });

  const [dateRange, setDateRange] = useState({
    startDate: startOfMonth(new Date()),
    endDate: endOfMonth(new Date()),
  });

  const refs = {
    byCategory: useRef(), byStatus: useRef(), leaderPerformance: useRef(), byDistrict: useRef(), byHour: useRef(), usersByStatus: useRef(), byMonth: useRef(),
    avgTimeCard: useRef()
  };

  useEffect(() => {
    setLoading(true);
    const formattedRange = dateRange.startDate && dateRange.endDate ? {
        startDate: dateRange.startDate.toISOString(),
        endDate: dateRange.endDate.toISOString(),
    } : {};

    Promise.all([
      adminService.getReportsByCategory(formattedRange),
      adminService.getReportsByStatus(formattedRange),
      adminService.getLeaderPerformance(formattedRange),
      adminService.getReportsByDistrict(formattedRange),
      adminService.getReportsByHour(formattedRange),
      adminService.getUsersByStatus(),
      adminService.getReportsByMonth(),
      adminService.getAverageVerificationTime(formattedRange),
    ]).then(([byCategory, byStatus, leaderPerf, byDistrict, byHour, usersByStatus, byMonth, avgTime]) => {
      setAnalyticsData({
        byCategory,
        byStatus: byStatus.map(d => ({ ...d, value: parseInt(d.value, 10) })),
        leaderPerf,
        byDistrict,
        usersByStatus: usersByStatus.map(d => ({ ...d, value: parseInt(d.value, 10) })),
        byMonth,
        byHour,
        avgTime: avgTime.avg_time_formatted,
      });
    }).catch(error => {
        console.error("Hubo un error al cargar los datos de análisis:", error);
    }).finally(() => {
        setLoading(false);
    });
  }, [dateRange.startDate, dateRange.endDate]);

  // SOLUCIÓN: Lógica de PDF completamente reestructurada
  const handleDownloadPDF = async () => {
    setModalOpen(false);
    setIsGeneratingPdf(true); // Activa el overlay

    const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

    const pdf = new jsPDF('p', 'mm', 'a4');
    pdf.text("Reporte de Analítica - Alerta Piura", 14, 20);
    let yPos = 30;

    const addImageToPdf = async (element, title) => {
      if (!element) return;
      try {
        const canvas = await html2canvas(element, { useCORS: true, scale: 2, backgroundColor: '#121212' });
        const imgData = canvas.toDataURL('image/png', 0.95);
        const imgProps = pdf.getImageProperties(imgData);
        const pdfWidth = pdf.internal.pageSize.getWidth() - 28;
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

        if (yPos + pdfHeight > 290) {
          pdf.addPage();
          yPos = 20;
        }
        pdf.text(title, 14, yPos);
        yPos += 10;
        pdf.addImage(imgData, 'PNG', 14, yPos, pdfWidth, pdfHeight);
        yPos += pdfHeight + 10;
      } catch (error) {
        console.error(`Error al renderizar el elemento: ${title}`, error);
      }
    };

    const chartsToPrint = [];
    if (selectedCharts.avgTimeCard) chartsToPrint.push({ ref: refs.avgTimeCard, title: "Tiempo Promedio de Verificación" });
    if (selectedCharts.byMonth) chartsToPrint.push({ ref: refs.byMonth, title: "Tendencia de Reportes en el Tiempo" });
    if (selectedCharts.byCategory) chartsToPrint.push({ ref: refs.byCategory, title: "Reportes por Categoría" });
    if (selectedCharts.byStatus) chartsToPrint.push({ ref: refs.byStatus, title: "Distribución por Estado" });
    if (selectedCharts.byDistrict) chartsToPrint.push({ ref: refs.byDistrict, title: "Reportes por Distrito" });
    if (selectedCharts.byHour) chartsToPrint.push({ ref: refs.byHour, title: "Actividad por Hora / Día" });
    if (selectedCharts.leaderPerformance) chartsToPrint.push({ ref: refs.leaderPerformance, title: "Rendimiento de Líderes" });
    if (selectedCharts.usersByStatus) chartsToPrint.push({ ref: refs.usersByStatus, title: "Distribución de Usuarios" });

    for (const chart of chartsToPrint) {
      await addImageToPdf(chart.ref.current, chart.title);
      await delay(50);
    }

    pdf.save("reporte_analitica.pdf");
    setIsGeneratingPdf(false); // Desactiva el overlay
  };

  if (loading || !analyticsData) {
      return (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
              <CircularProgress />
          </Box>
      );
  }
  return (
    <Box>
      <Modal open={isGeneratingPdf}>
            <Box sx={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', height: '100%', color: 'white' }}>
                <CircularProgress color="inherit" />
                <Typography sx={{ mt: 2 }}>Generando PDF, por favor espere...</Typography>
            </Box>
        </Modal>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, flexWrap: 'wrap', gap: 2 }}>
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold', mb: 0 }}>Análisis Avanzado</Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
                <ButtonGroup variant="outlined">
                    {/* FIX 3: Se añade el botón "Mostrar Todos" */}
                    <Button onClick={() => setDateRange({ startDate: null, endDate: null })}>Todos</Button>
                    <Button onClick={() => setDateRange({ startDate: startOfDay(new Date()), endDate: endOfDay(new Date()) })}>Hoy</Button>
                    <Button onClick={() => setDateRange({ startDate: startOfWeek(new Date()), endDate: endOfWeek(new Date()) })}>Semana</Button>
                    <Button onClick={() => setDateRange({ startDate: startOfMonth(new Date()), endDate: endOfMonth(new Date()) })}>Mes</Button>
                </ButtonGroup>
                <DatePicker
                    selected={dateRange.startDate}
                    onChange={(date) => setDateRange({ startDate: startOfMonth(date), endDate: endOfMonth(date) })}
                    dateFormat="MM/yyyy"
                    showMonthYearPicker
                    customInput={<Button variant="outlined">Seleccionar Mes</Button>}
                />
                <Button variant="contained" onClick={() => setModalOpen(true)}>Descargar PDF</Button>
            </Box>
        </Box>
        <Typography variant="h5" sx={{ mb: 2 }}>Métricas de Rendimiento</Typography>
        <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid item xs={12} md={4}>
                {/* La ref se mueve al componente Paper para una captura más precisa */}
                <Box ref={refs.avgTimeCard}>
                    <StatMetricCard 
                        title="Tiempo Promedio de Verificación"
                        value={analyticsData.avgTime || 'N/A'}
                        description="Tiempo promedio desde que un reporte es creado hasta que un líder lo modera."
                    />
                </Box>
            </Grid>
        </Grid>
        <Divider sx={{ mb: 4 }} />

      <Typography variant="h5" sx={{ mb: 2 }}>Análisis de Reportes</Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <AnalyticsSection 
            elementRef={refs.byCategory}
            title="Reportes por Categoría" 
            description="Visualiza las categorías de incidentes más comunes."
            csvData={analyticsData.byCategory}
            csvHeaders={[{ label: 'Categoria', key: 'name' }, { label: 'Total', key: 'value' }]}
          >
            <Box sx={{ height: 350 }}>
              <ResponsiveContainer width="100%" height="100%" minWidth={750} minHeight={300} >
                <BarChart data={analyticsData.byCategory}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Bar dataKey="value" fill="#8884d8" name="Total Reportes" />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </AnalyticsSection>
        </Grid>
        
        <Grid item xs={12} md={4}>
                <AnalyticsSection elementRef={refs.byStatus} title="Distribución de Reportes por Estado" description="Proporción de reportes según su estado actual.">
                    <Box sx={{ height: 350 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie data={analyticsData.byStatus} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label>
                                    {analyticsData.byStatus.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                                </Pie>
                                <Tooltip />
                                <Legend />
                            </PieChart>
                        </ResponsiveContainer>
                    </Box>
                </AnalyticsSection>
            </Grid>
        <Grid item xs={12} md={7}>
          <AnalyticsSection 
            elementRef={refs.byDistrict}
            title="Reportes por Distrito" 
            description="Cantidad de reportes generados en cada distrito."
            csvData={analyticsData.byDistrict}
            csvHeaders={[{ label: 'Distrito', key: 'name' }, { label: 'Total', key: 'value' }]}
          >
            <Box sx={{height: 350, width: 800}}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analyticsData.byDistrict} layout="horizontal" barSize={50}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <YAxis type="number" />
                  <XAxis dataKey="name" type="category" />
                  <Tooltip />
                  <Bar dataKey="value" fill="#00C49F" name="Reportes" />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </AnalyticsSection>
        </Grid>

        <Grid item xs={12} md={5}>
          <AnalyticsSection 
            elementRef={refs.byHour}
            title="Actividad por Hora del Día" 
            description="Horas del día en que se crean más reportes.">
            <Box sx={{ height: 350,width:500 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={analyticsData.byHour}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis allowDecimals={false}/>
                  <Tooltip />
                  <Line type="monotone" dataKey="value" stroke="#FF8042" name="Reportes" />
                </LineChart>
              </ResponsiveContainer>
            </Box>
          </AnalyticsSection>
        </Grid>
        <Grid item xs={12}>
                <AnalyticsSection elementRef={refs.byMonth} title="Tendencia de Reportes en el Tiempo" description="Volumen total de reportes creados cada mes.">
                    <Box sx={{ height: 300 }}>
                        <ResponsiveContainer width="100%" height="100%">
                            <LineChart data={analyticsData.byMonth}>
                                <CartesianGrid strokeDasharray="3 3" />
                                <XAxis dataKey="name" />
                                <YAxis allowDecimals={false} />
                                <Tooltip />
                                <Legend />
                                <Line type="monotone" dataKey="value" stroke="#8884d8" name="Reportes" />
                            </LineChart>
                        </ResponsiveContainer>
                    </Box>
                </AnalyticsSection>
            </Grid>
            </Grid>

        <Divider sx={{ my: 4 }} />

        <Typography variant="h5" sx={{ mb: 2 }}>Análisis de Usuarios y Líderes</Typography>
        <Grid container spacing={3}>
        <Grid item xs={12} lg={8}>
                 <AnalyticsSection elementRef={refs.leaderPerformance} title="Rendimiento de Líderes" description="Top líderes por reportes moderados.">
                     <TableContainer>
                        <Table>
                            <TableHead><TableRow><TableCell>Líder Vecinal (Alias)</TableCell><TableCell align="right">Reportes Moderados</TableCell></TableRow></TableHead>
                            <TableBody>
                                {analyticsData.leaderPerf.map((leader) => (
                                    <TableRow key={leader.name}><TableCell>{leader.name}</TableCell><TableCell align="right">{leader.value}</TableCell></TableRow>
                                ))}
                            </TableBody>
                        </Table>
                     </TableContainer>
                 </AnalyticsSection>
             </Grid>
             <Grid item xs={12} lg={4}>
                <AnalyticsSection elementRef={refs.usersByStatus} title="Distribución de Usuarios" description="Proporción de usuarios según su estado actual.">
                     <Box sx={{ height: 350 }}>
                         <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie data={analyticsData.usersByStatus} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={60} outerRadius={100} label>
                                     {analyticsData.usersByStatus?.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                                </Pie>
                                <Tooltip />
                                <Legend />
                            </PieChart>
                         </ResponsiveContainer>
                     </Box>
                 </AnalyticsSection>
             </Grid>
        </Grid>

        {/* FIX 2: Se añaden las opciones que faltaban en el diálogo */}
        <Dialog open={modalOpen} onClose={() => setModalOpen(false)}>
            <DialogTitle>Seleccionar Contenido para el Informe</DialogTitle>
            <DialogContent>
                <FormGroup>
                    <FormControlLabel control={<Checkbox checked={selectedCharts.avgTimeCard} onChange={(e) => setSelectedCharts(p => ({...p, avgTimeCard: e.target.checked}))} />} label="Tarjeta de Tiempo Promedio" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.byMonth} onChange={(e) => setSelectedCharts(p => ({...p, byMonth: e.target.checked}))} />} label="Gráfico de Tendencia por Mes" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.byCategory} onChange={(e) => setSelectedCharts(p => ({...p, byCategory: e.target.checked}))} />} label="Gráfico de Reportes por Categoría" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.byStatus} onChange={(e) => setSelectedCharts(p => ({...p, byStatus: e.target.checked}))} />} label="Gráfico de Distribución por Estado" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.byDistrict} onChange={(e) => setSelectedCharts(p => ({...p, byDistrict: e.target.checked}))} />} label="Gráfico de Reportes por Distrito" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.byHour} onChange={(e) => setSelectedCharts(p => ({...p, byHour: e.target.checked}))} />} label="Gráfico de Actividad por Hora/Día" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.leaderPerformance} onChange={(e) => setSelectedCharts(p => ({...p, leaderPerformance: e.target.checked}))} />} label="Tabla de Rendimiento de Líderes" />
                    <FormControlLabel control={<Checkbox checked={selectedCharts.usersByStatus} onChange={(e) => setSelectedCharts(p => ({...p, usersByStatus: e.target.checked}))} />} label="Gráfico de Distribución de Usuarios" />
                </FormGroup>
            </DialogContent>
            <DialogActions>
                <Button onClick={() => setModalOpen(false)}>Cancelar</Button>
                <Button onClick={handleDownloadPDF} variant="contained">Descargar</Button>
            </DialogActions>
        </Dialog>
    </Box>
  );
}

export default AnalyticsPage;