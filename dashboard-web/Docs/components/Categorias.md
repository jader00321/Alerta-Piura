# 📁 Documentación Externa — Componentes de Categorías

Este módulo agrupa los componentes relacionados con la **gestión de categorías** dentro del panel de administración.
Incluye funcionalidades para **crear, listar, reordenar, fusionar y aprobar categorías sugeridas** por los usuarios.

---

## 🧩 Índice de Componentes

1. [FormularioCrearCategoria.jsx](#formulario-crear-categoria)
2. [ItemCategoriaOficial.jsx](#item-categoria-oficial)
3. [ListaCategoriasOficiales.jsx](#lista-categorias-oficiales)
4. [ModalFusionarSugerencia.jsx](#modal-fusionar-sugerencia)
5. [PanelSugerencias.jsx](#panel-sugerencias)

---

## 📝 1. FormularioCrearCategoria.jsx

**Ruta:** `src/components/Categorias/FormularioCrearCategoria.jsx`

### 📄 Descripción

Formulario que permite crear una nueva categoría oficial.
Incluye un campo de texto para el nombre y un botón de acción con estado de carga (`loading`).

### ⚙️ Props

| Propiedad  | Tipo       | Descripción                                                                  |
| ---------- | ---------- | ---------------------------------------------------------------------------- |
| `onCreate` | `Function` | Función que recibe el nombre de la nueva categoría al hacer clic en "Crear". |
| `loading`  | `boolean`  | Indica si la acción está en proceso; deshabilita inputs y muestra spinner.   |

### 💻 Ejemplo de Uso

```jsx
<FormularioCrearCategoria
  onCreate={(nombre) => handleCrearCategoria(nombre)}
  loading={isSubmitting}
/>
```

### 🧠 Notas

* Valida que el nombre no esté vacío antes de enviar.
* Puede limpiar el campo de texto tras crear exitosamente una categoría.

---

## 📦 2. ItemCategoriaOficial.jsx

**Ruta:** `src/components/Categorias/ItemCategoriaOficial.jsx`

### 📄 Descripción

Elemento individual dentro de la lista de categorías oficiales.
Muestra el nombre, estadísticas de reportes y un botón de eliminación.
Compatible con **drag & drop** para reordenar categorías.

### ⚙️ Props

| Propiedad  | Tipo       | Descripción                                                               |
| ---------- | ---------- | ------------------------------------------------------------------------- |
| `category` | `Object`   | Objeto con información de la categoría.                                   |
| `provided` | `Object`   | Propiedades de `react-beautiful-dnd` o `@hello-pangea/dnd` para arrastre. |
| `snapshot` | `Object`   | Estado del elemento durante el arrastre.                                  |
| `onDelete` | `Function` | Callback ejecutado al eliminar la categoría.                              |

### 📊 Campos esperados en `category`

| Campo                 | Tipo     | Descripción                       |                      |
| --------------------- | -------- | --------------------------------- | -------------------- |
| `id`                  | `number  | string`                           | Identificador único. |
| `nombre`              | `string` | Nombre de la categoría.           |                      |
| `reportes_activos`    | `number` | Cantidad de reportes verificados. |                      |
| `reportes_pendientes` | `number` | Cantidad de reportes en revisión. |                      |
| `reportes_rechazados` | `number` | Cantidad de reportes rechazados.  |                      |

### 🧠 Notas

* La categoría `"Otro"` es fija: **no se puede arrastrar ni eliminar**.
* Usa `Tooltip`, `Chip` y `IconButton` de Material-UI para accesibilidad y estilo.

---

## 📋 3. ListaCategoriasOficiales.jsx

**Ruta:** `src/components/Categorias/ListaCategoriasOficiales.jsx`

### 📄 Descripción

Lista completa de categorías oficiales con soporte **drag & drop** mediante `@hello-pangea/dnd`.
Permite reorganizar las categorías y eliminar las existentes.

### ⚙️ Props

| Propiedad    | Tipo            | Descripción                                    |
| ------------ | --------------- | ---------------------------------------------- |
| `categories` | `Array<Object>` | Lista de categorías oficiales.                 |
| `loading`    | `boolean`       | Muestra `Skeleton` durante la carga.           |
| `onDragEnd`  | `Function`      | Callback ejecutado tras completar un arrastre. |
| `onDelete`   | `Function`      | Callback ejecutado al eliminar una categoría.  |

### 💻 Ejemplo de Uso

```jsx
<ListaCategoriasOficiales
  categories={categorias}
  loading={false}
  onDragEnd={handleReordenar}
  onDelete={handleEliminar}
/>
```

### 🧠 Notas

* Ignora el evento de arrastre para la categoría `"Otro"`.
* Incluye tres estados visuales: **cargando**, **vacío** y **con datos**.

---

## 🔄 4. ModalFusionarSugerencia.jsx

**Ruta:** `src/components/Categorias/ModalFusionarSugerencia.jsx`

### 📄 Descripción

Modal que permite **fusionar una categoría sugerida por usuarios** con una categoría oficial existente.
Se utiliza cuando el administrador desea reclasificar reportes asociados a una sugerencia.

### ⚙️ Props

| Propiedad    | Tipo            | Descripción                                              |
| ------------ | --------------- | -------------------------------------------------------- |
| `open`       | `boolean`       | Controla la visibilidad del modal.                       |
| `onClose`    | `Function`      | Cierra el modal.                                         |
| `suggestion` | `Object`        | Objeto con datos de la sugerencia a fusionar.            |
| `categories` | `Array<Object>` | Lista de categorías oficiales disponibles.               |
| `onConfirm`  | `Function`      | Ejecuta la fusión (`(nombreSugerido, idDestino) => {}`). |
| `loading`    | `boolean`       | Desactiva los inputs y muestra spinner.                  |

### 🧠 Notas

* Excluye la categoría `"Otro"` del selector.
* Muestra advertencia visual antes de confirmar la fusión.

---

## 💡 5. PanelSugerencias.jsx

**Ruta:** `src/components/Categorias/PanelSugerencias.jsx`

### 📄 Descripción

Panel que muestra las categorías sugeridas por usuarios.
Permite **aprobar** o **fusionar** cada sugerencia.

### ⚙️ Props

| Propiedad     | Tipo                                                 | Descripción                                 |
| ------------- | ---------------------------------------------------- | ------------------------------------------- |
| `suggestions` | `Array<{categoria_sugerida: string, count: number}>` | Lista de sugerencias pendientes.            |
| `loading`     | `boolean`                                            | Muestra `Skeleton` mientras carga.          |
| `onApprove`   | `Function`                                           | Callback para aprobar una sugerencia.       |
| `onMerge`     | `Function`                                           | Callback para iniciar el proceso de fusión. |

### 💻 Ejemplo de Uso

```jsx
<PanelSugerencias
  suggestions={[
    { categoria_sugerida: 'Seguridad', count: 3 },
    { categoria_sugerida: 'Residuos', count: 5 }
  ]}
  loading={false}
  onApprove={(nombre) => console.log('Aprobar', nombre)}
  onMerge={(sug) => console.log('Fusionar', sug)}
/>
```

### 🧠 Notas

* Usa `List`, `Skeleton`, y `Paper` para una interfaz fluida.
* Incluye icono de estado vacío (`ErrorOutlineIcon`) cuando no hay sugerencias.

---

## ⚙️ Dependencias utilizadas

* **React** (`useState`, `useEffect`)
* **Material-UI (MUI)**

  * `@mui/material` → Componentes visuales (Paper, Typography, Button, etc.)
  * `@mui/icons-material` → Iconos
* **@hello-pangea/dnd** → Funcionalidad de drag & drop
* **PropTypes (opcional)** → Validación de propiedades (puede añadirse)

---

## 🧩 Integración recomendada

Estos componentes suelen integrarse en un contenedor principal como:

```jsx
<Box>
  <FormularioCrearCategoria onCreate={handleCreate} loading={isLoading} />
  <ListaCategoriasOficiales
    categories={categorias}
    loading={isLoading}
    onDragEnd={handleReorder}
    onDelete={handleDelete}
  />
  <PanelSugerencias
    suggestions={sugerencias}
    loading={isLoading}
    onApprove={handleApprove}
    onMerge={handleMerge}
  />
  <ModalFusionarSugerencia
    open={openModal}
    onClose={closeModal}
    suggestion={sugerenciaActiva}
    categories={categorias}
    onConfirm={handleConfirmMerge}
    loading={isMerging}
  />
</Box>
```




