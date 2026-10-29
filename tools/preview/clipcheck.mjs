// Report how far each monster dips below the ground (Y=0) across its baked loop.
//   node tools/preview/clipcheck.mjs [Id ...]   (default: every out/preview/*.json)
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const dir = path.join(root, 'out/preview');
let ids = process.argv.slice(2);
if (!ids.length) ids = fs.readdirSync(dir).filter((f) => f.endsWith('.json') && !f.startsWith('_')).map((f) => f.slice(0, -5));

// 3x4 affine matrices as [r00..r22, x, y, z] using Roblox component order.
const fromCF = (c) => ({ x: c[0], y: c[1], z: c[2], r: c.slice(3, 12) });
function mul(a, b) {
  const r = new Array(9);
  for (let i = 0; i < 3; i++) for (let j = 0; j < 3; j++) r[i * 3 + j] = a.r[i * 3] * b.r[j] + a.r[i * 3 + 1] * b.r[3 + j] + a.r[i * 3 + 2] * b.r[6 + j];
  return { r, x: a.r[0] * b.x + a.r[1] * b.y + a.r[2] * b.z + a.x, y: a.r[3] * b.x + a.r[4] * b.y + a.r[5] * b.z + a.y, z: a.r[6] * b.x + a.r[7] * b.y + a.r[8] * b.z + a.z };
}
function inv(a) {
  const r = [a.r[0], a.r[3], a.r[6], a.r[1], a.r[4], a.r[7], a.r[2], a.r[5], a.r[8]];
  return { r, x: -(r[0] * a.x + r[1] * a.y + r[2] * a.z), y: -(r[3] * a.x + r[4] * a.y + r[5] * a.z), z: -(r[6] * a.x + r[7] * a.y + r[8] * a.z) };
}

for (const id of ids) {
  const d = JSON.parse(fs.readFileSync(path.join(dir, id + '.json'), 'utf8'));
  if (!Array.isArray(d.anim.joints)) d.anim.joints = [];
  d.anim.frames = (Array.isArray(d.anim.frames) ? d.anim.frames : []).map((r) => (Array.isArray(r) ? r : []));
  if (!d.anim.frames.length) d.anim.frames = [[]];
  const bones = new Map();
  for (const b of d.bones) bones.set(b.name, { ...b, rest: fromCF(b.cf) });
  for (const b of bones.values()) if (b.parent) b.c0 = mul(inv(bones.get(b.parent).rest), b.rest);
  const parts = d.parts.filter((p) => p.tr < 0.95);
  const jIdx = new Map(d.anim.joints.map((n, i) => [n, i]));
  let worst = Infinity, worstT = 0, worstPart = '';
  d.anim.frames.forEach((row, f) => {
    const world = new Map();
    for (const b of d.bones) {
      const e = bones.get(b.name);
      let w;
      if (!e.parent) w = e.rest;
      else {
        w = mul(world.get(e.parent), e.c0);
        const j = jIdx.get(e.name);
        if (j !== undefined) w = mul(w, fromCF(row.slice(j * 12, j * 12 + 12)));
      }
      world.set(b.name, w);
    }
    for (const p of parts) {
      const w = mul(world.get(p.bone), fromCF(p.cf));
      const [sx, sy, sz] = p.size;
      const hy = Math.abs(w.r[3]) * sx / 2 + Math.abs(w.r[4]) * sy / 2 + Math.abs(w.r[5]) * sz / 2;
      const low = w.y - hy;
      if (low < worst) { worst = low; worstT = f / d.anim.fps; worstPart = `${p.bone}`; }
    }
  });
  const flag = worst < -0.6 ? 'CLIPS' : 'ok';
  console.log(`${flag.padEnd(6)}${id.padEnd(24)} lowest ${worst.toFixed(2)} at t=${worstT.toFixed(2)}s (bone ${worstPart})`);
}
