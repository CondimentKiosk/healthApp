const express = require('express');
const router = express.Router();
const healthDiaryController = require('../controllers/healthDiaryController');

router.post('/', healthDiaryController.createHealthDiary);

router.get('/:patientId', healthDiaryController.getHealthDiaryByPatient);

router.delete('/:healthDiaryId', healthDiaryController.deleteHealthDiary);

module.exports=router;