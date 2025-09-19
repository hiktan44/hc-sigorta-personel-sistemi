# 🚀 Supabase Kurulum Rehberi

## 1. Supabase Projesi Oluşturma

### Adım 1: Supabase Hesabı
1. [supabase.com](https://supabase.com) adresine gidin
2. "Start your project" butonuna tıklayın
3. GitHub ile giriş yapın veya hesap oluşturun

### Adım 2: Yeni Proje Oluşturma
1. Dashboard'da "New Project" butonuna tıklayın
2. Proje bilgilerini doldurun:
   - **Name:** `hc-sigorta-personel`
   - **Database Password:** Güçlü bir şifre oluşturun
   - **Region:** `Europe (Frankfurt)` (en yakın)
3. "Create new project" butonuna tıklayın
4. Proje hazırlanmasını bekleyin (2-3 dakika)

## 2. Veritabanı Kurulumu

### Adım 1: SQL Editor'ı Açma
1. Sol menüden **SQL Editor** seçin
2. "New query" butonuna tıklayın

### Adım 2: Veritabanı Scriptini Çalıştırma
1. `supabase_setup.sql` dosyasının içeriğini kopyalayın
2. SQL Editor'a yapıştırın
3. **RUN** butonuna tıklayın
4. Tüm tabloların başarıyla oluşturulduğunu kontrol edin

### Adım 3: RLS (Row Level Security) Kontrolü
1. **Authentication** > **Policies** bölümüne gidin
2. Aşağıdaki policy'lerin oluşturulduğunu kontrol edin:
   - `Users can view own data`
   - `Users can view personel based on permissions`
   - `Only admins can modify month status`

## 3. API Anahtarlarını Alma

### Adım 1: Settings Sayfası
1. Sol menüden **Settings** > **API** seçin
2. Aşağıdaki bilgileri not alın:

```javascript
// Project URL
const SUPABASE_URL = 'https://your-project-id.supabase.co';

// Anon/Public Key
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### Adım 2: HTML Dosyasını Güncelleme
1. `index.html` dosyasını açın
2. Aşağıdaki satırları bulun:
```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```
3. Gerçek değerlerle değiştirin

### Adım 3: Gerçek Supabase Client'ı Aktifleştirme
Demo supabase nesnesini gerçek client ile değiştirin:

```javascript
// Demo supabase nesnesini sil ve aşağıdaki ile değiştir:
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

## 4. Authentication Kurulumu

### Adım 1: Auth Settings
1. **Authentication** > **Settings** bölümüne gidin
2. **Site URL** ayarını yapın: `http://localhost:8080`
3. **Email Auth** aktif olduğunu kontrol edin

### Adım 2: Demo Kullanıcıları Ekleme
1. **Authentication** > **Users** bölümüne gidin
2. "Add user" butonuna tıklayın
3. Admin kullanıcısı ekleyin:
   - **Email:** `admin@hcsigorta.com`
   - **Password:** `123456`
   - **Email Confirm:** ✅
   - **User Metadata:**
   ```json
   {
     "role": "admin",
     "name": "Sistem Yöneticisi",
     "permissions": ["ana-sayfa", "firma-1", "firma-2", "firma-3", "firma-4", "firma-5"]
   }
   ```

4. Firma kullanıcısı ekleyin:
   - **Email:** `teknoloji@hcsigorta.com`
   - **Password:** `123456`
   - **Email Confirm:** ✅
   - **User Metadata:**
   ```json
   {
     "role": "user",
     "name": "HC Teknoloji Kullanıcısı",
     "permissions": ["firma-2"]
   }
   ```

## 5. Test ve Doğrulama

### Adım 1: Bağlantı Testi
1. Browser console'u açın (F12)
2. Sayfayı yenileyin
3. Hata mesajı olmadığını kontrol edin

### Adım 2: Giriş Testi
1. `admin@hcsigorta.com` / `123456` ile giriş yapın
2. Tüm sekmelerin göründüğünü kontrol edin
3. Çıkış yapıp `teknoloji@hcsigorta.com` ile giriş yapın
4. Sadece HC Teknoloji sekmesinin göründüğünü kontrol edin

### Adım 3: Veritabanı Testi
1. **Table Editor** bölümüne gidin
2. `users` tablosunda kullanıcıların göründüğünü kontrol edin
3. `firmalar` tablosunda firma bilgilerinin olduğunu kontrol edin

## 6. Üretim Ortamı İçin Ek Ayarlar

### Güvenlik Ayarları
1. **Settings** > **API** > **JWT Settings**
2. JWT secret'ı güvenli tutun
3. **Database** > **Settings** > **SSL** aktif olduğunu kontrol edin

### Domain Ayarları
1. **Authentication** > **Settings**
2. **Site URL**'i gerçek domain ile güncelleyin
3. **Redirect URLs** listesine production URL'i ekleyin

### Backup Ayarları
1. **Settings** > **Database**
2. **Point-in-time Recovery** aktifleştirin
3. Otomatik backup ayarlarını yapın

## 7. Sorun Giderme

### Yaygın Hatalar

**1. "Invalid API key" Hatası**
- API anahtarının doğru kopyalandığını kontrol edin
- Supabase projesinin aktif olduğunu kontrol edin

**2. "Row Level Security" Hatası**
- RLS policy'lerinin doğru kurulduğunu kontrol edin
- Kullanıcı metadata'sının doğru olduğunu kontrol edin

**3. "CORS" Hatası**
- Site URL'in doğru ayarlandığını kontrol edin
- Redirect URL'lerin eklendiğini kontrol edin

### Debug Komutları

Browser console'da test için:

```javascript
// Supabase bağlantısını test et
console.log('Supabase URL:', SUPABASE_URL);
console.log('Supabase Client:', supabase);

// Kullanıcı durumunu kontrol et
supabase.auth.getUser().then(console.log);

// Tablo verilerini kontrol et
supabase.from('users').select('*').then(console.log);
```

## 8. İletişim

Kurulum sırasında sorun yaşarsanız:
- **Email:** support@hcsigorta.com
- **GitHub Issues:** Proje repository'sinde issue açın
- **Supabase Docs:** [docs.supabase.com](https://docs.supabase.com)

---

**© 2024 HC Sigorta - Supabase Kurulum Rehberi**
*Versiyon: 1.0*
*Son Güncelleme: 18.09.2024*
