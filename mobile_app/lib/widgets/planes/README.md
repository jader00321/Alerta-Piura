# Carpeta de Widgets: `planes`

## Descripción General

[cite_start]Esta carpeta contiene los widgets especializados para mostrar los planes de suscripción disponibles en la pantalla `PantallaPlanesSuscripcion`[cite: 31, 32, 59].

## Componentes Principales

### `tarjeta_plan.dart`

* [cite_start]**Widget:** `TarjetaPlan` [cite: 59]
* **Propósito:** Es la tarjeta de UI principal que muestra un plan de suscripción individual. Está diseñada para ser visualmente atractiva y clara, incentivando al usuario a seleccionar un plan.
* **UI y Lógica Clave:**
    * [cite_start]Muestra un chip de "Recomendado" si `isRecommended` es `true`[cite: 59].
    * [cite_start]Muestra el `plan.nombrePublico` y `plan.precioMensual`[cite: 59, 31].
    * [cite_start]**Análisis de Características:** Parsea el campo `plan.descripcion`[cite: 31], que es un string con saltos de línea (ej. `\n` o `\\n`). [cite_start]Divide el string y renderiza cada característica como una fila con un icono de `check_circle_outline`[cite: 59].
    * Muestra un botón "Seleccionar Plan" que ejecuta el callback `onSelected`.
* **Conexiones:**
    * [cite_start]**Usado por:** `PantallaPlanesSuscripcion`[cite: 32].
    * [cite_start]**Depende de:** `PlanSuscripcion` (modelo)[cite: 31].
    * [cite_start]**Acción:** El callback `onSelected` está conectado a la función `_navigateToPayment` en `PantallaPlanesSuscripcion`, la cual navega a `PantallaPago` pasando el plan seleccionado[cite: 32, 24].