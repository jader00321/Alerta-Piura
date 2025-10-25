import 'package:flutter/material.dart';
import 'package:mobile_app/api/reporte_service.dart';
import 'package:mobile_app/models/reporte_cercano_model.dart';

class DialogoDetallePendiente extends StatefulWidget {
  final ReporteCercano reporte;
  final VoidCallback onJoined;

  const DialogoDetallePendiente({
    super.key,
    required this.reporte,
    required this.onJoined,
  });

  @override
  State<DialogoDetallePendiente> createState() => _DialogoDetallePendienteState();
}

class _DialogoDetallePendienteState extends State<DialogoDetallePendiente> {
  bool _isLoading = false;
  bool _hasJoined = false;

  Future<void> _joinReport() async {
    setState(() => _isLoading = true);

    final response = await ReporteService().unirseReportePendiente(widget.reporte.id);
    
    if (mounted) {
      if (response['statusCode'] == 201 || response['message'] == 'You have already joined this report.') {
        setState(() {
          _hasJoined = true;
          _isLoading = false;
        });
        widget.onJoined(); // Notify the parent screen to refresh
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'An error occurred'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reporte.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.reporte.fotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.reporte.fotoUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image))),
                ),
              ),
            const SizedBox(height: 16),
            Text('Category: ${widget.reporte.categoria}'),
            const SizedBox(height: 8),
            const Text('This report is pending verification. If this is the same issue you are seeing, you can join this report to give it more priority.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading || _hasJoined ? null : _joinReport,
          icon: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(_hasJoined ? Icons.check : Icons.add),
          label: Text(_hasJoined ? 'You have Joined' : 'Me too! Join this Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasJoined ? Colors.green : Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}