<p align="center">
  <img src="mobile_app/assets/icons/Icon-512.png" alt="Alerta Piura Logo" width="150">
</p>

<h1 align="center">Alerta Piura: Plataforma Cívica Integral</h1>

<p align="center">
  <strong>Solución tecnológica end-to-end para la seguridad ciudadana, reporte de incidencias y gestión comunitaria.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB" alt="React">
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="Postgres">
  <img src="https://img.shields.io/badge/Socket.io-010101?style=for-the-badge&logo=socketdotio&logoColor=white" alt="Socket.io">
</p>

---

## 📋 Visión General

**Alerta Piura** es un ecosistema digital diseñado para empoderar a los ciudadanos y optimizar la respuesta de las autoridades ante incidencias urbanas y de seguridad. A través de la integración de tecnología móvil y web, la plataforma facilita la comunicación directa entre vecinos, líderes vecinales y administradores municipales.

Este proyecto destaca por su capacidad de manejar **comunicación en tiempo real**, **geolocalización avanzada** y un **motor analítico** para la toma de decisiones basada en datos.

## ✨ Funcionalidades Estrella

* **🚨 Botón SOS con Tracking:** Activación de alertas de emergencia con seguimiento de ubicación en tiempo real mediante *Background Services* y Sockets.
* **🗺️ Mapa de Calor de Incidencias:** Visualización dinámica en la web para identificar zonas críticas de delincuencia o fallos de infraestructura.
* **🛡️ Sistema de Moderación Modular:** Los líderes vecinales pueden validar, fusionar o rechazar reportes para garantizar la calidad de la información.
* **🏅 Gamificación Cívica:** Sistema de insignias y puntos para fomentar la participación ciudadana activa y responsable.
* **📊 Dashboard Analítico:** Panel web para administradores con gráficos de tendencias, reportes por distrito y métricas de rendimiento.

---

## 🏗️ Arquitectura del Ecosistema

<details>
<summary><b>📱 App Móvil (Flutter)</b></summary>

<br>

* **Tracking en segundo plano:** Implementación de servicios nativos para no perder la ubicación durante un SOS.
* **Gestión de Estado:** Uso de `ChangeNotifier` y `Providers` para una UI reactiva.
* **Mapas:** Integración con Google Maps para visualización de reportes cercanos y zonas de riesgo.
* **Suscripciones:** Módulo de suscripciones Premium integrado.

</details>

<details>
<summary><b>💻 Dashboard Web (React & Vite)</b></summary>

<br>

* **Visualización de Datos:** Gráficos avanzados (Recharts/Chart.js) para analizar la tasa de aprobación y tendencias de incidentes.
* **Gestión Operativa:** Control total sobre usuarios, roles, categorías y moderación de comentarios.
* **Real-time Admin:** Recepción de alertas de seguridad en tiempo real sin recargar la página.

</details>

<details>
<summary><b>⚙️ Backend & API (Node.js & Express)</b></summary>

<br>

* **Motor de Base de Datos:** PostgreSQL con una estructura relacional optimizada para reportes geolocalizados.
* **Sockets:** Implementación de `Socket.io` para notificaciones push instantáneas y rastreo en vivo.
* **Almacenamiento:** Gestión de evidencia multimedia (fotos) integrada con Cloudinary API.
* **Seguridad:** Autenticación robusta basada en JWT y middleware de protección de rutas.

</details>

---

## 🚀 Guía de Inicio Rápido

Para desplegar el ecosistema completo de manera local:

### 1. Requisitos Previos
* Node.js v16+
* Flutter SDK (Stable)
* PostgreSQL instalado y configurado.

### 2. Preparación del Backend
  ```bash
  cd backend
  npm install
  # Configura tu .env con las credenciales de BD y Cloudinary
  npm start

### 3. Lanzamiento del Dashboard Web
  ```Bash
  cd dashboard-web
  npm install
  npm run dev

### 4. Ejecución de la App Móvil
  ```Bash
  cd mobile_app
  flutter pub get
  flutter run

### 📈 Impacto Tecnológico

Este proyecto demuestra el dominio de un stack tecnológico completo para resolver problemas de gran escala, priorizando la experiencia de usuario y la eficiencia en el manejo de datos críticos en tiempo real.

---

Desarrollado con el compromiso de construir ciudades más seguras e inteligentes.
