/**
 * Utilities to normalize "broken" text coming from mis-encoded sources.
 *
 * Common issues we handle:
 * - Mojibake from UTF-8 decoded as Windows-1252 (e.g. "parkâ€™s", "â€“", "ðŸ˜Š")
 * - HTML entities (e.g. "&amp;", "&#39;", "&#x1F600;")
 */

const WIN1252_UNICODE_TO_BYTE: Record<number, number> = {
  0x20ac: 0x80, // €
  0x201a: 0x82, // ‚
  0x0192: 0x83, // ƒ
  0x201e: 0x84, // „
  0x2026: 0x85, // …
  0x2020: 0x86, // †
  0x2021: 0x87, // ‡
  0x02c6: 0x88, // ˆ
  0x2030: 0x89, // ‰
  0x0160: 0x8a, // Š
  0x2039: 0x8b, // ‹
  0x0152: 0x8c, // Œ
  0x017d: 0x8e, // Ž
  0x2018: 0x91, // ‘
  0x2019: 0x92, // ’
  0x201c: 0x93, // “
  0x201d: 0x94, // ”
  0x2022: 0x95, // •
  0x2013: 0x96, // –
  0x2014: 0x97, // —
  0x02dc: 0x98, // ˜
  0x2122: 0x99, // ™
  0x0161: 0x9a, // š
  0x203a: 0x9b, // ›
  0x0153: 0x9c, // œ
  0x017e: 0x9e, // ž
  0x0178: 0x9f, // Ÿ
};

function encodeWin1252(str: string): Uint8Array {
  const out = new Uint8Array(str.length);
  for (let i = 0; i < str.length; i++) {
    const code = str.charCodeAt(i);
    if (code <= 0xff) {
      out[i] = code;
      continue;
    }
    const b = WIN1252_UNICODE_TO_BYTE[code];
    out[i] = b !== undefined ? b : 0x3f; // '?'
  }
  return out;
}

function mojibakeScore(s: string): number {
  // Heuristic markers for "UTF-8 interpreted as CP1252" and broken emoji sequences.
  const re = /â€|Ã|Â|ðŸ|ï¿½|�/g;
  const matches = s.match(re);
  return matches ? matches.length : 0;
}

function tryFixMojibakeWin1252(s: string): string {
  if (!s) return s;

  // Quick prefilter to avoid touching normal strings.
  const looksBroken = /â€|Ã|Â|ðŸ|ï¿½|�/.test(s);
  if (!looksBroken) return s;

  const before = mojibakeScore(s);
  if (before === 0) return s;

  const bytes = encodeWin1252(s);
  const candidate = Buffer.from(bytes).toString('utf8');
  const after = mojibakeScore(candidate);

  // Only accept if it improves.
  if (after < before) return candidate;
  return s;
}

function decodeHtmlEntities(input: string): string {
  if (!input) return input;

  let s = input;

  // Named entities (common set)
  s = s
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&ndash;', '–')
    .replaceAll('&mdash;', '—')
    .replaceAll('&hellip;', '…');

  // Decimal numeric entities: &#39;
  s = s.replace(/&#(\d+);/g, (_, dec) => {
    const code = Number(dec);
    if (!Number.isFinite(code) || code < 0 || code > 0x10ffff) return _;
    try {
      return String.fromCodePoint(code);
    } catch {
      return _;
    }
  });

  // Hex numeric entities: &#x1F600;
  s = s.replace(/&#x([0-9a-fA-F]+);/g, (_, hex) => {
    const code = Number.parseInt(hex, 16);
    if (!Number.isFinite(code) || code < 0 || code > 0x10ffff) return _;
    try {
      return String.fromCodePoint(code);
    } catch {
      return _;
    }
  });

  return s;
}

export function normalizeText(input: string): string {
  if (!input) return input;

  // 1) Fix mojibake
  let s = tryFixMojibakeWin1252(input);

  // 2) Decode HTML entities
  s = decodeHtmlEntities(s);

  // 3) Clean up common artifacts
  s = s.replaceAll('\u00a0', ' '); // NBSP

  return s;
}

export function normalizeJsonDeep(value: unknown): unknown {
  if (typeof value === 'string') return normalizeText(value);
  if (Array.isArray(value)) return value.map(normalizeJsonDeep);
  if (value && typeof value === 'object') {
    const obj = value as Record<string, unknown>;
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(obj)) out[k] = normalizeJsonDeep(v);
    return out;
  }
  return value;
}


