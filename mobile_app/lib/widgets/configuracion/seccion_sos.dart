import 'package:flutter/material.dart';

/// {@template seccion_sos}
/// Un widget reutilizable que agrupa las configuraciones relacionadas con la
/// función de Alerta SOS en la pantalla de [SettingsScreen].
///
/// Este widget es **sin estado** (`StatelessWidget`) porque el estado
/// (la duración seleccionada) se gestiona en el widget padre ([SettingsScreen]),
/// que le pasa el valor y los callbacks. Esto se conoce como "levantar el estado"
/// (lifting state up).
///
/// Contiene:
/// 1. Un [Slider] para ajustar la duración del seguimiento SOS
///    ([sosDurationInMinutes]).
/// 2. Un [ListTile] que navega a [EditarContactoScreen] (`/editar-contacto`)
///    para gestionar el contacto de emergencia.
/// {@endtemplate}
class SeccionSOS extends StatelessWidget {
  /// El valor actual de la duración del SOS en minutos (ej. 10.0).
  /// Usado para establecer la posición inicial del [Slider].
  final double sosDurationInMinutes;
  /// Callback que se ejecuta continuamente mientras el [Slider] se mueve.
  /// Se usa para actualizar la UI en [SettingsScreen] en tiempo real.
  final Function(double) onDurationChanged;
  /// Callback que se ejecuta cuando el usuario *suelta* el [Slider].
  /// Se usa para guardar el valor final en [SharedPreferences] en [SettingsScreen].
  final Function(double) onDurationChangeEnd;

  /// {@macro seccion_sos}
  const SeccionSOS({
    super.key,
    required this.sosDurationInMinutes,
    required this.onDurationChanged,
    required this.onDurationChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de SOS',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            
            /// Sección de Duración
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Duración del seguimiento en vivo'),
              subtitle: Text(
                'La app transmitirá tu ubicación por ${sosDurationInMinutes.toInt()} minutos al activar el SOS.',
              ),
            ),
            Slider(
              value: sosDurationInMinutes,
              min: 5, // Duración mínima de 5 min.
              max: 30, // Duración máxima de 30 min.
              divisions: 5, // Pasos de 5 min (5, 10, 15, 20, 25, 30).
              label: '${sosDurationInMinutes.toInt()} min',
              onChanged: onDurationChanged, // Actualiza la UI del padre
              onChangeEnd: onDurationChangeEnd, // Guarda el valor en el padre
            ),
            const SizedBox(height: 16),
            const Divider(),

            /// Sección de Contacto de Emergencia
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_emergency_outlined),
              title: const Text('Contacto de Emergencia'),
              subtitle: const Text('Añadir o editar el número a notificar.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                /// Navega a la pantalla de edición de contacto.
                Navigator.pushNamed(context, '/editar-contacto');
              },
            ),
          ],
        ),
      ),
    );
  }
}