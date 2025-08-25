
const express = require('express');
const session = require('express-session');
const cors = require('cors');
const { loadRoleIds } = require('./routes/roles');

(async () => {
    try {
        await loadRoleIds();

        const app = express();
        app.use(cors());
        app.use(express.json());

        app.use(
            session({
                secret: 'secretSessionKey',      
                resave: false,
                saveUninitialized: true,
                cookie: { secure: false },
            })
        );

        app.use('/users', require('./routes/users'));
        app.use('/permissions', require('./routes/permissions'));
        app.use('/appointments', require('./routes/appointmentRoutes'));
        app.use('/medications', require('./routes/medicationRoutes'));
        app.use('/health', require('./routes/healthDiaryRoutes'));
        app.use('/symptoms', require('./routes/symptomRoutes'));

        const PORT = 4000;
        app.listen(PORT, '0.0.0.0', () => console.log(`API running on port ${PORT}`));

    } catch (err) {
        console.error('Failed to load roles:', err);
        process.exit(1);
    }
})();

