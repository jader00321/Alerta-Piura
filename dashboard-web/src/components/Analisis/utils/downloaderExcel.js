// src/components/Analisis/utils/downloaderExcel.js
import Excel from 'exceljs';
import { saveAs } from 'file-saver';

/**
 * Genera y descarga un Excel con los datos de analítica SELECCIONADOS.
 * @param {object} options
 * @param {object} options.analyticsData - Objeto con todos los datos.
 * @param {object} options.filterState - Estado del filtro.
 * @param {object} options.user - Objeto del usuario.
 * @param {object} options.selectedCharts - Objeto con las claves de los gráficos SELECCIONADOS.
 * @param {function} options.setIsGenerating - Setter para modal de carga.
 * @param {function} options.getChartContext - Helper para títulos dinámicos.
 */
export const handleDownloadExcel = async ({
    analyticsData,
    filterState,
    user,
    selectedCharts, // <-- NUEVA PROP
    setIsGenerating,
    getChartContext
}) => {
    if (!analyticsData) {
        console.error("No hay datos para exportar.");
        return;
    }
    
    setIsGenerating(true);
    await new Promise(resolve => setTimeout(resolve, 100));

    try {
        const workbook = new Excel.Workbook();
        workbook.creator = user?.alias || 'Admin Alerta Piura';
        workbook.created = new Date();

        // --- Hoja de Resumen (siempre se incluye) ---
        const summarySheet = workbook.addWorksheet('Resumen');
        // ... (código del resumen de la hoja, sin cambios) ...
        summarySheet.mergeCells('A1:D1');
        summarySheet.getCell('A1').value = 'Reporte de Analítica - Alerta Piura';
        summarySheet.getCell('A1').font = { size: 16, bold: true };
        summarySheet.getCell('A3').value = "Filtro Aplicado";
        summarySheet.getCell('B3').value = filterState.filterName;
        summarySheet.getCell('A4').value = "Periodo";
        summarySheet.getCell('B4').value = filterState.startDate 
            ? `${filterState.startDate.toLocaleDateString('es-PE')} - ${filterState.endDate.toLocaleDateString('es-PE')}`
            : 'Todos los registros';
        summarySheet.getCell('A5').value = "Fecha de Creación";
        summarySheet.getCell('B5').value = new Date().toLocaleString('es-PE');
        summarySheet.getCell('A6').value = "Generado por";
        summarySheet.getCell('B6').value = user?.alias || 'Admin';
        ['A3', 'A4', 'A5', 'A6'].forEach(cell => { summarySheet.getCell(cell).font = { bold: true }; });
        summarySheet.columns = [{ width: 20 }, { width: 35 }];

        // --- Función Helper (sin cambios) ---
        const addChartDataToSheet = (sheetName, columns, data) => {
            if (!data || data.length === 0) return;
            const sheet = workbook.addWorksheet(sheetName.substring(0, 31));
            sheet.addTable({
                name: `Tabla_${sheetName.replace(/[\s\W]+/g, '_').substring(0, 20)}`,
                ref: 'A1',
                headerRow: true,
                style: { theme: 'TableStyleMedium9', showRowStripes: true },
                columns: columns.map(col => ({ name: col.header, filterButton: true })),
                rows: data.map(row => columns.map(col => row[col.key])),
            });
            sheet.columns = columns.map(col => ({
                header: col.header,
                key: col.key,
                width: col.width || Math.max(col.header.length, 20)
            }));
        };

        // --- MODIFICADO: Añadir Hojas de Datos (solo si están seleccionadas) ---
        
        if (selectedCharts['byCategory']) {
            const { title: catTitle } = getChartContext('byCategory', null, filterState.filterName);
            addChartDataToSheet(catTitle, 
                [{ header: 'Categoría', key: 'name' }, { header: 'Total', key: 'value', width: 15 }],
                analyticsData.byCategory
            );
        }
        
        if (selectedCharts['byStatus']) {
            const { title: statTitle } = getChartContext('byStatus', null, filterState.filterName);
            addChartDataToSheet(statTitle,
                [{ header: 'Estado', key: 'name' }, { header: 'Total', key: 'value', width: 15 }],
                analyticsData.byStatus
            );
        }

        if (selectedCharts['byDistrict']) {
            const { title: distTitle } = getChartContext('byDistrict', null, filterState.filterName);
            addChartDataToSheet(distTitle,
                [{ header: 'Distrito', key: 'name' }, { header: 'Total', key: 'value', width: 15 }],
                analyticsData.byDistrict
            );
        }

        if (selectedCharts['leaderPerformance']) {
            const { title: leadTitle } = getChartContext('leaderPerformance', null, filterState.filterName);
            addChartDataToSheet(leadTitle,
                [{ header: 'Líder (Alias)', key: 'name' }, { header: 'Reportes Moderados', key: 'value', width: 25 }],
                analyticsData.leaderPerf
            );
        }

        if (selectedCharts['usersByStatus']) {
            const { title: userTitle } = getChartContext('usersByStatus', null, filterState.filterName);
            addChartDataToSheet(userTitle,
                [{ header: 'Estado Usuario', key: 'name' }, { header: 'Total', key: 'value', width: 20 }],
                analyticsData.usersByStatus
            );
        }

        if (selectedCharts['reportTrend']) {
            const { title: trendTitle } = getChartContext('reportTrend', analyticsData.reportTrend, filterState.filterName);
            addChartDataToSheet(trendTitle,
                [{ header: 'Periodo', key: 'name', width: 25 }, { header: 'Total Reportes', key: 'value', width: 20 }],
                analyticsData.reportTrend.data
            );
        }
        
        if (selectedCharts['verificationTrend']) {
            const { title: verifTitle } = getChartContext('verificationTrend', analyticsData.verificationTrend, filterState.filterName);
            addChartDataToSheet(verifTitle,
                [{ header: 'Periodo', key: 'name', width: 25 }, { header: 'Promedio (Horas)', key: 'value', width: 20 }],
                analyticsData.verificationTrend.data
            );
        }
        
        // (Nota: 'avgTimeCard' y 'approvalRate' no se añaden como hojas separadas
        // porque sus datos ya están en 'verificationTrend' y 'byStatus' respectivamente)

        // --- Generar y Descargar Archivo ---
        const buffer = await workbook.xlsx.writeBuffer();
        const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        saveAs(blob, `Reporte_Analitica_${filterState.filterName.replace(/[\s\W]+/g, '_')}_${new Date().toISOString().split('T')[0]}.xlsx`);

    } catch (error) {
         console.error("Error al generar el archivo Excel:", error);
    } finally {
        setIsGenerating(false);
    }
};