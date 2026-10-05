// Render preview contact sheets with headless Chromium.
//   node tools/preview/shoot.mjs <Id> [<Id> ...]          default sheets
//   node tools/preview/shoot.mjs <Id> --views=34,side --times=0,1 --name=custom --zoom=1.5
// Writes out/shots/<Id>_<name>.png
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
let chromium;
try { ({ chromium } = require('playwright')); }
catch { ({ chromium } = require('/opt/node22/lib/node_modules/playwright')); }

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const outDir = path.join(root, 'out/shots');
fs.mkdirSync(outDir, { recursive: true });

const args = process.argv.slice(2);
const ids = args.filter((a) => !a.startsWith('--'));
const opt = Object.fromEntries(args.filter((a) => a.startsWith('--')).map((a) => { const [k, v] = a.slice(2).split('='); return [k, v ?? '1']; }));

const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.png': 'image/png' };
const server = http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  const file = path.join(root, url);
  if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'Content-Type': MIME[path.extname(file)] || 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const port = server.address().port;

const browser = await chromium.launch({
  executablePath: fs.existsSync('/opt/pw-browsers/chromium') ? undefined : undefined,
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});

const SHOWCASE = ids[0] === '_showcase';
const SHEETS = SHOWCASE
  ? (opt.view || 'aisle,overview').split(',').map((v) => ({ name: v, q: { mode: 'showcase', view: v, t: opt.t || '1.5', cw: opt.cw || '1600', ch: opt.ch || '900' } }))
  : opt.views || opt.times || opt.nt
  ? [{ name: opt.name || 'custom', q: { views: opt.views || '34', times: opt.times || '', nt: opt.nt || '', cols: opt.cols || '', zoom: opt.zoom || '1', focus: opt.focus || '', cw: opt.cw || '', ch: opt.ch || '' } }]
  : [
      { name: 'views', q: { views: '34,front,side,back', times: '0', cols: '2', cw: '640', ch: '520' } },
      { name: 'motion', q: { views: '34', nt: '8', cols: '4', cw: '440', ch: '380' } },
    ];

let failed = 0;
for (const id of ids) {
  for (const sh of SHEETS) {
    const q = new URLSearchParams({ m: id, mode: 'sheet', ...Object.fromEntries(Object.entries(sh.q).filter(([, v]) => v)) });
    if (SHOWCASE) q.delete('m');
    const page = await browser.newPage({ viewport: { width: 2600, height: 2000 } });
    const errors = [];
    page.on('pageerror', (e) => errors.push(String(e)));
    page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
    await page.goto(`http://127.0.0.1:${port}/tools/preview/viewer.html?${q}`);
    await page.waitForFunction(() => window.__done === true, null, { timeout: 180000 });
    const err = await page.evaluate(() => window.__error);
    if (err || errors.length) { console.log(`[${id}] errors:`, err || '', errors.join('\n')); failed++; }
    const el = await page.$('#sheet');
    const file = path.join(outDir, `${id}_${sh.name}.png`);
    if (el) {
      await el.screenshot({ path: file });
      console.log(`wrote ${path.relative(root, file)}`);
    }
    await page.close();
  }
}
await browser.close();
server.close();
process.exit(failed ? 1 : 0);
