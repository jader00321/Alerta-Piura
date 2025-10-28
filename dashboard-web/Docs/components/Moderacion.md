# ⚖️ Módulo Moderación

## 📘 Descripción general
Este módulo gestiona la moderación de contenido y usuarios en el sistema. Incluye paneles para comentarios reportados, historial de moderación y usuarios reportados.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `PanelComentariosReportados.jsx` | Moderación de comentarios reportados por usuarios |
| `PanelHistorialModeracion.jsx` | Historial de acciones de moderación realizadas |
| `PanelUsuariosReportados.jsx` | Gestión de usuarios reportados por la comunidad |

---

## 💬 PanelComentariosReportados

### 🎯 Funcionalidades
- **Listar** comentarios reportados con motivos
- **Desestimar** reportes injustificados
- **Eliminar** comentarios inapropiados
- **Feedback visual** durante acciones

### ⚙️ Estados
- `reportedComments`: Lista de comentarios reportados
- `isLoading`: Estado de carga inicial
- `isResolving`: Estado durante resolución de reportes
- `error`: Mensajes de error

### 🎨 Características UI
- **Layout vertical** con Stack
- **Comentario destacado** con borde de error
- **Botones de acción** alineados a la derecha
- **Estados de deshabilitación** durante acciones

### 💡 Acciones Disponibles
```javascript
// Desestimar reporte (mantener comentario)
handleResolve(reportId, 'desestimar')

// Eliminar comentario reportado
handleResolve(reportId, 'eliminar_comentario')