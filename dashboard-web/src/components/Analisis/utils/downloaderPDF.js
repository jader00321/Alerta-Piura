// src/components/Analisis/utils/downloaderPDF.js
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

/**
 * Genera y descarga un PDF con los gráficos seleccionados.
 * @param {object} options
 * @param {object} options.filterState - Estado del filtro { filterName, startDate, endDate }.
 * @param {object} options.user - Objeto del usuario autenticado { alias, ... }.
 * @param {object} options.selectedCharts - Objeto con las claves de los gráficos a imprimir.
 * @param {object} options.sectionsConfig - Configuración de secciones { key: { title, ref } }.
 * @param {function} options.setIsGenerating - Setter para mostrar el modal de carga.
 */
export const handleDownloadPDF = async ({
    filterState,
    user,
    selectedCharts,
    sectionsConfig,
    setIsGenerating
}) => {
    setIsGenerating(true);
    await new Promise(resolve => setTimeout(resolve, 100)); // Delay para que el modal se muestre

    const pdf = new jsPDF('p', 'mm', 'a4');
    const pageHeight = pdf.internal.pageSize.getHeight();
    const pageWidth = pdf.internal.pageSize.getWidth();
    const margin = 14;

    // --- Encabezado del PDF ---
    const adminAlias = user?.alias || "Usuario Admin";
    const fechaCreacionStr = `Generado el: ${new Date().toLocaleString('es-PE')}`;
    
    const formatDate = (date) => date ? new Date(date).toLocaleDateString('es-PE') : null;
    const startDateStr = formatDate(filterState.startDate);
    const endDateStr = formatDate(filterState.endDate);
    const periodoStr = startDateStr && endDateStr 
       ? `Periodo: ${startDateStr} - ${endDateStr}`
       : `Periodo: ${filterState.filterName}`; // Usa el nombre si no hay fechas

    pdf.setFontSize(16);
    pdf.text("Reporte de Analítica - Alerta Piura", margin, 20);
    
    pdf.setFontSize(10);
    pdf.text(periodoStr, margin, 28);
    pdf.text(`Generado por: ${adminAlias}`, margin, 34);
    pdf.text(fechaCreacionStr, pageWidth - margin, 28, { align: 'right' });
    
    let currentPage = 0; 
    const startY = 42;
    // --- Fin del Encabezado ---

    const addSectionToPdf = async (key, title, elementRef) => {
        const element = elementRef.current;
        if (!element) {
          console.warn(`Elemento no encontrado para ref: ${key}`);
          return;
        }
        try {
            if (currentPage > 0) {
                pdf.addPage();
                pdf.setFontSize(12);
                pdf.text(title, margin, 20);
            } else {
                 pdf.setFontSize(12);
                 pdf.text(title, margin, startY);
            }
            currentPage++;

            const canvas = await html2canvas(element, { useCORS: true, scale: 2, backgroundColor: '#ffffff' });
            const imgData = canvas.toDataURL('image/png', 0.95);
            
            const imgProps = pdf.getImageProperties(imgData);
            const pdfImgWidth = pageWidth - (margin * 2);
            const pdfImgHeight = (imgProps.height * pdfImgWidth) / imgProps.width;

            const yPos = (currentPage === 1) ? startY + 4 : 28;
            const availableHeight = pageHeight - yPos - 20;
            
            let finalImgHeight = pdfImgHeight;
            if (pdfImgHeight > availableHeight) {
                finalImgHeight = availableHeight;
            }

            pdf.addImage(imgData, 'PNG', margin, yPos, pdfImgWidth, finalImgHeight);

        } catch (error) {
            console.error(`Error al añadir sección ${title} al PDF:`, error);
        }
    };

    // Iterar sobre la configuración
    for (const [key, config] of Object.entries(sectionsConfig)) {
       if (selectedCharts[key]) {
            // Usar el título dinámico de la configuración
            await addSectionToPdf(key, config.title, config.ref);
            await new Promise(resolve => setTimeout(resolve, 50));
       }
    }

    pdf.save(`Reporte_Analitica_${filterState.filterName.replace(/[\s\W]+/g, '_')}.pdf`);
    setIsGenerating(false);
};