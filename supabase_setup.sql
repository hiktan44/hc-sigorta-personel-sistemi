-- HC Sigorta Modern Personel Yönetim Sistemi
-- Supabase Veritabanı Kurulum Scripti

-- 1. Kullanıcılar Tablosu (User Management)
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('admin', 'user')),
    permissions TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Firmalar Tablosu
CREATE TABLE firmalar (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(100) NOT NULL,
    color_class VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Aylık Durum Tablosu (Month Status)
CREATE TABLE month_status (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    is_finalized BOOLEAN DEFAULT false,
    finalized_by UUID REFERENCES users(id),
    finalized_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(month)
);

-- 4. Personel Tablosu
CREATE TABLE personel (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    firma_id VARCHAR(20) REFERENCES firmalar(id),
    month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    isim VARCHAR(255) NOT NULL,
    telefon VARCHAR(20),
    email VARCHAR(255),
    departman VARCHAR(100) NOT NULL,
    pozisyon VARCHAR(100) NOT NULL,
    brut_maas DECIMAL(12,2) NOT NULL,
    calistigi_gun INTEGER NOT NULL CHECK (calistigi_gun BETWEEN 1 AND 30),
    adres TEXT,
    
    -- Hesaplanan alanlar (Excel formülleri)
    oranli_maas DECIMAL(12,2) GENERATED ALWAYS AS ((brut_maas / 30) * calistigi_gun) STORED,
    ssk_isci DECIMAL(12,2) GENERATED ALWAYS AS (((brut_maas / 30) * calistigi_gun) * 15 / 100) STORED,
    gelir_vergisi DECIMAL(12,2) GENERATED ALWAYS AS ((((brut_maas / 30) * calistigi_gun) - (((brut_maas / 30) * calistigi_gun) * 15 / 100)) * 20 / 100) STORED,
    damga_vergisi DECIMAL(12,2) GENERATED ALWAYS AS (((brut_maas / 30) * calistigi_gun) * 0.76 / 100) STORED,
    ssk_isveren DECIMAL(12,2) GENERATED ALWAYS AS (((brut_maas / 30) * calistigi_gun) * 37.75 / 100) STORED,
    muhasebe_parasi DECIMAL(12,2) DEFAULT 50,
    
    -- Toplam hesaplamalar
    toplam_isci_kesinti DECIMAL(12,2) GENERATED ALWAYS AS (
        (((brut_maas / 30) * calistigi_gun) * 15 / 100) + 
        ((((brut_maas / 30) * calistigi_gun) - (((brut_maas / 30) * calistigi_gun) * 15 / 100)) * 20 / 100) + 
        (((brut_maas / 30) * calistigi_gun) * 0.76 / 100)
    ) STORED,
    
    net_maas DECIMAL(12,2) GENERATED ALWAYS AS (
        ((brut_maas / 30) * calistigi_gun) - (
            (((brut_maas / 30) * calistigi_gun) * 15 / 100) + 
            ((((brut_maas / 30) * calistigi_gun) - (((brut_maas / 30) * calistigi_gun) * 15 / 100)) * 20 / 100) + 
            (((brut_maas / 30) * calistigi_gun) * 0.76 / 100)
        )
    ) STORED,
    
    toplam_isveren_maliyet DECIMAL(12,2) GENERATED ALWAYS AS (
        ((brut_maas / 30) * calistigi_gun) + 
        (((brut_maas / 30) * calistigi_gun) * 37.75 / 100) + 
        50
    ) STORED,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(firma_id, month, isim) -- Aynı ay ve firmada aynı isimde personel olamaz
);

-- 5. Audit Log Tablosu (Değişiklik Takibi)
CREATE TABLE audit_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Sistem Ayarları Tablosu
CREATE TABLE system_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- İndeksler
CREATE INDEX idx_personel_firma_month ON personel(firma_id, month);
CREATE INDEX idx_personel_month ON personel(month);
CREATE INDEX idx_month_status_month ON month_status(month);
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_users_email ON users(email);

-- Trigger Functions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Updated At Triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personel_updated_at BEFORE UPDATE ON personel
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Audit Log Trigger Function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, user_id)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD), current_setting('app.current_user_id', true)::UUID);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user_id)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW), current_setting('app.current_user_id', true)::UUID);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, new_values, user_id)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW), current_setting('app.current_user_id', true)::UUID);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Audit Triggers
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_personel_trigger
    AFTER INSERT OR UPDATE OR DELETE ON personel
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE personel ENABLE ROW LEVEL SECURITY;
ALTER TABLE month_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data unless they are admin
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id OR 
                     (SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- Personel policies based on user permissions
CREATE POLICY "Users can view personel based on permissions" ON personel
    FOR SELECT USING (
        firma_id = ANY((SELECT permissions FROM users WHERE id = auth.uid())) OR
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

CREATE POLICY "Users can insert personel based on permissions" ON personel
    FOR INSERT WITH CHECK (
        firma_id = ANY((SELECT permissions FROM users WHERE id = auth.uid())) OR
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

CREATE POLICY "Users can update personel based on permissions" ON personel
    FOR UPDATE USING (
        firma_id = ANY((SELECT permissions FROM users WHERE id = auth.uid())) OR
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
    );

-- Month status policies - only admins can finalize
CREATE POLICY "Everyone can view month status" ON month_status FOR SELECT USING (true);
CREATE POLICY "Only admins can modify month status" ON month_status
    FOR ALL USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- Audit log - only admins can view
CREATE POLICY "Only admins can view audit log" ON audit_log
    FOR SELECT USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- Başlangıç Verileri
INSERT INTO firmalar (id, name, icon, color_class) VALUES
('ana-sayfa', 'Ana Sayfa', 'fas fa-chart-line', 'gradient-bg'),
('firma-1', 'HC Sigorta Ana', 'fas fa-building', 'firma-1'),
('firma-2', 'HC Teknoloji', 'fas fa-laptop-code', 'firma-2'),
('firma-3', 'HC Danışmanlık', 'fas fa-handshake', 'firma-3'),
('firma-4', 'HC Emlak', 'fas fa-home', 'firma-4'),
('firma-5', 'HC Finans', 'fas fa-chart-pie', 'firma-5'),
('firma-6', 'HC Turizm', 'fas fa-plane', 'firma-6'),
('firma-7', 'HC Sağlık', 'fas fa-heartbeat', 'firma-7'),
('firma-8', 'HC Eğitim', 'fas fa-graduation-cap', 'firma-8'),
('firma-9', 'HC Lojistik', 'fas fa-truck', 'firma-9'),
('firma-10', 'HC Enerji', 'fas fa-bolt', 'firma-10');

-- Demo kullanıcılar (şifreler bcrypt ile hashlenmiş "123456")
INSERT INTO users (email, password_hash, name, role, permissions) VALUES
('admin@hcsigorta.com', '$2b$10$rKvK1YjMZkNqnBaYvbgHKOX7fDfkJZKQQQQQQQQQQQQQQQQQQQQQQQ', 'Sistem Yöneticisi', 'admin', 
 ARRAY['ana-sayfa', 'firma-1', 'firma-2', 'firma-3', 'firma-4', 'firma-5', 'firma-6', 'firma-7', 'firma-8', 'firma-9', 'firma-10']),
('teknoloji@hcsigorta.com', '$2b$10$rKvK1YjMZkNqnBaYvbgHKOX7fDfkJZKQQQQQQQQQQQQQQQQQQQQQQ', 'HC Teknoloji Kullanıcısı', 'user', ARRAY['firma-2']),
('danismanlik@hcsigorta.com', '$2b$10$rKvK1YjMZkNqnBaYvbgHKOX7fDfkJZKQQQQQQQQQQQQQQQQQQQQQQ', 'HC Danışmanlık Kullanıcısı', 'user', ARRAY['firma-3']),
('emlak@hcsigorta.com', '$2b$10$rKvK1YjMZkNqnBaYvbgHKOX7fDfkJZKQQQQQQQQQQQQQQQQQQQQQQ', 'HC Emlak Kullanıcısı', 'user', ARRAY['firma-4']),
('finans@hcsigorta.com', '$2b$10$rKvK1YjMZkNqnBaYvbgHKOX7fDfkJZKQQQQQQQQQQQQQQQQQQQQQQ', 'HC Finans Kullanıcısı', 'user', ARRAY['firma-5']);

-- Sistem ayarları
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('ssk_isci_orani', '15', 'İşçi SSK + İşsizlik primi oranı (%)'),
('gelir_vergisi_orani', '20', 'Gelir vergisi oranı (%)'),
('damga_vergisi_orani', '0.76', 'Damga vergisi oranı (%)'),
('ssk_isveren_orani', '37.75', 'İşveren SSK oranı (%)'),
('muhasebe_parasi', '50', 'Sabit muhasebe parası (₺)'),
('max_calisma_gun', '30', 'Maksimum çalışma günü'),
('min_calisma_gun', '1', 'Minimum çalışma günü');

-- Mevcut ay durumu
INSERT INTO month_status (month, is_finalized) VALUES
('2024-09', false);

-- Demo personel verileri
INSERT INTO personel (firma_id, month, isim, telefon, email, departman, pozisyon, brut_maas, calistigi_gun, adres, created_by) VALUES
-- HC Sigorta Ana
('firma-1', '2024-09', 'Dr. Ahmet Yılmaz', '0532 123 4567', 'ahmet@hcsigorta.com', 'Yönetim', 'Genel Müdür', 80000, 22, 'İstanbul', (SELECT id FROM users WHERE email = 'admin@hcsigorta.com')),
('firma-1', '2024-09', 'Ayşe Kaya', '0533 234 5678', 'ayse@hcsigorta.com', 'İnsan Kaynakları', 'İK Uzmanı', 35000, 22, 'İstanbul', (SELECT id FROM users WHERE email = 'admin@hcsigorta.com')),
('firma-1', '2024-09', 'Mehmet Demir', '0534 345 6789', 'mehmet@hcsigorta.com', 'Satış', 'Satış Temsilcisi', 28000, 20, 'Ankara', (SELECT id FROM users WHERE email = 'admin@hcsigorta.com')),

-- HC Teknoloji
('firma-2', '2024-09', 'Fatma Şahin', '0535 456 7890', 'fatma@hcteknoloji.com', 'IT', 'Yazılım Geliştirici', 45000, 22, 'İstanbul', (SELECT id FROM users WHERE email = 'teknoloji@hcsigorta.com')),
('firma-2', '2024-09', 'Ali Yıldız', '0536 567 8901', 'ali@hcteknoloji.com', 'IT', 'Sistem Yöneticisi', 40000, 22, 'İzmir', (SELECT id FROM users WHERE email = 'teknoloji@hcsigorta.com')),

-- HC Danışmanlık
('firma-3', '2024-09', 'Zeynep Özkan', '0537 678 9012', 'zeynep@hcdanismanlik.com', 'Hukuk', 'Hukuk Müşaviri', 50000, 22, 'Ankara', (SELECT id FROM users WHERE email = 'danismanlik@hcsigorta.com'));

-- Views (Raporlama için)
CREATE VIEW v_personel_summary AS
SELECT 
    p.firma_id,
    f.name as firma_name,
    p.month,
    COUNT(*) as personel_sayisi,
    SUM(p.oranli_maas) as toplam_brut_maas,
    SUM(p.net_maas) as toplam_net_maas,
    SUM(p.toplam_isci_kesinti) as toplam_isci_kesinti,
    SUM(p.toplam_isveren_maliyet) as toplam_isveren_maliyet
FROM personel p
JOIN firmalar f ON p.firma_id = f.id
GROUP BY p.firma_id, f.name, p.month
ORDER BY p.firma_id, p.month;

CREATE VIEW v_monthly_summary AS
SELECT 
    month,
    COUNT(*) as toplam_personel,
    SUM(oranli_maas) as toplam_brut_maas,
    SUM(net_maas) as toplam_net_maas,
    SUM(toplam_isci_kesinti) as toplam_isci_kesinti,
    SUM(toplam_isveren_maliyet) as toplam_isveren_maliyet,
    (SELECT is_finalized FROM month_status ms WHERE ms.month = p.month) as is_finalized
FROM personel p
GROUP BY month
ORDER BY month DESC;

-- Functions
CREATE OR REPLACE FUNCTION get_user_permissions(user_email TEXT)
RETURNS TEXT[] AS $$
BEGIN
    RETURN (SELECT permissions FROM users WHERE email = user_email AND is_active = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION can_modify_month(check_month TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT (SELECT COALESCE(is_finalized, false) FROM month_status WHERE month = check_month);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Finalize month function
CREATE OR REPLACE FUNCTION finalize_month(target_month TEXT, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
BEGIN
    -- Check if user is admin
    SELECT role INTO user_role FROM users WHERE id = user_id;
    
    IF user_role != 'admin' THEN
        RAISE EXCEPTION 'Only admin users can finalize months';
    END IF;
    
    -- Insert or update month status
    INSERT INTO month_status (month, is_finalized, finalized_by, finalized_at)
    VALUES (target_month, true, user_id, NOW())
    ON CONFLICT (month) 
    DO UPDATE SET 
        is_finalized = true,
        finalized_by = user_id,
        finalized_at = NOW();
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
