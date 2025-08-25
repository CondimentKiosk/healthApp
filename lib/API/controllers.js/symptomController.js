const db = require("../db");

const getSymptomsByPatient = async (req, res) => {
    const patientId = req.params.patientId;
    try {
        const [rows] = await db.query(
            "SELECT symptom_id, symptom_name, is_predefined, patient_id FROM symptom WHERE is_predefined = 1 OR patient_id = ?",
            [patientId]
        );

        const formatted = rows.map(symptom => ({
            ...symptom,
            is_predefined: symptom.is_predefined === 1
        }));

        res.json(formatted);
    } catch (err) {
        console.error("Error fetching symptoms:", err);
        res.status(500).json({ error: "Failed to fetch symptoms" });
    }
};


const addSymptom = async (req, res) => {
    const {
        patient_id,
        name
    } = req.body;

    try {

        if (!patient_id || !name) {
            return res.status(400).json({ error: "patientId and name required" });
        }

       const [result] = await db.query(
            "INSERT INTO symptom (symptom_name, is_predefined, patient_id) VALUES (?, ?, ?)",
            [name, 0, patient_id]
        );

        const newSymptom = {
            symptom_id: result.insertId,
            symptom_name: name,
            is_predefined: false,
            patient_id,
        };

        res.status(201).json(newSymptom);
    } catch (err) {
        console.error("Error adding symptom:", err);
        res.status(500).json({ error: "Failed to add symptom" });
    }
};

module.exports = { getSymptomsByPatient, addSymptom };