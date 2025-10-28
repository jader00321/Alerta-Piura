# Carpeta de Widgets: `crear_reporte`

## Descripción General

Esta carpeta es fundamental para la creación y edición de reportes. Sus widgets dividen el formulario complejo de `CreateReportScreen` y `PantallaEditarReporteAutor` en secciones lógicas y reutilizables.

El estado (controladores de texto, valores seleccionados) se maneja en las pantallas padre, y estos widgets *sin estado* simplemente reciben los controladores y callbacks.

## Componentes Principales

### `seccion_evidencia.dart`

* **Widget:** `SeccionEvidencia`
* **Propósito:** Maneja la selección y vista previa de la imagen de evidencia.
* **Lógica Clave y UI:**
    * Muestra un `Container` tappable de 200px de altura.
    * Si `imageFile` (un `XFile`) es `null`, muestra un icono de cámara y el texto "Añadir Foto de Evidencia".
    * Si `imageFile` no es `null`, muestra la imagen seleccionada usando `Image.file(File(imageFile!.path))` con `fit: BoxFit.cover`.
    * El `onTap` del widget está vinculado al callback `onPickImage`, que llama a la función `_pickImage()` en la pantalla padre.

### `seccion_detalles_principales.dart`

* **Widget:** `SeccionDetallesPrincipales`
* **Propósito:** Renderiza los campos *principales y requeridos* del reporte.
* **Lógica Clave y UI:**
    * Contiene los `TextFormField` para "Título" y `DropdownButtonFormField` para "Nivel de Urgencia" y "Categoría".
    * Muestra un `CircularProgressIndicator` si `isLoadingCategories` es `true`.
    * **Lógica Condicional:** Si el `categoriaSeleccionada` es igual al `otroCategoriaId` (pasado como parámetro), muestra un `TextFormField` adicional para `categoriaSugeridaController`, que también se vuelve requerido.
    * Es usado tanto por `CreateReportScreen` como por `PantallaEditarReporteAutor`.

### `seccion_detalles_adicionales.dart`

* **Widget:** `SeccionDetallesAdicionales`
* **Propósito:** Renderiza los campos *secundarios u opcionales* del reporte.
* **Lógica Clave y UI:**
    * Contiene `TextFormField` para "Descripción", "Referencia de Ubicación" y "Etiquetas".
    * Contiene `DropdownButtonFormField` para "Distrito" e "Impacto del Problema".
    * Muestra un `ListTile` tappable para "Hora del Incidente", que llama al callback `onSelectTime` (que abre un `showTimePicker` en la pantalla padre).
    * Muestra `ActionChip`s con `recommendedTags` que, al ser presionados, llaman al callback `onAddTag`.

### `seccion_acciones_finales.dart`

* **Widget:** `SeccionAccionesFinales`
* **Propósito:** Muestra las acciones finales del formulario: anonimato, geolocalización y envío.
* **Lógica Clave y UI:**
    * `CheckboxListTile` para "Publicar como anónimo", vinculado a `isAnonimo` y `onAnonimoChanged`.
    * `OutlinedButton` "Obtener Ubicación Actual", vinculado a `onGetCurrentLocation`.
    * Muestra un texto de confirmación `Ubicación obtenida: ...` si `currentLocation` no es `null`.
    * `ElevatedButton` "Enviar Reporte", vinculado a `onSubmitReport`. Este botón muestra un `CircularProgressIndicator` y se deshabilita si `isLoading` es `true`.