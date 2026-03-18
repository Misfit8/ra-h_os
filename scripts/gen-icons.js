// Generates PWA icons: yellow eye on black background
// Run: node scripts/gen-icons.js
const zlib = require('zlib');
const fs = require('fs');
const path = require('path');

function crc32(buf) {
  const table = [];
  for (let i = 0; i < 256; i++) {
    let c = i;
    for (let j = 0; j < 8; j++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    table[i] = c;
  }
  let crc = 0xFFFFFFFF;
  for (let i = 0; i < buf.length; i++) crc = table[(crc ^ buf[i]) & 0xFF] ^ (crc >>> 8);
  return (crc ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const typeB = Buffer.from(type);
  const crcVal = Buffer.alloc(4);
  crcVal.writeUInt32BE(crc32(Buffer.concat([typeB, data])));
  return Buffer.concat([len, typeB, data, crcVal]);
}

function pixelsToPNG(size, pixels /* RGB flat buffer */) {
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 2; // RGB

  // Build raw image data: prepend filter byte 0 to each row
  const rows = [];
  for (let y = 0; y < size; y++) {
    const row = Buffer.alloc(1 + size * 3);
    row[0] = 0; // filter: None
    pixels.copy(row, 1, y * size * 3, (y + 1) * size * 3);
    rows.push(row);
  }
  const raw = Buffer.concat(rows);
  const compressed = zlib.deflateSync(raw, { level: 9 });

  return Buffer.concat([
    sig,
    chunk('IHDR', ihdr),
    chunk('IDAT', compressed),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function makeEyeIcon(size) {
  const cx = size / 2;
  const cy = size / 2;

  // Eye lens: horizontal ellipse
  const eyeA = size * 0.40; // semi-width
  const eyeB = size * 0.22; // semi-height

  // Iris circle (filled yellow)
  const irisR = size * 0.19;

  // Pupil circle (black)
  const pupilR = size * 0.11;

  // Highlight dot (white, upper-left of pupil)
  const hlR = size * 0.035;
  const hlOff = pupilR * 0.45;

  // Yellow: #FFD700
  const Y = [255, 215, 0];
  // Black
  const B = [0, 0, 0];
  // White
  const W = [255, 255, 255];

  const pixels = Buffer.alloc(size * size * 3); // default black

  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const dx = x - cx;
      const dy = y - cy;
      const d2 = dx * dx + dy * dy;

      const inEyeLens = (dx / eyeA) ** 2 + (dy / eyeB) ** 2 <= 1;
      const inIris = d2 <= irisR * irisR;
      const inPupil = d2 <= pupilR * pupilR;
      const hlDx = dx - (-hlOff);
      const hlDy = dy - (-hlOff);
      const inHighlight = hlDx * hlDx + hlDy * hlDy <= hlR * hlR;

      const idx = (y * size + x) * 3;

      let color = B; // background
      if (inEyeLens) color = Y;
      if (inIris) color = Y;     // same yellow — iris blends with lens
      if (inPupil) color = B;    // black pupil
      if (inHighlight) color = W; // white glint

      pixels[idx]     = color[0];
      pixels[idx + 1] = color[1];
      pixels[idx + 2] = color[2];
    }
  }

  return pixelsToPNG(size, pixels);
}

const publicDir = path.join(__dirname, '../public');
fs.writeFileSync(path.join(publicDir, 'icon-192.png'), makeEyeIcon(192));
fs.writeFileSync(path.join(publicDir, 'icon-512.png'), makeEyeIcon(512));
console.log('Generated eye icons in /public');
