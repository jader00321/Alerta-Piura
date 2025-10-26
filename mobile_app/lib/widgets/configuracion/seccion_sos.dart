import 'package:flutter/material.dart';

class SeccionSOS extends StatelessWidget {
  final double sosDurationInMinutes;
  final Function(double) onDurationChanged;
  final Function(double) onDurationChangeEnd;

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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Duración del seguimiento en vivo'),
              subtitle: Text(
                'La app transmitirá tu ubicación por ${sosDurationInMinutes.toInt()} minutos al activar el SOS.',
              ),
            ),
            Slider(
              value: sosDurationInMinutes,
              min: 5,
              max: 30,
              divisions: 5,
              label: '${sosDurationInMinutes.toInt()} min',
              onChanged: onDurationChanged,
              onChangeEnd: onDurationChangeEnd,
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_emergency_outlined),
              title: const Text('Contacto de Emergencia'),
              subtitle: const Text('Añadir o editar el número a notificar.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/editar-contacto');
              },
            ),
          ],
        ),
      ),
    );
  }
}
