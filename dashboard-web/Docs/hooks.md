# 📘 Documentación del Hook `useDebounce`

## 🧩 Ubicación del archivo



---

## 📝 Descripción general

El hook **`useDebounce`** es una función personalizada de React que **retrasa la actualización de un valor** hasta que el usuario deje de modificarlo durante un período de tiempo determinado.
Se utiliza comúnmente para **optimizar el rendimiento** en situaciones donde se realizan acciones costosas (como llamadas a una API o cálculos) cada vez que un valor cambia rápidamente, por ejemplo, al escribir en un campo de búsqueda.

---

## ⚙️ Funcionalidad principal

* Recibe un valor (`value`) y un retraso en milisegundos (`delay`).
* Retorna una versión **retrasada** del valor, que solo se actualiza cuando el valor original deja de cambiar durante el tiempo especificado.
* Usa internamente `setTimeout` y `useEffect` para manejar el temporizador y cancelar actualizaciones previas.

---

## 📥 Parámetros

| Parámetro | Tipo           | Descripción                                                              |
| --------- | -------------- | ------------------------------------------------------------------------ |
| `value`   | `T` (genérico) | El valor que se desea "retrasa" (puede ser texto, número, objeto, etc.). |
| `delay`   | `number`       | Tiempo de espera en milisegundos antes de actualizar el valor retornado. |

---

## 📤 Valor de retorno

| Retorno          | Tipo | Descripción                                                                                   |
| ---------------- | ---- | --------------------------------------------------------------------------------------------- |
| `debouncedValue` | `T`  | El valor actualizado solo después de que haya transcurrido el `delay` sin cambios en `value`. |

---

## 🧠 Ejemplo de uso

```jsx
import { useState, useEffect } from 'react';
import { useDebounce } from './hooks/useDebounce';

function Buscador() {
  const [texto, setTexto] = useState('');
  const textoDebounced = useDebounce(texto, 500);

  useEffect(() => {
    if (textoDebounced) {
      console.log('Buscando:', textoDebounced);
      // Aquí podrías llamar a una API:
      // fetch(`/api/buscar?q=${textoDebounced}`);
    }
  }, [textoDebounced]);

  return (
    <input
      type="text"
      placeholder="Buscar..."
      onChange={(e) => setTexto(e.target.value)}
    />
  );
}
```

**Resultado:**
El efecto solo se ejecuta 500 ms después de que el usuario deje de escribir, evitando múltiples llamadas innecesarias a la API.

---

## 🔄 Flujo interno del hook

1. Se inicializa un estado local `debouncedValue` con el valor inicial.
2. Cada vez que `value` o `delay` cambian:

   * Se establece un temporizador (`setTimeout`) que actualiza `debouncedValue` tras el tiempo indicado.
   * Si `value` cambia antes de que finalice el tiempo, el temporizador anterior se cancela (`clearTimeout`).
3. El hook retorna el valor más reciente solo cuando el usuario deja de interactuar por el tiempo establecido.

---

## 🧩 Dependencias principales

* **React Hooks:** `useState`, `useEffect`
* **Temporizadores de JavaScript:** `setTimeout`, `clearTimeout`

---

## 📄 Observaciones

* Ideal para campos de búsqueda, filtros dinámicos o validaciones que no deben ejecutarse con cada pulsación.
* El patrón debounce mejora la **experiencia de usuario** y reduce la **carga en el servidor**.
* Puede combinarse con otros hooks como `useMemo` o `useCallback` para mayor eficiencia.

---

