# Documentación Completa - index.html (Punto de Entrada HTML)

## 📋 TABLA DE CONTENIDOS
- [Descripción General](#descripción-general)
- [Estructura HTML Completa](#estructura-html-completa)
- [Meta Tags y SEO](#meta-tags-y-seo)
- [Configuración de Viewport](#configuración-de-viewport)
- [Assets y Recursos](#assets-y-recursos)
- [Integración con React](#integración-con-react)
- [Configuración CSS Global](#configuración-css-global)
- [Optimización y Performance](#optimización-y-performance)

---

## 🎯 DESCRIPCIÓN GENERAL

### Propósito del Archivo
`index.html` es el archivo HTML principal que sirve como punto de entrada para la aplicación React. Define la estructura base, configuración de metadatos y carga los recursos esenciales.

### Características Clave
- ✅ **Estructura HTML5 estándar** con configuración en español
- ✅ **Meta tags optimizados** para SEO y responsive design
- ✅ **Configuración de PWA** (Progressive Web App)
- ✅ **Integración con React** via `main.jsx`
- ✅ **Favicon y assets** personalizados

---

## 🏗️ ESTRUCTURA HTML COMPLETA

### 📁 Archivo: `index.html`

```html
<!doctype html>
<html lang="es">
  <head>
    <!-- Configuración de caracteres y viewport -->
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" href="/logo.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Meta tags principales -->
    <title>Reporta Piura - Panel de Administración</title>
    <meta name="description" content="Panel de administración para la plataforma Reporta Piura - Sistema de reportes ciudadanos">
    
    <!-- Open Graph Meta Tags (para redes sociales) -->
    <meta property="og:title" content="Reporta Piura - Panel de Administración">
    <meta property="og:description" content="Panel de administración para la plataforma Reporta Piura - Sistema de reportes ciudadanos">
    <meta property="og:type" content="website">
    
    <!-- Twitter Card Meta Tags -->
    <meta name="twitter:card" content="summary">
    <meta name="twitter:title" content="Reporta Piura - Panel de Administración">
    <meta name="twitter:description" content="Panel de administración para la plataforma Reporta Piura - Sistema de reportes ciudadanos">
  </head>
  <body>
    <!-- Contenedor principal donde se montará la aplicación React -->
    <div id="root"></div>
    
    <!-- Punto de entrada de la aplicación React -->
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>

<!-- Codificación de caracteres -->
<meta charset="UTF-8" />

<!-- Viewport para responsive design -->
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<!-- Título de la página -->
<title>Reporta Piura - Panel de Administración</title>

<!-- Descripción para SEO -->
<meta name="description" content="Panel de administración para la plataforma Reporta Piura - Sistema de reportes ciudadanos">

<!-- Palabras clave (opcional pero recomendado) -->
<meta name="keywords" content="reporta piura, administración, reportes ciudadanos, piura, gestión">

<!-- Autor -->
<meta name="author" content="Equipo Reporta Piura">

<!-- Robots (control de indexación) -->
<meta name="robots" content="index, follow">

