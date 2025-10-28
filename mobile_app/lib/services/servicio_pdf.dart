import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mobile_app/screens/pantalla_panel_analitico.dart'; // Importa AnaliticasData
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// {@template servicio_pdf}
/// Servicio encargado de generar informes en PDF del lado del cliente.
///
/// Utiliza el paquete `pdf` para construir el documento y `path_provider`
/// para guardarlo en el almacenamiento local de la aplicación.
/// {@endtemplate}
class ServicioPdf {
  /// {@template servicio_pdf.generarInformeAnalitico}
  /// Genera un informe PDF basado en los datos de [AnaliticasData].
  ///
  /// El informe incluye:
  /// - Título y fecha de generación.
  /// - Tabla de "Reportes por Categoría".
  /// - Tabla de "Reportes por Distrito".
  /// - Tabla de "Tendencia de Reportes".
  ///
  /// Guarda el archivo en un subdirectorio "Informes" dentro del
  /// directorio de documentos de la app y devuelve el [File] generado.
  ///
  /// [data]: Los datos analíticos cargados desde [PantallaPanelAnalitico].
  /// {@endtemplate}
  Future<File> generarInformeAnalitico(AnaliticasData data) async {
    final pdf = pw.Document();

    /// Carga las fuentes Roboto (regular y bold) desde los assets.
    /// Es necesario para que el PDF pueda renderizar texto.
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final font = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(boldFontData);

    /// Define estilos de texto reutilizables.
    final style = pw.TextStyle(font: font, fontSize: 10);
    final titleStyle = pw.TextStyle(font: boldFont, fontSize: 18);
    final headerStyle = pw.TextStyle(font: boldFont, fontSize: 12);
    final tableHeader = pw.TextStyle(font: boldFont, fontSize: 10);

    /// Añade una página al documento PDF.
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        /// Define la cabecera de cada página.
        header: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              child:
                  pw.Text('Reporte Analítico - Reporta Piura', style: style));
        },
        /// Define el pie de página (número de página).
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
                  style: style));
        },
        /// Construye el contenido de la página.
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Reporte Analítico Global', style: titleStyle),
          ),
          pw.Text(
              'Generado el: ${DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(DateTime.now())}',
              style: style),
          pw.Divider(height: 24),

          /// Tabla de Reportes por Categoría.
          pw.Text('Reportes por Categoría', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Categoría', 'Total'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.porCategoria
                .map((d) => [d.name, d.value.toInt().toString()])
                .toList(),
          ),
          pw.SizedBox(height: 24),

          /// Tabla de Reportes por Distrito.
          pw.Text('Reportes por Distrito', style: headerStyle),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Distrito', 'Total'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.porDistrito
                .map((d) => [d.name, d.value.toInt().toString()])
                .toList(),
          ),
          pw.SizedBox(height: 24),

          /// Tabla de Tendencia de Reportes.
          pw.Text('Tendencia de Reportes (Últimos 30 días)',
              style: headerStyle),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Reportes'],
            cellStyle: style,
            headerStyle: tableHeader,
            data: data.tendencia
                .map((d) => [d.name, d.value.toInt().toString()])
                .toList(),
          ),
        ],
      ),
    );

    /// Obtiene el directorio de documentos de la aplicación.
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Informes';
    /// Crea el subdirectorio "Informes" si no existe.
    await Directory(path).create(recursive: true);

    /// Define un nombre de archivo único basado en la fecha/hora actual.
    final fileName =
        'Reporte_Analitico_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
    final file = File('$path/$fileName');
    /// Escribe los bytes del PDF al archivo.
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}