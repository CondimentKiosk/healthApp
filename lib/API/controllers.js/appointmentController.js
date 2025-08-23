const db = require('../db');

const createAppointment = async (req, res) => {
    const {
        apt_description,
        date,
        time,
        doctor,
        category_id,
        location,
        apt_notes,
        is_bookmarked,
        patient_id,
        user_id
    } = req.body;

    const createdBy = user_id;
    const updatedBy = user_id;

    try {

        // 1. Check if doctor exists
        const [existingDoctors] = await db.query(
            `SELECT doctor_id FROM doctor WHERE doctor_name = ? LIMIT 1`,
            [doctor]
        );

        let doctorId;

        if (existingDoctors.length > 0) {
            doctorId = existingDoctors[0].doctor_id;
        } else {
            const [doctorResult] = await db.query(
                `INSERT INTO doctor (doctor_name) VALUES (?)`,
                [doctor]
            );
            doctorId = doctorResult.insertId;
        }

        const [existingLocations] = await db.query(
            `SELECT location_id FROM location WHERE address_line_1 = ? LIMIT 1`,
            [location]
        );

        let locationId;

        if (existingLocations.length > 0) {
            locationId = existingLocations[0].doctor_id;
        } else {
            const [locationResult] = await db.query(
                `INSERT INTO location (address_line_1) VALUES (?)`,
                [location]
            );
            locationId = locationResult.insertId;
        }


        const [result] = await db.query(
            `INSERT INTO appointment
        (apt_description, date, time, doctor_id, category_id, location_id, apt_notes,
         is_bookmarked, created_by, updated_by, patient_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                apt_description || null, date, time, doctorId, category_id, locationId,
                apt_notes || null, is_bookmarked || null, createdBy, updatedBy, patient_id
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
    const {
        apt_description,
        date,
        time,
        doctor,
        location,
        user_id,
        appointment_id
    } = req.body;

    const appointmentId = appointment_id;
    const updatedBy = user_id;

    try {

        const [existingDoctors] = await db.query(
            `SELECT doctor_id FROM doctor WHERE doctor_name = ? LIMIT 1`,
            [doctor]
        );

        let doctorId;

        if (existingDoctors.length > 0) {
            doctorId = existingDoctors[0].doctor_id;
        } else {
            const [doctorResult] = await db.query(
                `INSERT INTO doctor (doctor_name) VALUES (?)`,
                [doctor]
            );
            doctorId = doctorResult.insertId;
        }

        const [existingLocations] = await db.query(
            `SELECT location_id FROM location WHERE address_line_1 = ? LIMIT 1`,
            [location]
        );

        let locationId;

        if (existingLocations.length > 0) {
            locationId = existingLocations[0].doctor_id;
        } else {
            const [locationResult] = await db.query(
                `INSERT INTO location (address_line_1) VALUES (?)`,
                [location]
            );
            locationId = locationResult.insertId;
        }

        const [result] = await db.query(
            `UPDATE appointment
       SET apt_description = ?, date = ?, time = ?, doctor_id = ?, location_id = ?, updated_by = ?
       WHERE appointment_id = ?`,
            [
                apt_description, date, time, doctorId, locationId, updatedBy, appointmentId
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
