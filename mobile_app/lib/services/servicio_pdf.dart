import 'dart:io';
import 'package:mobile_app/models/analiticas_dashboard_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ServicioPdf {
  /// Genera un informe PDF completo para prensa/reporteros.
  Future<File> generarInformeAnalitico(AnaliticasDashboardData data) async {
    final pdf = pw.Document();

    // Estilos base
    final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);
    final subHeaderStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800);
    final normalStyle = const pw.TextStyle(fontSize: 10);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- TÍTULO ---
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('Reporte Piura - Informe Analítico', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(color: PdfColors.grey600)),
              ],
            ),
          ),
          pw.Divider(thickness: 2, color: PdfColors.grey300),
          pw.SizedBox(height: 20),

          // --- SECCIÓN 1: EFICIENCIA Y URGENCIA ---
          pw.Text('1. Indicadores de Gestión', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCard('Tiempo Promedio de Atención', '${data.eficiencia.tiempoPromedioHoras} horas'),
              _buildMetricCard('Total Reportes Procesados', '${data.eficiencia.totalProcesados}'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text('Distribución por Urgencia:', style: subHeaderStyle),
          pw.SizedBox(height: 5),
          pw.TableHelper.fromTextArray(
            headers: ['Nivel', 'Cantidad'],
            data: data.porUrgencia.map((d) => [d.name, d.value.toInt().toString()]).toList(),
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: normalStyle,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          ),
          pw.SizedBox(height: 20),

          // --- SECCIÓN 2: PROBLEMAS PRINCIPALES ---
          pw.Text('2. Top Problemas de la Ciudad', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Categoría', 'Total Reportes'],
            data: data.porCategoria.map((d) => [d.name, d.value.toInt().toString()]).toList(),
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
            cellStyle: normalStyle,
            cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
          ),
          pw.SizedBox(height: 20),

          // --- SECCIÓN 3: GEOGRAFÍA ---
          pw.Text('3. Distribución por Distrito', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Distrito', 'Reportes'],
            data: data.porDistrito.map((d) => [d.name, d.value.toInt().toString()]).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),

          // --- SECCIÓN 4: TENDENCIA ---
          pw.Text('4. Tendencia de Actividad (Últimos 30 días)', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 10,
            runSpacing: 5,
            children: data.tendencia.map((d) => 
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Column(
                  children: [
                    pw.Text(d.name.substring(5), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)), // MM-DD
                    pw.Text(d.value.toInt().toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]
                )
              )
            ).toList()
          ),
          
          pw.SizedBox(height: 30),
          pw.Footer(
            leading: pw.Text('Reporta Piura - Transparencia Ciudadana', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Informes';
    await Directory(path).create(recursive: true);
    final fileName = 'Reporte_Prensa_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildMetricCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.blue50
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ]
      )
    );
  }
}