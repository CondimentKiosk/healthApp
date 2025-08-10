
const db = require('../db');

let PATIENT_ROLE_ID = null;
let CARER_ROLE_ID = null;

async function loadRoleIds() {
    const [rows] = await db.query(`SELECT role_id, role_name FROM role`);

    for (const row of rows) {
        if (row.role_name.toLowerCase() === 'patient') {
            PATIENT_ROLE_ID = row.role_id;
        } else if (row.role_name.toLowerCase() === 'carer') {
            CARER_ROLE_ID = row.role_id;
        }
    }

    if (!PATIENT_ROLE_ID || !CARER_ROLE_ID) {
        throw new Error('Missing required roles in database');
    }
}

module.exports = {
    loadRoleIds,
    get PATIENT_ROLE_ID() { return PATIENT_ROLE_ID; },
    get CARER_ROLE_ID() { return CARER_ROLE_ID; }
};
