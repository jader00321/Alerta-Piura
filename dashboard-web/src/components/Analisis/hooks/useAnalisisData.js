// src/components/Analisis/hooks/useAnalisisData.js
import { useState, useCallback, useEffect } from 'react';
import adminService from '../../../services/adminService'; // Ajusta la ruta a tu adminService

/**
 * Hook personalizado para gestionar el fetching de datos de analítica.
 * @param {object} filterState - El estado del filtro actual { startDate, endDate, filterName }.
 * @param {boolean} isAuthenticated - Si el usuario está autenticado.
 * @returns {{analyticsData: object, loading: boolean, error: string, fetchData: function}}
 */
export const useAnalisisData = (filterState, isAuthenticated) => {
    const [analyticsData, setAnalyticsData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    const fetchData = useCallback(async () => {
        if (!isAuthenticated) {
            setLoading(false);
            return;
        }
        setLoading(true);
        setError('');

        const formattedRange = filterState.startDate && filterState.endDate ? {
            startDate: filterState.startDate.toISOString().split('T')[0],
            endDate: filterState.endDate.toISOString().split('T')[0],
        } : {};

        try {
            const [
                byCategory, byStatus, leaderPerf, byDistrict,
                usersByStatus, reportTrend, avgTime, verificationTrend
            ] = await Promise.all([
                adminService.getReportsByCategory(formattedRange),
                adminService.getReportsGroupedByStatus(formattedRange),
                adminService.getLeaderPerformance(formattedRange),
                adminService.getReportsByDistrict(formattedRange),
                adminService.getUsersByStatus(),
                adminService.getReportTrend(formattedRange),
                adminService.getAverageVerificationTime(formattedRange),
                adminService.getVerificationTimeTrend(formattedRange)
            ]);

            setAnalyticsData({
                byCategory: byCategory || [],
                byStatus: (byStatus || []).map(d => ({ ...d, value: parseInt(d.value, 10) })),
                leaderPerf: leaderPerf || [],
                byDistrict: byDistrict || [],
                usersByStatus: (usersByStatus || []).map(d => ({ ...d, value: parseInt(d.value, 10) })),
                reportTrend: reportTrend || { data: [], groupingType: 'month' },
                avgTime: avgTime?.avg_time_formatted,
                verificationTrend: verificationTrend || { data: [], groupingType: 'month' }
            });

        } catch (err) {
            console.error("Hubo un error al cargar los datos de análisis:", err);
            setError("No se pudieron cargar los datos de análisis.");
            setAnalyticsData(null);
        } finally {
            setLoading(false);
        }
    }, [isAuthenticated, filterState]);

    useEffect(() => {
        fetchData();
    }, [fetchData]); // Se dispara solo cuando 'fetchData' (y sus dependencias) cambian.

    return { analyticsData, loading, error, fetchData };
};