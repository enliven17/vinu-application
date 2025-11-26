const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'db',
    database: process.env.DB_NAME || 'myapp',
    password: process.env.DB_PASSWORD || 'password',
    port: 5432,
});

// Wait for DB to be ready
const connectWithRetry = () => {
    pool.query('SELECT NOW()', (err, res) => {
        if (err) {
            console.log('Database connection failed, retrying in 5 seconds...', err.message);
            setTimeout(connectWithRetry, 5000);
        } else {
            console.log('Database connected successfully');
            createTable();
        }
    });
};

const createTable = () => {
    pool.query(`
        CREATE TABLE IF NOT EXISTS messages (
            id SERIAL PRIMARY KEY,
            content TEXT NOT NULL
        );
    `, (err, res) => {
        if (err) {
            console.error('Error creating table', err);
        } else {
            console.log('Table created or already exists');
            // Seed data if empty
            pool.query('SELECT COUNT(*) FROM messages', (err, res) => {
                if (!err && res.rows[0].count == 0) {
                    pool.query("INSERT INTO messages (content) VALUES ('Hello from the Database!')");
                }
            });
        }
    });
};

connectWithRetry();

app.get('/', (req, res) => {
    res.send('Hello from Backend!');
});

app.get('/api/message', async (req, res) => {
    try {
        const result = await pool.query('SELECT content FROM messages LIMIT 1');
        if (result.rows.length > 0) {
            res.json({ message: result.rows[0].content });
        } else {
            res.json({ message: 'No messages found' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});

app.listen(port, () => {
    console.log(`Backend listening at http://localhost:${port}`);
});
