const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const investRoutes = require('./routes/invest.routes');
const entrepreneurRoutes = require('./routes/entrepreneur.routes');
const prestataireRoutes = require('./routes/prestataire.routes');
const formateurRoutes = require('./routes/formateur.routes');
const chatbotRoutes = require('./routes/chatbot.routes');

const app = express();
const port = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/invest', investRoutes);
app.use('/api/entrepreneur', entrepreneurRoutes);
app.use('/api/prestataire', prestataireRoutes);
app.use('/api/formateur', formateurRoutes);
app.use('/api/chatbot', chatbotRoutes);

app.get('/', (req, res) => {
  res.send('NexaMa Backend API is running!');
});

app.listen(port, () => {
  console.log(`Serveur démarré sur http://localhost:${port}`);
});
