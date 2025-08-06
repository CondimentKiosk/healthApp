const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/users', require('./routes/users'));


app.listen(3000, () => console.log('API running on port 3000'));
