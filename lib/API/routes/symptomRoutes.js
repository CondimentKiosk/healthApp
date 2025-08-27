const express = require('express');
const router = express.Router();
const symptomController = require('../controllers/symptomController');

router.post('/', symptomController.addSymptom);

router.get('/:patientId', symptomController.getSymptomsByPatient);

module.exports=router;