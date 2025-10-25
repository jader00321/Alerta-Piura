// src/components/Analisis/utils/contextHelpers.js
import { startOfMonth, endOfMonth } from 'date-fns';

/**
 * Obtiene el estado de filtro por defecto (Este Mes).
 */
export const getInitialFilterState = () => {
    const now = new Date();
    return {
        startDate: startOfMonth(now),
        endDate: endOfMonth(now),
        filterName: 'Este Mes'
    };
};

/**
 * Genera el estado inicial de los checkboxes del modal.
 * @param {object} sectionsConfig - El objeto de configuración de secciones.
 * @returns {object} Un objeto con todas las claves en 'true'.
 */
export const createInitialSelection = (sectionsConfig) => {
    const initialState = {};
    for (const key in sectionsConfig) {
      initialState[key] = true;
    }
    return initialState;
};

/**
 * Genera el título y descripción dinámicos para un gráfico.
 * @param {string} chartKey - La clave del gráfico (ej. 'reportTrend').
 * @param {object} data - El objeto de datos del gráfico (puede contener 'groupingType').
 * @param {string} filterName - El nombre del filtro activo (ej. 'Hoy').
 * @returns {{title: string, desc: string}}
 */
export const getChartContext = (chartKey, data, filterName) => {
    // Definiciones base
    const titles = {
        avgTimeCard: "Tiempo Promedio de Verificación",
        reportTrend: "Tendencia de Reportes",
        verificationTrend: "Tendencia Tiempo Verificación (Horas)",
        byCategory: "Reportes por Categoría",
        byStatus: "Distribución por Estado",
        approvalRate: "Tasa Aprobación vs. Rechazo",
        byDistrict: "Reportes por Distrito",
        leaderPerformance: "Rendimiento de Líderes",
        usersByStatus: "Distribución de Usuarios"
    };
    const descs = {
        avgTimeCard: "Promedio desde creación hasta moderación.",
        reportTrend: "Volumen histórico de reportes creados.",
        verificationTrend: "Promedio de horas para moderar un reporte.",
        byCategory: "Categorías más comunes.",
        byStatus: "Proporción de reportes por estado.",
        approvalRate: "Basado en reportes moderados.",
        byDistrict: "Distribución geográfica.",
        leaderPerformance: "Top líderes por reportes moderados.",
        usersByStatus: "Proporción por estado actual."
    };

    let title = titles[chartKey] || "Gráfico";
    let desc = descs[chartKey] || "Datos de analítica.";

    // Lógica adaptativa para gráficos de tendencia
    if (chartKey === 'reportTrend' || chartKey === 'verificationTrend') {
        const groupingType = data?.groupingType || 'month';
        
        if (groupingType === 'hour') {
            title += " por Hora";
            desc = `Volumen de datos agrupado por hora para: ${filterName}.`;
        } else if (groupingType === 'day') {
            title += " por Día";
            desc = `Volumen de datos agrupado por día para: ${filterName}.`;
        } else { // month
            title += " por Mes";
            desc = `Volumen de datos agrupado por mes.`;
        }
    } else if (chartKey !== 'usersByStatus' && chartKey !== 'avgTimeCard') {
        // Añadir contexto de filtro a todos los demás gráficos
        desc += ` (Filtro: ${filterName})`;
    } else if (chartKey === 'avgTimeCard') {
         desc += ` (Filtro: ${filterName})`;
    }

    return { title, desc };
};