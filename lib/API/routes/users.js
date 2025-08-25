const express = require('express');
const router = express.Router();
const db = require('../db');

const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;
router.get('/', (req, res) => {
  res.send('GET /users is reachable');
});

const { PATIENT_ROLE_ID, CARER_ROLE_ID } = require('./roles');
const getUserAccess = require('./permissions');

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
        `INSERT INTO user_patient_permission (user_id, patient_id, resource_id, access_level_id) VALUES ?`,
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
        `INSERT INTO user_patient_permission (user_id, patient_id, resource_id, access_level_id) VALUES ?`,
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
    const [users] = await db.query(`
      SELECT user.user_id, user.email, user.password, role.role_name AS role
      FROM user
      JOIN role ON user.role_id = role.role_id
      WHERE user.email = ?
    `, [email]);


    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email' });
    }

    const user = users[0];

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    let patientId = user.user_id; // default

    if (user.role === 'carer') {
      const [rows] = await db.query(`
        SELECT patient_id 
        FROM user_patient_permission
        WHERE user_id = ?
        LIMIT 1
      `, [user.user_id]);


      patientId = rows.length > 0 ? rows[0].patient_id : null;
    }

    req.session.userId = user.user_id;
    req.session.patientId = patientId;

    // optional: comment this out if AccessRights is still noisy
    let access = {};
    try {
      if (patientId) {
        access = await getUserAccess(user.user_id, patientId);
      }
    } catch (accessErr) {
    }

    res.json({
      message: 'Login successful',
      user_id: user.user_id,
      role: user.role,
      patient_id: patientId,
      access,
    });

  } catch (err) {
    res.status(500).json({ error: 'Login failed' });
  }
});


module.exports = router;
