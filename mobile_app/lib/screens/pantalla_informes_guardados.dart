import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

/// {@template pantalla_informes_guardados}
/// Pantalla que lista los informes PDF generados por el usuario
/// y guardados localmente en el directorio de documentos de la app.
///
/// Permite abrir, eliminar o guardar los informes en la carpeta de descargas del dispositivo.
/// {@endtemplate}
class PantallaInformesGuardados extends StatefulWidget {
  /// {@macro pantalla_informes_guardados}
  const PantallaInformesGuardados({super.key});

  @override
  State<PantallaInformesGuardados> createState() =>
      _PantallaInformesGuardadosState();
}

/// Estado para [PantallaInformesGuardados].
///
/// Maneja la carga de la lista de archivos PDF, así como las acciones
/// de abrir, eliminar y guardar en descargas.
class _PantallaInformesGuardadosState
    extends State<PantallaInformesGuardados> {
  /// Futuro que contiene la lista de archivos PDF encontrados.
  late Future<List<File>> _informesFuture;

  @override
  void initState() {
    super.initState();
    _informesFuture = _listarInformes();
  }

  /// Lee el directorio de documentos de la app, filtra los archivos PDF
  /// y los devuelve ordenados por fecha de modificación descendente.
  Future<List<File>> _listarInformes() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Informes';
    final dir = Directory(path);

    if (await dir.exists()) {
      final files = await dir
          .list()
          .where((item) => item.path.endsWith('.pdf'))
          .toList();
      // Ordena por fecha de modificación, más reciente primero
      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));
      return files.cast<File>();
    } else {
      return []; // Devuelve lista vacía si el directorio no existe
    }
  }

  /// Recarga la lista de informes.
  Future<void> _refrescarInformes() async {
    setState(() {
      _informesFuture = _listarInformes();
    });
  }

  /// Abre un archivo PDF usando el paquete [open_file].
  Future<void> _abrirInforme(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el archivo: ${result.message}')));
    }
  }

  /// Solicita permisos y copia un archivo PDF a la carpeta de descargas del dispositivo.
  Future<void> _guardarEnDescargas(File file) async {
    // Solicitar permiso de almacenamiento (importante para Android >= 10)
    final status = await Permission.storage.request();

    if (!mounted) return;

    if (status.isGranted) {
      try {
        // Obtener directorio de descargas (puede variar por plataforma)
        // Usar path_provider para obtener el directorio de descargas puede ser más robusto
        // pero getExternalStorageDirectories(type: StorageDirectory.downloads) es una opción
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('No se pudo encontrar el directorio de descargas.');
        }

        final fileName = file.path.split('/').last;
        final newPath = '${downloadsDir.path}/$fileName';
        await file.copy(newPath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informe guardado en Descargas: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar en descargas: $e'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permiso de almacenamiento denegado.'),
            backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes PDF Guardados'),
      ),
      body: RefreshIndicator(
        onRefresh: _refrescarInformes,
        child: FutureBuilder<List<File>>(
          future: _informesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error al listar informes: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No has generado ningún informe PDF todavía.\nPuedes hacerlo desde el Panel Analítico.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            final files = snapshot.data!;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path.split('/').last;
                final fileStat = file.statSync();

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf,
                        color: Colors.red, size: 36),
                    title: Text(fileName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                        'Guardado: ${DateFormat('dd/MM/yy, HH:mm').format(fileStat.modified)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'open') {
                          _abrirInforme(file);
                        }
                        if (value == 'save') {
                          _guardarEnDescargas(file);
                        }
                        if (value == 'delete') {
                          file.delete().then((_) => _refrescarInformes());
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'open', child: Text('Abrir')),
                        const PopupMenuItem(
                            value: 'save', child: Text('Guardar en Descargas')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                    onTap: () => _abrirInforme(file),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}