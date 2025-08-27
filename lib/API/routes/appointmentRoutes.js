const express = require('express');
const router = express.Router();
const appointmentController = require('../controllers/appointmentController');

router.post('/', appointmentController.createAppointment);

router.get('/:patientId', appointmentController.getAppointmentsByPatient);

router.put('/:appointmentId', appointmentController.updateAppointment);

router.delete('/:appointmentId', appointmentController.deleteAppointment);

module.exports = router;
