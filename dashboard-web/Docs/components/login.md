# 🔐 Módulo Login

## 📘 Descripción general
Este módulo gestiona la autenticación de administradores en el sistema Alerta Piura. Incluye el formulario de login y un panel visual ilustrativo.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `FormularioLogin.jsx` | Formulario de autenticación para administradores |
| `PanelIlustracionLogin.jsx` | Panel visual con ilustración para la página de login |

---

## 📝 FormularioLogin

### 🎯 Funcionalidades
- **Validación** de campos email y contraseña
- **Estados de carga** con spinner
- **Manejo de errores** con alertas
- **Diseño responsive** y accesible

### ⚙️ Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| `onLoginSubmit` | function | required | Callback al enviar formulario |
| `error` | string | undefined | Mensaje de error a mostrar |
| `loading` | boolean | false | Estado de carga del formulario |

### 🎨 Características de UI
- **Logo** de la aplicación
- **Iconos** en campos de entrada
- **Copyright** dinámico con año actual
- **Feedback visual** durante carga

### 💡 Uso Básico
```jsx
<FormularioLogin
  onLoginSubmit={(email, password) => handleLogin(email, password)}
  error={errorMessage}
  loading={isLoading}
/>