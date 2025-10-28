# 🔐 Documentación — `AuthContext.jsx`

## 🗂️ Ubicación
```
src/context/AuthContext.jsx
```

## 📘 Descripción general

El archivo **`AuthContext.jsx`** define el **Contexto de Autenticación** de la aplicación, utilizando la API de Context de React para manejar el estado global del usuario autenticado.

Su objetivo es proporcionar un **sistema centralizado de autenticación** basado en **JSON Web Tokens (JWT)** y mantener la conexión en tiempo real mediante **Socket.io**.

---

## ⚙️ Funcionalidad principal

- Gestiona el **inicio y cierre de sesión** del usuario administrador.  
- Verifica la **validez del token JWT** almacenado en `localStorage`.  
- Proporciona un **estado global** de autenticación accesible desde cualquier componente.  
- Controla la **conexión y desconexión de sockets** mediante `socketService`.  
- Expone un **hook personalizado** `useAuth()` para consumir el contexto fácilmente.

---

## 🧩 Componentes principales

### 1. **AuthContext**
```js
const AuthContext = createContext(null);
```
Crea el contexto principal que contendrá la información de autenticación.  
Se inicializa con `null` hasta que el proveedor lo establezca.

---

### 2. **useAuth()**
```js
export const useAuth = () => useContext(AuthContext);
```
Hook personalizado para acceder al contexto desde cualquier componente hijo.  
Permite obtener los valores y funciones del proveedor (`AuthProvider`).

**Retorna:**
- `user` → datos del usuario actual.
- `isAuthenticated` → booleano que indica si hay sesión activa.
- `loading` → indica si se está verificando el estado inicial.
- `login(token)` → función para autenticar al usuario.
- `logout()` → función para cerrar sesión.

---

### 3. **AuthProvider**
```js
export const AuthProvider = ({ children }) => { ... }
```
Proveedor del contexto de autenticación que envuelve toda la aplicación.

**Responsabilidades:**
- Verificar la validez del token JWT al cargar la app.
- Establecer el estado de autenticación global.
- Conectar y desconectar el socket según el estado de sesión.
- Renderizar los componentes hijos (`children`) solo cuando la verificación inicial ha terminado.

---

## 🔁 Ciclo de vida (useEffect)

```js
useEffect(() => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    try {
      const decoded = jwtDecode(token);
      if (decoded.exp * 1000 > Date.now()) {
        setUser(decoded.user);
        setIsAuthenticated(true);
        socketService.connect(token);
      } else {
        handleLogout();
      }
    } catch (error) {
      handleLogout();
    }
  }
  setLoading(false);
}, []);
```

- Se ejecuta **una sola vez al montar el componente**.  
- Obtiene el token del almacenamiento local.
- Si el token es válido y no ha expirado:
  - Se decodifica y se guarda el usuario.
  - Se conecta el socket con autenticación.
- Si no es válido o expiró:
  - Se ejecuta `handleLogout()` para limpiar el estado.

---

## 🔑 Métodos principales

### 🔸 `handleLogin(token)`
Guarda el token recibido, decodifica la información del usuario y establece el estado autenticado.

```js
const handleLogin = (token) => {
  localStorage.setItem('admin_token', token);
  const decoded = jwtDecode(token);
  setUser(decoded.user);
  setIsAuthenticated(true);
  socketService.connect(token);
};
```

- Guarda el token en `localStorage`.
- Decodifica el usuario desde el JWT.
- Conecta el socket con el token.

---

### 🔸 `handleLogout()`
Limpia el almacenamiento local, reinicia el estado y desconecta el socket.

```js
const handleLogout = () => {
  localStorage.removeItem('admin_token');
  setUser(null);
  setIsAuthenticated(false);
  socketService.disconnect();
};
```

---

## 🧠 Estado global expuesto
```js
const value = {
  user,
  isAuthenticated,
  loading,
  login: handleLogin,
  logout: handleLogout,
};
```

| Propiedad | Tipo | Descripción |
|------------|------|-------------|
| `user` | `Object` \| `null` | Información del usuario autenticado |
| `isAuthenticated` | `boolean` | Indica si el usuario ha iniciado sesión |
| `loading` | `boolean` | Estado de carga inicial |
| `login(token)` | `Function` | Inicia sesión con el token JWT |
| `logout()` | `Function` | Cierra sesión y desconecta el socket |

---

## 🌐 Dependencias utilizadas

| Dependencia | Descripción |
|--------------|--------------|
| `react` | Manejo de contextos, hooks (`useState`, `useEffect`, etc.) |
| `jwt-decode` | Decodifica tokens JWT para extraer datos del usuario y su expiración |
| `socketService` | Servicio que gestiona la conexión en tiempo real vía Socket.io |

---

## 📦 Integración con la aplicación

El `AuthProvider` debe envolver toda la aplicación (en `main.jsx` o `App.jsx`):

```jsx
import { AuthProvider } from './context/AuthContext';

ReactDOM.createRoot(document.getElementById('root')).render(
  <AuthProvider>
    <App />
  </AuthProvider>
);
```

Así, cualquier componente podrá acceder a `useAuth()` para conocer el estado de autenticación.

---

## 🧾 Ejemplo de uso

```jsx
import React from 'react';
import { useAuth } from '../context/AuthContext';

const UserStatus = () => {
  const { user, isAuthenticated, logout } = useAuth();

  return (
    <div>
      {isAuthenticated ? (
        <>
          <p>Bienvenido, {user?.name}</p>
          <button onClick={logout}>Cerrar sesión</button>
        </>
      ) : (
        <p>No has iniciado sesión</p>
      )}
    </div>
  );
};
```

---

## 🧩 Conclusión

El contexto de autenticación **centraliza el manejo de sesión** y facilita la interacción entre componentes que dependen del usuario autenticado.  
Además, garantiza la **sincronización con el socket** y la **persistencia del token**, mejorando la seguridad y la experiencia del usuario.

---
