// src/pages/PaginaAnalisis.jsx
import React, { useState, useRef } from 'react';
import { Box, Typography, CircularProgress, Modal, Divider, Alert } from '@mui/material';
import { useAuth } from '../context/AuthContext';

// --- Lógica ---
import { useAnalisisData } from '../components/Analisis/hooks/useAnalisisData';
import { getInitialFilterState, createInitialSelection, getChartContext } from '../components/Analisis/utils/contextHelpers';
import { handleDownloadPDF } from '../components/Analisis/utils/downloaderPDF';
import { handleDownloadExcel } from '../components/Analisis/utils/downloaderExcel';

// --- Layout ---
import SeccionMetricas from '../components/Analisis/layout/SeccionMetricas';
import SeccionReportes from '../components/Analisis/layout/SeccionReportes';
import SeccionUsuarios from '../components/Analisis/layout/SeccionUsuarios';

// --- Componentes ---
import FiltrosFechaAnalisis from '../components/Analisis/FiltrosFechaAnalisis';
import ModalSeleccionPDF from '../components/Analisis/ModalSeleccionPDF';
// --- NUEVO ---
import ModalSeleccionExcel from '../components/Analisis/ModalSeleccionExcel';

/**
 * PaginaAnalisis - Página principal de análisis y reportes del sistema
 * @returns {JSX.Element}
 */
function PaginaAnalisis() {
  const { isAuthenticated, user } = useAuth();
  
  // --- Estado de Filtros y Modales ---
  const [filterState, setFilterState] = useState(getInitialFilterState());
  const [modalPdfOpen, setModalPdfOpen] = useState(false);
  const [modalExcelOpen, setModalExcelOpen] = useState(false); // <-- NUEVO
  const [isGenerating, setIsGenerating] = useState(false);

  // --- Refs y Configuración de Secciones ---
  const refs = {
      avgTimeCard: useRef(),
      reportTrend: useRef(),
      byCategory: useRef(),
      byStatus: useRef(),
      byDistrict: useRef(),
      leaderPerformance: useRef(),
      usersByStatus: useRef(),
      verificationTrend: useRef(),
      approvalRate: useRef(),
  };

  /**
   * Configuración de secciones para los modales de exportación
   * Define los títulos y referencias de cada sección del dashboard
   * @type {Object}
   */
  const sectionsConfig = {
      'avgTimeCard': { title: "Tiempo Promedio (KPI)", ref: refs.avgTimeCard }, // Título corto para modal
      'reportTrend': { title: "Tendencia de Reportes", ref: refs.reportTrend },
      'verificationTrend': { title: "Tendencia Tiempo Verificación", ref: refs.verificationTrend },
      'byCategory': { title: "Reportes por Categoría", ref: refs.byCategory },
      'byStatus': { title: "Distribución por Estado", ref: refs.byStatus },
      'approvalRate': { title: "Tasa Aprobación vs. Rechazo", ref: refs.approvalRate },
      'byDistrict': { title: "Reportes por Distrito", ref: refs.byDistrict },
      'leaderPerformance': { title: "Rendimiento de Líderes", ref: refs.leaderPerformance },
      'usersByStatus': { title: "Distribución de Usuarios", ref: refs.usersByStatus },
  };

  // Estado para la selección del modal
  const [selectedPdfCharts, setSelectedPdfCharts] = useState(createInitialSelection(sectionsConfig));
  const [selectedExcelCharts, setSelectedExcelCharts] = useState(createInitialSelection(sectionsConfig)); // <-- NUEVO

  // --- Hook de Fetching de Datos ---
  const { analyticsData, loading, error } = useAnalisisData(filterState, isAuthenticated);

  // --- Handlers de Descarga ---
  
  /**
   * Maneja la confirmación de descarga PDF
   * Actualiza títulos dinámicos y ejecuta la descarga
   */
  const onConfirmDownloadPDF = () => {
    // Actualizar títulos dinámicos antes de pasar
    const dynamicConfig = { ...sectionsConfig };
    dynamicConfig.reportTrend.title = getChartContext('reportTrend', analyticsData.reportTrend, filterState.filterName).title;
    dynamicConfig.verificationTrend.title = getChartContext('verificationTrend', analyticsData.verificationTrend, filterState.filterName).title;
    // ... (puedes actualizar otros títulos si es necesario) ...

    handleDownloadPDF({
        filterState,
        user,
        selectedCharts: selectedPdfCharts, // Usa el estado de PDF
        sectionsConfig: dynamicConfig,
        setIsGenerating
    });
    setModalPdfOpen(false); // Cierra el modal
  };

  /**
   * Maneja la confirmación de descarga Excel
   * Ejecuta la exportación de datos a formato Excel
   */
  const onConfirmDownloadExcel = () => {
    handleDownloadExcel({
        analyticsData,
        filterState,
        user,
        selectedCharts: selectedExcelCharts, // Usa el estado de Excel
        setIsGenerating,
        getChartContext
    });
    setModalExcelOpen(false); // Cierra el modal
  };

  // --- Handlers de Modales ---
  const handleOpenPdfModal = () => setModalPdfOpen(true);
  const handleClosePdfModal = () => setModalPdfOpen(false);
  const handlePdfSelectionChange = (newSelection) => setSelectedPdfCharts(newSelection);

  const handleOpenExcelModal = () => setModalExcelOpen(true); // <-- NUEVO
  const handleCloseExcelModal = () => setModalExcelOpen(false); // <-- NUEVO
  const handleExcelSelectionChange = (newSelection) => setSelectedExcelCharts(newSelection); // <-- NUEVO
  
  // --- Props comunes para layouts ---
  const layoutProps = {
      refs,
      analyticsData,
      loading,
      getChartContext,
      filterState
  };

  return (
    <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
        {/* Modal de carga global */}
        <Modal open={isGenerating || (loading && !analyticsData)}>
            <Box sx={{ 
                display: 'flex', 
                flexDirection: 'column', 
                justifyContent: 'center', 
                alignItems: 'center', 
                height: '100%', 
                color: 'white', 
                bgcolor: 'rgba(0, 0, 0, 0.7)'
            }}>
                <CircularProgress color="inherit" />
                <Typography sx={{ mt: 2 }}>
                    {isGenerating ? "Generando archivo..." : "Cargando datos..."}
                </Typography>
            </Box>
        </Modal>

        {/* Header de la página */}
        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>Análisis Avanzado</Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
           Explora tendencias y métricas detalladas de la plataforma.
        </Typography>
        
        {/* --- MODIFICADO: Pasados los nuevos handlers --- */}
        <FiltrosFechaAnalisis
            activeFilterName={filterState.filterName}
            onFilterChange={setFilterState}
            onOpenPdfModal={handleOpenPdfModal}
            onOpenExcelModal={handleOpenExcelModal} // <-- NUEVO
            loading={loading}
        />

        {/* Indicador de filtro activo */}
        {!loading && filterState.filterName && (
            <Alert severity="info" sx={{ mb: 3 }}>
                Mostrando datos para: <strong>{filterState.filterName}</strong>
            </Alert>
        )}

        {/* Contenido Principal */}
        {loading && !analyticsData ? (
             <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
                 <CircularProgress size={60}/>
             </Box>) 
            : error ? ( <Alert severity="error">{error}</Alert> )
            : !analyticsData ? ( <Alert severity="warning">No hay datos disponibles.</Alert> )
            : (
            <Box>
                {/* --- MODIFICADO: Se pasa 'contentMinHeight="auto"' --- */}
                <SeccionMetricas {...layoutProps} contentMinHeight="auto" />
                <Divider sx={{ mb: 4 }} />
                <SeccionReportes {...layoutProps} />
                <Divider sx={{ my: 4 }} />
                <SeccionUsuarios {...layoutProps} />
            </Box>
        )}

        {/* Modal para selección de PDF */}
         <ModalSeleccionPDF
             open={modalPdfOpen}
             onClose={handleClosePdfModal}
             selectedCharts={selectedPdfCharts}
             onChartSelectionChange={handlePdfSelectionChange}
             onConfirmDownload={onConfirmDownloadPDF}
             sectionsConfig={sectionsConfig}
         />
         
         {/* --- NUEVO: Modal para selección de Excel --- */}
         <ModalSeleccionExcel
             open={modalExcelOpen}
             onClose={handleCloseExcelModal}
             selectedCharts={selectedExcelCharts}
             onChartSelectionChange={handleExcelSelectionChange}
             onConfirmDownload={onConfirmDownloadExcel}
             sectionsConfig={sectionsConfig}
         />
    </Box>
  );
}

export default PaginaAnalisis;