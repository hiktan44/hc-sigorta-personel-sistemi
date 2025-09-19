// HC Sigorta - Supabase Entegrasyon Modülü
// Bu dosya index.html'e dahil edilecek

// Supabase bağlantı ayarları - GERÇEK DEĞERLER
const SUPABASE_CONFIG = {
    url: 'https://cdjhtcntbnfdzmjnrhrf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkamh0Y250Ym5mZHptam5yaHJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMjQ2OTYsImV4cCI6MjA3MzgwMDY5Nn0.o7uXImEIULZQ-KTAPLjNTbiDcmd1GVM34slCJQtU6X8'
};

// Supabase Client oluştur
let supabaseClient;

// Supabase başlatma fonksiyonu
function initializeSupabase() {
    if (!SUPABASE_CONFIG.url.includes('your-project-id')) {
        // Gerçek Supabase client
        supabaseClient = window.supabase.createClient(
            SUPABASE_CONFIG.url,
            SUPABASE_CONFIG.anonKey
        );
        console.log('✅ Supabase bağlantısı kuruldu!');
        return true;
    } else {
        console.warn('⚠️ Supabase ayarları yapılandırılmamış! Demo modda çalışıyor.');
        return false;
    }
}

// Auth fonksiyonları
const AuthService = {
    // Kullanıcı girişi
    async signIn(email, password) {
        try {
            const { data, error } = await supabaseClient.auth.signInWithPassword({
                email,
                password
            });
            
            if (error) throw error;
            
            // Kullanıcı bilgilerini al
            const { data: userData } = await supabaseClient
                .from('users')
                .select('*')
                .eq('email', email)
                .single();
                
            return { 
                user: data.user, 
                userData,
                session: data.session 
            };
        } catch (error) {
            console.error('Giriş hatası:', error);
            throw error;
        }
    },    
    // Kullanıcı çıkışı
    async signOut() {
        try {
            const { error } = await supabaseClient.auth.signOut();
            if (error) throw error;
            return true;
        } catch (error) {
            console.error('Çıkış hatası:', error);
            throw error;
        }
    },
    
    // Mevcut kullanıcıyı al
    async getUser() {
        try {
            const { data: { user } } = await supabaseClient.auth.getUser();
            
            if (user) {
                const { data: userData } = await supabaseClient
                    .from('users')
                    .select('*')
                    .eq('email', user.email)
                    .single();
                    
                return { user, userData };
            }
            
            return null;
        } catch (error) {
            console.error('Kullanıcı bilgisi alma hatası:', error);
            return null;
        }
    }
};

// Personel CRUD işlemleri
const PersonelService = {
    // Personel listesini getir
    async getPersonelList(firmaId, month) {
        try {
            let query = supabaseClient
                .from('personel')
                .select('*');
                
            if (firmaId && firmaId !== 'ana-sayfa') {
                query = query.eq('firma_id', firmaId);
            }
            
            if (month) {
                query = query.eq('month', month);
            }
            
            const { data, error } = await query.order('isim');
            
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Personel listesi alma hatası:', error);
            throw error;
        }
    },
    
    // Yeni personel ekle
    async addPersonel(personelData) {
        try {
            const { data: userData } = await AuthService.getUser();
            
            const { data, error } = await supabaseClient
                .from('personel')
                .insert([{
                    ...personelData,
                    created_by: userData.user.id
                }])
                .select()
                .single();
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Personel ekleme hatası:', error);
            throw error;
        }
    },    
    // Personel güncelle
    async updatePersonel(id, updates) {
        try {
            const { data, error } = await supabaseClient
                .from('personel')
                .update(updates)
                .eq('id', id)
                .select()
                .single();
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Personel güncelleme hatası:', error);
            throw error;
        }
    },
    
    // Personel sil
    async deletePersonel(id) {
        try {
            const { error } = await supabaseClient
                .from('personel')
                .delete()
                .eq('id', id);
                
            if (error) throw error;
            return true;
        } catch (error) {
            console.error('Personel silme hatası:', error);
            throw error;
        }
    }
};

// Firma işlemlericonst FirmaService = {
    // Firma listesini getir
    async getFirmaList() {
        try {
            const { data, error } = await supabaseClient
                .from('firmalar')
                .select('*')
                .eq('is_active', true)
                .order('id');
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Firma listesi alma hatası:', error);
            throw error;
        }
    },
    
    // Kullanıcının yetkili olduğu firmaları getir
    async getUserFirmaList(userPermissions) {
        try {
            const firmaList = await this.getFirmaList();
            
            // Admin tüm firmaları görebilir
            const { data: userData } = await AuthService.getUser();
            if (userData?.userData?.role === 'admin') {
                return firmaList;
            }
            
            // Normal kullanıcı sadece yetkili olduğu firmaları görebilir
            return firmaList.filter(firma => 
                userPermissions.includes(firma.id)
            );
        } catch (error) {
            console.error('Kullanıcı firma listesi alma hatası:', error);
            throw error;
        }
    }
};

// Ay durumu işlemlericonst MonthStatusService = {
    // Ay durumunu kontrol et
    async checkMonthStatus(month) {
        try {
            const { data, error } = await supabaseClient
                .from('month_status')
                .select('*')
                .eq('month', month)
                .single();
                
            if (error && error.code !== 'PGRST116') throw error;
            
            return data || { month, is_finalized: false };
        } catch (error) {
            console.error('Ay durumu kontrol hatası:', error);
            throw error;
        }
    },
    
    // Ayı kilitle
    async finalizeMonth(month) {
        try {
            const { data: userData } = await AuthService.getUser();
            
            const { data, error } = await supabaseClient
                .rpc('finalize_month', {
                    target_month: month,
                    user_id: userData.user.id
                });
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Ay kilitleme hatası:', error);
            throw error;
        }
    }
};

// Özet ve raporlamaconst ReportService = {
    // Firma özeti getir
    async getFirmaSummary(month) {
        try {
            const { data, error } = await supabaseClient
                .from('v_personel_summary')
                .select('*')
                .eq('month', month);
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Firma özeti alma hatası:', error);
            throw error;
        }
    },
    
    // Aylık özet getir
    async getMonthlySummary() {
        try {
            const { data, error } = await supabaseClient
                .from('v_monthly_summary')
                .select('*')
                .order('month', { ascending: false })
                .limit(12);
                
            if (error) throw error;
            return data;
        } catch (error) {
            console.error('Aylık özet alma hatası:', error);
            throw error;
        }
    }
};

// Export etme
window.SupabaseIntegration = {
    initialize: initializeSupabase,
    AuthService,
    PersonelService,
    FirmaService,
    MonthStatusService,
    ReportService,
    getClient: () => supabaseClient
};