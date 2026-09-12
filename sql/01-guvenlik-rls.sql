-- ═══════════════════════════════════════════════════════════════════════
--  MUTFAK GROUP — FİYAT LİSTESİ · GÜVENLİK
--  Bu dosya OTOMATİK ÇALIŞTIRILMADI. Ne zaman uygulayacağınıza siz karar
--  verin; adımları sırayla Supabase → SQL Editor içine yapıştırın.
--
--  SORUN
--  -----
--  Sayfa, tarayıcıdan doğrudan veritabanına yazıyor ve bunu herkese açık
--  "anon" anahtarıyla yapıyor. O anahtar index.html'in içinde, yani sayfayı
--  açan herkeste var. Admin şifresi yalnızca ARAYÜZÜ gizliyor; şifreyi hiç
--  bilmeyen biri de tarayıcı konsolundan fiyatları değiştirebilir veya
--  tüm listeyi silebilir.
--
--  ÇÖZÜM
--  -----
--  anon rolüne SADECE OKUMA izni ver, yazmayı giriş yapmış kullanıcıya bırak.
--
--  ⚠ SIRALAMA ÖNEMLİ: Önce ADIM 1'deki kullanıcıyı oluşturun. ADIM 2'yi
--  kullanıcı hazır olmadan çalıştırırsanız kendi düzenleme erişiminizi de
--  kaparsınız. Adımları yoğun olmadığınız bir saatte uygulayın.
-- ═══════════════════════════════════════════════════════════════════════


-- ───────────────────────────────────────────────────────────────────────
-- ADIM 1 — Yönetici kullanıcısını oluşturun   (SQL değil, panelden)
-- ───────────────────────────────────────────────────────────────────────
-- Supabase panelinde:  Authentication → Users → "Add user"
--   E-posta : (kullandığınız bir adres)
--   Şifre   : güçlü bir şifre
--   "Auto confirm user" seçeneğini işaretleyin.
-- Bu kullanıcıyla giriş yapabildiğinizi doğrulamadan ADIM 2'ye geçmeyin.


-- ───────────────────────────────────────────────────────────────────────
-- ADIM 2 — RLS'i açın ve kuralları tanımlayın
-- ───────────────────────────────────────────────────────────────────────
alter table public.products    enable row level security;
alter table public.site_config enable row level security;

-- Eski/çakışan kurallar varsa temizle
drop policy if exists products_read_all      on public.products;
drop policy if exists products_write_auth    on public.products;
drop policy if exists site_config_read_all   on public.site_config;
drop policy if exists site_config_write_auth on public.site_config;

-- HERKES okuyabilir (müşteri görünümü çalışmaya devam etsin diye)
create policy products_read_all
  on public.products for select
  to anon, authenticated
  using (true);

create policy site_config_read_all
  on public.site_config for select
  to anon, authenticated
  using (true);

-- YALNIZCA giriş yapmış kullanıcı yazabilir
create policy products_write_auth
  on public.products for all
  to authenticated
  using (true) with check (true);

create policy site_config_write_auth
  on public.site_config for all
  to authenticated
  using (true) with check (true);


-- ───────────────────────────────────────────────────────────────────────
-- ADIM 3 — Şifre artık config içinde durmasın
-- ───────────────────────────────────────────────────────────────────────
-- Uygulamanın yeni sürümü şifreyi düz metin yerine SHA-256 özeti olarak
-- saklar ve ilk girişte kendiliğinden yükseltir. ADIM 1-2 tamamlandıktan
-- ve giriş Supabase Auth'a taşındıktan sonra bu alan tamamen gereksizdir:
--
--   update public.site_config
--      set config = (config - 'adminPw') - 'adminPwHash'
--    where id = 1;
--
-- (Bu satırı ancak arayüz Supabase Auth ile giriş yapmaya başladıktan
--  sonra çalıştırın; öncesinde çalıştırırsanız admin ekranına giremezsiniz.)


-- ───────────────────────────────────────────────────────────────────────
-- ADIM 4 — Doğrulama
-- ───────────────────────────────────────────────────────────────────────
-- a) Gizli sekmede sayfayı açın: fiyat listesi GÖRÜNMELİ.
-- b) Tarayıcı konsolunda şunu deneyin — 401/403 dönmeli, 200 DEĞİL:
--
--      fetch(SUPA_URL + '/rest/v1/products?id=eq.1', {
--        method: 'PATCH',
--        headers: { apikey: SUPA_KEY, Authorization: 'Bearer ' + SUPA_KEY,
--                   'Content-Type': 'application/json' },
--        body: '{"price":"1"}'
--      }).then(r => console.log(r.status));
--
-- c) 200 dönüyorsa kural uygulanmamıştır; ADIM 2'yi tekrar kontrol edin.
