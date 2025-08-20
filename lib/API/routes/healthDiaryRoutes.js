const express = require('express');
const router = express.Router();
const healthDiaryController = require('../controllers.js/healthDiaryController');

router.post('/', healthDiaryController.createHealthDiary);

router.get('/:carerId/:patientId', healthDiaryController.getHealthDiaryByPatient);

router.delete('/:healthDiaryId', healthDiaryController.deleteHealthDiary);

module.exports=router;