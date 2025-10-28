# Carpeta de Widgets: `pago`

## Descripción General

Esta carpeta contiene los widgets reutilizables que construyen la pantalla de checkout o pago (`PantallaPago`) y la pantalla de añadir nueva tarjeta (`PantallaAgregarMetodoPago`).

La estrategia clave aquí es la reutilización del `FormularioPago`.

## Componentes Principales

### `formulario_pago.dart`

* **Widget:** `FormularioPago`
* **Propósito:** Es un widget de UI reutilizable que **encapsula los campos de formulario** para una tarjeta de crédito, pero **sin incluir un widget `Form` propio**.
* **UI y Lógica Clave:**
    * Contiene `TextFormField`s para "Nombre del Titular", "Número de Tarjeta", "Expira (MM/AA)" y "CVC".
    * Recibe los `TextEditingController`s como parámetros desde el widget padre.
    * **Formateadores de UX:** Incluye `TextInputFormatter`s personalizados (`_CardNumberInputFormatter`, `_CardExpirationInputFormatter`) para añadir automáticamente espacios (ej. `0000 0000 ...`) y la barra `/` (ej. `MM/AA`) mientras el usuario escribe, mejorando la experiencia de entrada de datos.
    * **Importante:** Al no tener su propio `Form`, permite que `PantallaPago` y `PantallaAgregarMetodoPago` lo usen dentro de *sus propios* `GlobalKey<FormState>`, permitiendo una validación centralizada en la pantalla padre.
* **Conexiones:**
    * **Usado por:** `PantallaPago`, `PantallaAgregarMetodoPago`.

### `resumen_pago.dart`

* **Widget:** `ResumenPago`
* **Propósito:** Muestra una `Card` de resumen del plan que el usuario está a punto de comprar.
* **UI:**
    * Muestra el `plan.nombrePublico` y el `plan.precioMensual`.
    * Muestra una fila final de "Total a Pagar" resaltando el precio.
* **Conexiones:**
    * **Usado por:** `PantallaPago`.
    * **Depende de:** `PlanSuscripcion` (modelo).