import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/api/servicio_suscripcion.dart';
import 'package:mobile_app/models/perfil_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/widgets/esqueletos/esqueleto_perfil.dart';

class PantallaGestionarSuscripcion extends StatefulWidget {
  const PantallaGestionarSuscripcion({super.key});

  @override
  State<PantallaGestionarSuscripcion> createState() =>
      _PantallaGestionarSuscripcionState();
}

class _PantallaGestionarSuscripcionState
    extends State<PantallaGestionarSuscripcion> {
  final PerfilService _perfilService = PerfilService();
  final ServicioSuscripcion _suscripcionService = ServicioSuscripcion();
  late Future<Perfil> _perfilFuture;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _perfilFuture = _perfilService.getMiPerfil();
  }

  Future<void> _handleCancelarSuscripcion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text(
            '¿Estás seguro de que quieres cancelar tu suscripción? Tus beneficios premium seguirán activos hasta la fecha de expiración.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No, mantener')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, Cancelar')),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        setState(() => _isCancelling = true);
      }
      final response = await _suscripcionService.cancelarSuscripcion();

      if (!mounted) return;

      final message = response['data']['message'] ?? 'Ocurrió un error.';
      final success = response['statusCode'] == 200;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );

      await context.read<AuthNotifier>().refreshUserStatus();

      Navigator.pop(context, true);

      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Suscripción')),
      body: FutureBuilder<Perfil>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EsqueletoPerfil();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Error al cargar los datos de tu suscripción.'));
          }
          final perfil = snapshot.data!;
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu Plan Actual', style: theme.textTheme.titleLarge),
                      const Divider(height: 24),
                      ListTile(
                        leading: const Icon(Icons.workspace_premium,
                            color: Colors.amber, size: 40),
                        title: Text(perfil.nombrePlan ?? 'Plan Gratuito',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          perfil.fechaFinSuscripcion != null
                              ? 'Válido hasta: ${DateFormat('dd MMMM yyyy', 'es_ES').format(perfil.fechaFinSuscripcion!)}'
                              : 'Actualiza a Premium para obtener beneficios.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.swap_horiz_outlined),
                        title: const Text('Cambiar de Plan'),
                        subtitle:
                            const Text('Explora otros planes disponibles.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/subscription_plans');
                        },
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.credit_card_outlined),
                        title: const Text('Métodos de Pago'),
                        subtitle: const Text('Gestiona tus tarjetas.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/metodos_pago');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isCancelling ? null : _handleCancelarSuscripcion,
                icon: _isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar Suscripción'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
