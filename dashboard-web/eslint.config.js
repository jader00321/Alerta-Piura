/**
 * @file eslint.config.js
 * @description
 * Archivo de configuración "flat config" de ESLint para el proyecto.
 *
 * Esta configuración define las reglas de linting para archivos JavaScript (js) y JSX,
 * optimizada para un proyecto de React que utiliza Vite.
 *
 * Incluye:
 * - Reglas base recomendadas de ESLint (@eslint/js).
 * - Reglas de React Hooks (eslint-plugin-react-hooks).
 * - Reglas de React Refresh (HMR) para Vite (eslint-plugin-react-refresh).
 * - Ignorados globales (directorio 'dist').
 * - Variables globales de entorno de navegador (browser globals).
 */

import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

// `defineConfig` es un helper que proporciona autocompletado y verificación de tipos
// para tu configuración.
export default defineConfig([
  // 1. Ignorados Globales
  // Define archivos o directorios que ESLint debe ignorar por completo.
  globalIgnores(['dist']), // Ignora el directorio de 'build' (producción)

  // 2. Configuración principal para archivos JS y JSX
  {
    // Aplica este bloque de configuración a los archivos que coincidan
    files: ['**/*.{js,jsx}'],

    // 'extends' aplica conjuntos de reglas predefinidos.
    // El orden es importante; las configuraciones posteriores pueden anular a las anteriores.
    extends: [
      js.configs.recommended, // Reglas base recomendadas de ESLint (ej. 'no-undef')
      reactHooks.configs['recommended-latest'], // Aplica las reglas de Hooks (ej. 'exhaustive-deps')
      reactRefresh.configs.vite, // Reglas específicas para Fast Refresh (HMR) en Vite
    ],

    // 'languageOptions' define el entorno de JavaScript
    languageOptions: {
      ecmaVersion: 2020, // Versión de ECMAScript a la que se adhiere el código
      globals: globals.browser, // Define variables globales del navegador (ej. 'window', 'document')
      parserOptions: {
        ecmaVersion: 'latest', // Usa el parser más moderno
        ecmaFeatures: { jsx: true }, // Habilita el análisis de sintaxis JSX
        sourceType: 'module', // Permite el uso de 'import'/'export'
      },
    },

    // 'rules' permite personalizar o anular reglas de 'extends'
    rules: {
      // Personalización de 'no-unused-vars':
      // Marca como error las variables no usadas, EXCEPTO aquellas
      // que comiencen con una Mayúscula o un guion bajo (ej. 'React', '_evento').
      // Útil para desestructuración de props donde no se usan todas las variables.
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
])