const db = require('../db');

const editUserAccess = async (req, res) => {
  const { patientId, userId } = req.params;
  const permissions = req.body; // because Flutter sends array directly


  if (!patientId || !userId) {
    return res.status(400).json({ error: 'Invalid request body' });
  }

  try {
    for (const { resource_name, level_name } of permissions) {
      const [resourceRow] = await db.query(
        'SELECT resource_id FROM resource WHERE resource_name = ?',
        [resource_name]
      );

      if (resourceRow.length === 0) {
        return res.status(400).json({ error: `Invalid resource type: ${resource_name}` });
      }
      const resourceId = resourceRow[0].resource_id;

      const [accessRow] = await db.query(
        'SELECT access_level_id FROM access_level WHERE level_name = ?',
        [level_name]
      );

      if (accessRow.length === 0) {
        return res.status(400).json({ error: `Invalid access type: ${level_name}` });
      }
      const accessLevelId = accessRow[0].access_level_id;

      await db.query(
        `
    INSERT INTO user_patient_permission (user_id, patient_id, resource_id, access_level_id)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE access_level_id = VALUES(access_level_id)
    `,
        [userId, patientId, resourceId, accessLevelId]
      );
    }


    res.json({ message: 'Permissions updated successfully' });
  } catch (err) {
    console.error('Error updating permissions:', err);
    res.status(500).json({ error: 'Failed to edit permissions' });
  }
};

const getAllPatientUsers = async (req, res) => {
  const patientId = req.params.patientId;

  if (!patientId) {
    return res.status(400).json({ error: "Patient id missing" });
  }

  try {
    const [rows] = await db.query(
      `SELECT DISTINCT upp.user_id, u.first_name, u.last_name 
      FROM user_patient_permission upp
      JOIN user u ON upp.user_id = u.user_id
      WHERE upp.patient_id = ?`,
      [patientId]
    );
    res.json({ message: `Users for patient : ${patientId}`, users: rows });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Failed to get useres" })
  }
}

module.exports = { editUserAccess, getAllPatientUsers };