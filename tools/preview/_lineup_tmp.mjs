import { chromium } from 'playwright';
import fs from 'fs';
const dir = process.argv[2];
const ids = 'GuardChicken BunnyBouncer ScarecrowSentry ThornHedgehog SnapjawFlytrap IronhornRhino BogjawGator HornetWarlord BriarRex ElderhornTitan'.split(' ');
const imgs = ids.map((i, k) => `<div><img src="data:image/png;base64,${fs.readFileSync(`${dir}/${i}_hero.png`).toString('base64')}"><b>#${k + 1}</b></div>`).join('');
const html = `<body style="margin:0;background:#111"><div id=g style="display:grid;grid-template-columns:repeat(5,416px);gap:4px;padding:4px">${imgs}</div><style>div>div{position:relative}img{width:416px;display:block}b{position:absolute;right:8px;bottom:6px;color:#fff;font:bold 30px sans-serif;text-shadow:0 0 4px #000}</style></body>`;
const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 2200, height: 1200 } });
await p.setContent(html); await (await p.$('#g')).screenshot({ path: `${dir}/Guardians_lineup.png` }); await b.close();
