const express = require('express');
const router = express.Router();
const db = require('../db');

const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;
router.get('/', (req, res) => {
  res.send('GET /users is reachable');
});

const { PATIENT_ROLE_ID, CARER_ROLE_ID } = require('./roles');

router.post('/', async (req, res) => {

  const {
    user_name,
    age,
    birthday,
    email,
    password,
    role_id,
    hsc_number,
    patient_email
  } = req.body;
  //console.log('Incoming body:', req.body);

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const [result] = await connection.query(
      `INSERT INTO user 
      (user_name, age, birthday, email, password, role_id, hsc_number) 
      VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [user_name, age, birthday, email, hashedPassword, role_id, hsc_number]
    );
    const newUserId = result.insertId;
    const [resources] = await connection.query(`SELECT resource_id FROM resource`);

    if (role_id === PATIENT_ROLE_ID) {
      const patientPermissions = resources.map(r => [newUserId, newUserId, r.resource_id, 3]);
      await connection.query(
        `INSERT INTO user_patient_permission (guardian_id, patient_id, resource_id, access_level_id) VALUES ?`,
        [patientPermissions]
      );
    }
    const patient_email = req.body.linked_patient_email;
    if (role_id === CARER_ROLE_ID) {
      if (!patient_email) {
        throw new Error('Patient email is required to link carer');
      }

      const [[patient]] = await connection.query(
        `SELECT user_id FROM user WHERE email = ? AND role_id = ?`,
        [patient_email, PATIENT_ROLE_ID]
      );

      if (!patient) {
        throw new Error('Patient not found');
      }

      const carerPermissions = resources.map(r => [newUserId, patient.user_id, r.resource_id, 1]);

      await connection.query(
        `INSERT INTO user_patient_permission (guardian_id, patient_id, resource_id, access_level_id) VALUES ?`,
        [carerPermissions]
      );
    }

    await connection.commit();

    res.status(201).json({ message: `User '${user_name}' created`, user_id: newUserId });

  } catch (err) {
    await connection.rollback();
    console.error(err);
    res.status(400).json({ error: err.message || 'Registration failed' });
  } finally {
    connection.release();
  }
});


router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const [users] = await db.query(`SELECT user.user_id, user.email, user.password, role.role_name AS role
FROM user
JOIN role ON user.role_id = role.role_id
WHERE user.email = ?`
      , [email]);

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email' });
    }

     const user = users[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }


    const { user_id, role } = users[0];
    let patientId = user_id;

    if (role === 'carer') {
      const [rows] = await db.query(
        `SELECT patient_id 
         FROM user_patient_permission 
         WHERE guardian_id = ? 
         LIMIT 1`,
        [user_id]
      );

      if (rows.length > 0) {
        patientId = rows[0].patient_id;
      } else {
        patientId = null;
      }
    }

    res.json({
      message: 'Login successful',
      user_id,
      role,
      patient_id: patientId
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});


module.exports = router;
