# Carpeta de Widgets: `historial_pagos`

## Descripción General

Esta carpeta contiene los widgets utilizados para mostrar el historial de transacciones del usuario en la pantalla `PantallaHistorialPagos`.

## Componentes Principales

### `tarjeta_historial_pago.dart`

* **Widget:** `TarjetaHistorialPago`
* **Propósito:** Muestra un resumen de una sola transacción de pago en la lista del historial.
* **UI:**
    * Es un `ListTile` dentro de un `Card`.
    * Muestra un `CircleAvatar` a la izquierda con un icono de `check_circle` (verde) o `error` (rojo) según el `pago.estadoTransaccion`.
    * Muestra el `pago.nombrePlan` como título y `pago.fechaFormateada` como subtítulo.
    * Muestra el `pago.montoPagado` a la derecha, junto con un `Icon(Icons.chevron_right)` para indicar que es tappable.
* **Conexiones:**
    * **Usado por:** `PantallaHistorialPagos`.
    * **Depende de:** `HistorialPago` (modelo).
    * **Acción:** Al ser presionado (`onTap`), navega a la ruta `/detalle_boleta`, pasando el `pago.id` como argumento.