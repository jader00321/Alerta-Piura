import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/notificacion_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';

/// Pantalla que muestra el contenido completo de una notificación.
/// Incluye lógica inteligente para procesar el [payload] y ofrecer
/// navegación contextual (ej. ir al reporte, ir al chat).
class DetalleNotificacionScreen extends StatefulWidget {
  final Notificacion notificacion;

  const DetalleNotificacionScreen({super.key, required this.notificacion});

  @override
  State<DetalleNotificacionScreen> createState() => _DetalleNotificacionScreenState();
}

class _DetalleNotificacionScreenState extends State<DetalleNotificacionScreen> {
  
  @override
  void initState() {
    super.initState();
    // Marca como leída automáticamente al entrar (Lógica de negocio)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().markAsRead(widget.notificacion.id);
    });
  }

  /// Analiza el payload y ejecuta la navegación correspondiente.
  void _handleNavigation(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id']; // Puede ser int o string

    try {
      if (type == 'report_detail' && id != null) {
        // Navegar al detalle del reporte (funciona para autores y líderes)
        Navigator.pushNamed(
          context, 
          '/reporte_detalle', 
          arguments: int.parse(id.toString())
        );
      } else if (type == 'verification_panel') {
        // Navegar al panel de verificación (solo líderes)
        // Asumimos que HomeScreen maneja la redirección a la pestaña correcta
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (type == 'moderation_history') {
         // Navegar al historial de moderación
         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede abrir el detalle de este elemento.'))
        );
      }
    } catch (e) {
      debugPrint('Error al navegar desde notificación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al intentar navegar.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notificacion;
    final theme = Theme.of(context);
    final authNotifier = context.watch<AuthNotifier>();
    final bool isLider = authNotifier.isLider; // Verifica rol actual

    // --- ANÁLISIS DEL PAYLOAD PARA BOTÓN DE ACCIÓN ---
    bool showActionButton = false;
    String buttonLabel = 'Ver Detalles';
    IconData buttonIcon = Icons.open_in_new;
    Map<String, dynamic>? payloadData;

    if (n.payload != null && n.payload!.isNotEmpty) {
       try {
         // Decodificamos el JSON que viene del backend
         final dynamic decoded = jsonDecode(n.payload!);
         
         // Manejo robusto: a veces jsonDecode devuelve String si se codificó doble
         if (decoded is Map<String, dynamic>) {
           payloadData = decoded;
         } else if (decoded is String) {
           payloadData = jsonDecode(decoded);
         }

         if (payloadData != null) {
            final type = payloadData['type'];
            
            // REGLA 1: Reportes (Aprobación, Rechazo, Comentarios)
            // Visible para todos (Autores y Líderes)
            if (type == 'report_detail') {
              showActionButton = true;
              buttonLabel = 'Ver Reporte';
              buttonIcon = Icons.article_outlined;
            }
            
            // REGLA 2: Solicitudes de Revisión (Sistema)
            // Solo visible si el usuario actual es LÍDER VECINAL o ADMIN
            else if (type == 'verification_panel' || type == 'moderation_history') {
              if (isLider) {
                showActionButton = true;
                buttonLabel = 'Ir al Panel de Líder';
                buttonIcon = Icons.admin_panel_settings_outlined;
              }
            }
         }
       } catch (e) {
         debugPrint("Error parseando payload en detalle: $e");
       }
    }

    return Scaffold(
      appBar: AppBar(
        // Título vacío para dar aire, acciones a la derecha
        actions: [
          // Botón Archivar/Desarchivar
          IconButton(
            icon: Icon(n.archivado ? Icons.unarchive : Icons.archive_outlined),
            tooltip: n.archivado ? 'Desarchivar' : 'Archivar',
            onPressed: () {
              _showConfirmationDialog(
                context, 
                title: n.archivado ? '¿Desarchivar?' : '¿Archivar?',
                content: 'Esta notificación se moverá a ${n.archivado ? "tu bandeja de entrada" : "archivados"}.',
                onConfirm: () {
                  context.read<NotificationProvider>().archiveNotification(n);
                  Navigator.pop(context); // Volver a la lista tras acción
                }
              );
            },
          ),
          // Botón Eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: () {
              _showConfirmationDialog(
                context,
                title: '¿Eliminar notificación?',
                content: 'Esta acción no se puede deshacer.',
                isDestructive: true,
                onConfirm: () {
                  context.read<NotificationProvider>().deleteNotification(n.id);
                  Navigator.pop(context); // Volver a la lista tras acción
                }
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA (Categoría y Fecha) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    n.categoria, 
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSecondaryContainer
                    )
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(n.fechaEnvio),
                  style: TextStyle(
                    // Color adaptativo para modo oscuro/claro
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 13
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- TÍTULO ---
            Text(
              n.titulo,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // Color correcto en Dark Mode
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // --- CUERPO DEL MENSAJE ---
            Text(
              n.cuerpo,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                fontSize: 16,
              ),
            ),

            // --- INFORMACIÓN DEL REMITENTE (Si existe) ---
            if (n.remitenteInfo != null && n.remitenteInfo!.isNotEmpty) ...[
               const SizedBox(height: 30),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: theme.colorScheme.outline.withOpacity(0.2)
                   ),
                 ),
                 child: Row(
                   children: [
                     CircleAvatar(
                       radius: 18,
                       backgroundColor: theme.colorScheme.primary,
                       child: Icon(Icons.person, size: 20, color: theme.colorScheme.onPrimary),
                     ),
                     const SizedBox(width: 12),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           n.remitenteInfo?['alias'] ?? 'Usuario',
                           style: const TextStyle(fontWeight: FontWeight.bold),
                         ),
                         Text(
                           'Rol: ${n.remitenteInfo?['rol']?.toString().toUpperCase() ?? 'DESCONOCIDO'}',
                           style: TextStyle(
                             fontSize: 12, 
                             color: theme.textTheme.bodySmall?.color
                           ),
                         ),
                       ],
                     )
                   ],
                 ),
               )
            ],

            const SizedBox(height: 40),

            // --- BOTÓN DE ACCIÓN INTELIGENTE ---
            if (showActionButton && payloadData != null)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _handleNavigation(context, payloadData!),
                    icon: Icon(buttonIcon),
                    label: Text(buttonLabel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper para mostrar diálogos de confirmación
  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm, bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancelar')
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Cerrar diálogo
              onConfirm(); // Ejecutar acción
            },
            child: Text(
              isDestructive ? 'Eliminar' : 'Confirmar', 
              style: TextStyle(
                color: isDestructive ? Colors.red : null,
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }
}