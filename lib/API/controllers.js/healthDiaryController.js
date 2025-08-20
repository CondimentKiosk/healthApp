const db = require('../db');

const createHealthDiary = async (req, res) => {
    const {
        entry_date,
        entry_time,
        entry_notes,
        symptoms 
    } = req.body;

    const createdBy = req.session.userId;
    const patientId = req.session.patientId;

    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        const [diaryResult] = await conn.query(
            `INSERT INTO health_diary (entry_date, entry_time, entry_notes, entered_by, patient_id)
             VALUES (?, ?, ?, ?, ?)`,
            [entry_date, entry_time, entry_notes, createdBy, patientId]
        );
        const entryId = diaryResult.insertId;

        for (const { symptom_name, rating } of symptoms) {
            let [rows] = await conn.query(
                `SELECT symptom_id FROM symptom WHERE symptom_name = ?`,
                [symptom_name]
            );

            let symptomId;
            if (rows.length > 0) {
                symptomId = rows[0].symptom_id;
            } else {
                const [symptomResult] = await conn.query(
                    `INSERT INTO symptom (symptom_name) VALUES (?)`,
                    [symptom_name]
                );
                symptomId = symptomResult.insertId;
            }

            await conn.query(
                `INSERT INTO health_entry_symptom (entry_id, symptom_id, rating)
                 VALUES (?, ?, ?)`,
                [entryId, symptomId, rating]
            );
        }

        await conn.commit();
        res.status(201).json({ message: 'Health Diary created', entry_id: entryId });

    } catch (err) {
        await conn.rollback();
        console.error(err);
        res.status(500).json({ error: 'Failed to create health diary' });
    } finally {
        conn.release();
    }
};

const getHealthDiaryByPatient = async (req, res) => {
    const patientId = req.params.patientId;
    try {
        const [rows] = await db.query(
            `SELECT hd.entry_id, hd.entry_date, hd.entry_time, hd.entry_notes,
                    s.symptom_name, hes.rating
             FROM health_diary hd
             JOIN health_entry_symptom hes ON hd.entry_id = hes.entry_id
             JOIN symptom s ON hes.symptom_id = s.symptom_id
             WHERE hd.patient_id = ?
             ORDER BY hd.entry_date DESC, hd.entry_time DESC`,
            [patientId]
        );

        const entriesMap = new Map();

        rows.forEach(row => {
            if (!entriesMap.has(row.entry_id)) {
                entriesMap.set(row.entry_id, {
                    entry_id: row.entry_id,
                    entry_date: row.entry_date,
                    entry_time: row.entry_time,
                    entry_notes: row.entry_notes,
                    symptoms: []
                });
            }
            entriesMap.get(row.entry_id).symptoms.push({
                symptom_name: row.symptom_name,
                rating: row.rating
            });
        });

        const nestedResult = Array.from(entriesMap.values());
        res.json(nestedResult);

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch health diary' });
    }
};

const deleteHealthDiary = async (req, res) => {
    const { healthDiaryId } = req.params;

    try {
        const [result] = await db.query(
            `DELETE FROM health_diary WHERE entry_id = ?`,
            [healthDiaryId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Health Diary not found' });
        }

        res.json({ message: 'Health Diary deleted' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete health diary' });
    }
};

module.exports = { createHealthDiary, getHealthDiaryByPatient, deleteHealthDiary };
