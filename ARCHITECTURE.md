# ROTA — Teknik Mimari

**Sürüm:** v0.2
**Durum:** Taslak — Claude ve Gemini bağımsız mimari incelemeleri sonrası
**Amaç:** ROTA'nın teknik olarak nasıl kurulacağını tanımlamak.

Bu belge ürün vizyonunun tekrarı değildir. Ürün özelliklerinin ayrıntıları ROTA Vizyon Belgesi, Kod Aşaması Devir Belgesi ve ilgili alan belgelerinde tutulur.

Bu belge yalnızca:

* ürün kararlarının teknik mimariye etkisini,
* kabul edilmiş teknik çözümleri,
* sistem sınırlarını,
* henüz açık olan teknik kararları

tanımlar.

---

# 1. Karar Etiketleri

Bu belgede üç temel karar türü kullanılır.

## [ÜRÜN KARARI]

ROTA'nın ürün belgelerinde kesinleşmiş karardır.

Teknik mimari bu karara uymak zorundadır.

Teknik kolaylık gerekçesiyle sessizce değiştirilemez.

## [TEKNİK KARAR]

Ürün kararlarını gerçekleştirmek için geliştirme sürecinde seçilmiş teknik çözümdür.

Gerekirse ileride değiştirilebilir; değişiklik açık biçimde kayıt altına alınır.

## [AÇIK KARAR]

Henüz kesinleşmemiş teknik veya mimari konudur.

AI değerlendirmeleri öneri sunabilir fakat öneriler insan onayı olmadan proje kararı değildir.

---

# 2. Temel Teknoloji

[TEKNİK KARAR]

ROTA mobil uygulaması doğrudan:

* Flutter
* Dart

ile geliştirilecektir.

[TEKNİK KARAR]

İlk hedef platform Android'dir.

Mimari Flutter'ın ileride diğer platformlara açılmasını gereksiz yere engellememelidir; ancak ilk geliştirme ve test önceliği Android olacaktır.

[TEKNİK KARAR]

Backend için başlangıç tercihi:

* Supabase
* PostgreSQL

olacaktır.

[TEKNİK KARAR]

Learning Engine, nihai uygulamayla aynı dilde geliştirilecektir.

Motor saf Dart olacaktır.

## Teknik karar değişikliği

[TEKNİK KARAR]

Önceki teknik planda:

```text
TypeScript motor prototipi
→ doğrulama
→ Dart'a taşıma
```

yaklaşımı bulunuyordu.

Bu karar daha sonra değiştirilmiştir.

Güncel yol:

```text
Doğrudan Dart Learning Engine
→ test
→ Flutter uygulamasına entegrasyon
```

TypeScript artık aktif geliştirme yolunun parçası değildir.

---

# 3. Mimari Ana İlke

[ÜRÜN KARARI]

ROTA'nın kritik akademik kararlarını üretken AI değil, deterministik Learning Engine verir.

AI:

* motor kararlarını açıklayabilir,
* kişiselleştirebilir,
* uygun dile çevirebilir,
* bazı alanlarda sinyal üretebilir,

ancak kritik akademik kararın sahibi değildir.

[TEKNİK KARAR]

Learning Engine:

* Flutter UI'dan,
* Supabase'den,
* AI servislerinden,
* ağ bağlantısından

bağımsız çalışabilecek şekilde tasarlanacaktır.

Temel bağımlılık yönü:

```text
Presentation
     ↓
Application
     ↓
Domain + Learning Engine
```

Dış dünya:

```text
Supabase
Local Storage
AI Providers
Notifications
OCR / Image Services
      ↓
Infrastructure
      ↓
Application
      ↓
Domain + Learning Engine
```

Domain ve Learning Engine dış katmanları bilmez.

---

# 4. Mimari Katmanlar

## 4.1 Domain

[TEKNİK KARAR]

Domain katmanı ROTA'nın temel kavramlarını ve veri yapılarını tanımlar.

Örnek kavramlar:

* Subject
* Topic
* Prerequisite
* Evidence
* Mastery
* StudentTopicState
* StudyTask
* StudyRoute
* ExamResult
* StudySession
* PlanningMode
* Reason

Domain'in temel görevi kavramları ve veriyi taşımaktır.

### Domain / Engine sınırı

[TEKNİK KARAR]

Pratik sınır:

> **Veri ve değişmez kavram Domain'dedir; akademik hesaplama Learning Engine'dedir.**

Başka bir ifadeyle:

> **Bir akademik değer hesaplanıyorsa veya eğitim kararı üretiliyorsa Engine'dedir.**

Örneğin:

`Mastery` yapısı Domain'de bulunabilir:

```text
score
confidence
```

Ancak bu değerlerin nasıl hesaplandığı Learning Engine'in sorumluluğudur.

Domain:

* Flutter import etmez,
* Supabase bilmez,
* AI bilmez,
* HTTP bilmez,
* kullanıcı arayüzü davranışı içermez.

---

## 4.2 Learning Engine

[ÜRÜN KARARI]

Sürüm 1'de derinlikli Learning Engine yalnızca TYT + AYT Matematik için çalışacaktır.

TYT ve AYT Matematik iki ayrı motor değildir.

Tek bütünleşik matematik öğrenme sistemi kullanılır.

[TEKNİK KARAR]

Learning Engine saf Dart kodudur.

Motor mümkün olduğunca:

* stateless,
* side-effect içermeyen,
* deterministik,
* immutable girdilerle çalışan

bir yapı olacaktır.

Learning Engine:

* doğrudan veritabanı okumaz/yazmaz,
* Supabase SDK kullanmaz,
* AI çağrısı yapmaz,
* Flutter state yönetmez,
* bildirim göndermez,
* sistem saatini doğrudan okumaz.

---

## 4.3 Application

[TEKNİK KARAR]

Application katmanı korunacaktır ancak ince tutulacaktır.

Görevi akademik hesaplama yapmak değil, **use-case orchestration** yapmaktır.

Örnek:

```text
gerekli öğrenci durumunu al
→ yeni Evidence'ları al
→ Engine'i çağır
→ sonucu al
→ persistence katmanına ilet
```

Örnek use-case'ler:

* yarının rotasını üret,
* deneme sonucunu işle,
* çalışma oturumunu kapat,
* sabah planını tazele,
* yeni çalışma gününe geç.

Application katmanına mastery formülü, prerequisite gate veya rota sıralama algoritması yazılmaz.

---

## 4.4 Infrastructure

[TEKNİK KARAR]

Dış sistem bağlantıları burada bulunur.

Örnek:

* Supabase
* PostgreSQL erişimi
* local storage
* AI provider adapter'ları
* bildirim servisleri
* OCR / image servisleri

Infrastructure, Domain ve Engine'i dış servislere bağlar; fakat dış servis ayrıntıları motora sızmaz.

---

## 4.5 Presentation

[TEKNİK KARAR]

Flutter ekranları ve kullanıcı etkileşimi burada bulunur.

Presentation:

* kullanıcı girdisini alır,
* state'i gösterir,
* Application use-case'lerini çağırır,
* sonucu ekrana yansıtır.

Presentation katmanında akademik eğitim kuralları bulunmaz.

---

# 5. Matematik Önkoşul Grafiği

[ÜRÜN KARARI]

TYT + AYT Matematik tek bütünleşik önkoşul grafiği kullanır.

Grafik:

* statik eğitim bilgisidir,
* öğrenci verisi değildir,
* konu düğümlerinden oluşur,
* yönlü önkoşul ilişkilerini taşır,
* döngüsüz bir yapı olarak tasarlanmıştır.

[ÜRÜN KARARI]

Önkoşul ilişkileri en az:

* hard
* soft

olabilir.

## Hard prerequisite

Önkoşul hiç başlanmamışsa hedef konu kilitlenebilir.

Önkoşul zayıfsa köprü görevi zorunlu olabilir.

## Soft prerequisite

Hedef konu tamamen kilitlenmez.

Önkoşul zayıfsa bridge task önerilebilir.

[ÜRÜN KARARI]

Önkoşul kapısı değerlendirilmeden sınav önemi veya net getirisi hedef konuyu açamaz.

Önce öğrenme bütünlüğü korunur.

---

# 6. Önkoşul Grafiğinin Teknik Kaynağı

[TEKNİK KARAR]

Aktif uygulamadaki prerequisite graph saf Dart veri yapısı olarak tutulacaktır.

Başlangıçta:

```text
const Dart graph data
```

kullanılır.

Grafiğin Supabase'den runtime alınması Sürüm 1 başlangıcında gerekli değildir.

[TEKNİK KARAR]

İnsan-okunur önkoşul grafiği belgesi grafiğin eğitimsel referansıdır.

Dart implementasyonu bu referansın makine-okunur karşılığıdır.

Eski TypeScript implementasyonu varsa aktif kaynak olarak kabul edilmez.

[TEKNİK KARAR]

Grafiğin tek aktif Dart implementasyonu bulunmalıdır.

Aynı grafiğin birbirinden bağımsız iki aktif kod kaynağı tutulmaz.

---

# 7. Graph Versioning

[TEKNİK KARAR]

Prerequisite graph bir sürüm numarası taşımalıdır.

Örneğin:

```dart
graphVersion = "1.0.0"
```

Grafik değişiklikleri Git üzerinden izlenir.

[TEKNİK KARAR]

Graph sürümü özellikle grafiğe bağlı olarak üretilen artefaktlarda gerektiğinde saklanmalıdır.

Örnek:

* prerequisite evaluation sonucu,
* StudyRoute,
* ReasonTrail,
* aggregate StudentTopicState snapshot'ının ilgili kısmı.

[TEKNİK KARAR]

Her ham Evidence nesnesinin zorunlu olarak graphVersion taşıması gerekmez.

Ham Evidence'ın kendisi çoğu durumda:

> öğrencinin yaptığı ölçülebilir eylem

olduğu için grafikten bağımsızdır.

Graph version yalnızca grafik semantiğine gerçekten bağlı veride tutulmalıdır.

---

# 8. Hâkimiyet Modeli

[ÜRÜN KARARI]

Her konu için hâkimiyet:

```text
score
confidence
```

çiftiyle temsil edilir.

Motor yalnızca:

> öğrencinin tahmini seviyesi nedir?

sorusuna değil:

> bu tahmine ne kadar güveniyoruz?

sorusuna da cevap verir.

[ÜRÜN KARARI]

Hâkimiyet dört temel akademik bileşenden beslenir:

1. çalışma süresi
2. pratik miktarı
3. soru başarısı
4. deneme performansı

[ÜRÜN KARARI]

Kullanıcıya gösterilen okunur bantlar:

```text
başlanmadı
öğreniliyor
gelişiyor
hâkim
pekişmiş
```

Motor arka planda sürekli değerlerle çalışabilir.

[AÇIK KARAR]

Beta öncesinde kesinleştirilmeyecek değerler:

* mastery ağırlıkları,
* confidence formülü,
* mastery eşikleri,
* decay katsayıları,
* çeşitli tetik eşikleri.

---

# 9. Evidence Modeli

[TEKNİK KARAR]

Motorun akademik girdileri mümkün olduğunca yapılandırılmış Evidence nesneleri üzerinden temsil edilir.

Evidence gerektiğinde şu bilgileri taşıyabilir:

* öğrenci,
* konu / ders ilişkisi,
* evidence türü,
* değer,
* zaman,
* kaynak kanal,
* ölçülmüş / tahmini oluş,
* güvenilirlik bilgisi.

Örnek Evidence kaynakları:

* çalışma oturumu,
* soru çözümü,
* deneme,
* öğrenci öz-değerlendirmesi,
* soru kütüphanesi sinyali.

[ÜRÜN KARARI]

Öz-değerlendirme nesnel performans verisinin içine karıştırılmaz.

Algı ve performans ayrı veri kanalları olarak kalır.

---

# 10. Evidence Aggregation ve StudentTopicState

[TEKNİK KARAR]

Learning Engine her rota üretiminde öğrencinin tüm tarihsel ham Evidence arşivini baştan taramak zorunda bırakılmayacaktır.

Temel veri akışı:

```text
Raw Evidence
     ↓
Aggregation / State Update
     ↓
StudentTopicState
     ↓
Learning Engine
     ↓
StudyRoute
```

`StudentTopicState`, öğrencinin konuya ilişkin güncel akademik durumunun özetlenmiş snapshot'ıdır.

Motor günlük planlamada esas olarak bu güncel state üzerinden çalışır.

[TEKNİK KARAR]

Ham Evidence geçmişi gerektiğinde:

* audit,
* trend,
* confidence,
* evidence freshness,
* yeniden hesaplama

amaçları için saklanabilir.

Ancak her motor çağrısında bütün geçmişi belleğe taşımak temel tasarım değildir.

[AÇIK KARAR]

Aggregation algoritmasının tam yapısı `ROTA_ENGINE_SPEC.md` içinde tanımlanacaktır.

---

# 11. Oturum ve Deneme Kanalları

[ÜRÜN KARARI]

Konu-belirli çalışma oturumları ile deneme performansı aynı veri kanalı değildir.

Oturum:

> öğrenci hangi konu üzerinde çalıştığını bilir.

Deneme:

> öğrenci konuyu kendisi tanımak zorundadır.

Bu nedenle Evidence modeli veri kaynağını ayırt edebilmelidir.

[AÇIK KARAR]

Bu kanalların mastery üzerindeki kesin katsayıları beta verisiyle belirlenecektir.

---

# 12. Transfer

[ÜRÜN KARARI]

Transfer, konu belirtilmeden karşılaşılan sorunun hangi bilgiyle çözüleceğini tanıma becerisi olarak ayrı bir kavramdır.

Transfer yalnızca karışık/deneme benzeri bağlamlardan güvenilir biçimde beslenebilir.

[AÇIK KARAR]

Transfer'in nihai mastery modelindeki rolü henüz kesin değildir.

Olası roller:

* ağırlıklı bileşen,
* tavan,
* çarpan,
* ayrı üst-seviye sinyal.

Mimari Transfer'i ileride destekleyebilecek şekilde veri kaybı yaratmamalıdır; ancak v0.2 bu kavramın nihai matematiksel modelini belirlemez.

---

# 13. Zaman ve Determinizm

[TEKNİK KARAR]

Learning Engine sistem saatini doğrudan okumaz.

Örneğin:

```dart
DateTime.now()
```

motorun akademik karar mantığı içinde doğrudan kullanılmaz.

Motorun ihtiyaç duyduğu zaman:

```text
now
```

veya test edilebilir bir Clock abstraction üzerinden dışarıdan verilir.

Bunun amacı:

* deterministik davranış,
* tekrar üretilebilir testler,
* kontrollü scenario testleri

sağlamaktır.

---

# 14. Engine Girdi / Çıktı Kontratı

[TEKNİK KARAR]

Learning Engine'in temel çalışma modeli saf girdi → çıktı yaklaşımıdır.

Kavramsal örnek:

```text
Current Student State
+ New Evidence
+ Calendar / Availability
+ Student Preferences
+ Engine Config
+ Current Time
+ Prerequisite Graph
        ↓
Learning Engine
        ↓
Updated Academic State
+ Study Route
+ Reason Trail
```

Gerçek Dart API'si `ROTA_ENGINE_SPEC.md` aşamasında kesinleştirilecektir.

[TEKNİK KARAR]

Engine kendi içinde kalıcı kullanıcı state'i tutmaz.

Persistence dış katmanın sorumluluğudur.

---

# 15. Günlük Rota Kaynakları

[ÜRÜN KARARI]

Motor çalışma adaylarını üç öğrenme kaynağından üretir:

## Progress

Öğrenme yolunda sıradaki uygun konu.

## Repair

Zayıf veya açık bulunan konunun güçlendirilmesi.

## Reinforcement

Daha önce öğrenilmiş fakat yeniden yoklanması veya pekiştirilmesi gereken konu.

Bunlardan ayrı bir eksen vardır:

## Measurement

Motorun daha iyi karar verebilmek için yeni veri toplama ihtiyacı.

Measurement öğrenme kaynağı değil, epistemik ihtiyaçtır.

---

# 16. Planning Modes

[ÜRÜN KARARI]

İlk motor dört planlama modu kullanır:

```text
normal
pre_exam
post_exam
avoidance
```

[ÜRÜN KARARI]

Deneme takvimi güçlü sinyaldir.

Deneme öncesi / sonrası durumları gerektiğinde avoidance davranışına baskın gelebilir.

[ÜRÜN KARARI]

Avoidance tek bir ertelemeye göre değil, davranış örüntüsüne göre değerlendirilir.

[AÇIK KARAR]

Modların kesin eşikleri beta sırasında kalibre edilecektir.

---

# 17. Bridge Task

[ÜRÜN KARARI]

Zayıf önkoşul bulunduğunda gerekli koşullarda bridge task üretilebilir.

Bridge task:

* gerçek çalışma görevidir,
* günlük iş slotu tüketir,
* hedef konudan önce gelir,
* hangi prerequisite nedeniyle üretildiğini bilir.

Örnek:

```text
Türev kısa tekrar
→
İntegral
```

---

# 18. Günlük İş Limiti

[ÜRÜN KARARI]

Bir çalışma gününde en fazla dört iş bulunabilir.

Dört iş hedef değil, tavandır.

Gerçek yük:

* müsaitlik,
* öğrencinin tercih ettiği çalışma süresi,
* görevlerin yükü

gibi etkenlerle azaltılabilir.

[ÜRÜN KARARI]

Kaçırılmış görev ertesi güne otomatik kopyalanmaz.

Motor ertesi günü yeniden değerlendirir.

---

# 19. Reason / Decision Trail

[ÜRÜN KARARI]

Motorun ürettiği kritik görevler neden üretildiğini açıklayabilecek karar izi taşımalıdır.

[TEKNİK KARAR]

Reason yapıları string tabanlı serbest veri olarak bırakılmayacaktır.

Uygun alanlarda:

* enum,
* sealed class,
* tip güvenli domain modelleri

kullanılacaktır.

Örnek alanlar:

```text
source
mode
trigger
topicId
prerequisitePath
relevantMetrics
graphVersion
```

[TEKNİK KARAR]

Reason/Decision Trail yalnızca debugging verisi değildir.

Gerekli karar geçmişleri kalıcı olarak saklanabilir.

Bu:

* geçmiş kararların açıklanması,
* AI Koç'un gerçek motor gerekçesine dayanması,
* audit/debugging,
* beta sırasında motor davranışının incelenmesi

için değerlidir.

Storage biçimi Infrastructure katmanının sorumluluğudur.

---

# 20. AI Sınırı

[ÜRÜN KARARI]

ROTA'da iki temel AI rolü vardır.

## Coach / Explainer AI

Motor kararını:

* açıklar,
* kişiselleştirir,
* uygun tona dönüştürür.

Motor kararını değiştiremez.

## Solver AI

Öğrencinin gönderdiği soruya çözüm üretir.

Bu üretken görev Learning Engine'in parçası değildir.

[TEKNİK KARAR]

AI sağlayıcıları adapter sınırı arkasında tutulacaktır.

Domain ve Learning Engine doğrudan herhangi bir AI SDK veya sağlayıcıya bağlı olmayacaktır.

[AÇIK KARAR]

Gerçek AI sağlayıcısı veya sağlayıcıları henüz kilitlenmemiştir.

Bu karar motor geliştirmesini engellemez.

---

# 21. Safety Boundary

[ÜRÜN KARARI]

Safety sistemi akademik Learning Engine'in bir alt özelliği değildir.

Bağımsız ve daha yüksek öncelikli bir katmandır.

Kavramsal akış:

```text
User Interaction
       ↓
Safety Gate
       ↓
Academic Application
       ↓
Learning Engine
```

Risk durumu oluştuğunda akademik akış durabilir.

[ÜRÜN KARARI]

ROTA kriz çözmeye veya terapi üretmeye çalışmaz.

Gerektiğinde akademik yönlendirmeden geri çekilir.

[TEKNİK KARAR]

Safety kodu Learning Engine içine gömülmez.

Safety katmanı akademik davranış verisinden sinyal okuyabilir.

Ancak Learning Engine safety protokolünün iç mantığına bağımlı hale gelmez.

[AÇIK KARAR]

Gerçek güvenlik eşikleri ve protokoller uzman + hukuki çalışma tamamlanmadan kesinleştirilmeyecektir.

---

# 22. Basit Takip Dersleri

[ÜRÜN KARARI]

Sürüm 1'de TYT + AYT Matematik dışındaki Sayısal derslerde derinlikli Learning Engine yoktur.

Bu derslerde:

* çalışma kaydı,
* konu bazlı deneme analizi,
* basit zaman-temelli tekrar sinyalleri

bulunabilir.

Ancak:

* prerequisite graph,
* bridge sistemi,
* Matematik düzeyindeki günlük karar motoru

çalışmaz.

[TEKNİK KARAR]

Matematik motorunun ileride başka derslere genişletilmesini engelleyecek gereksiz sıkı bağlantılar kurulmaz.

Ancak henüz kullanılmayan dersler için şimdiden soyut motor altyapısı oluşturulmaz.

---

# 23. Backend Sınırı

[TEKNİK KARAR]

Supabase/PostgreSQL ilk backend çözümüdür.

Beklenen kalıcı veri örnekleri:

* kullanıcı hesabı,
* öğrenci profili,
* hedefler,
* StudySession,
* Evidence,
* StudentTopicState,
* ExamResult,
* StudyRoute,
* görev geçmişi,
* takvim/müsaitlik,
* soru kütüphanesi metadata'sı,
* kaynaklar.

Ayrıntılı schema bu belgede tanımlanmaz.

Bunun için ayrı veri modeli belgesi hazırlanabilir.

[TEKNİK KARAR]

Learning Engine Supabase SDK kullanmaz.

Veriler dış katmanda domain modellerine dönüştürülür ve Engine'e verilir.

---

# 24. Repository / Data Access

[AÇIK KARAR]

Repository pattern tüm entity'ler için baştan zorunlu tutulmayacaktır.

Aynı zamanda Presentation kodunun doğrudan Supabase sorguları yazması da kabul edilmeyecektir.

Başlangıç prensibi:

> Veri erişimi Infrastructure sınırının arkasında kalmalıdır.

İlk gerçek veri akışları ortaya çıktığında:

* doğrudan DataSource,
* sade Repository interface,
* birkaç aggregate-root repository

seçeneklerinden en az karmaşık olanı kullanılacaktır.

Bu karar ilk Learning Engine kodunu engellemez.

---

# 25. Local Data / Offline

[TEKNİK KARAR]

Sürüm 1 başlangıcında tam offline-first senkronizasyon mimarisi kurulmayacaktır.

Şimdiden:

* PowerSync,
* karmaşık conflict resolution,
* tam çift yönlü offline sync

gibi altyapılar eklenmez.

[TEKNİK KARAR]

Learning Engine'in çalışması internet bağlantısına yapısal olarak bağımlı olmayacaktır.

Gerekli güncel öğrenci state'i ve günlük rota gibi kritik küçük veri kümelerinin yerelde tutulabilmesine mimari izin vermelidir.

[AÇIK KARAR]

Hangi local persistence çözümünün kullanılacağı henüz seçilmemiştir.

Bu seçim gerçek local veri ihtiyacı ortaya çıktığında yapılacaktır.

---

# 26. Flutter State Management

[TEKNİK KARAR]

Flutter state management çözümü olarak **Riverpod** kullanılacaktır.

Tercih gerekçeleri:

* domain/engine bağımsızlığını desteklemesi,
* BuildContext zorunluluğunun olmaması,
* test edilebilirlik,
* tek geliştirici için yönetilebilir boilerplate,
* Flutter uygulamasında kontrollü dependency yönetimi.

[TEKNİK KARAR]

Riverpod:

* Domain içine,
* Learning Engine içine

girmez.

Presentation/Application tarafında kullanılır.

---

# 27. Klasör Stratejisi

[TEKNİK KARAR]

ROTA başlangıçta hibrit klasör stratejisi kullanacaktır.

Çekirdek sistem layer-oriented tutulur:

```text
domain
engine
application
infrastructure
```

UI tarafı feature-oriented tutulabilir:

```text
presentation/
  features/
```

Amaç klasör sayısını artırmak değil, bağımlılık sınırlarını görünür tutmaktır.

Boş veya kullanılmayan klasörler sırf mimaride yazıyor diye oluşturulmayacaktır.

Kavramsal başlangıç:

```text
lib/
  domain/
  engine/
  application/
  infrastructure/
  presentation/
    features/
  shared/
```

Gerçek klasörler ihtiyaç çıktıkça açılır.

---

# 28. Engine Configuration

[TEKNİK KARAR]

Beta sırasında değişmesi beklenen değerler kodun farklı yerlerine magic number olarak dağıtılmaz.

Örnek:

* mastery ağırlıkları,
* confidence eşikleri,
* prerequisite gate eşikleri,
* decay katsayıları,
* mode eşikleri,
* tekrar parametreleri.

Başlangıçta bu değerler merkezi bir saf Dart `EngineConfig` yapısında tutulacaktır.

[TEKNİK KARAR]

İlk sürümde remote config sistemi kurulmaz.

İhtiyaç oluşursa ileride değiştirilebilir.

---

# 29. Test Stratejisi

[TEKNİK KARAR]

En yoğun otomatik test alanı Learning Engine olacaktır.

Öncelikli testler:

* prerequisite graph validation,
* prerequisite gate,
* mastery calculation,
* confidence,
* Evidence aggregation,
* bridge generation,
* planning modes,
* candidate generation,
* candidate ranking,
* route generation,
* Reason Trail,
* graph version compatibility.

[TEKNİK KARAR]

Motor testleri:

* Flutter widget'larına,
* Supabase'e,
* gerçek AI API'sine,
* internete

bağımlı değildir.

## Scenario tests

Gerçek öğrenci durumlarını temsil eden scenario testleri ayrıca tutulacaktır.

Örnek:

> Fonksiyonlarda güçlü, polinomlarda zayıf, Limit'e başlamamış öğrenci için motor hangi rotayı üretir?

Scenario testleri yalnızca yazılım doğruluğunu değil, eğitim kararlarının mantığını da denetlemeye yardımcı olur.

---

# 30. Mimari Olarak Ertelenenler

v0.2 şu alanları çözmeye çalışmaz:

* mentör paneli,
* özel ders pazaryeri,
* deneme kulübü,
* topluluk sistemi,
* ödeme altyapısı,
* üyelik limitleri,
* diğer YKS alanları,
* diğer sınav dikeyleri,
* diğer dersler için derinlikli motor,
* karmaşık offline sync,
* remote config sistemi.

Bu gelecek ihtiyaçları Sürüm 1 mimarisini gereksiz karmaşıklaştırmak için kullanılmaz.

---

# 31. Hâlen Açık Mimari Kararlar

Aşağıdaki konular henüz kesin teknik karar değildir:

1. Repository katmanının gerçek kapsamı.
2. Local persistence teknolojisi.
3. Gerçek AI sağlayıcısı / sağlayıcıları.
4. Transfer'in mastery modelindeki matematiksel rolü.
5. Aggregation algoritmasının ayrıntıları.
6. Ham Evidence saklama ve özetleme politikalarının ayrıntıları.
7. UUID / ID üretim stratejisi.
8. Supabase authentication'ın kesin akışı.
9. Safety protokolünün gerçek eşikleri.
10. Deneme sonucu girişinin teknik biçimi.
11. AI Solver'ın Sürüm 1'e girip girmeyeceği.
12. Uzun vadeli graph migration stratejisi.

Bu başlıkların tamamı ilk motor kodunu yazmadan önce çözülmek zorunda değildir.

---

# 32. Mimari Kurallar

Aksi yönde bilinçli ve kayıtlı bir karar alınmadıkça:

1. Eğitim kararları Flutter widget'larında üretilmez.
2. Learning Engine doğrudan veritabanına erişmez.
3. Learning Engine doğrudan AI çağrısı yapmaz.
4. Domain Flutter'a bağımlı değildir.
5. Learning Engine Flutter'a bağımlı değildir.
6. Domain ve Engine `package:flutter/...` import etmez.
7. Matematik prerequisite graph öğrenci verisinden ayrı tutulur.
8. Motorun kritik kararları izlenebilir gerekçe taşır.
9. Beta'da kalibre edilecek değerler kodun içine dağınık biçimde gömülmez.
10. Safety sistemi akademik motora gömülmez.
11. AI motor kararının yerine geçmez.
12. Ürün belgelerinde kesinleşmemiş davranış mimaride sessizce ürün kararı haline getirilmez.
13. Gelecekte gerekebilir düşüncesiyle erken ve gereksiz abstraction kurulmaz.
14. Teknik karar değişiklikleri sessizce yapılmaz; kayda geçirilir.
15. AI önerileri insan onayı olmadan proje kararı değildir.
16. Learning Engine sistem saatini doğrudan okumaz.
17. Ham Evidence geçmişinin tamamı her rota üretiminde zorunlu olarak motora yüklenmez.
18. Flutter state management çözümü Domain/Engine sınırına sızmaz.
19. Supabase erişimi Presentation içine dağılmaz.
20. Grafiğin aynı anda birden fazla aktif makine-okunur kaynağı tutulmaz.

---

# 33. Mimari Değişiklik Kaydı

## v0.1

İlk teknik mimari taslağı oluşturuldu.

Temel teknoloji:

```text
Flutter + Dart
Supabase/PostgreSQL
Android-first
```

TypeScript ara motor yaklaşımından vazgeçildi.

---

## v0.2

Claude mimari eleştirisi ve Gemini bağımsız mimari denetimi değerlendirilerek güncellendi.

Eklenen veya netleştirilen önemli kararlar:

* Domain / Engine sorumluluk sınırı netleştirildi.
* Application katmanı ince use-case orchestration olarak tanımlandı.
* Learning Engine stateless/pure-function yönünde sabitlendi.
* zaman enjeksiyonu kuralı eklendi.
* Engine girdi/çıktı kontratı kavramsal olarak tanımlandı.
* prerequisite graph'ın aktif implementasyonunun Dart olmasına karar verildi.
* graphVersion eklendi.
* graph version'ın yalnız grafiğe gerçekten bağlı artefaktlara taşınması benimsendi.
* Evidence aggregation / StudentTopicState snapshot ayrımı eklendi.
* oturum ve deneme Evidence kanalları açıklaştırıldı.
* Transfer mimari seviyede görünür hale getirildi fakat matematiksel rolü açık bırakıldı.
* Reason modeli tip güvenli hale getirildi ve kalıcı karar izi olabilmesi kabul edildi.
* Riverpod state management tercihi yapıldı.
* hibrit klasör stratejisi kabul edildi.
* EngineConfig merkezi Dart config yaklaşımı kabul edildi.
* full offline-first senkronizasyon başlangıç kapsamından çıkarıldı.
* minimum local-state desteğine mimari kapı açık bırakıldı.
* Repository yaklaşımı erken kilitlenmedi.
* Domain/Engine'in Flutter import etmemesi açık mimari kural haline getirildi.

---

# 34. Bu Belgenin AI'lar Tarafından Kullanımı

Bu belge ChatGPT, Claude ve Gemini için ortak teknik referanstır.

Bir AI kod veya mimari önerdiğinde:

1. Önce `[ÜRÜN KARARI]` maddelerine uymalıdır.
2. `[TEKNİK KARAR]` değiştiriyorsa bunu açıkça belirtmelidir.
3. `[AÇIK KARAR]` alanlarında alternatif sunabilir.
4. Ürün belgelerinde bulunmayan davranışı ürün kararı gibi varsaymamalıdır.
5. ROTA Sürüm 1 kapsamını aşan gereksiz sistemler kurmamalıdır.
6. Domain / Engine sınırlarını korumalıdır.
7. AI'ın motor kararının yerine geçmesine yol açacak mimari önermemelidir.
8. Bir önerinin ürün kararı mı teknik karar mı olduğunu birbirine karıştırmamalıdır.

Amaç, üç AI'ın aynı kod tabanı üzerinde farklı varsayımlarla farklı sistemler inşa etmesini engellemektir.

---

# 35. Sonraki Teknik Belgeler

Bu mimari kabul edildiğinde sıradaki belgeler:

```text
ARCHITECTURE.md
        ↓
CODING_RULES.md
        ↓
ROTA_ENGINE_SPEC.md
        ↓
İlk Coding Ticket
```

`CODING_RULES.md` kod yazma disiplinini,

`ROTA_ENGINE_SPEC.md` ise Learning Engine'in gerçek davranışını ve kontratlarını ayrıntılı olarak tanımlayacaktır.

Önkoşul grafiğinin G1–G7 eğitimsel kuralları ve gerçek konu/kenar listesi mimari belgesine kopyalanmayacak; ilgili önkoşul grafiği belgesi ve `ROTA_ENGINE_SPEC.md` üzerinden yönetilecektir.
