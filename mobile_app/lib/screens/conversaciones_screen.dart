import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/api/perfil_service.dart';
import 'package:mobile_app/models/conversacion_model.dart';
import 'package:mobile_app/screens/chat_screen.dart';
import 'package:mobile_app/services/socket_service.dart'; // Importar Socket

class ConversacionesScreen extends StatefulWidget {
  const ConversacionesScreen({super.key});

  @override
  State<ConversacionesScreen> createState() => _ConversacionesScreenState();
}

class _ConversacionesScreenState extends State<ConversacionesScreen> with SingleTickerProviderStateMixin {
  final PerfilService _perfilService = PerfilService();
  late TabController _tabController;
  
  // Controlador para la barra de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Datos originales (sin filtrar)
  List<Conversacion> _conversaciones = [];
  List<ReporteSinChat> _reportesSinChat = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    // Limpiar recursos
    _tabController.dispose();
    _searchController.dispose();
    // Dejar de escuchar el evento de refresco al salir de la pantalla
    SocketService().off('refresh_conversations_list');
    super.dispose();
  }

  /// Configura la escucha de eventos del socket para recarga automática
  void _setupSocketListeners() {
    SocketService().on('refresh_conversations_list', (data) {
      // Si llega un mensaje nuevo a cualquier chat, recargamos la lista silenciosamente
      // para actualizar el último mensaje y el contador de no leídos.
      if (mounted) {
        // 'silent: true' evita que aparezca el spinner de carga interrumpiendo al usuario
        _loadData(silent: true);
      }
    });
  }

  /// Carga los datos del servidor.
  /// [silent]: Si es true, no muestra el indicador de carga (útil para actualizaciones en tiempo real).
  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    
    try {
      final results = await Future.wait([
        _perfilService.getMisConversaciones(),
        _perfilService.getReportesSinChat(),
      ]);
      
      if (mounted) {
        setState(() {
          _conversaciones = results[0] as List<Conversacion>;
          _reportesSinChat = results[1] as List<ReporteSinChat>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos: $e");
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculamos totales para los badges de los tabs
    final unreadCountTotal = _conversaciones.where((c) => c.unreadCount > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          // Botón de Recarga Manual
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
            onPressed: () => _loadData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(text: 'Chats'),
            Tab(text: 'No Leídos ${unreadCountTotal > 0 ? "($unreadCountTotal)" : ""}'),
            const Tab(text: 'Iniciar Chat'),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              // Al cambiar el texto, hacemos setState para que los filtros de abajo se reapliquen
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por título o código...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                // Botón para borrar texto
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ) 
                  : null,
              ),
            ),
          ),

          // --- CONTENIDO DE PESTAÑAS ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. TODOS LOS CHATS
                    _buildChatList(_conversaciones),
                    
                    // 2. SOLO NO LEÍDOS
                    _buildChatList(
                      _conversaciones.where((c) => c.unreadCount > 0).toList(), 
                      emptyMsg: "Estás al día. No hay mensajes sin leer."
                    ),
                    
                    // 3. INICIAR NUEVOS
                    _buildNewChatList(_reportesSinChat),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  // --- Widget Lista de Chats (Estilo WhatsApp) ---
  Widget _buildChatList(List<Conversacion> lista, {String emptyMsg = "No hay conversaciones."}) {
    // Aplicar filtro de búsqueda
    final searchQuery = _searchController.text.toLowerCase();
    final filteredList = lista.where((c) => 
      c.tituloReporte.toLowerCase().contains(searchQuery) || 
      c.codigoReporte.toLowerCase().contains(searchQuery)
    ).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty ? 'No hay coincidencias.' : emptyMsg, 
              style: const TextStyle(fontSize: 16, color: Colors.grey)
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        final conv = filteredList[index];
        final hasUnread = conv.unreadCount > 0;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // Colores para modo oscuro/claro
        final titleColor = hasUnread 
            ? (isDark ? Colors.white : Colors.black) 
            : (isDark ? Colors.grey.shade300 : Colors.black87);
            
        final subtitleColor = hasUnread 
            ? (isDark ? Colors.white : Colors.black87) 
            : Colors.grey;

        // Color de acento (Verde/Teal) para hora y badge
        final accentColor = hasUnread ? Colors.green : Colors.grey;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: conv.fotoUrl != null ? NetworkImage(conv.fotoUrl!) : null,
            child: conv.fotoUrl == null 
                ? Icon(Icons.assignment, color: theme.colorScheme.onPrimaryContainer) 
                : null,
          ),
          title: Text(
            conv.tituloReporte,
            style: TextStyle(
              fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w600,
              fontSize: 16,
              color: titleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                    children: [
                      TextSpan(
                        text: conv.ultimoEsAdmin ? "Soporte: " : "Tú: ",
                        style: TextStyle(
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          color: hasUnread ? theme.colorScheme.primary : subtitleColor,
                        ),
                      ),
                      TextSpan(
                        text: conv.ultimoMensaje,
                        style: TextStyle(
                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(conv.fechaUltimoMensaje),
                style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: hasUnread ? FontWeight.w900 : FontWeight.normal
                ),
              ),
              const SizedBox(height: 6),
              if (hasUnread)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green, // Verde siempre visible
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conv.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
            ],
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  reporteId: conv.idReporte,
                  reporteTitulo: conv.tituloReporte,
                  fromReportDetails: false, // Permite ver detalles
                ),
              ),
            );
            _loadData(silent: true); // Refrescar al volver para limpiar contador
          },
        );
      },
    );
  }

  // --- Widget Lista "Iniciar Chat" ---
  Widget _buildNewChatList(List<ReporteSinChat> lista) {
    // Aplicar filtro de búsqueda
    final searchQuery = _searchController.text.toLowerCase();
    final filteredList = lista.where((r) => 
      r.titulo.toLowerCase().contains(searchQuery)
    ).toList();

    if (filteredList.isEmpty) {
      return Center(child: Text(searchQuery.isNotEmpty ? "No hay coincidencias." : "No tienes reportes disponibles.", style: const TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (_,__) => const Divider(indent: 70),
      itemBuilder: (context, index) {
        final reporte = filteredList[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.add_comment, color: Colors.grey),
          ),
          title: Text(reporte.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text("Estado: ${reporte.estado} • ${reporte.fecha}"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(
                reporteId: reporte.id, 
                reporteTitulo: reporte.titulo,
                fromReportDetails: false,
              )),
            );
            _loadData(silent: true);
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); 
    }
    return DateFormat('dd/MM/yy').format(date);
  }
}