// lib/services/servicio_pdf.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mobile_app/screens/pantalla_panel_analitico.dart'; // Importa AnaliticasData
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ServicioPdf {
  
  Future<File> generarInformeAnalitico(AnaliticasData data) async {
    final pdf = pw.Document();
    
    final font = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
    final boldFont = await pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

    final style = pw.TextStyle(font: font, fontSize: 10);
    final titleStyle = pw.TextStyle(font: boldFont, fontSize: 18);
    final headerStyle = pw.TextStyle(font: boldFont, fontSize: 12);
    final tableHeader = pw.TextStyle(font: boldFont, fontSize: 10);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: pw.Text('Reporte Analítico - Reporta Piura', style: style)
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: style)
          );
        },
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Reporte Analítico Global', style: titleStyle),
          ),
          pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(DateTime.now())}', style: style),
          pw.Divider(height: 24),

          pw.Text('Reportes por Categoría', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Categoría', 'Total'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.porCategoria.map((d) => [d.name, d.value.toInt().toString()]).toList(),
          ),
          pw.SizedBox(height: 24),

          pw.Text('Reportes por Distrito', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Distrito', 'Total'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.porDistrito.map((d) => [d.name, d.value.toInt().toString()]).toList(),
          ),
          pw.SizedBox(height: 24),
          
          pw.Text('Tendencia de Reportes (Últimos 30 días)', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'Reportes'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.tendencia.map((d) => [d.name, d.value.toInt().toString()]).toList(),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Informes';
    await Directory(path).create(recursive: true);
    
    final fileName = 'Reporte_Analitico_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}