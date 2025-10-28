# 📘 Documentación externa de `App.jsx`

## 🧩 Ubicación del archivo
`/src/App.jsx`

---

## 📝 Descripción general
El archivo **`App.jsx`** es el punto central de la aplicación React, responsable de configurar el **enrutamiento**, el **tema visual (MUI)** y la **autenticación**.  
En él se integran tres pilares fundamentales del proyecto:

1. **`react-router-dom`** para la navegación entre páginas.  
2. **`ThemeProvider`** de Material UI para el tema global.  
3. **`AuthProvider`** para la gestión del estado de autenticación (login/logout).

Este archivo define cómo se renderiza la aplicación según el estado del usuario (autenticado o no) y garantiza una transición fluida entre el inicio de sesión y las páginas internas protegidas.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Enrutamiento principal** | Define las rutas públicas (`/login`) y protegidas (`/*`). |
| **Protección de rutas** | Usa el contexto de autenticación (`useAuth`) para determinar si el usuario puede acceder a determinadas vistas. |
| **Tema global MUI** | Aplica el tema visual definido en `theme.js` a toda la app. |
| **Gestión de carga (`loading`)** | Muestra un spinner de carga mientras se verifica el token de sesión. |

---

## 🧩 Componentes definidos

### 1. **ProtectedRoute**
Componente auxiliar que **restringe el acceso** a rutas privadas.

#### 🔧 Lógica interna:
- Muestra un spinner (`CircularProgress`) mientras se valida el token.
- Si el usuario **no está autenticado**, redirige automáticamente a `/login`.
- Si está autenticado, renderiza los componentes hijos protegidos.

### 2. **AuthConsumer**
Componente de orden superior que **consume el contexto de autenticación** (`useAuth`) y permite pasar su estado a través de una función `children`.

#### 🧠 Patrón utilizado:
Render prop pattern → `{({ isAuthenticated, loading }) => (...)}`  
Esto permite mostrar diferentes vistas dependiendo del estado de autenticación.

### 3. **App**
El componente raíz de la aplicación.

#### 🔧 Responsabilidades:
- Configurar `ThemeProvider` y `CssBaseline` (para aplicar estilos globales de MUI).
- Iniciar `BrowserRouter` para el manejo de rutas.
- Proveer el contexto de autenticación con `AuthProvider`.
- Renderizar condicionalmente:
  - Pantalla de carga (mientras se verifica la sesión).
  - Página de login (`LoginPage`).
  - Panel principal protegido (`DashboardLayout`).

---

## 🗺️ Estructura de enrutamiento

| Ruta | Tipo | Descripción |
|------|------|--------------|
| `/login` | Pública | Permite al usuario iniciar sesión. Si ya está autenticado, redirige automáticamente al dashboard. |
| `/*` | Protegida | Agrupa todas las vistas internas dentro de `DashboardLayout` (Resumen, Usuarios, Reportes, etc.). |

### 📂 Rutas internas dentro del Dashboard
Las siguientes páginas están integradas en `DashboardLayout`:
- `PaginaResumen`
- `PaginaUsuarios`
- `PaginaCategorias`
- `ModerationPage`
- `PaginaReportes`
- `PaginaAlertasSOS`
- `PaginaAnalisis`
- `PaginaRegistroSms`
- `PaginaHistorialNotificaciones`

---

## 🧠 Flujo general del componente

1. Se monta `App` y se inicializa el contexto de autenticación.
2. Mientras `AuthContext` verifica el token JWT:
   - Muestra un **spinner de carga** (pantalla centrada con `CircularProgress`).
3. Si el usuario **no está autenticado**, se redirige a `/login`.
4. Si el usuario **está autenticado**, se renderiza `DashboardLayout` con las páginas internas protegidas.

---

## 📦 Dependencias utilizadas
| Librería | Uso principal |
|-----------|----------------|
| `react-router-dom` | Manejo de rutas, redirecciones y navegación. |
| `@mui/material` | Diseño visual, tema y componentes UI. |
| `@mui/icons-material` | Iconografía de Material Design (no usada directamente aquí, pero en subcomponentes). |
| `AuthContext` | Manejo de sesión y autenticación global. |

---

## 🧩 Ejemplo de flujo lógico simplificado

```jsx
if (loading) {
  return <Spinner />;
}

if (!isAuthenticated) {
  return <Navigate to="/login" />;
}

return <DashboardLayout />;
```

---

## 📄 Observaciones
- El **sistema de protección de rutas** asegura que ninguna página interna se cargue sin autenticación previa.
- El componente `ProtectedRoute` se deja definido por claridad, aunque en esta versión no se usa directamente (la protección se maneja dentro de `Route`).
- Las animaciones de carga mejoran la experiencia del usuario durante la verificación inicial del token.

