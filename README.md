# mutfakgroup-fiyat

Mutfak Group ürün fiyat listesi. Tek dosyalık bir web uygulaması
(`index.html`); veriler Supabase'de `products` ve `site_config`
tablolarında tutulur, ayrı bir sunucu kodu yoktur.

İki görünüm vardır:

- **Müşteri görünümü** — salt okunur liste, arama, grup filtreleri, yazdırma.
- **Admin görünümü** — hücrelerin yerini düzenleme kutuları alır; ürün ve
  kategori ekleme/silme/sıralama, toplu fiyat işlemleri ve sayfa ayarları.

## Dosyalar

| Yol | Ne işe yarar |
|---|---|
| `index.html` | Uygulamanın tamamı (HTML + CSS + JS) |
| `sql/01-guvenlik-rls.sql` | Veritabanı yazma izinlerini kapatma adımları — **çalıştırılmadı** |
| `sql/02-veri-modeli.sql` | Fiyatı sayıya çevirme, kategori tablosu, zaman damgası — **çalıştırılmadı** |

`sql/` altındaki dosyalar otomatik uygulanmaz. Ne zaman ve hangi sırayla
çalıştırılacağına siz karar verirsiniz; her ikisi de içinde adım adım
anlatım ve doğrulama sorgusu taşır.

## Bilinmesi gereken: şifre veriyi korumaz

Sayfa veritabanına tarayıcıdan, herkese açık `anon` anahtarıyla yazıyor. O
anahtar `index.html` içinde olduğundan sayfayı açan herkeste var. Admin
şifresi yalnızca **arayüzü** gizler; şifreyi bilmeyen teknik bir kullanıcı
da listeyi değiştirebilir.

Kalıcı çözüm `sql/01-guvenlik-rls.sql` dosyasındadır: `anon` rolüne sadece
okuma izni verilir, yazma giriş yapmış kullanıcıya bırakılır. Sıralamaya
uyun — adımları ters uygularsanız kendi erişiminizi de kaparsınız.

## Fiyat biçimi

Fiyat alanına hem `1.250,50` hem `1250.50` yazılabilir; ikisi de aynı
sayı olarak okunur. Veritabanına her zaman sade biçimde (`1250.5`)
yazılır, ekranda ve baskıda Türkçe biçimde (`1.250,50 ₺`) gösterilir.
Para birimi ve ondalık hane sayısı **Sayfa Ayarları → Fiyat Gösterimi**
altından değiştirilir.

## Geliştirme

Derleme adımı yok. Dosyayı bir yerel sunucuyla açmak yeterlidir:

```bash
python3 -m http.server 8000     # sonra http://localhost:8000
```

`file://` ile açmayın: şifre özeti için gereken `crypto.subtle` yalnızca
güvenli bağlamda (https veya localhost) çalışır.
