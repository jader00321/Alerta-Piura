const { Pool } = require('pg');
require('dotenv').config();

// Creamos un "pool" de conexiones a la base de datos.
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Exportamos un objeto con dos métodos:
module.exports = {
  // 1. La función 'query' para consultas simples (como la usábamos antes).
  query: (text, params) => pool.query(text, params),
  
  // 2. La función 'getClient' para manejar transacciones más complejas.
  //    Esta era la función que faltaba.
  getClient: () => pool.connect(),
};