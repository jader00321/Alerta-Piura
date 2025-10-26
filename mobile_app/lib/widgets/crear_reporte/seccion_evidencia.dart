import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SeccionEvidencia extends StatelessWidget {
  final XFile? imageFile;
  final VoidCallback onPickImage;

  const SeccionEvidencia({
    super.key,
    required this.imageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(128),
          ),
          child: imageFile != null
              ? Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                )
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
