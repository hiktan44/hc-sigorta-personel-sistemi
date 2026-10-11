const { readFileSync, readdirSync, statSync } = require('node:fs');
const { resolve, dirname } = require('node:path');
const { Script, runInNewContext } = require('node:vm');
const assert = require('node:assert/strict');

const root = resolve(__dirname, '..');
let count = 0;
for (const file of readdirSync(root)) {
  const path = resolve(root, file);
  if (!statSync(path).isFile()) continue;
  if (file.endsWith('.js')) {
    new Script(readFileSync(path, 'utf8'), { filename: file });
    count++;
  }
  if (!file.endsWith('.html')) continue;
  const html = readFileSync(path, 'utf8');
  let inline = 0;
  for (const match of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi)) {
    const [, attrs, source] = match;
    const src = attrs.match(/\bsrc\s*=\s*["']([^"']+)["']/i)?.[1];
    if (src) {
      if (!/^(?:https?:)?\/\//i.test(src)) assert.ok(statSync(resolve(dirname(path), src)).isFile(), 'Yerel JavaScript dosyası eksik');
      continue;
    }
    const type = attrs.match(/\btype\s*=\s*["']([^"']+)["']/i)?.[1]?.toLowerCase();
    if (type && !['text/javascript', 'application/javascript'].includes(type)) {
      if (type === 'module') throw new Error('Modül script için ayrı parser kontrolü gerekiyor');
      continue;
    }
    new Script(source, { filename: `${file}:script-${++inline}` });
    count++;
  }
}
const window = {};
runInNewContext(readFileSync(resolve(root, 'supabase-entegrasyon.js'), 'utf8'), { window }, { timeout: 1000 });
const api = window.SupabaseIntegration;
assert.ok(api, 'Entegrasyon API girişi açılmadı');
for (const name of ['AuthService', 'PersonelService', 'FirmaService', 'MonthStatusService', 'ReportService']) {
  assert.equal(typeof api[name], 'object', `${name} yüklenemedi`);
  assert.ok(Object.values(api[name]).some(value => typeof value === 'function'), `${name} işlevleri eksik`);
}
assert.equal(api.getClient(), undefined, 'Kurgusal açılışta sağlayıcı bağlantısı kurulmamalı');
console.log(`${count} JavaScript ayrıştırma kontrolü ve entegrasyon açılışı geçti; dış sağlayıcı çağrısı yapılmadı.`);
