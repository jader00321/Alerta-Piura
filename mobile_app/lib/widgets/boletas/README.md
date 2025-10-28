# Carpeta de Widgets: `boletas`

## Descripción General

Este widget se utiliza para mostrar el detalle de una transacción de pago completada. Es la "boleta" o "factura" digital que el usuario puede consultar desde su historial de pagos.

## Componentes Principales

### `tarjeta_detalle_boleta.dart`

* **Propósito:** Renderizar una vista detallada y bien formateada de una transacción de pago, basada en el modelo [BoletaDetalle](../models/boleta_detalle_model.dart).
* **UI:**
    * **Cabecera:** Muestra "Boleta de Venta", el ID de la transacción y un [Chip] con el estado (`Aprobado`, `Fallido`, etc.).
    * **Facturado a:** Muestra el nombre y email del usuario.
    * **Descripción del Servicio:** Muestra el nombre del plan contratado y la fecha exacta de la transacción.
    * **Método de Pago:** Muestra la tarjeta utilizada (ej. "VISA terminada en **** 4242").
    * **Total:** Muestra el monto final pagado.
* **Dependencias Clave:**
    * `model/boleta_detalle_model.dart`
* **Interacciones:**
    * Este es un widget puramente visual. No tiene lógica de estado interna ni callbacks.
* **Flujo de Datos:**
    1.  `PantallaDetalleBoleta` recibe un `transactionId` como argumento de navegación.
    2.  Llama a `PerfilService.getDetalleBoleta(transactionId)` para obtener un objeto `BoletaDetalle`.
    3.  Pasa este objeto `BoletaDetalle` al constructor de `TarjetaDetalleBoleta`, que se encarga de renderizar todos los campos.