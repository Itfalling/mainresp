// Offline previewer for the part-built monsters. Mirrors Roblox's rig math:
//   boneWorld(child) = boneWorld(parent) * C0 * Transform      (C1 = identity)
//   partWorld        = boneWorld(bone) * partLocal
// Modes:
//   ?m=<Id>                         interactive orbit + playback
//   ?m=<Id>&mode=sheet&views=34,side&times=0,1.5  contact sheet (rows=times, cols=views)
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';

const params = new URLSearchParams(location.search);
const id = params.get('m');
const mode = params.get('mode') || 'live';
const dataUrl = params.get('src') || `../../out/preview/${id}.json`;

// ---------- helpers ----------
function cfToMatrix(c) {
  const m = new THREE.Matrix4();
  m.set(c[3], c[4], c[5], c[0],
        c[6], c[7], c[8], c[1],
        c[9], c[10], c[11], c[2],
        0, 0, 0, 1);
  return m;
}

function studTexture() {
  const s = 64;
  const cv = document.createElement('canvas');
  cv.width = cv.height = s;
  const g = cv.getContext('2d');
  g.fillStyle = '#ffffff';
  g.fillRect(0, 0, s, s);
  // subtle panel edge
  g.strokeStyle = 'rgba(0,0,0,0.10)';
  g.lineWidth = 2;
  g.strokeRect(1, 1, s - 2, s - 2);
  // stud: shadow ring + highlight
  const cx = s / 2, cy = s / 2, r = s * 0.27;
  g.fillStyle = 'rgba(0,0,0,0.22)';
  g.beginPath(); g.arc(cx + 2.5, cy + 3, r, 0, Math.PI * 2); g.fill();
  const grad = g.createLinearGradient(cx - r, cy - r, cx + r, cy + r);
  grad.addColorStop(0, '#ffffff');
  grad.addColorStop(1, '#d4d4d4');
  g.fillStyle = grad;
  g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.fill();
  g.strokeStyle = 'rgba(0,0,0,0.18)';
  g.lineWidth = 1.5;
  g.stroke();
  const t = new THREE.CanvasTexture(cv);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 4;
  return t;
}
const STUDS = studTexture();

// Box-project UVs (1 unit = 1 stud) for any non-indexed geometry.
function boxProjectUVs(geo) {
  const pos = geo.attributes.position;
  const nrm = geo.attributes.normal;
  const uv = new Float32Array(pos.count * 2);
  for (let i = 0; i < pos.count; i++) {
    const nx = Math.abs(nrm.getX(i)), ny = Math.abs(nrm.getY(i)), nz = Math.abs(nrm.getZ(i));
    const x = pos.getX(i), y = pos.getY(i), z = pos.getZ(i);
    let u, v;
    if (nx >= ny && nx >= nz) { u = z; v = y; }
    else if (ny >= nx && ny >= nz) { u = x; v = z; }
    else { u = x; v = y; }
    uv[i * 2] = u + 0.5; uv[i * 2 + 1] = v + 0.5;
  }
  geo.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
  return geo;
}

function wedgeGeometry(sx, sy, sz) {
  const x = sx / 2, y = sy / 2, z = sz / 2;
  // Roblox WedgePart: full bottom, full back (+Z) face, slope rising from front-bottom (-Z) to back-top (+Z).
  const A = [-x, -y, -z], B = [x, -y, -z], C = [x, -y, z], D = [-x, -y, z];
  const E = [-x, y, z], F = [x, y, z];
  const tris = [
    // bottom
    A, C, B, A, D, C,
    // back (+Z)
    D, F, C, D, E, F,
    // slope
    A, B, F, A, F, E,
    // right side (+X)
    B, C, F,
    // left side (-X)
    A, E, D,
  ];
  return solidFromTris(tris);
}

// Build geometry from triangles, fixing winding so every face points outward.
function solidFromTris(tris) {
  const cen = [0, 0, 0];
  for (const v of tris) { cen[0] += v[0]; cen[1] += v[1]; cen[2] += v[2]; }
  cen.forEach((_, i) => (cen[i] /= tris.length));
  const out = [];
  for (let i = 0; i < tris.length; i += 3) {
    let [a, b, c] = [tris[i], tris[i + 1], tris[i + 2]];
    const u = [b[0] - a[0], b[1] - a[1], b[2] - a[2]], w = [c[0] - a[0], c[1] - a[1], c[2] - a[2]];
    const n = [u[1] * w[2] - u[2] * w[1], u[2] * w[0] - u[0] * w[2], u[0] * w[1] - u[1] * w[0]];
    const tc = [(a[0] + b[0] + c[0]) / 3 - cen[0], (a[1] + b[1] + c[1]) / 3 - cen[1], (a[2] + b[2] + c[2]) / 3 - cen[2]];
    if (n[0] * tc[0] + n[1] * tc[1] + n[2] * tc[2] < 0) [b, c] = [c, b];
    out.push(...a, ...b, ...c);
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute('position', new THREE.BufferAttribute(new Float32Array(out), 3));
  g.computeVertexNormals();
  return boxProjectUVs(g);
}

function cornerWedgeGeometry(sx, sy, sz) {
  const x = sx / 2, y = sy / 2, z = sz / 2;
  const A = [-x, -y, -z], B = [x, -y, -z], C = [x, -y, z], D = [-x, -y, z];
  const T = [x, y, -z];
  return solidFromTris([A, C, B, A, D, C, B, C, T, A, B, T, C, D, T, D, A, T]);
}

function boxGeometry(sx, sy, sz) {
  const g = new THREE.BoxGeometry(sx, sy, sz).toNonIndexed();
  return boxProjectUVs(g);
}

const geoCache = new Map();
function geometryFor(p) {
  const [sx, sy, sz] = p.size;
  const key = `${p.kind}:${sx}:${sy}:${sz}`;
  if (geoCache.has(key)) return geoCache.get(key);
  let g;
  switch (p.kind) {
    case 'block': g = boxGeometry(sx, sy, sz); break;
    case 'wedge': g = wedgeGeometry(sx, sy, sz); break;
    case 'cwedge': g = cornerWedgeGeometry(sx, sy, sz); break;
    case 'ball': g = new THREE.SphereGeometry(sx / 2, 28, 18); break;
    case 'ellipsoid': g = new THREE.SphereGeometry(0.5, 28, 18); g.scale(sx, sy, sz); break;
    case 'cyl': {
      const d = Math.min(sy, sz);
      g = new THREE.CylinderGeometry(d / 2, d / 2, sx, 28);
      g.rotateZ(Math.PI / 2);
      break;
    }
    default: g = boxGeometry(sx, sy, sz);
  }
  geoCache.set(key, g);
  return g;
}

const matCache = new Map();
function materialFor(p) {
  const key = `${p.mat}:${p.color}:${p.tr}:${p.studs}`;
  if (matCache.has(key)) return matCache.get(key);
  const color = new THREE.Color(p.color);
  let m;
  const transparent = p.tr > 0;
  if (p.mat === 'Neon') {
    const c = color.clone().multiplyScalar(1.7);
    m = new THREE.MeshBasicMaterial({ color: c, transparent, opacity: 1 - p.tr });
  } else if (p.mat === 'ForceField') {
    m = new THREE.MeshBasicMaterial({ color: color.clone().multiplyScalar(1.6), transparent: true, opacity: 0.35 * (1 - p.tr), blending: THREE.AdditiveBlending, depthWrite: false });
  } else if (p.mat === 'Glass') {
    m = new THREE.MeshStandardMaterial({ color, roughness: 0.05, metalness: 0.1, transparent: true, opacity: Math.min(0.55, 1 - p.tr) });
  } else {
    const metal = ['Metal', 'Foil', 'DiamondPlate', 'CorrodedMetal'].includes(p.mat);
    const shiny = ['SmoothPlastic', 'Ice', 'Glacier', 'Marble'].includes(p.mat);
    m = new THREE.MeshStandardMaterial({
      color,
      roughness: metal ? 0.35 : shiny ? 0.45 : 0.75,
      metalness: metal ? 0.6 : 0,
      map: p.studs ? STUDS : null,
      transparent, opacity: 1 - p.tr,
    });
  }
  matCache.set(key, m);
  return m;
}

// ---------- scene ----------
async function load() {
  const res = await fetch(dataUrl);
  if (!res.ok) throw new Error(`cannot load ${dataUrl}`);
  return res.json();
}

function buildRig(data, scene) {
  const bones = new Map();
  const order = [];
  for (const b of data.bones) {
    const g = new THREE.Group();
    g.matrixAutoUpdate = false;
    const rest = cfToMatrix(b.cf);
    const entry = { name: b.name, parent: b.parent, group: g, rest, c0: null, world: new THREE.Matrix4() };
    bones.set(b.name, entry);
    order.push(entry);
    scene.add(g);
  }
  for (const e of order) {
    if (e.parent) {
      const p = bones.get(e.parent);
      e.c0 = p.rest.clone().invert().multiply(e.rest);
    }
  }
  const trans = (data.anim && data.anim.trans) || {};
  const animated = [];
  for (const p of data.parts) {
    let mat = materialFor(p);
    if (trans[p.name]) { mat = mat.clone(); mat.transparent = true; }
    const mesh = new THREE.Mesh(geometryFor(p), mat);
    if (trans[p.name]) animated.push({ mesh, track: trans[p.name] });
    mesh.matrixAutoUpdate = false;
    mesh.matrix.copy(cfToMatrix(p.cf));
    mesh.castShadow = p.mat !== 'Neon' && p.tr < 0.5;
    mesh.receiveShadow = true;
    if (p.tr > 0) mesh.renderOrder = 2;
    bones.get(p.bone).group.add(mesh);
  }
  // effects (approximate)
  let lights = 0;
  for (const fx of data.effects) {
    const bone = bones.get(fx.bone);
    if (!bone) continue;
    if (fx.kind === 'light' && lights < 8) {
      lights++;
      const l = new THREE.PointLight(fx.color, Math.min(1.5, (fx.brightness || 0.8)) * 5, (fx.range || 10), 1.6);
      l.matrixAutoUpdate = false;
      l.matrix.copy(cfToMatrix(fx.cf));
      bone.group.add(l);
    } else if (fx.kind === 'emitter') {
      const n = Math.min(40, Math.max(6, Math.round((fx.rate || 8) * 1.2)));
      const pos = new Float32Array(n * 3);
      const s = fx.size || [1, 1, 1];
      const spread = fx.preset === 'glow' ? 0.6 : fx.preset === 'smoke' ? 1.6 : 1.2;
      let seed = 1;
      for (const ch of fx.name) seed = (seed * 31 + ch.charCodeAt(0)) % 9973;
      const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
      for (let i = 0; i < n; i++) {
        pos[i * 3] = (rnd() - 0.5) * s[0] * spread;
        pos[i * 3 + 1] = (rnd() - 0.2) * s[1] * spread + (fx.preset === 'ember' || fx.preset === 'fire' ? rnd() * 3 : 0);
        pos[i * 3 + 2] = (rnd() - 0.5) * s[2] * spread;
      }
      const geo = new THREE.BufferGeometry();
      geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
      const size = { glow: 1.5, smoke: 3, fire: 1.2, burst: 0.01, dust: 0.01, spark: 0.4, sparkle: 0.45 }[fx.preset] ?? 0.5;
      const mat = new THREE.PointsMaterial({ color: new THREE.Color(fx.color).multiplyScalar(fx.preset === 'smoke' ? 1 : 1.2), size, sizeAttenuation: true, transparent: true, opacity: fx.preset === 'smoke' ? 0.2 : fx.preset === 'glow' ? 0.25 : 0.8, blending: fx.preset === 'smoke' ? THREE.NormalBlending : THREE.AdditiveBlending, depthWrite: false, map: SPRITE });
      const pts = new THREE.Points(geo, mat);
      pts.matrixAutoUpdate = false;
      pts.matrix.copy(cfToMatrix(fx.cf));
      bone.group.add(pts);
    }
  }
  return { bones, order, animated };
}

const SPRITE = (() => {
  const cv = document.createElement('canvas');
  cv.width = cv.height = 64;
  const g = cv.getContext('2d');
  const grad = g.createRadialGradient(32, 32, 0, 32, 32, 32);
  grad.addColorStop(0, 'rgba(255,255,255,1)');
  grad.addColorStop(0.35, 'rgba(255,255,255,0.6)');
  grad.addColorStop(1, 'rgba(255,255,255,0)');
  g.fillStyle = grad;
  g.fillRect(0, 0, 64, 64);
  const t = new THREE.CanvasTexture(cv);
  return t;
})();

const tmp = new THREE.Matrix4();
function applyPose(rig, data, t) {
  const a = data.anim;
  const n = a.frames.length;
  const f = ((Math.floor(t * a.fps) % n) + n) % n;
  const row = a.frames[f];
  const tf = new Map();
  a.joints.forEach((name, j) => tf.set(name, row.slice(j * 12, j * 12 + 12)));
  for (const a of rig.animated || []) {
    const v = (Array.isArray(a.track) ? a.track[f] : a.track[String(f + 1)]) ?? 0;
    a.mesh.visible = v < 0.98;
    a.mesh.material.opacity = 1 - v;
  }
  for (const e of rig.order) {
    if (!e.parent) {
      e.world.copy(e.rest);
    } else {
      const p = rig.bones.get(e.parent);
      e.world.copy(p.world).multiply(e.c0);
      const c = tf.get(e.name);
      if (c) e.world.multiply(cfToMatrix(c));
    }
    e.group.matrix.copy(e.world);
    e.group.matrixWorldNeedsUpdate = true;
  }
}

function makeScene(data) {
  const scene = new THREE.Scene();
  scene.background = new THREE.Color('#9fd6ff');
  const hemi = new THREE.HemisphereLight('#e3f2ff', '#6f9a5a', 1.25);
  scene.add(hemi);
  const sun = new THREE.DirectionalLight('#fff6e6', 2.0);
  const b = data.bounds;
  const size = Math.max(b.max[0] - b.min[0], b.max[1] - b.min[1], b.max[2] - b.min[2]);
  sun.position.set(size * 0.8, size * 1.6, -size * 1.1);
  sun.castShadow = true;
  sun.shadow.mapSize.set(2048, 2048);
  const sc = sun.shadow.camera;
  sc.left = sc.bottom = -size * 1.2; sc.right = sc.top = size * 1.2;
  sc.near = 0.1; sc.far = size * 6;
  sun.shadow.bias = -0.0008;
  scene.add(sun);
  const fill = new THREE.DirectionalLight('#cfe0ff', 0.6);
  fill.position.set(-size, size * 0.5, size);
  scene.add(fill);
  // studded green ground
  const gsize = size * 8;
  const gg = new THREE.PlaneGeometry(gsize, gsize);
  gg.rotateX(-Math.PI / 2);
  const uv = gg.attributes.uv;
  for (let i = 0; i < uv.count; i++) uv.setXY(i, uv.getX(i) * gsize, uv.getY(i) * gsize);
  const ground = new THREE.Mesh(gg, new THREE.MeshStandardMaterial({ color: '#5bd34a', roughness: 0.9, map: STUDS }));
  ground.receiveShadow = true;
  scene.add(ground);
  return scene;
}

function makeRenderer(w, h) {
  const r = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  r.setPixelRatio(1);
  r.setSize(w, h);
  r.shadowMap.enabled = true;
  r.shadowMap.type = THREE.PCFSoftShadowMap;
  r.toneMapping = THREE.NeutralToneMapping;
  r.toneMappingExposure = 1.12;
  r.outputColorSpace = THREE.SRGBColorSpace;
  return r;
}

function makeComposer(renderer, scene, camera, w, h) {
  const c = new EffectComposer(renderer);
  c.setSize(w, h);
  c.addPass(new RenderPass(scene, camera));
  c.addPass(new UnrealBloomPass(new THREE.Vector2(w, h), 0.32, 0.35, 1.05));
  c.addPass(new OutputPass());
  return c;
}

const VIEWS = {
  '34': [0.85, 0.42, -1],
  front: [0, 0.18, -1],
  side: [1, 0.2, 0.02],
  back: [-0.7, 0.4, 1],
  left: [-1, 0.25, -0.15],
  top: [0.05, 1, -0.45],
  low: [0.6, 0.05, -1],
  head: [0.5, 0.1, -1],
};

function frameCamera(camera, data, view, zoom = 1, focus = null) {
  const b = data.bounds;
  const center = focus ? new THREE.Vector3(...focus) : new THREE.Vector3((b.min[0] + b.max[0]) / 2, (b.min[1] + b.max[1]) / 2, (b.min[2] + b.max[2]) / 2);
  const ext = new THREE.Vector3(b.max[0] - b.min[0], b.max[1] - b.min[1], b.max[2] - b.min[2]);
  const radius = ext.length() / 2;
  const dir = new THREE.Vector3(...(VIEWS[view] || VIEWS['34'])).normalize();
  const dist = (radius * 1.0) / Math.tan(THREE.MathUtils.degToRad(camera.fov / 2)) / zoom;
  camera.position.copy(center).addScaledVector(dir, dist);
  camera.near = dist * 0.02; camera.far = dist * 10;
  camera.lookAt(center);
  camera.updateProjectionMatrix();
}

async function sheet(data) {
  const views = (params.get('views') || '34,side').split(',');
  const cycle = data.anim.cycle;
  let times = (params.get('times') || '').split(',').filter(Boolean).map(Number);
  const nt = Number(params.get('nt') || 0);
  if (nt > 0) times = Array.from({ length: nt }, (_, i) => (cycle * i) / nt);
  if (!times.length) times = [0];
  const cols = Number(params.get('cols') || views.length);
  const cells = [];
  for (const t of times) for (const v of views) cells.push({ t, v });
  const rows = Math.ceil(cells.length / cols);
  const cw = Number(params.get('cw') || 520), ch = Number(params.get('ch') || 420);
  const zoom = Number(params.get('zoom') || 1);
  const focus = params.get('focus') ? params.get('focus').split(',').map(Number) : null;

  const renderer = makeRenderer(cw, ch);
  const scene = makeScene(data);
  const rig = buildRig(data, scene);
  const camera = new THREE.PerspectiveCamera(35, cw / ch, 0.1, 5000);
  const composer = makeComposer(renderer, scene, camera, cw, ch);

  const out = document.createElement('canvas');
  out.id = 'sheet';
  document.body.style.overflow = 'visible';
  out.width = cols * cw; out.height = rows * ch + 40;
  const g = out.getContext('2d');
  g.fillStyle = '#0e1016'; g.fillRect(0, 0, out.width, out.height);
  g.fillStyle = '#fff'; g.font = 'bold 22px system-ui';
  g.fillText(`${data.displayName}  [${data.rarity}]  parts:${data.parts.length}  joints:${data.anim.joints.length}  cycle:${cycle}s`, 12, 28);
  document.body.appendChild(out);

  cells.forEach((cell, i) => {
    applyPose(rig, data, cell.t);
    scene.updateMatrixWorld(true);
    frameCamera(camera, data, cell.v, zoom, focus);
    composer.render();
    const x = (i % cols) * cw, y = Math.floor(i / cols) * ch + 40;
    g.drawImage(renderer.domElement, x, y);
    g.fillStyle = 'rgba(0,0,0,0.55)'; g.fillRect(x, y, 150, 26);
    g.fillStyle = '#fff'; g.font = '16px system-ui';
    g.fillText(`${cell.v}  t=${cell.t.toFixed(2)}s`, x + 6, y + 18);
  });
  window.__done = true;
}

async function live(data) {
  const w = innerWidth, h = innerHeight;
  const renderer = makeRenderer(w, h);
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  document.body.appendChild(renderer.domElement);
  renderer.domElement.id = 'live';
  const scene = makeScene(data);
  const rig = buildRig(data, scene);
  const camera = new THREE.PerspectiveCamera(35, w / h, 0.1, 5000);
  frameCamera(camera, data, '34');
  const controls = new OrbitControls(camera, renderer.domElement);
  const b = data.bounds;
  controls.target.set((b.min[0] + b.max[0]) / 2, (b.min[1] + b.max[1]) / 2, (b.min[2] + b.max[2]) / 2);
  controls.update();
  const composer = makeComposer(renderer, scene, camera, w, h);
  document.getElementById('hud').innerHTML = `<b>${data.displayName}</b><br>${data.rarity} · ${data.parts.length} parts · ${data.anim.joints.length} joints`;
  const start = performance.now();
  addEventListener('resize', () => {
    renderer.setSize(innerWidth, innerHeight);
    composer.setSize(innerWidth, innerHeight);
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
  });
  renderer.setAnimationLoop(() => {
    const t = (performance.now() - start) / 1000;
    applyPose(rig, data, t);
    controls.update();
    composer.render();
  });
  window.__done = true;
}

function tagSprite(name, rarity) {
  const cv = document.createElement('canvas');
  cv.width = 512; cv.height = 160;
  const g = cv.getContext('2d');
  g.textAlign = 'center';
  g.lineJoin = 'round';
  const grads = { Divine: ['#ff8fd8', '#ffe36b', '#8dff8a', '#7fd4ff'], Cosmic: ['#7b5cff', '#ff5ce1', '#5ce1ff'], Secret: ['#ffffff', '#9aa0b4'], Mythic: ['#ff6b9a', '#ff2a4d'], Legendary: ['#ffe35c', '#ff9a1a'], Epic: ['#d07bff', '#8a3dff'] };
  const stops = grads[rarity] || ['#ffffff', '#ffffff'];
  g.font = 'bold 56px system-ui';
  const lg = g.createLinearGradient(100, 0, 412, 0);
  stops.forEach((c, i) => lg.addColorStop(i / Math.max(1, stops.length - 1), c));
  g.lineWidth = 8; g.strokeStyle = '#141414'; g.strokeText(rarity, 256, 60); g.fillStyle = lg; g.fillText(rarity, 256, 60);
  g.font = 'bold 64px system-ui';
  g.strokeText(name, 256, 135); g.fillStyle = '#fff'; g.fillText(name, 256, 135);
  const t = new THREE.CanvasTexture(cv);
  t.colorSpace = THREE.SRGBColorSpace;
  const sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: t, depthWrite: false, toneMapped: false }));
  sp.scale.set(12, 3.75, 1);
  return sp;
}

async function showcase() {
  const scene0 = await (await fetch('../../out/preview/_showcase.json')).json();
  const datas = await Promise.all(scene0.monsters.map(async (m) => (await fetch(`../../out/preview/${m.id}.json`)).json()));
  const L = scene0.length || 200;
  const fake = { bounds: { min: [-L / 2, 0, -40], max: [L / 2, 30, 40] } };
  const cw = Number(params.get('cw') || 1600), ch = Number(params.get('ch') || 900);
  const renderer = makeRenderer(cw, ch);
  document.body.appendChild(renderer.domElement);
  renderer.domElement.id = 'sheet';
  const scene = makeScene(fake);
  const rigs = [];
  scene0.monsters.forEach((m, i) => {
    const holder = new THREE.Group();
    holder.matrixAutoUpdate = false;
    holder.matrix.copy(cfToMatrix(m.cf));
    scene.add(holder);
    rigs.push({ rig: buildRig(datas[i], holder), data: datas[i] });
    const tag = tagSprite(m.name, m.rarity);
    tag.position.set(...m.tag);
    scene.add(tag);
  });
  for (const p of scene0.parts) {
    const mesh = new THREE.Mesh(boxGeometry(...p.size), materialFor({ mat: 'Plastic', color: p.color, tr: 0, studs: true }));
    mesh.matrixAutoUpdate = false;
    mesh.matrix.copy(cfToMatrix(p.cf));
    mesh.castShadow = true; mesh.receiveShadow = true;
    scene.add(mesh);
  }
  const t = Number(params.get('t') || 1.5);
  rigs.forEach(({ rig, data }, i) => applyPose(rig, data, t + i * 0.37));
  scene.updateMatrixWorld(true);
  const camera = new THREE.PerspectiveCamera(Number(params.get('fov') || 50), cw / ch, 0.5, 5000);
  const view = params.get('view') || 'aisle';
  if (view === 'aisle') { camera.position.set(-L / 2 - 10, 16, 0); camera.lookAt(-L / 6, 6, 0); }
  else if (view === 'overview') { camera.position.set(0, L * 0.45, L * 0.45); camera.lookAt(0, 0, 0); }
  else if (view.startsWith('pen')) {
    const idx = Number(view.slice(3));
    const m = scene0.monsters[idx];
    const side = m.tag[2] < 0 ? 1 : -1;
    camera.position.set(m.tag[0] + 10, 12, m.tag[2] + side * 34);
    camera.lookAt(m.tag[0], 7, m.tag[2]);
  }
  const composer = makeComposer(renderer, scene, camera, cw, ch);
  composer.render();
  window.__done = true;
}

(mode === 'showcase' ? showcase() : load().then((data) => (mode === 'sheet' ? sheet(data) : live(data)))).catch((e) => {
  document.body.innerHTML = `<pre style="color:#f66">${e.stack || e}</pre>`;
  window.__error = String(e);
  window.__done = true;
});
