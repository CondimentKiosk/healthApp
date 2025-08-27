const express = require('express');
const router = express.Router();
const permissionController = require('../controllers/permissionController');
const db = require('../db');
const { getUserAccess } = require('../controllers/accessUtil');



router.put('/:userId/:patientId', permissionController.editUserAccess)
router.get('/:patientId/allUsers', permissionController.getAllPatientUsers);

router.get('/access/:userId/:patientId', async (req, res) => {
  const { userId, patientId } = req.params;
  try {
    const accessMap = await getUserAccess(userId, patientId);
    res.json(accessMap);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;
