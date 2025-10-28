import 'package:flutter/material.dart';

/// {@template navigator_key}
/// Una [GlobalKey] estática para el [NavigatorState] de [MaterialApp].
///
/// Esta clave es esencial para permitir la navegación desde fuera del árbol
/// de widgets (es decir, desde servicios que no tienen un `BuildContext`).
///
/// Su principal consumidor es [NotificationService], que la utiliza para
/// abrir la pantalla correcta (ej. `/reporte_detalle`) cuando el usuario
/// toca una notificación mientras la app está terminada o en segundo plano.
///
/// Se asigna en `main.dart` a la propiedad `navigatorKey` de `MaterialApp`.
/// {@endtemplate}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();