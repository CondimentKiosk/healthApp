const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');

router.post('/', medicationController.createMedication);

router.get('/:patientId', medicationController.getMedicationsByPatient);

router.put('/:medicationId', medicationController.updateMedication);

router.delete('/:medicationId', medicationController.deleteMedication);

module.exports=router;