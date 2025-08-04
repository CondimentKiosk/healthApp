const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', async (req, res) => {
  const [users] = await db.query('SELECT * FROM user');
  res.json(users);
});

module.exports = router;
