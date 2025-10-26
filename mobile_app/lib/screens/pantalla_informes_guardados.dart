// lib/screens/pantalla_informes_guardados.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // <-- CORRECCIÓN: Importamos 'open_file'
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PantallaInformesGuardados extends StatefulWidget {
  const PantallaInformesGuardados({super.key});

  @override
  State<PantallaInformesGuardados> createState() =>
      _PantallaInformesGuardadosState();
}

class _PantallaInformesGuardadosState extends State<PantallaInformesGuardados> {
  late Future<List<File>> _informesFuture;

  @override
  void initState() {
    super.initState();
    _informesFuture = _listarInformes();
  }

  Future<List<File>> _listarInformes() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Informes';
    final dir = Directory(path);

    if (await dir.exists()) {
      final files =
          await dir.list().where((item) => item.path.endsWith('.pdf')).toList();
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return files.cast<File>();
    }
    return [];
  }

  void _refrescarInformes() {
    setState(() {
      _informesFuture = _listarInformes();
    });
  }

  Future<void> _abrirInforme(File file) async {
    // La sintaxis de la API es idéntica
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No se pudo abrir el archivo: ${result.message}')),
        );
      }
    }
  }

  Future<void> _guardarEnDescargas(File file) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      try {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          final newPath = '${downloadsDir.path}/ReportaPiura';
          final newDir = Directory(newPath);
          if (!await newDir.exists()) {
            await newDir.create(recursive: true);
          }
          downloadsDir = newDir;
        } else {
          downloadsDir = await getApplicationDocumentsDirectory(); // iOS
        }

        final fileName = file.path.split('/').last;
        await file.copy('${downloadsDir.path}/$fileName');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Guardado en Descargas/ReportaPiura/$fileName')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al guardar: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Se requiere permiso de almacenamiento para guardar.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Informes Guardados')),
      body: FutureBuilder<List<File>>(
        future: _informesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar informes.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes informes guardados.'));
          }

          final files = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refrescarInformes(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
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
                        if (value == 'open') _abrirInforme(file);
                        if (value == 'save') _guardarEnDescargas(file);
                        if (value == 'delete') {
                          file.delete().then((_) => _refrescarInformes());
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'open', child: Text('Abrir')),
                        const PopupMenuItem(
                            value: 'save', child: Text('Guardar en Descargas')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                    onTap: () => _abrirInforme(file),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
