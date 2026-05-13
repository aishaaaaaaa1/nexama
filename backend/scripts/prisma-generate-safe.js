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

const result = spawnSync('npx', ['prisma', 'generate'], {
  cwd: BACKEND_ROOT,
  stdio: 'inherit',
  shell: true,
});
process.exit(result.status ?? 1);
