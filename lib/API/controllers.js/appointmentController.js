const db = require('../db');

const createAppointment = async (req, res) => {
    const {
        apt_description,
        date,
        time,
        doctor,
        apt_notes,
        is_bookmarked,
        
    } = req.body;

    const createdBy = req.session.userId
        const updatedBy = req.session.userId
        const patientId = req.session.patientId

    try {
        const [result] = await db.query(
            `INSERT INTO appointment
        (apt_description, date, time, doctor_id, apt_notes,
         is_bookmarked, created_by, updated_by, patient_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                apt_description || null, date, time, doctor || null,
                apt_notes || null, is_bookmarked || null, createdBy, updatedBy, patientId
            ]
        );

        res.status(201).json({ message: 'Appointment created', appointment_id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create appointment' });
    }
};

const getAppointmentsByPatient = async (req, res) => {
        const patientId = req.session.patientId

    try {

        const [rows] = await db.query(
            `SELECT * FROM appointment WHERE patient_id = ? ORDER BY date DESC, time DESC`,
            [patientId]
        );

        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch appointments' });
    }
};

const updateAppointment = async (req, res) => {
    const { appointmentId } = req.params;
    const {
        apt_description,
        date,
        time,
        doctor_id,
        category,
        location,
        apt_notes,
        is_bookmarked,
    } = req.body;

        const updatedBy = req.session.userId

    try {
        const [result] = await db.query(
            `UPDATE appointment
       SET apt_description = ?, date = ?, time = ?, 
           updated_by = ?
       WHERE appointment_id = ?`,
            [
                apt_description, date, time, updatedBy, appointmentId
            ]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Appointment not found' });
        }

        res.json({ message: 'Appointment updated' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update appointment' });
    }
};

const deleteAppointment = async (req, res) => {
    const { appointmentId } = req.params;

    try {
        const [result] = await db.query(
            `DELETE FROM appointment WHERE appointment_id = ?`,
            [appointmentId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Appointment not found' });
        }

        res.json({ message: 'Appointment deleted' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete appointment' });
    }
};

module.exports = { createAppointment, getAppointmentsByPatient, updateAppointment, deleteAppointment };
