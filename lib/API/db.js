const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  user: 'your_db_user',
  password: 'your_db_pass',
  database: 'your_db_name',
});

module.exports = pool;
