# HC Sigorta JavaScript düzeltmesi

F101: Üç servis bildirimi yorum satırına yapıştığından supabase-entegrasyon.js ayrıştırılamıyordu. Yorum ile bildirim arasındaki satır sonları geri kondu. İş kuralları ve veritabanı işlemleri değiştirilmedi.

Kontrol betiği bağımsız JavaScript dosyalarını ve HTML içindeki klasik script bloklarını Node'un gerçek JavaScript parser'ıyla kontrol eder. Entegrasyon script'i kurgusal window nesnesinde yüklenir; beş servis dışa aktarımı ve henüz bağlantı kurulmamış istemci doğrulanır. Sağlayıcı SDK'sı, canlı veritabanı, personel/maaş verisi veya tarayıcı özellikleri çalıştırılmaz.

GitHub Actions aynı kontrolü taslak PR ve codex dallarında çalıştırır. Mevcut Pages işi yalnız master dalına push ile çalışır; taslak PR bir Pages dağıtımı başlatmaz. Bu çalışma master/Coolify/Pages dağıtımını değiştirmedi.

Eski sabit GitHub kaynağı node --check ile SyntaxError veriyordu. Yeni kaynağın dokuz script ayrıştırma kontrolü ve kurgusal entegrasyon açılışı başarılıdır. Ana index.html'in bu entegrasyon dosyasını kullandığı veya canlı Supabase işlevlerinin doğrulandığı iddia edilmez.
