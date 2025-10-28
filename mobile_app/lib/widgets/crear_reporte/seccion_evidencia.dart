import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// {@template seccion_evidencia}
/// Widget reutilizable que maneja la selección y vista previa de la
/// imagen de evidencia en el formulario de [CreateReportScreen].
///
/// Muestra un placeholder con un icono de cámara. Si se selecciona una
/// imagen ([imageFile] no es nulo), muestra la imagen desde el archivo.
/// Es tappable ([onPickImage]) para abrir el selector de imágenes.
/// {@endtemplate}
class SeccionEvidencia extends StatelessWidget {
  /// El archivo de imagen (de [ImagePicker]) que ha sido seleccionado.
  /// Si es `null`, se muestra el placeholder.
  final XFile? imageFile;
  /// Callback que se ejecuta al tocar el widget para seleccionar una imagen.
  final VoidCallback onPickImage;

  /// {@macro seccion_evidencia}
  const SeccionEvidencia({
    super.key,
    required this.imageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Asegura que la imagen respete los bordes.
      child: InkWell(
        onTap: onPickImage, // Llama al callback del padre.
        child: Container(
          height: 200, // Altura fija para la vista previa.
          width: double.infinity,
          decoration: BoxDecoration(
            // Fondo sutil por si la imagen no carga o es transparente.
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
          ),
          child: imageFile != null
              /// Muestra la imagen seleccionada desde el archivo.
              ? Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover, // Cubre el contenedor.
                )
              /// Muestra el placeholder si [imageFile] es nulo.
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Añadir Foto de Evidencia'),
                  ],
                ),
        ),
      ),
    );
  }
}