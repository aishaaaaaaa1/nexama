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
const preferredPort = Number(process.env.PORT) || 3000;
const portStrict =
  process.env.PORT_STRICT === '1' || process.env.PORT_STRICT === 'true';

function bindServer(p) {
  return new Promise((resolve, reject) => {
    const srv = app.listen(p, () => resolve({ server: srv, port: p }));
    srv.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        srv.close(() => reject(err));
      } else {
        reject(err);
      }
    });
  });
}

async function listenWithPortFallback(startPort, maxAttempts = 20) {
  const end = startPort + maxAttempts;
  for (let p = startPort; p < end; p++) {
    try {
      const result = await bindServer(p);
      if (p !== startPort) {
        console.warn(
          `[nexama] Port ${startPort} was busy — using ${p}. Stop the duplicate server or set PORT=${p} in .env if your frontend expects a fixed port.`
        );
      }
      return result;
    } catch (err) {
      if (err.code !== 'EADDRINUSE') throw err;
      if (p < end - 1) {
        console.warn(`[nexama] Port ${p} in use, trying ${p + 1}...`);
      }
    }
  }
  throw new Error(
    `No free port between ${startPort} and ${end - 1}. Set PORT_STRICT=1 and free port ${startPort}, or close other apps.`
  );
}

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

async function runStartupDbCheck() {
  try {
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();
    const count = await prisma.projets.count();
    console.log(`--- DB CONNECTED: ${count} projects found ---`);
  } catch (err) {
    console.error('--- DB CONNECTION ERROR ---', err.message);
  }
}

if (portStrict) {
  const server = app.listen(preferredPort, async () => {
    console.log(`Server is running on port ${preferredPort}`);
    await runStartupDbCheck();
  });
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(
        `Port ${preferredPort} is already in use. Stop the other process or unset PORT_STRICT to try the next free port.`
      );
      process.exit(1);
    }
    throw err;
  });
} else {
  listenWithPortFallback(preferredPort)
    .then(async ({ server, port }) => {
      console.log(`Server is running on port ${port}`);
      await runStartupDbCheck();
    })
    .catch((err) => {
      console.error(err.message || err);
      process.exit(1);
    });
}
