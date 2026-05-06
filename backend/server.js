const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const investRoutes = require('./routes/invest.routes');
const entrepreneurRoutes = require('./routes/entrepreneur.routes');
const prestataireRoutes = require('./routes/prestataire.routes');
const formateurRoutes = require('./routes/formateur.routes');
const chatbotRoutes = require('./routes/chatbot.routes');
const adminRoutes = require('./routes/admin.routes');
const matchingRoutes = require('./routes/matching.routes');
const messageRoutes = require('./routes/messages.routes');
const financeRoutes = require('./routes/finance.routes');
const marketplaceRoutes = require('./routes/marketplace.routes');

const app = express();
const port = process.env.PORT || 3000;

// Log all requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '50mb' }));
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/invest', investRoutes);
app.use('/api/entrepreneur', entrepreneurRoutes);
app.use('/api/prestataire', prestataireRoutes);
app.use('/api/formateur', formateurRoutes);
app.use('/api/chatbot', chatbotRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/matching', matchingRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/marketplace', marketplaceRoutes);
app.use('/api/business-plan', require('./routes/business-plan.routes'));
app.use('/api/projects-execution', require('./routes/project-execution.routes'));
app.use('/api/courses', require('./routes/course.routes'));
app.use('/api/trainer', require('./routes/trainer.routes'));
app.use('/api/forum', require('./routes/forum.routes'));

app.get('/', (req, res) => {
  res.send('NexaMa Backend API is running!');
});

app.listen(port, async () => {
  console.log(`Server is running on port ${port}`);
  
  // Diagnostic au démarrage
  try {
    const { PrismaClient } = require('@prisma/client');
    const p = new PrismaClient();
    const count = await p.projets.count();
    console.log(`--- DB CONNECTED: ${count} projects found ---`);
  } catch (err) {
    console.error('--- DB CONNECTION ERROR ---', err.message);
  }
});
