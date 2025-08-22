const express = require('express');
const router = express.Router();
const db = require('../db');

async function getUserAccess(userId, patientId) {
  console.log('Fetching access for:', userId, patientId);

  const query = `
    SELECT r.resource_name, a.level_name
    FROM user_patient_permission upp
    LEFT JOIN resource r ON upp.resource_id = r.resource_id
    LEFT JOIN access_level a ON upp.access_level_id = a.access_level_id
    WHERE upp.user_id = ? AND upp.patient_id = ?;
  `;

  const [rows] = await db.query(query, [userId, patientId]);
  console.log('DB rows:', rows);

  const accessMap = {};
  rows.forEach(row => {
    accessMap[row.resource_name] = row.level_name;
  });

  return accessMap;
}

module.exports = getUserAccess;
