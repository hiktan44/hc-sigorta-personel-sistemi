# 🚀 HC Sigorta Deployment Rehberi

## 📋 Dağıtım Bilgileri

### 🌐 GitHub Repository
**URL:** https://github.com/hiktan44/hc-sigorta-personel-sistemi

### 🔗 Netlify Deployment Seçenekleri

#### Option 1: GitHub Integration (Önerilen)
1. [Netlify Dashboard](https://app.netlify.com)'a giriş yapın
2. **"New site from Git"** butonuna tıklayın
3. **GitHub** seçin ve repository'yi bağlayın
4. Repository: `hiktan44/hc-sigorta-personel-sistemi`
5. Build settings:
   - **Build command:** (boş bırakın)
   - **Publish directory:** `.` (root folder)
6. **Deploy site** butonuna tıklayın

#### Option 2: Manual Deploy
1. Projeyi ZIP olarak indirin
2. [Netlify Drop](https://app.netlify.com/drop)'a sürükleyip bırakın
3. Site otomatik olarak yayınlanır

### ⚙️ Build Konfigürasyonu
- **Framework:** Static HTML
- **Build Command:** Yok (Static site)
- **Publish Directory:** `.` (Root)
- **Node Version:** 18.x

### 🔧 Environment Variables (İsteğe bağlı)
Supabase entegrasyonu için:
```
SUPABASE_URL=your-project-url
SUPABASE_ANON_KEY=your-anon-key
```

### 📱 Demo Kullanıcıları
```
👤 Sistem Yöneticisi:
   Kullanıcı: admin
   Şifre: admin123

👤 Şirket Kullanıcısı:
   Kullanıcı: klinik  
   Şifre: 123456
```

### 🌟 Özellikler
- ✅ Mobil uyumlu responsive design
- ✅ Asgari ücret muafiyet sistemi
- ✅ Evrak yönetimi ve upload
- ✅ PDF/Excel/Print özellikleri
- ✅ WhatsApp ve Gmail paylaşım
- ✅ Multi-user yetki sistemi
- ✅ Detaylı bordro hesaplamaları
- ✅ Modern UI/UX tasarım

### 🔗 Bağlantılar
- **GitHub:** https://github.com/hiktan44/hc-sigorta-personel-sistemi
- **Demo Site:** (Netlify deployment sonrası)
- **Dokümantasyon:** README.md

### 📞 Destek
HC Sigorta Teknik Ekibi için GitHub Issues kullanın.

---
**🏥 HC Sigorta Personel Yönetim Sistemi**  
*Modern, Güvenli, Kullanıcı Dostu*
