const db = require('../db');



const createMedication = async (req, res) => {
    const {
        med_name,
        dosage,
        times_per,
        frequency_type,
        medication_type,
        current_stock,
        low_stock_alert,
        notes
    } = req.body;

    const createdBy = req.session.userId
const updatedBy = req.session.userId
const patientId = req.session.patientId

    try {

        const [freqType] = await db.query(
            `SELECT frequency_type_id FROM frequency_type WHERE type_name = ?`,
            [frequency_type]
        );
        if (freqType.length === 0) {
            return res.status(400).json({ error: `Invalid frequency type: ${frequency_type}` });
        }
        const frequency_type_id = freqType[0].frequency_type_id;

        const [medType] = await db.query(
            `SELECT medication_type_id FROM medication_type WHERE type_name = ?`,
            [medication_type]
        );
        if (medType.length === 0) {
            return res.status(400).json({ error: `Invalid medication type: ${medication_type}` });
        }
        const medication_type_id = medType[0].medication_type_id;




        const [result] = await db.query(
            `INSERT INTO medication
            (med_name, dosage, times_per, frequency_type_id, medication_type_id,
            current_stock, low_stock_alert, notes, created_by, updated_by, patient_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                med_name, dosage, times_per, frequency_type_id, medication_type_id,
                current_stock, low_stock_alert, notes || null, createdBy, updatedBy, patientId
            ]
        );

        res.status(201).json({ message: 'Medication Created', medication_id: result.insertId });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create medication' });


    }
};

const getMedicationsByPatient = async (req, res) => {

const patientId = req.params.patientId
    try {

        const [rows] = await db.query(
            `SELECT * FROM medication WHERE patient_id = ?`,
            [patientId]
        );

        res.json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch medications' });
    }
};

const updateMedication = async (req, res) => {
    
    const {
        med_name,
        dosage,
        times_per,
        frequency_type,
        medication_type,
        current_stock,
        low_stock_alert,
        notes
    } = req.body;

        const updatedBy = req.session.userId; 
    const patientId = req.session.patientId; 
    const medicationId = req.params.medicationId;


    try {
        const [freqType] = await db.query(
            `SELECT frequency_type_id FROM frequency_type WHERE type_name = ?`,
            [frequency_type]
        );
        if (freqType.length === 0) {
            return res.status(400).json({ error: `Invalid frequency type: ${frequency_type}` });
        }
        const frequency_type_id = freqType[0].frequency_type_id;

        const [medType] = await db.query(
            `SELECT medication_type_id FROM medication_type WHERE type_name = ?`,
            [medication_type]
        );
        if (medType.length === 0) {
            return res.status(400).json({ error: `Invalid medication type: ${medication_type}` });
        }
        const medication_type_id = medType[0].medication_type_id;

        const [result] = await db.query(
            `UPDATE medication
            SET med_name = ?, dosage =?, times_per =?, frequency_type_id =?, medication_type_id =?,
            current_stock =? , low_stock_alert=?, notes=?, updated_by=?, patient_id=? 
            WHERE medication_id = ?`,
            [
            med_name, dosage, times_per, frequency_type_id, medication_type_id,
            current_stock, low_stock_alert, notes || null, updatedBy, patientId, medicationId
            ]
        );
        res.json({ message: 'Medication updated', medication_id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update medication' });
    }
};

const deleteMedication = async (req, res) => {
    const { medicationId } = req.params;

    try {
        const [result] = await db.query(
            `DELETE FROM medication WHERE medication_id = ?`,
            [medicationId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Medication not found' });
        }

        res.json({ message: 'Medication deleted' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete medication' });
    }
};

module.exports = {createMedication, getMedicationsByPatient, updateMedication, deleteMedication}