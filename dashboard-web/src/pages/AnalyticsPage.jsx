import React, { useEffect, useState, useRef } from 'react';
import { Box, Paper, Typography, CircularProgress, Grid, Tabs, Tab, Button, Dialog, DialogTitle, DialogContent, DialogActions, FormGroup, FormControlLabel, Checkbox } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import adminService from '../services/adminService';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

// Componente para una sección de análisis con título y descripción
const AnalyticsSection = ({ title, description, children }) => (
  <Paper sx={{ p: 3, mb: 4, borderRadius: '12px' }} elevation={3}>
    <Typography variant="h6" gutterBottom>{title}</Typography>
    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>{description}</Typography>
    {children}
  </Paper>
);

function AnalyticsPage() {
  const [value, setValue] = useState(0);
  const [loading, setLoading] = useState(true);
  const [analyticsData, setAnalyticsData] = useState({});
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedCharts, setSelectedCharts] = useState({
    byCategory: true,
    byStatus: true,
    leaderPerformance: true,
  });

  // Refs para capturar los gráficos
  const byCategoryRef = useRef();
  const byStatusRef = useRef();
  const leaderPerformanceRef = useRef();

  useEffect(() => {
    Promise.all([
      adminService.getReportsByCategory(),
      adminService.getReportsByStatus(),
      adminService.getUsersByStatus(),
      adminService.getAverageResolutionTime(),
      adminService.getLeaderPerformance(),
    ]).then(([byCategory, byStatus, usersByStatus, avgTime, leaderPerf]) => {
      setAnalyticsData({ byCategory, byStatus, usersByStatus, avgTime, leaderPerf });
      setLoading(false);
    }).catch(console.error);
  }, []);

  const handleDownloadPDF = async () => {
    setModalOpen(false);
    const pdf = new jsPDF('p', 'mm', 'a4');
    pdf.text("Reporte de Analítica - Alerta Piura", 14, 20);
    let yPos = 30;

    const addImageToPdf = async (element, title) => {
      if (element) {
        const canvas = await html2canvas(element);
        const imgData = canvas.toDataURL('image/png');
        const imgProps = pdf.getImageProperties(imgData);
        const pdfWidth = pdf.internal.pageSize.getWidth() - 28;
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
        if (yPos + pdfHeight > 280) { // Check for page break
          pdf.addPage();
          yPos = 20;
        }
        pdf.text(title, 14, yPos);
        yPos += 10;
        pdf.addImage(imgData, 'PNG', 14, yPos, pdfWidth, pdfHeight);
        yPos += pdfHeight + 10;
      }
    };
    
    if (selectedCharts.byCategory) await addImageToPdf(byCategoryRef.current, "Reportes por Categoría");
    if (selectedCharts.byStatus) await addImageToPdf(byStatusRef.current, "Distribución de Reportes por Estado");
    if (selectedCharts.leaderPerformance) await addImageToPdf(leaderPerformanceRef.current, "Rendimiento de Líderes");

    pdf.save(`analitica-alerta-piura-${new Date().toISOString().split('T')[0]}.pdf`);
  };

  const handleTabChange = (event, newValue) => {
    setValue(newValue);
  };

  if (loading) return <CircularProgress />;

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Análisis Avanzado</Typography>
        <Button variant="contained" onClick={() => setModalOpen(true)}>Descargar Informe PDF</Button>
      </Box>

      <AnalyticsSection title="Reportes por Categoría" description="Visualiza las categorías de incidentes más comunes reportadas por los ciudadanos.">
        <Box ref={byCategoryRef} sx={{ height: 300 }}>
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={analyticsData.byCategory} layout="vertical" margin={{ left: 50 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" />
              <YAxis type="category" dataKey="name" width={150} />
              <Tooltip />
              <Bar dataKey="value" fill="#8884d8" name="Total" />
            </BarChart>
          </ResponsiveContainer>
        </Box>
      </AnalyticsSection>

      <Tabs value={value} onChange={handleTabChange} sx={{ mb: 3 }}>
        <Tab label="Visión General de Reportes" />
        <Tab label="Rendimiento y Moderación" />
      </Tabs>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <AnalyticsSection title="Rendimiento de Líderes" description="Top 10 de líderes vecinales por cantidad de reportes moderados (aprobados o rechazados).">
            <Box ref={leaderPerformanceRef} sx={{ height: 300 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analyticsData.leaderPerf}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="value" fill="#82ca9d" name="Reportes Moderados" />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </AnalyticsSection>
        </Grid>
        <Grid item xs={12} md={6}>
          <AnalyticsSection title="Distribución de Reportes por Estado" description="Proporción de reportes según su estado actual en el sistema.">
            <Box ref={byStatusRef} sx={{ height: 300 }}>
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
      </Grid>
      
      {/* Download Modal */}
      <Dialog open={modalOpen} onClose={() => setModalOpen(false)}>
        <DialogTitle>Seleccionar Contenido para el Informe</DialogTitle>
        <DialogContent>
          <FormGroup>
            <FormControlLabel control={<Checkbox checked={selectedCharts.byCategory} onChange={(e) => setSelectedCharts(prev => ({...prev, byCategory: e.target.checked}))} />} label="Gráfico de Reportes por Categoría" />
            <FormControlLabel control={<Checkbox checked={selectedCharts.byStatus} onChange={(e) => setSelectedCharts(prev => ({...prev, byStatus: e.target.checked}))} />} label="Gráfico de Distribución por Estado" />
            <FormControlLabel control={<Checkbox checked={selectedCharts.leaderPerformance} onChange={(e) => setSelectedCharts(prev => ({...prev, leaderPerformance: e.target.checked}))} />} label="Gráfico de Rendimiento de Líderes" />
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