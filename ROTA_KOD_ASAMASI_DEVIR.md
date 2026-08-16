# ROTA --- Kod Aşaması Devir Belgesi

## Güncel teknik, ürün ve pedagojik referans --- Flutter/Dart

**Sürüm:** 2026-08-16\
**Statü:** Güncel tek çalışma sözleşmesi

> **Belgenin amacı:** Bu dosya ROTA'nın kod aşamasındaki ortak teknik,
> ürün ve pedagojik referansıdır. Yeni bir geliştirme oturumunda tek
> başına ana bağlam sağlayabilmesi hedeflenir.
>
> **Güncellik ilkesi:** Eski bir karar ile yeni karar çakıştığında bu
> belgedeki güncel hüküm esas alınır. Yeni kararlar eski kararların
> yanına arşiv gibi eklenmez; ilgili bölüm değiştirilir ve belge tek,
> tutarlı sözleşme olarak tutulur.
>
> **Kritik kural:** Kod, ürün kararının yerine geçmez. Pedagojik veya
> ürün davranışı belirsizse kod yazmadan önce karar netleştirilir.

------------------------------------------------------------------------

# 0. ÇALIŞMA KURALI

ROTA'da geliştirme sırası:

1.  Ürün davranışını ve pedagojik amacı netleştir.
2.  Mevcut kodun bu sözleşmeyle uyumunu denetle.
3.  En küçük davranış değişikliği için önce test yaz.
4.  Saf Dart domain/engine mantığını değiştir.
5.  `flutter analyze` ve `flutter test` çalıştır.
6.  Git durumunu kontrol et.
7.  Yeşil test + temiz analyzer + anlaşılır checkpoint olmadan sonraki
    büyük katmana geçme.
8.  UI'ı motor davranışı kesinleşince bağla.

Özellikle şu konular varsayımla kodlanmaz:

-   görev türleri ve görev zincirleri,
-   Practice lifecycle,
-   Reinforcement lifecycle,
-   günlük görev sınırı,
-   Selected Mode / Observed Work Profile / Academic Profile ayrımı,
-   müsaitlik ve kapasite,
-   öğrenci/koç görevi ayrımı,
-   onboarding prior / gerçek Evidence ayrımı,
-   hâkimiyet ve confidence,
-   refresh ve replacement,
-   önkoşul / Bridge,
-   AI ile deterministik motorun görev paylaşımı.

------------------------------------------------------------------------

# 1. ÜRÜN KİMLİĞİ

## 1.1 ROTA nedir?

ROTA, YKS'ye hazırlanan öğrenciler için AI koç destekli kişisel çalışma
platformudur.

Temel kullanıcı:

-   kuruma gitse de gitmese de kendi çalışma düzenini yürütmek isteyen,
-   neyi, ne zaman ve hangi sırayla çalışacağı konusunda desteğe ihtiyaç
    duyan,
-   sürdürülebilir bir çalışma sistemi kurmak isteyen öğrencidir.

ROTA'nın temel vaadi:

-   öğrencinin durumunu doğru anlamak,
-   öğrenme yolunu görünür kılmak,
-   uygun bir çalışma rotası önermek,
-   az veriyle de faydalı çalışmak,
-   veri geldikçe kişiselleştirmeyi geliştirmek,
-   gerekçeyi açıklamak,
-   öğrencinin tercihine saygı göstermektir.

ROTA sonuç, puan veya sıralama garantisi vermez.

Temel iletişim ilkeleri:

-   yönlendirir, zorlamaz;
-   ölçer, yargılamaz;
-   gerçeği söyler, suçlamaz;
-   motive eder, manipüle etmez;
-   öğrencinin özerkliğini korur.

ROTA sloganı:

> **İlerlemeye devam et. Yeter ki bir adım daha at.**

------------------------------------------------------------------------

# 2. SÜRÜM 1 KAPSAMI

## 2.1 Hedef

Sürüm 1:

-   YKS Sayısal öğrencilerini hedefler.
-   TYT + AYT Matematik'te derinlikli akıllı motor kullanır.
-   TYT + AYT Matematik'i tek bütünleşik önkoşul grafiği olarak ele
    alır.
-   Diğer Sayısal derslerde daha basit takip + konu/deneme analizi
    sunar.

Derinlikli motorun ilk şablonu Matematik'tir.

## 2.2 Derinlikli Matematik motoru

Temel parçalar:

-   TYT + AYT bütünleşik önkoşul grafiği,
-   hard / soft prerequisite ilişkileri,
-   dört bileşenli hâkimiyet,
-   `{puan, güven}` yaklaşımı,
-   okunur mastery bantları,
-   Progress / Practice / Repair / Reinforcement / Measurement / Bridge
    görev sözleşmesi,
-   Practice lifecycle,
-   Reinforcement lifecycle,
-   deterministik karar motoru,
-   açıklayıcı ve kişiselleştirici AI katmanı.

## 2.3 Basit takip dersleri

Sürüm 1'de derinlikli günlük motor Matematik'tedir.

Basit takip dersleri:

-   TYT Türkçe,
-   TYT Sosyal,
-   TYT + AYT Fizik,
-   TYT + AYT Kimya,
-   TYT + AYT Biyoloji.

Bu dersler yalnızca yapılacaklar listesine indirgenmemelidir. Az veriyle
de öğrenciyi ileri taşıyan standart pedagojik takip sağlamalıdır.

## 2.4 Öğrencinin kaynakları

ROTA öğrencinin düzenli kullandığı kaynakları yardımcı bağlam olarak
tutabilir:

-   kitap,
-   YouTube kanalı / öğretmen,
-   diğer öğrenme kaynakları.

Kaynak eklemek zorunlu değildir. ROTA öğrencinin kaynağını sırf sistem
listesinde olmadığı için geçersiz saymaz ve kendiliğinden kalite hükmü
vermez.

------------------------------------------------------------------------

# 3. TEKNOLOJİ VE GELİŞTİRME STRATEJİSİ

## 3.1 Teknoloji

**Flutter / Dart.**

TypeScript ara motor yaklaşımı geçerli değildir.

Motor doğrudan Dart ile, UI'dan bağımsız domain/engine katmanları
halinde geliştirilir.

## 3.2 Ortam

-   Flutter
-   Dart
-   VS Code
-   Android Studio / Android SDK
-   İlk hedef Android

## 3.3 AI görev paylaşımı

ChatGPT, Claude ve Gemini ortak teknik referansla kullanılabilir.

AI kritik eğitim kararının sahibi değildir.

> **Deterministik motor karar verir; AI açıklar, kişiselleştirir ve izin
> verilen sınırlar içinde sinyal çıkarır.**

------------------------------------------------------------------------

# 4. GÜNCEL KOD DURUMU

Belgede kayıtlı son doğrulanmış checkpoint:

-   Flutter/Dart
-   branch: `main`
-   **257 test geçti**
-   analyzer temiz
-   çalışma ağacı temiz
-   son kayıtlı push: `c3ca0ae`
-   commit: `Add refresh budget protection policy`

Bu checkpoint tarihsel güvenli başlangıç noktasıdır. Yeni oturumda
gerçek repo durumu ayrıca doğrulanmalıdır.

Mevcut geliştirme alanları arasında:

-   candidate ve ranking,
-   route generation,
-   daily study budget,
-   task effort,
-   budget route selection,
-   plan refresh,
-   refresh evaluation,
-   replacement selection,
-   budgeted ranked route generation,
-   refresh budget policy,
-   reinforcement signal/candidate pipeline

bulunmaktadır.

**Önemli:** Eski dakika-budget ve eski Reinforcement varsayımları yeni
ürün sözleşmesine göre yeniden denetlenmelidir. Yeni davranış
kesinleşmeden eski kod genişletilmez.

------------------------------------------------------------------------

# 5. PROFİL MİMARİSİ

ROTA öğrenciyi tek bir "Başlangıç / Orta / İleri öğrenci" etiketiyle
tanımlamaz.

Üç farklı kavram ayrıdır:

1.  **Selected Mode**
2.  **Observed Work Profile**
3.  **Academic Profile**

## 5.1 Selected Mode

Kullanıcı modları:

-   **Rahat**
-   **Dengeli**
-   **Sıkı**

Bunlar akademik seviye değildir.

Selected Mode, öğrencinin ROTA'dan istediği **çalışma temposunu ve plan
yoğunluğunu** ifade eder.

## 5.2 Observed Work Profile

Öğrencinin genel çalışma davranışını gözlemler.

Örnek sinyaller:

-   düzenlilik,
-   hacim,
-   sürdürülebilirlik,
-   tempo,
-   bağımsızlık,
-   görev tamamlama,
-   deneme disiplini,
-   öğrencinin kendi isteğiyle eklediği çalışmalar.

Düşük ROTA kullanımı tek başına düşük çalışma kapasitesi olarak
yorumlanmaz.

## 5.3 Academic Profile

Academic Profile ders bazlıdır.

Örneğin:

``` text
Selected Mode: Sıkı

Observed Work Profile: İleri kapasite

Academic Profile:
Matematik -> İleri
Fizik     -> Başlangıç
Kimya     -> Orta
```

Matematik Academic Profile altında ayrıca konu bazlı Mastery bulunur.

Bu iç sınıflandırmaların tamamının öğrenciye etiket olarak gösterilmesi
gerekmez.

## 5.4 Çalışma hacmi ile akademik zorluk ayrıdır

> **Çalışma kapasitesi / tempo:** Ne kadar yük taşıyabilir?
>
> **Academic Profile / Mastery:** Bu yükün içeriği ne kadar zor olmalı?

Örneğin Sıkı moddaki fakat Geometride başlangıç düzeyindeki öğrenci 60
soruluk Practice alabilir; sorular kolay-orta ağırlıklı olabilir.

Selected Mode'un hacim standardı akademik zorluk etiketi değildir.

## 5.5 Sıkı mod hedef olabilir

Öğrenci Sıkı modu seçmiş fakat henüz bu tempoyu sürdüremiyorsa:

> Selected Mode korunur -\> Adaptive Tempo geçici olarak düşebilir -\>
> öğrenci kademeli olarak seçtiği standarda yaklaştırılır.

Observed Work Profile, öğrencinin seçtiği modu sessizce yeniden
adlandırmaz.

------------------------------------------------------------------------

# 6. GÖREV SÖZLEŞMESİ

Matematik motorunda altı temel görev türü vardır:

1.  **Progress** --- yeni konuyu öğrenme
2.  **Practice** --- öğrenileni bağımsız soru çözerek uygulama
3.  **Repair** --- belirgin öğrenme açığını teşhis etme ve/veya giderme
4.  **Reinforcement** --- öğrenilmiş bilgiyi yeniden çalışarak
    sağlamlaştırma
5.  **Measurement** --- mevcut durumu ölçme
6.  **Bridge** --- prerequisite açığını kapatma

Ayrı bir `QuestionSolving` task type yoktur. Soru çözümü Practice'in
temel eylemidir.

Tekrar Branş Denemesi yeni bir yedinci ana task type değildir;
**Reinforcement'ın bir biçimidir**.

Deneme Branş Denemesi ise **Measurement** tarafındadır.

------------------------------------------------------------------------

# 7. TEMEL ÖĞRENME ZİNCİRİ

ROTA'nın temel pedagojik sırası:

> **Öğren -\> örnekleri anla -\> bağımsız uygula -\> hatayı/anlamadığın
> noktayı teşhis et -\> yeniden çalış -\> doğruluğu ve tutarlılığı
> geliştir -\> hızlan.**

Hız yeni öğrenmenin başlangıç ölçütü değildir.

Yeni bir konuda öğrencinin:

-   yavaş olması,
-   bir soruda uzun süre düşünmesi,
-   başlangıçta az soru çözmesi

tek başına olumsuzluk değildir.

------------------------------------------------------------------------

# 8. PROGRESS

Progress yeni konuyu öğrenme görevidir.

Öğrenci:

-   kitap,
-   not,
-   video,
-   öğretmen desteği

kullanabilir.

Temel örnek çözümleri incelemek Progress'in pedagojik içeriğinin
parçasıdır; ayrı görev olmak zorunda değildir.

Bir konuyu yalnızca izlemek/okumak öğrenme sürecinin tamamı kabul
edilmez. Bağımsız uygulamaya geçilmelidir.

------------------------------------------------------------------------

# 9. PRACTICE

## 9.1 Practice'in amacı

Practice, öğrencinin bilgiyi **kendi başına kullanma becerisini**
geliştirir.

Öğrenci soruları önce kendisi çözmeye çalışır. Özellikle yeni konuda bir
soruya uzun süre düşünmek normaldir. Çözümden sonra yapılamayan
soruların nedeni mümkün olduğunca incelenir.

## 9.2 İlk dört Practice zorunlu pedagojik başlangıçtır

Yeni konu için yapılandırılmış ilk dört Practice korunur.

Denetimlerde önerilen "erken adaptasyonla Practice 3-4'ü atlama"
yaklaşımı kabul edilmemiştir.

Zorluk yapısı:

-   **Practice 1-2:** kolay + orta ağırlık
-   **Practice 3-4:** orta + zor ağırlık

Bu dört Practice yalnızca veri toplama noktaları değildir; öğrencinin
soru çözme deneyimini geliştiren öğrenme sürecidir.

## 9.3 Practice hacimleri

Her Practice aynı Selected Mode hacmini kullanır:

-   **Rahat:** 30 soru
-   **Dengeli:** 40 soru
-   **Sıkı:** 60 soru

Bir konuda dört Practice tamamlandığında standart toplam bağımsız
Practice hacmi:

-   Rahat: **120 soru**
-   Dengeli: **160 soru**
-   Sıkı: **240 soru**

Bu sayılar başlangıç standardıdır. Gelecekte öğrenci davranışına göre
adaptifleşebilir; ancak Observed Work Profile bu standardı sessizce
değiştirmez.

## 9.4 Practice sırası ve zamanlama

Practice'ler sıralıdır:

``` text
Progress -> P1 -> P2 -> P3 -> P4
```

P1, Progress'ten **aynı gün**, mümkün değilse **ertesi gün** hedeflenir.
ROTA kendi planında konu öğrenme ile ilk bağımsız uygulama arasında uzun
boşluk bırakmamalıdır.

P2, P3 ve P4 için:

-   bir önceki Practice tamamlandıktan sonra sıradaki Practice **1-3 gün
    içinde hedeflenir**;
-   üç gün sert deadline değildir;
-   öğrenci geciktirirse görev başarısız sayılmaz veya zorla tamamlanmış
    kabul edilmez;
-   sıradaki Practice gecikmiş / yüksek öncelikli aday olarak kalabilir;
-   öğrenci özerkliği ve günlük plan sözleşmesi korunur.

## 9.5 Practice ve Reinforcement paralel lifecycle'lardır

P1 tamamlandığında Reinforcement lifecycle'ının referans tarihi oluşur.

P2-P4 kendi sıralı Practice lifecycle'ında ilerler. Reinforcement kendi
haftalık pencerelerinde ilerler.

Motor Practice 2-4 ile Reinforcement arasında yapay bir "önce mutlaka R
sonra P" sırası kurmaz.

------------------------------------------------------------------------

# 10. PRACTICE EVIDENCE

Practice tamamlandığında mümkün olduğunda:

-   konu,
-   gerçek soru sayısı,
-   doğru,
-   yanlış,
-   boş,
-   uygun olduğunda zorluk ve hata nedeni

kaydedilir.

## 10.1 Yalnız "Tamamladım" da Evidence'dır

Öğrenci soru sayısı veya D/Y/B girmeden Practice'i "Tamamladım" olarak
işaretlerse çalışma çöpe gitmez.

ROTA şu bilgiyi gerçek fakat zayıf akademik Evidence olarak tutar:

> Öğrenci bu konuda Practice yaptığını bildirdi.

Ancak sistem **30/40/60 sorunun gerçekten çözüldüğünü varsaymaz**.

Gerçek soru sayısı, D/Y/B ve benzeri yapılandırılmış veriler daha güçlü
Evidence oluşturur.

Bu Evidence türleri için sabit `0.1` vb. katsayı henüz belirlenmemiştir.

------------------------------------------------------------------------

# 11. REINFORCEMENT --- GÜNCEL SADE MODEL

## 11.1 Eski profil-temelli takvim kaldırıldı

Aşağıdaki eski sistem artık geçerli değildir:

``` text
Rahat    -> 7 / 21 / 40
Dengeli  -> 10 / 25 / 50
Sıkı     -> 13 / 29 / 59
```

Selected Mode veya Observed Work Profile Reinforcement aralıklarını bu
şekilde belirlemez.

Kodda bu eski interval/profile davranışının kalıntıları bulunursa
kaldırılmalı veya yeni sözleşmeyle yeniden tasarlanmalıdır.

## 11.2 Reinforcement lifecycle başlangıcı

Reinforcement referans tarihi **P1 tamamlandığında** oluşur.

Progress'in tamamlanması tek başına Reinforcement lifecycle'ını
başlatmaz.

## 11.3 İlk hafta Reinforcement yok

P1'den sonraki ilk hafta topic Reinforcement üretilmez.

Amaç:

-   P2-P4'e alan açmak,
-   yeni Matematik konularına alan açmak,
-   farklı derslerin görevlerine planlama alanı bırakmak,
-   aynı konunun günlük planı gereksiz yere işgal etmesini önlemek.

İlk hafta zaten yoğun bağımsız Practice dönemidir.

## 11.4 Topic Reinforcement --- 2., 3. ve 4. haftalar

İlk fiili topic Reinforcement, P1'e göre **ikinci haftalık pencerede**
başlar.

Pedagojik adlandırmada bunlar:

-   R1 --- 2. hafta
-   R2 --- 3. hafta
-   R3 --- 4. hafta

olarak ele alınır.

Her topic Reinforcement:

-   yaklaşık **15 soru** içerir,
-   Selected Mode'a göre 30/40/60'a dönüşmez,
-   süre tutulmasını gerektirmez,
-   sınav değildir,
-   kaynak kullanımına izin verir,
-   öğrencinin notuna dönmesine izin verir,
-   konu anlatımı/video/örnek çözüm incelemesine izin verir,
-   konu tekrarı ile soru çözümünü aynı çalışmada birleştirir.

Bu nedenle topic Reinforcement gerçek performans ölçümü değildir.

## 11.5 Reinforcement sırası ve erteleme davranışı

Topic Reinforcement üç sıralı pedagojik adımdan oluşur:

- R1
- R2
- R3

Normal akışta R1, P1 tamamlandıktan sonraki ikinci haftalık dönemde hedeflenir.

Reinforcement'lar sıralıdır:

```text
R1 -> R2 -> R3
```

Bir Reinforcement hedeflendiği dönemde tamamlanmazsa kaybolmaz ve bir sonraki Reinforcement'a geçilmez.

Örneğin R1 yapılmadıysa R2 üretilmez; R1 öğrencinin sıradaki topic Reinforcement'ı olarak kalır ve sonraki uygun planlama fırsatlarında yeniden değerlendirilir.

Ancak ertelenen Reinforcement:

- ertesi gün otomatik olarak zorla plana eklenmez,
- günlük dört görev sınırını aşmaz,
- öğrencinin bilinçli seçtiği görevleri otomatik olarak silmez,
- aynı anda birden fazla eski Reinforcement borcu üretmez.

Amaç öğrencinin konu başına üç Reinforcement temasını gerçekten tamamlamasını sağlarken görev kartopu oluşturmamaktır.

Practice lifecycle ve topic Reinforcement lifecycle bu açıdan benzerdir: Practice `P1 -> P2 -> P3 -> P4`, topic Reinforcement `R1 -> R2 -> R3` şeklinde sıra atlamadan ilerler. Fark, Practice'in yoğun başlangıç döneminde 1-3 günlük hedeflerle; Reinforcement'ın ise daha seyrek ve esnek aralıklarla planlanmasıdır.

## 11.6 Reinforcement otomatik Practice üretmez

Topic Reinforcement zaten aktif soru çözümü içerir.

Bu nedenle:

> **Reinforcement -\> otomatik Practice**

zinciri kullanılmaz.

Reinforcement sırasında belirgin bir öğrenme açığı ortaya çıkarsa
**Repair adayı** oluşabilir.

## 11.7 5. hafta ve sonrası --- Tekrar Branş Denemesi

5.  haftadan sonra tek tek konu Reinforcement'ları giderek **Tekrar
    Branş Denemesi** biçimine dönüşür.

Bu çalışma:

-   ana task type olarak `Reinforcement` altında kalır,
-   görev biçimi/subtype düzeyinde `branchReinforcement` olarak
    modellenebilir,
-   öğrenme / hatırlama amaçlıdır,
-   süre baskısı taşımaz,
-   gerektiğinde kaynak kullanımına izin verir.

İlk 2-4. hafta topic çalışmaları subtype düzeyinde `topicReinforcement`
olarak modellenebilir.

`topicReinforcement` ve `branchReinforcement` adları teknik tasarımda
kullanılabilecek güncel çalışma adlarıdır; yeni bir yedinci ana task
type açılmaz.

## 11.8 Deneme Branş Denemesi ayrıdır

**Deneme Branş Denemesi** gerçek performans ölçümüdür:

-   Measurement tarafındadır,
-   sınav koşullarına daha yakındır,
-   kaynak kullanılmaz,
-   performans Evidence'ı üretir.

Kesin ayrım:

``` text
Tekrar Branş Denemesi
-> REINFORCEMENT
-> öğrenmek / hatırlamak
-> kaynak kullanımı serbest
-> süre baskısı yok

Deneme Branş Denemesi
-> MEASUREMENT
-> performansı ölçmek
-> kaynak kullanılmaz
-> sınav koşullarına yakın
```

## 11.9 Erken öğrenme dönemi özeti

``` text
Progress
   |
   v
P1 tamamlandı -------- Reinforcement referans tarihi
   |
   +--> P2: 1-3 gün içinde hedef
   +--> P3: P2'den 1-3 gün içinde hedef
   +--> P4: P3'ten 1-3 gün içinde hedef

1. hafta  -> topic Reinforcement YOK
2. hafta  -> R1 hedeflenir
             |
             | tamamlanmazsa R1 sıradaki Reinforcement olarak kalır
             v
R1 tamamlandı -> sonraki uygun haftalık dönemde R2
R2 tamamlandı -> sonraki uygun haftalık dönemde R3
R3 tamamlandı -> topic Reinforcement lifecycle tamamlandı
                 |
                 v
          branchReinforcement
          / Tekrar Branş Denemesi
```

Bu yapı aynı konunun planı uzun süre doldurmasını önlemeyi ve yeni
konulara / diğer derslere alan bırakmayı amaçlar.

------------------------------------------------------------------------

# 12. REPAIR

Repair, belirgin öğrenme açığını gidermeye yöneliktir.

Repair yalnızca "konuyu yeniden anlat" görevi değildir; gerektiğinde
**teşhis + onarım** birlikte yapabilir.

Örnek çelişkili Evidence:

-   Practice güçlü,
-   Branş denemeleri güçlü,
-   fakat üç genel denemede aynı konudan tekrar eden hata.

Bu durumda sorun yalnızca zaman yönetimi varsayılmaz.

Repair:

> yanlış/boş deneme sorularına dön -\> benzer karma sorular çöz -\>
> problemin kavram / hatırlama / transfer boyutunu anlamaya çalış -\>
> hedefli müdahale yap

akışını içerebilir.

Ayrı Measurement her durumda zorunlu değildir.

Repair otomatik olarak ayrı Practice üretmek zorunda değildir. Bağımsız
Practice ihtiyacı varsa motor ayrıca değerlendirebilir.

------------------------------------------------------------------------

# 13. MEASUREMENT

Measurement öğretme görevi değildir.

Amaç:

> öğrencinin mevcut durumuna ilişkin yeni ve daha güvenilir veri
> toplamak.

Measurement özellikle gerçekten durumun bilinmediği veya ek ölçümün
karar değerini anlamlı biçimde artıracağı durumlarda kullanılabilir.

Measurement sonucu:

-   rota korunabilir,
-   Repair oluşabilir,
-   Reinforcement ihtiyacı görülebilir,
-   Practice ihtiyacı doğabilir.

Measurement ile Reinforcement aynı şey değildir:

-   **Measurement = ölçmek**
-   **Reinforcement = öğrenmek / hatırlamak / sağlamlaştırmak**

------------------------------------------------------------------------

# 14. ONBOARDING PRIOR VE GERÇEK EVIDENCE

Onboarding sırasında öğrenciden alınabilecek bilgiler:

-   sorumlu olduğu dersler,
-   yaklaşık net ortalamaları,
-   çalışma alışkanlıkları / kapasite beyanı,
-   Selected Mode.

Onboarding netleri ve öz-değerlendirmeler **gerçek akademik Evidence
değildir**.

Bunlar ayrı **initial prior** olarak tutulur.

Gerçek çalışma ve deneme Evidence'ı geldikçe prior'ın etkisi azalır.

Motor onboarding bilgisini gerçek Practice/deneme kanıtıyla aynı güven
düzeyinde ele almaz.

------------------------------------------------------------------------

# 15. AZ VERİYLE ÇALIŞMA İLKESİ

ROTA'nın temel ilkesi:

> **Zengin veri kişiselleştirmeyi artırır; ROTA'nın temel faydasının
> önkoşulu değildir.**

Öğrenci ROTA'yı kullanıyor fakat az veri giriyorsa:

-   standart pedagojik sistem devam eder,
-   güçlü profil hükümleri verilmez,
-   gereksiz kişiselleştirme yapılmaz,
-   plan veri eksikliği nedeniyle cezalandırıcı biçimde ağırlaştırılmaz.

Öğrenci ROTA'yı kullanmıyor ve veri yoksa:

> "öğrenci çalışmıyor"

sonucu çıkarılmaz.

Bu durumda veri problemi değil, ürün kullanımı problemi olabilir.

ROTA öğrencinin yalnız koçluk için değil günlük işini kolaylaştırmak
için açabileceği araçlar sunmalıdır.

Aday araçlar:

-   puan / net hesaplama,
-   kronometre,
-   ajanda,
-   yanlış / boş soru havuzu,
-   sınava kalan gün,
-   ileride başka öğrenci araçları.

Ürün düşüncesi:

> **"Bana veri gir ki sana yardım edeyim" değil;**
>
> **"İşini kolaylaştırayım, kullandıkça seni daha iyi tanıyayım."**

Bu araçların ayrıntılı ürün tasarımı ayrı oturumda yapılacaktır.

------------------------------------------------------------------------

# 16. ACADEMIC PROFILE, ADAPTIVE PLAN VE EVIDENCE TRENDLERİ

Academic Profile ile günlük/adaptif plan aynı hızda değişmez.

Tek kötü gerçek deneme:

-   Academic Profile'ı hemen değiştirmez,
-   fakat planı geçici olarak daha temkinli yapabilir.

Genel güçlü trend standardı:

> **Üç benzer tür gerçek deneme**

olarak korunur.

Ancak onboarding prior ile **ilk iki gerçek deneme arasında çok büyük ve
aynı yönde fark** varsa, üç deneme tamamlanmadan da ciddi erken sinyal
olarak değerlendirilebilir.

Bu, prior ile Evidence ayrımını bozmaz; gerçek Evidence'ın prior'ı hızla
düzeltmesine izin verir.

------------------------------------------------------------------------

# 17. HÂKİMİYET MODELİ

Hâkimiyet dört ana bileşenden beslenebilir:

1.  çalışma süresi,
2.  pratik miktarı,
3.  soru başarısı,
4.  deneme performansı.

Her değer `{puan, güven}` yaklaşımıyla ele alınır.

Az, eski veya zayıf veri düşük güven üretir.

Okunur bantlar:

``` text
başlanmadı
-> öğreniliyor
-> gelişiyor
-> hâkim
-> pekişmiş
```

Hâkimiyet düşebilir.

Ancak yeni Reinforcement modeli yalnız mastery band düşüşünü bekleyen
saf evidence-driven bir model değildir.

Özellikle erken dönemde:

-   P1 sonrası ilk hafta yoğun Practice,
-   2-4. haftalarda yapısal topic Reinforcement,
-   5.  hafta+ branch Reinforcement

pedagojik minimum ritmi vardır.

Mastery ve Evidence yine Repair, ranking, zorluk, kişiselleştirme ve
diğer kararları etkileyebilir.

------------------------------------------------------------------------

# 18. SORU KANALLARI VE EVIDENCE

## 18.1 Practice

Konu belirli soru çözümü:

-   topic,
-   gerçek soru sayısı,
-   D/Y/B,
-   varsa zorluk/hata nedeni

sinyali üretebilir.

## 18.2 Topic Reinforcement

Yaklaşık 15 soruluk öğrenme amaçlı çalışmadır.

Kaynak kullanımı serbest olduğu için Practice veya Measurement ile aynı
Evidence gücünde değerlendirilmemelidir.

Reinforcement tamamlanması gerçek bir çalışma olayıdır; ancak performans
sınavı gibi yorumlanmaz.

## 18.3 Deneme

Deneme:

-   konu bazlı performans,
-   konu-üstü tanıma / transfer

sinyali üretebilir.

Transfer'in nihai ağırlığı beta aşamasında kalibre edilecektir.

------------------------------------------------------------------------

# 19. GÖREV SÜRESİ VE MÜSAİTLİK

## 19.1 Göreve önceden süre atanmaz

Öğrenci veya koç görev oluştururken görev için zorunlu
`estimatedMinutes` istenmez.

Görev kendi başına bir çalışma eylemidir.

## 19.2 Gerçekleşen süre sonradan Evidence olabilir

Çalışma sırasında:

-   Başladım
-   Mola
-   Bitirdim

akışı kullanılabilir.

Kronometreyle ölçülen süre yüksek güvenli gerçekleşen süre verisidir.

Kronometre kullanılmazsa sonradan bildirilen süre daha düşük güvenli
veri olabilir.

Bu:

> önceden tahmin edilmiş task süresi değil, gerçekleşen çalışma
> Evidence'ıdır.

## 19.3 Müsaitlik kesin dakika kotası değildir

"Yarın yaklaşık 2 saat çalışabilirim" beyanı kesin 120 dakikalık hard
budget değildir.

ROTA bunu koçun önerdiği iş yükünün yoğunluğunu ayarlamak için
kullanabilir.

Öğrencinin kendi seçtiği işler yaklaşık müsaitliği aşabilir.

------------------------------------------------------------------------

# 20. KAPASİTE, TERCİH VE ADAPTIVE TEMPO

Kapasite öğrencinin zaman içinde gerçekten sürdürebildiği çalışma
örüntüsüdür.

Selected Mode öğrencinin tercih ettiği tempodur.

Observed Work Profile gözlenen davranıştır.

Bunlar birbirine indirgenmez.

Kapasite-tercih çelişkisi süreklilik gösterirse öğrenciye
gösterilebilir; tek günlük sapma öğrencinin tercihini geçersiz kılmaz.

------------------------------------------------------------------------

# 21. GÜNLÜK DÖRT GÖREV SINIRI

Normal ortak günlük çalışma listesinde:

> **Maksimum 4 görev.**

Bu:

-   görev sayısı sınırıdır,
-   dakika budget'ı değildir.

Progress ve Practice ayrı görevlerdir.

Reinforcement da slot tüketir.

Öğrencinin bilinçli eklediği işler de ortak liste sözleşmesi içinde
değerlendirilir; yaklaşık müsaitlik aşımı tek başına silme nedeni
değildir.

Practice ve Reinforcement zamanlama politikaları dört görev sınırıyla
birlikte çalışmalıdır.

------------------------------------------------------------------------

# 22. ÖĞRENCİ VE KOÇ GÖREVLERİ

Öğrencinin bilinçli seçimi güçlü koruma taşır.

Koç görevleri:

-   rota,
-   prerequisites,
-   Mastery,
-   Practice lifecycle,
-   Reinforcement lifecycle,
-   Repair / Measurement ihtiyacı,
-   yaklaşık müsaitlik

gibi verilerle oluşturulur.

Koç öğrencinin yerine karar vermek yerine uygun rota önerir.

------------------------------------------------------------------------

# 23. PLAN REFRESH VE LIFECYCLE

Temel ayrım:

-   active plan,
-   draftStudentModified,
-   draftUntouched.

Active plan refresh ile değiştirilmez.

Öğrencinin bilinçli değiştirdiği draft sessizce ağırlaştırılmaz.

Eksik lifecycle metadata'sı varsa sistem öğrencinin niyetini tahmin
ederek işi değiştirmemelidir.

Refresh:

1.  mevcut task'ı değerlendirir,
2.  keep / replace kararı üretir,
3.  gerekiyorsa ranked refreshed candidates içinden replacement seçer,
4.  korunan görevleri dikkate alır,
5.  dört görev sınırı ve güncel lifecycle kurallarıyla son planı
    oluşturur.

Practice 1-4 ve Reinforcement pencereleri refresh/replacement tarafından
yanlışlıkla yeniden başlatılmamalıdır.

------------------------------------------------------------------------

# 24. BÜTÇE VE EFFORT KODLARI

Mevcut kodda daha önce geliştirilen:

-   `DailyStudyBudget`
-   `StudyTaskEffort`
-   `budget_route_selector`
-   `study_task_effort_policy`
-   `budgeted_ranked_route_generator`
-   `plan_refresh_budget_policy`

katmanları bulunmaktadır.

Eski dakika-budget varsayımı güncel ürün sözleşmesiyle yeniden
değerlendirilmelidir.

Yeni temel karar:

> Günlük müsaitlik, görevlerin tahmini dakika toplamını kesin olarak
> sınırlayan hard budget değildir.

Bu katmanlar ileride:

-   workload yoğunluğu,
-   candidate seçimi,
-   student choice protection,
-   gerçekleşen süre Evidence'ı

ayrımına göre yeniden tasarlanabilir.

Kesin tasarım oluşmadan eski budget davranışı genişletilmez.

------------------------------------------------------------------------

# 25. ÖNKOŞUL VE BRIDGE

TYT + AYT Matematik tek bütünleşik prerequisite grafiğidir.

Kenarlar:

-   hard,
-   soft

olabilir.

Hard prerequisite kilitli bir konuyu öğrenci kendi günlük planına
eklemek isterse sistem bunu yasaklamaz veya sessizce silmez.

Ürün kontratı:

> **İzin ver + prerequisite gerçeğini göster + uygun Bridge öner.**

Kilitli konu open gibi gösterilmez.

Bridge:

-   hedef konunun kendisi değildir,
-   prerequisite açığını kapatır,
-   günlük görev kapasitesinde slot tüketir,
-   depth ve zincirleme önleme kurallarına tabidir.

------------------------------------------------------------------------

# 26. KARAR MOTORU

Ana pedagojik kaynaklar:

-   Progress,
-   Practice,
-   Repair,
-   Reinforcement,
-   Measurement,
-   Bridge.

Motor deterministiktir.

AI:

-   açıklama,
-   kişiselleştirme,
-   sınırlı sinyal çıkarma

katmanıdır.

AI olmadan da temel rota üretilebilmelidir.

------------------------------------------------------------------------

# 27. GÜNLÜK ÇALIŞMA AKIŞI

Genel akış:

``` text
akşam taslak
   |
sabah tazeleme
   |
günlük görev listesi
   |
Başladım
   |
Mola
   |
Bitirdim
   |
gerçekleşen süre (varsa)
   |
Practice / deneme / reinforcement verisi
   |
Evidence
   |
gelecek rota güncellemesi
```

Görev listesi normalde gün içinde sabit kalır; durum değişir.

Kaçırılan görev otomatik olarak ertesi güne taşınmaz.

Motor ertesi günü yeniden üretirken geçmiş sinyalleri ve lifecycle
durumunu dikkate alır.

Topic Reinforcement için ayrıca kaçırılan haftalık pencere borç olarak
yığılmaz.

------------------------------------------------------------------------

# 28. AI KOÇUN PEDAGOJİK DİLİ

AI koç yalnızca "şunu yap" dememelidir.

Gerektiğinde neden ve nasıl yapılacağını da açıklar.

Özellikle:

-   önce anlamayı,
-   örnekleri incelemeyi,
-   kendi başına düşünmeyi,
-   soruya zaman ayırmayı,
-   çözümden sonra hatayı incelemeyi,
-   hızın daha sonraki aşama olduğunu

hatırlatabilir.

Dil:

-   açık,
-   sakin,
-   yargısız,
-   veriyle gerekçeli,
-   öğrencinin özerkliğine saygılı

olmalıdır.

------------------------------------------------------------------------

# 29. GÜVENLİK

ROTA çalışma stratejisti ve AI koçtur; terapist değildir.

Yüksek riskli kriz sinyallerinde akademik motorun önüne bağımsız
güvenlik katmanı geçmelidir.

Güvenlik mimarisi:

-   bağımsız,
-   öncelikli,
-   ilk kapı

olarak ele alınmalıdır.

------------------------------------------------------------------------

# 30. BİLİNÇLİ OLARAK AÇIK BIRAKILAN KARARLAR

Aşağıdaki başlıklar henüz kesin değildir veya beta / ayrı ürün oturumu
gerektirir:

-   Mastery bileşen ağırlıkları,
-   confidence kalibrasyonu,
-   prerequisite eşikleri,
-   oturum / deneme çarpanları,
-   hata nedenlerinin Mastery hesabındaki ağırlığı,
-   Practice "yalnız tamamladım" Evidence'ının matematiksel ağırlığı,
-   mola tetikleyici çarpanları,
-   kapasite-tercih çelişkisi eşiği,
-   Adaptive Tempo'nun kesin algoritması,
-   Academic Profile eşikleri ve geçiş kuralları,
-   zorluk sinyalinin kesin kaynağı,
-   transfer'in nihai rolü,
-   deneme sonucunun giriş biçimi,
-   Reinforcement yığılması,
-   aynı haftada kaç topic Reinforcement'ın plana alınacağı,
-   `15 × konu sayısı` büyüdüğünde seçim politikası,
-   5.  hafta+ Tekrar Branş Denemesi'nin konu seçme / hacim / sıklık
        algoritması,
-   `topicReinforcement` / `branchReinforcement` subtype'larının kesin
    domain temsili,
-   basit takip derslerinin tekrar sistemi,
-   tüm TYT-AYT konu yüküyle haftalık program kapasitesi,
-   çözüm üreten AI'ın fotoğraftan matematik okuma doğruluğu,
-   üyelik kademeleri,
-   mentör katmanı,
-   güvenlik katmanının ayrıntılı mekanizması,
-   "Öğrenci ROTA'yı neden her gün açsın?" ürün oturumu ve günlük
    araçların kesin kapsamı.

Bu başlıklar varsayımla kodlanmaz.

------------------------------------------------------------------------

# 31. MEVCUT REINFORCEMENT KODU İÇİN DENETİM NOTU

Mevcut kod aramasında Reinforcement şu ana katmanlarda görülmüştür:

-   `lib/domain/reinforcement_signal.dart`
-   `lib/domain/study_candidate.dart`
-   `lib/domain/study_route.dart`
-   `lib/engine/signal/reinforcement_signal_generator.dart`
-   `lib/engine/candidate/reinforcement_candidate_generator.dart`
-   candidate generator / merger
-   route builder / selector
-   planning / replacement / invalidation
-   ranking
-   ilgili unit ve pipeline testleri

Mevcut `reinforcement_signal_generator.dart` davranışı Reinforcement
ihtiyacını esas olarak
`MasteryBand -> strengthByBand -> masteryMaintenance` üzerinden
üretmektedir.

Bu davranış yeni erken dönem Reinforcement sözleşmesini tek başına
karşılamaz.

Yeni modelde:

-   P1 tamamlanma zamanı,
-   haftalık Reinforcement penceresi,
-   o pencerenin tamamlanıp tamamlanmadığı,
-   2-4. hafta topic Reinforcement,
-   5.  hafta+ branch Reinforcement

gibi lifecycle bilgileri gerekecektir.

`lastMeaningfulEvidenceAt` bu lifecycle'ın başlangıcı olarak
kullanılmamalıdır; yeni Evidence geldikçe değiştiği için Reinforcement
takvimini yanlışlıkla yeniden başlatabilir.

Mevcut `StudentTopicState` şu anda:

-   `topicId`
-   `hasEvidence`
-   `mastery`
-   `masteryBand`
-   `lastMeaningfulEvidenceAt`
-   `calculatedAt`

alanlarını taşımaktadır ve yeni Reinforcement lifecycle'ını tek başına
ifade etmek için yeterli görünmemektedir.

Ancak lifecycle bilgisinin tam olarak hangi domain modelinde tutulacağı
henüz kodlanmadan tasarlanmalıdır.

------------------------------------------------------------------------

# 32. SONRAKİ KODLAMA SIRASI

## R-INF-01 --- Reinforcement sadeleştirme

### R-INF-01A --- Mevcut davranışı test düzeyinde çıkar

Önce:

-   `reinforcement_signal_generator_test.dart`
-   `reinforcement_pipeline_test.dart`

okunur.

Hangi testlerin eski `MasteryBand -> masteryMaintenance` varsayımını
sözleşme olarak koruduğu belirlenir.

### R-INF-01B --- Lifecycle domain sözleşmesini belirle

Kod yazmadan önce şu verilerin doğru sahibi belirlenir:

-   P1 tamamlanma zamanı,
-   Practice sıra/progress bilgisi,
-   Reinforcement haftalık pencere durumu,
-   tamamlanmış topic Reinforcement pencereleri,
-   branch Reinforcement'a geçiş bilgisi.

### R-INF-01C --- İlk kırmızı test

En küçük yeni davranış için önce test yazılır.

İlk hedef eski sistemi bir kerede silmek değil, yeni lifecycle'ın en
küçük deterministik kuralını kanıtlamaktır.

Önerilen ilk davranış:

> P1 tamamlanmamış konu topic Reinforcement üretmez; P1 tamamlanmış konu
> ilk haftada da topic Reinforcement üretmez.

Ardından 2., 3., 4. hafta ve kaçırılmış pencere davranışları ayrı küçük
testlerle eklenir.

### Sonraki adımlar

Reinforcement lifecycle yeşil olduktan sonra:

1.  Practice 1-4 lifecycle ve 1-3 günlük hedefleme,
2.  Practice 30/40/60 Selected Mode hacmi,
3.  Practice Evidence,
4.  topicReinforcement / branchReinforcement temsili,
5.  Repair sinyali entegrasyonu,
6.  dört görev sınırıyla birlikte planlama,
7.  refresh/replacement doğrulaması,
8.  eski budget/effort katmanlarının yeniden tasarımı

küçük TDD adımlarıyla ele alınır.

Her değişiklikten sonra:

``` text
flutter analyze
flutter test
git status
```

kontrol edilir.

------------------------------------------------------------------------

# 33. BELGENİN GÜNCELLİK İLKESİ

Bu belge karar günlüğü değildir.

Yeni ürün/pedagoji/teknik karar alındığında:

1.  ilgili eski hüküm bulunur,
2.  eski hüküm güncellenir veya kaldırılır,
3.  yeni hüküm doğru bölüme işlenir,
4.  gerekiyorsa Açık Kararlar güncellenir,
5.  kod etkisi belirtilir,
6.  çelişkili eski ifade bırakılmaz.

Amaç:

> **ROTA şu anda nasıl davranmalıdır?**

sorusuna tek ve tutarlı cevap vermektir.
