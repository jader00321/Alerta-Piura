import 'package:flutter/material.dart';

class SeccionSOS extends StatelessWidget {
  final double sosDurationInMinutes;
  final Function(double) onDurationChanged;
  final Function(double) onDurationChangeEnd;
  
  final bool isSosActive;
  final VoidCallback onStopSos;

  const SeccionSOS({
    super.key,
    required this.sosDurationInMinutes,
    required this.onDurationChanged,
    required this.onDurationChangeEnd,
    required this.isSosActive,
    required this.onStopSos,
  });

  // Función auxiliar para confirmar antes de detener
  void _confirmarDetencion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Finalizar Alerta?"),
        content: const Text("Esto detendrá el envío de tu ubicación a las autoridades y contactos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx); // Cerrar diálogo
              onStopSos(); // Ejecutar acción real
            },
            child: const Text("Sí, Finalizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sos, color: isSosActive ? Colors.red : theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Configuración de Pánico',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            if (isSosActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      "¡ALERTA EN CURSO!",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "La configuración está bloqueada mientras el SOS está activo.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // CAMBIO: Llamamos a la función con diálogo
                        onPressed: () => _confirmarDetencion(context),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text("FINALIZAR ALERTA AHORA"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Duración del seguimiento en vivo'),
                subtitle: Text('${sosDurationInMinutes.toInt()} minutos'),
                trailing: Icon(Icons.timer, color: theme.colorScheme.primary),
              ),
              Slider(
                value: sosDurationInMinutes,
                min: 5,
                max: 30,
                divisions: 5,
                label: '${sosDurationInMinutes.toInt()} min',
                onChanged: onDurationChanged,
                onChangeEnd: onDurationChangeEnd,
                activeColor: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 8),
              const Divider(),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.contact_phone_outlined),
                title: const Text('Contacto de Emergencia'),
                subtitle: const Text('Añadir o editar el número a notificar.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/editar-contacto'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}