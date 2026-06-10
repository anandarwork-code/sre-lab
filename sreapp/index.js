const express = require('express');
const mysql = require('mysql2');
const app = express();
const db = mysql.createConnection({
        host: '192.168.122.127',
        user: 'sreapp',
        password: process.env.DB_PASSWORD,
        database: 'srelab'
});
db.connect((err) => {
        if (err) {
                console.error('DB connection failed:', err.message);
                process.exit(1);
        }
        console.log('Connected to MySQL on sre-lab sucessfully');
});
app.get('/', (req, res) => {
        res.send('sre app running')
});
app.get('/health', (req, res) => {
        db.query('SELECT 1', (err) => {
                if (err) return res.status(500).send('DB.error');
                res.send('OK-DB connected');
        });
});
app.listen(3000, () => {
        console.log('server running on port 300');
});
