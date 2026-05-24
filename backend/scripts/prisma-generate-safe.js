/**
 * Windows: prisma generate fails with EPERM when Node still loads
 * query_engine-windows.dll.node (e.g. npm run dev). This stops listeners
 * on the backend port range, then runs prisma generate.
 */
const { execSync, spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const BACKEND_ROOT = path.resolve(__dirname, '..');
const envPath = path.join(BACKEND_ROOT, '.env');
let startPort = 3000;
if (fs.existsSync(envPath)) {
  const m = fs.readFileSync(envPath, 'utf8').match(/^\s*PORT\s*=\s*(\d+)/m);
  if (m) startPort = parseInt(m[1], 10) || 3000;
}

const PORT_ATTEMPTS = 22;
const ports = Array.from({ length: PORT_ATTEMPTS }, (_, i) => startPort + i);

function killListenersOnPort(port) {
  try {
    const out = execSync(`netstat -ano | findstr :${port}`, {
      encoding: 'utf8',
      windowsHide: true,
    });
    const pids = new Set();
    for (const line of out.split(/\r?\n/)) {
      if (!line.includes('LISTENING')) continue;
      const parts = line.trim().split(/\s+/);
      const pid = parts[parts.length - 1];
      if (pid && /^\d+$/.test(pid)) pids.add(pid);
    }
    for (const pid of pids) {
      try {
        execSync(`taskkill /PID ${pid} /F`, {
          stdio: 'ignore',
          windowsHide: true,
        });
      } catch {
        /* ignore */
      }
    }
  } catch {
    /* no netstat match */
  }
}

console.log(
  '[prisma-generate-safe] Freeing ports %s–%s (stop npm run dev if you prefer Ctrl+C first)',
  ports[0],
  ports[ports.length - 1]
);
for (const p of ports) killListenersOnPort(p);

// Use project-local Prisma (avoids npx downloading Prisma 7+ into npm-cache when disk is tight).
const prismaCli = path.join(BACKEND_ROOT, 'node_modules', 'prisma', 'build', 'index.js');
if (!fs.existsSync(prismaCli)) {
  console.error(
    '[prisma-generate-safe] Prisma not installed. From backend folder run:\n' +
      '  npm install\n' +
      '  npm run prisma:generate'
  );
  process.exit(1);
}

const result = spawnSync(process.execPath, [prismaCli, 'generate'], {
  cwd: BACKEND_ROOT,
  stdio: 'inherit',
  env: process.env,
});
process.exit(result.status ?? 1);
