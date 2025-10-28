# Carpeta de Widgets: `alertas_personalizadas`

## Descripción General

Estos widgets componen la interfaz de usuario para la pantalla de "Alertas Personalizadas" (`PantallaAlertasPersonalizadas`). Esta funcionalidad es una característica premium que permite a los usuarios crear "Zonas Seguras" (geovallas) y recibir notificaciones cuando se verifican reportes de alta peligrosidad dentro de esas zonas.

Los widgets de esta carpeta se encargan de visualizar las zonas ya creadas.

## Componentes Principales

### `tarjeta_zona_segura.dart`

* **Propósito:** Muestra una tarjeta individual para una [ZonaSegura](../models/zona_segura_model.dart) creada por el usuario.
* **UI:**
    * **Mini-Mapa:** Renderiza un `FlutterMap` no interactivo centrado en las coordenadas `centro` de la zona.
    * **Círculo de Radio:** Dibuja un `CircleLayer` sobre el mapa para mostrar visualmente el `radio` (en metros) de la zona.
    * **Información:** Muestra el `nombreZona` y el radio en kilómetros.
* **Dependencias Clave:**
    * `package:flutter_map/flutter_map.dart`
    * `package:latlong2/latlong.dart`
* **Interacciones:**
    * Recibe todos los datos (nombre, centro, radio) como parámetros.
    * Expone un callback `onDelete` que se vincula a un `IconButton` de eliminar.
* **Flujo de Datos:**
    1.  `PantallaAlertasPersonalizadas` obtiene la `List<ZonaSegura>` desde `PerfilService.getMisZonasSeguras()`.
    2.  La pantalla crea un `ListView.builder` y genera una `TarjetaZonaSegura` por cada ítem.
    3.  El callback `onDelete` de la tarjeta llama a la función `_eliminarZona()` en la pantalla, la cual muestra un diálogo de confirmación y llama a `PerfilService.eliminarZonaSegura()`.