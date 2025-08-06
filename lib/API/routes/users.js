const express = require('express');
const router = express.Router();
const db = require('../db');

const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;

router.post('/', async (req, res) => {
  const {
    user_name,
    age,
    birthday,
    email,
    password,
    role_id,
    access_type_id,
    hsc_number
  } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const [result] = await db.query(
      `INSERT INTO user 
      (user_name, age, birthday, email, password, role_id, access_type_id, hsc_number) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [user_name, age, birthday, email, hashedPassword, role_id, access_type_id, hsc_number]
    );

    const newUserId = result.insertId;

    res.status(201).json({ message: `User '${newUserId.user_name}' created` , user_id: newUserId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error occurred while registering' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const [users] = await db.query('SELECT * FROM user WHERE email = ?', [email]);

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email' });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid password' });
    }

    res.json({
      message: 'Login successful',
      user_id: user.user_id,
      role_id: user.role_id,
      access_type_id: user.access_type_id,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});


module.exports = router;
