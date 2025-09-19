# 🏢 HC Sigorta - Modern Personel Yönetim Sistemi

Modern, kullanıcı dostu ve güvenli personel maaş hesaplama ve yönetim sistemi. Supabase backend ile desteklenen, çok firmalı yapıda çalışan gelişmiş web uygulaması.

## ✨ Özellikler

### 🎯 **Temel Özellikler**
- **10 Firma Desteği** - Her firma için ayrı sayfa ve yetkilendirme
- **Aylık Veri Saklama** - Geçmiş aylara dönük görüntüleme
- **Excel Formül Sistemi** - Gerçek SSK ve vergi hesaplamaları
- **Kullanıcı Yetkilendirme** - Admin ve firma kullanıcıları
- **Kesinleştirme Sistemi** - SSK beyanname sonrası veri kilitleme
- **200 Personel Kapasitesi** - Ölçeklenebilir yapı

### 🔐 **Güvenlik Özellikleri**
- **Row Level Security (RLS)** - Supabase güvenlik katmanı
- **Kullanıcı Bazlı Erişim** - Sadece yetkili sayfaları görme
- **Audit Log** - Tüm değişikliklerin takibi
- **Şifreli Kimlik Doğrulama** - Güvenli giriş sistemi

### 💰 **Maaş Hesaplama Formülleri**
```
Oranlı Maaş = BrütÜcret / 30 * ÇalışılanGün
İşçi SSK (%15) = OranliMaas * 15 / 100
Gelir Vergisi (%20) = (OranliMaas - İşçiSSK) * 20 / 100
Damga Vergisi (%0.76) = OranliMaas * 0.76 / 100
İşveren SSK (%37.75) = OranliMaas * 37.75 / 100
Muhasebe Parası = 50₺ (sabit)
```

## 🚀 Kurulum

### 1. **Supabase Kurulumu**

1. [Supabase](https://supabase.com) hesabı oluşturun
2. Yeni proje oluşturun
3. `supabase_setup.sql` dosyasını SQL Editor'de çalıştırın
4. API anahtarlarınızı kopyalayın

### 2. **Proje Yapılandırması**

```javascript
// modern_hc_sigorta_system.html dosyasında güncelleme yapın
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

### 3. **Demo Kullanıcılar**

| E-mail | Şifre | Yetki | Erişim |
|--------|-------|--------|--------|
| `admin@hcsigorta.com` | `123456` | Ana Yönetici | Tüm firmalar + yönetim |
| `teknoloji@hcsigorta.com` | `123456` | Firma Kullanıcısı | Sadece HC Teknoloji |
| `danismanlik@hcsigorta.com` | `123456` | Firma Kullanıcısı | Sadece HC Danışmanlık |

## 📊 Veritabanı Yapısı

### **Ana Tablolar**

#### `users` - Kullanıcı Yönetimi
```sql
- id (UUID, Primary Key)
- email (VARCHAR, Unique)
- password_hash (VARCHAR)
- name (VARCHAR)
- role (admin/user)
- permissions (TEXT[])
- is_active (BOOLEAN)
```

#### `personel` - Personel Bilgileri
```sql
- id (UUID, Primary Key)
- firma_id (VARCHAR, Foreign Key)
- month (VARCHAR, Format: YYYY-MM)
- isim, telefon, email, departman, pozisyon
- brut_maas, calistigi_gun, adres
- Hesaplanan alanlar (Generated Columns):
  * oranli_maas, ssk_isci, gelir_vergisi
  * damga_vergisi, ssk_isveren, muhasebe_parasi
  * toplam_isci_kesinti, net_maas, toplam_isveren_maliyet
```

#### `month_status` - Aylık Durum Takibi
```sql
- id (UUID, Primary Key)
- month (VARCHAR, Unique)
- is_finalized (BOOLEAN)
- finalized_by (UUID, Foreign Key)
- finalized_at (TIMESTAMP)
```

#### `audit_log` - Değişiklik Takibi
```sql
- id (UUID, Primary Key)
- table_name (VARCHAR)
- record_id (UUID)
- action (INSERT/UPDATE/DELETE)
- old_values, new_values (JSONB)
- user_id (UUID, Foreign Key)
```

## 🎨 Kullanıcı Arayüzü

### **Modern Tasarım Özellikleri**
- **Glassmorphism** efektleri
- **Gradient** arka planlar
- **Hover animasyonları**
- **Responsive** tasarım
- **Dark mode** desteği (gelecek)
- **Tailwind CSS** framework

### **Firma Renk Kodları**
```css
.firma-1  { background: linear-gradient(135deg, #10b981, #34d399); } /* HC Sigorta Ana */
.firma-2  { background: linear-gradient(135deg, #ef4444, #f87171); } /* HC Teknoloji */
.firma-3  { background: linear-gradient(135deg, #06b6d4, #22d3ee); } /* HC Danışmanlık */
.firma-4  { background: linear-gradient(135deg, #f59e0b, #fbbf24); } /* HC Emlak */
.firma-5  { background: linear-gradient(135deg, #ec4899, #f472b6); } /* HC Finans */
```

## 🔧 API Fonksiyonları

### **Kullanıcı Yönetimi**
```javascript
// Giriş yapma
await login(email, password)

// Çıkış yapma
logout()

// Kullanıcı yetkilerini kontrol etme
getUserPermissions(userEmail)
```

### **Personel Yönetimi**
```javascript
// Personel ekleme
await savePersonel(firmaId, personelData)

// Personel güncelleme
await updatePersonel(personelId, personelData)

// Personel silme
await deletePersonel(personelId)

// Firma personellerini listeleme
await loadFirmaData(firmaId, month)
```

### **Ay Yönetimi**
```javascript
// Ayı kesinleştirme (Sadece admin)
await finalizeMonth(month)

// Ay durumunu kontrol etme
await checkMonthStatus(month)

// Aylık özet verilerini alma
await getMonthlyData(month)
```

## 📱 Kullanım Kılavuzu

### **Ana Yönetici (Admin) İşlemleri**

1. **Giriş Yapma**
   - `admin@hcsigorta.com` ile giriş yapın
   - Tüm firmaları görebilirsiniz

2. **Personel Yönetimi**
   - Herhangi bir firmaya personel ekleyebilirsiniz
   - Tüm personelleri düzenleyebilirsiniz
   - Geçmiş aylardaki verileri düzeltebilirsiniz

3. **Ay Kesinleştirme**
   - SSK beyannamesi verdikten sonra "Ayı Kesinleştir" butonuna basın
   - Kesinleştirilen ay artık değiştirilemez
   - Sadece admin kullanıcı düzeltme yapabilir

4. **Kullanıcı Yönetimi**
   - Yeni firma kullanıcıları ekleyebilirsiniz
   - Kullanıcı yetkilerini düzenleyebilirsiniz

### **Firma Kullanıcısı İşlemleri**

1. **Giriş Yapma**
   - Size atanan e-mail ile giriş yapın
   - Sadece kendi firmanızı görebilirsiniz

2. **Personel İşlemleri**
   - Kendi firmanıza personel ekleyebilirsiniz
   - Mevcut personelleri düzenleyebilirsiniz
   - Kesinleştirilen aylarda işlem yapamazsınız

3. **Raporlama**
   - Kendi firmanızın maaş raporlarını görüntüleyebilirsiniz
   - Excel'e aktarım yapabilirsiniz

## 📈 Raporlama

### **Dashboard Özellikleri**
- **Toplam Personel Sayısı**
- **Toplam Brüt Maaş**
- **Toplam Net Maaş**
- **Toplam İşveren Maliyeti**
- **Firma Bazlı Özet Kartları**
- **Detaylı Personel Tablosu**

### **Excel Export**
- Tüm veriler Excel formatında indirilebilir
- Firma bazlı ayrı sayfalar
- Formül hesaplamaları dahil

## 🔒 Güvenlik Politikaları

### **Row Level Security (RLS)**
```sql
-- Kullanıcılar sadece kendi verilerini görebilir
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id OR 
                     (SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- Personel verileri yetki bazlı erişim
CREATE POLICY "Users can view personel based on permissions" ON personel
    FOR SELECT USING (
        firma_id = ANY((SELECT permissions FROM users WHERE id = auth.uid())) OR
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );
```

### **Audit Trail**
- Tüm veri değişiklikleri loglanır
- Kim, ne zaman, neyi değiştirdi takip edilir
- Sadece admin kullanıcılar audit logları görebilir

## 🚀 Gelecek Özellikler

### **v2.0 Planları**
- [ ] **Mobile App** (React Native)
- [ ] **Dark Mode** desteği
- [ ] **Bildirim Sistemi**
- [ ] **Toplu İşlemler** (Excel import/export)
- [ ] **Grafik ve Analitik** dashboard
- [ ] **E-imza** entegrasyonu
- [ ] **PDF Rapor** oluşturma
- [ ] **API Entegrasyonu** (SGK, Vergi Dairesi)

### **v2.1 Planları**
- [ ] **Multi-tenant** yapı
- [ ] **Backup/Restore** sistemi
- [ ] **Role-based** detaylı yetkilendirme
- [ ] **Workflow** yönetimi
- [ ] **Chat/Mesajlaşma** sistemi

## 🛠️ Teknik Detaylar

### **Teknoloji Stack**
- **Frontend:** HTML5, CSS3, JavaScript (Vanilla)
- **Backend:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Database:** PostgreSQL with RLS
- **Styling:** Tailwind CSS
- **Icons:** Font Awesome
- **Animations:** Animate.css

### **Browser Desteği**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### **Performans**
- **Lazy Loading** - Büyük tablolar için
- **Caching** - Supabase cache stratejisi
- **Optimized Queries** - İndeksli sorgular
- **Responsive Images** - Otomatik boyutlandırma

## 📞 Destek

### **Teknik Destek**
- **E-mail:** support@hcsigorta.com
- **Telefon:** +90 212 XXX XX XX
- **Çalışma Saatleri:** 09:00 - 18:00 (Hafta içi)

### **Dokümantasyon**
- **API Dokümantasyonu:** `/docs/api`
- **Kullanıcı Kılavuzu:** `/docs/user-guide`
- **Video Eğitimler:** `/docs/videos`

## 📄 Lisans

Bu proje HC Sigorta şirketine aittir. Tüm hakları saklıdır.

---

**© 2024 HC Sigorta - Modern Personel Yönetim Sistemi**

*Geliştirilme Tarihi: Eylül 2024*  
*Versiyon: 1.0.0*  
*Son Güncelleme: 18.09.2024*
