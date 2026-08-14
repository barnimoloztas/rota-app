# ROTA_ENGINE_SPEC.md

**Belge:** ROTA Learning Engine Specification
**Sürüm:** v0.2
**Durum:** Kodlama öncesi bağlayıcı motor davranış sözleşmesi
**Hedef uygulama:** Flutter / Dart
**Kapsam:** Sürüm 1 — YKS Sayısal; derinlikli öğrenme motoru yalnızca TYT + AYT Matematik
**Tarih:** Ağustos 2026

---

# 0. BU SÜRÜM HAKKINDA

Bu belge, daha önce oluşturulmuş `ROTA_ENGINE_SPEC.md` içeriğinin tamamının yerine geçer.

Önceki dosyada v0.1 ve v0.2 parçalarının yanlış yerlere eklenmiş, bazı bölümlerin silinmiş veya farklı revizyonların birbirine karışmış olma ihtimali bulunduğundan bu sürüm bir yama değildir. Belge baştan, tek parça ve bütünleşik olarak yeniden kurulmuştur.

> **Bu belgenin v0.2 sürümü tek geçerli `ROTA_ENGINE_SPEC.md` kaynağıdır. Önceki v0.1/v0.2 parçaları normatif değildir.**

Bu belge ürün vizyonunu yeniden tanımlamaz. Öğrenme motorunun ne yaptığı, hangi verileri nasıl yorumladığı, hangi kararları deterministik olarak verdiği ve hangi kararların henüz açık bırakıldığı için teknik davranış sözleşmesidir.

Teknoloji yönü:

* Nihai ürün Flutter / Dart ile geliştirilecektir.
* Learning Engine doğrudan Dart ile yazılacaktır.
* TypeScript ara motoru kullanılmayacaktır.
* Engine Flutter UI'dan bağımsız saf Dart mantığı olarak kurulacaktır.

---

# 1. BELGENİN YETKİ ALANI

ROTA belgeleri farklı sorulara cevap verir.

* **Vizyon Belgesi:** ROTA nedir, kimin içindir, hangi problemi çözer?
* **ARCHITECTURE.md:** Sistem hangi katmanlardan oluşur ve bağımlılıklar nasıl akar?
* **ROTA_ENGINE_SPEC.md:** Öğrenme motoru hangi eğitimsel kurallarla karar verir?
* **Önkoşul grafiği:** Matematik konuları ve aralarındaki pedagojik ilişkiler nelerdir?
* **CODING_RULES.md:** Bu kararlar kodlanırken hangi geliştirme disiplini uygulanır?

Bir davranış bu belgede `[AÇIK]` olarak işaretlenmişse kod yazan insan veya AI onu kendi varsayımıyla kesinleştiremez.

Bir kalibrasyon değeri `[BETA]` olarak bırakılmışsa geçici implementasyon değeri kullanılabilir; ancak bu değer ürün gerçeği veya pedagojik sabit olarak kabul edilemez.

---

# 2. MOTORUN TEMEL AMACI

Learning Engine'in Sürüm 1'deki temel sorusu şudur:

> **Bu öğrencinin mevcut Matematik durumu, kanıtları, önkoşulları, yakın sınav takvimi ve gerçek günlük kapasitesi dikkate alındığında sıradaki en uygun çalışma işleri nelerdir ve neden?**

Motor bunun için:

1. yeni Evidence'ı öğrenci state'ine işler,
2. konu hâkimiyeti ve güven düzeylerini günceller,
3. önkoşul ilişkilerini değerlendirir,
4. ilerleme adaylarını üretir,
5. açık kapatma adaylarını üretir,
6. pekiştirme adaylarını üretir,
7. ölçüm ihtiyacını üretir,
8. aynı konuya ait adayları birleştirir,
9. planlama bağlamını çözer,
10. adayları sıralar,
11. kapasite ve günlük sınırlar altında rota oluşturur,
12. task ve route seviyesinde karar izi üretir.

---

# 3. SÜRÜM 1 MOTOR KAPSAMI

## 3.1 Derinlikli motor

Sürüm 1'de tam Learning Engine yalnızca:

* TYT Matematik
* AYT Matematik

için çalışır.

Bunlar iki bağımsız sistem değildir.

> **TYT + AYT Matematik tek bütünleşik öğrenme grafiğidir.**

TYT'deki bir konu AYT'deki bir konunun önkoşulu olabilir.

Motor sınav etiketi üzerinden değil, öğrenme ilişkisi üzerinden çalışır.

Geometri de Matematik grafiğinin içindedir.

## 3.2 Basit takip dersleri

Sürüm 1'de diğer Sayısal derslerinde:

* çalışma oturumu,
* süre,
* soru sayısı,
* doğru / yanlış / boş,
* konu bazlı deneme analizi,
* konu performans eğilimi,
* kronik zayıflık sinyali,
* zaman-temelli nazik tekrar dürtüsü

bulunabilir.

Ancak bu derslerde Sürüm 1 için:

* derinlikli mastery motoru,
* `{score, confidence}` ile pedagojik rota,
* prerequisite graph,
* prerequisite gate,
* bridge üretimi,
* Matematik'teki akıllı günlük rota motoru

yoktur.

---

# 4. BOZULAMAZ MOTOR İLKELERİ

## 4.1 Kritik akademik kararı AI vermez

AI:

* serbest girdiden sinyal çıkarabilir,
* motor kararını açıklayabilir,
* tonu kişiselleştirebilir.

Ancak:

* hangi konunun açılacağı,
* hangi prerequisite'in yetersiz olduğu,
* bridge gerekip gerekmediği,
* hangi konunun rota adayı olduğu,
* adayın hangi pedagojik kaynaktan geldiği

gibi kritik kararları deterministik motor verir.

## 4.2 Aynı girdi aynı sonucu üretir

Motor deterministiktir.

Aynı:

* graph version,
* config version,
* öğrenci state'i,
* Evidence,
* takvim bağlamı,
* tercihler,
* aktif çalışma günü,
* değerlendirme zamanı

aynı sonucu üretmelidir.

## 4.3 Engine gizli state tutmaz

Engine kendi içinde kullanıcı state'i saklamaz.

Input alır ve output üretir.

Persistence dış katmanın görevidir.

## 4.4 Engine dış servis bilmez

Learning Engine:

* Supabase bilmez,
* HTTP çağrısı yapmaz,
* AI sağlayıcısı bilmez,
* Riverpod bilmez,
* Flutter widget'ı bilmez,
* platform API'si bilmez.

Engine saf Dart'tır.

## 4.5 Reason sonradan uydurulmaz

Task ve route gerekçeleri karar anında üretilir.

AI bu gerekçeyi yalnızca doğal dile çevirir.

## 4.6 Belirsizlik saklanmaz

Yetersiz veya eski veri:

* sahte certainty üretmemeli,
* kesin mastery ilan etmemeli,
* gerektiğinde Measurement ihtiyacı doğurmalıdır.

## 4.7 Açık karar sessizce kapanmaz

`[AÇIK]` veya `[BETA]` bırakılan davranış geliştirici tarafından ürün kararı gibi kilitlenemez.

---

# 5. ANA VERİ AKIŞI

Learning Engine davranışı tek yönlüdür:

`Evidence → StudentTopicState → Candidates → Route`

Ancak bu zincir **iki ayrı use-case** olarak uygulanır.

## 5.1 State Update

Yeni Evidence veya zaman-tabanlı state yenilemesi:

`StateUpdater → Updated StudentTopicState`

## 5.2 Route Generation

Güncel snapshot'tan rota:

`RouteEngine → StudyRoute`

Bu ayrım bağlayıcıdır.

Route generation yeni Evidence'ı doğrudan state'e işleyemez.

State update rota oluşturmaz.

Böylece:

* side-effect sınırı korunur,
* state hesapları ayrı test edilir,
* route aynı snapshot üzerinde tekrar üretilebilir,
* deterministik davranış denetlenebilir.

---

# 6. TEMEL DOMAIN KAVRAMLARI

Çekirdek kavramlar:

* `Topic`
* `TopicId`
* `PrerequisiteEdge`
* `PrerequisiteType`
* `PrerequisiteGraph`
* `GraphVersion`
* `Evidence`
* `EvidenceChannel`
* `StudentTopicState`
* `StudentLearningSnapshot`
* `Mastery`
* `MasteryBand`
* `GateOutcome`
* `PlanningMode`
* `Candidate`
* `CandidateSource`
* `StudyTask`
* `StudyRoute`
* `TaskReason`
* `RouteReasonSummary`
* `EngineConfig`

Pratik sınır:

> **Ham veya türetilmiş veri taşıyorsa Domain; hesaplayan eğitim mantığı Engine'dedir.**

---

# 7. TOPIC VE ÖNKOŞUL GRAFİĞİ

## 7.1 Stabil Topic ID

Her konu stabil bir kimliğe sahiptir.

Kullanıcıya gösterilen başlık değişse bile Topic ID mümkün olduğunca değişmez.

## 7.2 Grafik öğrenci state'i değildir

Prerequisite graph statik pedagojik bilgi tabanıdır.

* uzman doğrulamalıdır,
* version taşır,
* nadiren değiştirilir.

## 7.3 Granülerlik

Grafik orta granülerlikte konu düzeyindedir.

Pedagojik olarak bağımsız çalışma ve önkoşul birimi oluşturmayan küçük alt kavramlar gereksiz node yapılmaz.

## 7.4 Edge türleri

### Hard prerequisite

Gerçek pedagojik önkoşuldur.

Eksikliği hedefe geçişi engelleyebilir veya bridge gerektirebilir.

### Soft prerequisite

Hedef için faydalıdır fakat tek başına kilit oluşturmaz.

Yetersizliği:

* ranking etkisi,
* reason uyarısı,
* opsiyonel bridge önerisi

oluşturabilir.

Soft edge'in sayısal etkisi `[BETA]`dır.

## 7.5 Transitif shortcut

Sırf erişilebilirlik için gereksiz transitif edge eklenmez.

Grafik pedagojik doğrudan ilişkileri ifade eder.

---

# 8. GRAPH VALIDATION

Graph kullanılmadan önce doğrulanmalıdır.

En az şu hata sınıfları yakalanır:

* duplicate Topic ID,
* duplicate edge,
* olmayan Topic'e edge,
* self-edge,
* illegal cycle,
* geçersiz edge type,
* eksik graph version,
* metadata tutarsızlığı.

Graph invalid ise route üretimi yapılmaz.

---

# 9. EFFECTIVE PREREQUISITE

Bir hedef için doğrudan ve zincirsel prerequisite ilişkileri gerektiğinde birlikte değerlendirilebilir.

Temel semantik:

* yalnız hard edge'lerden oluşan gerekli zincir efektif hard olabilir,
* gerekli yolda soft bir halka varsa sırf transitif ilişki nedeniyle hard lock üretilmez.

Effective prerequisite hesabının:

* graph yüklenirken ön-hesaplanması,
* veya runtime'da deterministik traversal ile bulunması

bir implementasyon tercihidir.

Davranış değişmemelidir.

Performans nedeniyle derived graph index oluşturulabilir; bu index öğrenci state'i değildir ve graph version'a bağlıdır.

---

# 10. GRAPH VERSION VE STATE UYUMU

Her `StudentLearningSnapshot`, hangi `graphVersion` altında üretildiğini bilmelidir.

Route generation için:

> **Snapshot graphVersion ile aktif graphVersion uyumlu olmalıdır.**

Uyumsuzluk sessizce tolere edilmez.

## 10.1 Migration

Graph değişikliğinde açık migration gerekir.

Migration örnekleri:

* Topic ID rename → deterministik ID mapping,
* Topic split → açık migration kuralı,
* Topic merge → açık migration kuralı,
* silinen Topic → archive / explicit mapping.

Motor:

> "Bu eski topic artık yok, mastery'yi en yakın yeni topic'e taşıyayım."

gibi pedagojik tahmin yapamaz.

Mastery yalnız açık version-to-version migration kuralı varsa taşınabilir.

Migration tamamlanmamışsa yeni graph üzerinde normal rota üretimi yapılmaz.

Bu bir beklenen outcome olarak raporlanır.

---

# 11. STUDENT TOPIC STATE

Bir öğrencinin bir konudaki durumu tek mastery sayısı değildir.

En az şu kavramlar ayrılır:

* gerçek akademik temas var mı?
* mastery score,
* confidence,
* son anlamlı Evidence zamanı,
* evidence coverage/summary,
* ilgili trend bilgisi,
* state'in hesaplandığı zaman.

## 11.1 Başlanmışlık ayrı state'tir

Score tek başına "başlandı mı?" bilgisini taşımaz.

Kavramsal olarak:

* `untouched`: gerçek çalışma/performans Evidence'ı yok,
* `touched`: en az bir anlamlı gerçek Evidence var.

Onboarding prior gerçek temas sayılmaz.

Bu ayrım zorunludur.

Çünkü:

`low score + low confidence`

hem:

* hiç başlanmamış,
* hem de yeni başlanmış fakat henüz az Evidence bulunan

iki farklı durumu temsil edebilir.

---

# 12. EVIDENCE MODELİ

Evidence ham akademik gözlemdir.

Derived state değildir.

Temel kanallar:

1. çalışma süresi,
2. pratik miktarı,
3. konu-belirli soru performansı,
4. deneme konu performansı.

Ek sinyaller:

* onboarding prior,
* Question Library,
* erteleme/kaçırma,
* öz-değerlendirme,
* transfer.

Ek sinyalin mastery'ye girdiği açıkça belirlenmeden score'a karıştırılmaz.

---

# 13. EVIDENCE AGGREGATION VE MASTERY UPDATE AYRIMI

İki hesap kavramsal olarak ayrıdır.

## 13.1 Evidence Aggregation

Ham Evidence'tan anlamlı özet çıkarır.

Örnek:

* toplam çalışma,
* yakın dönem soru başarısı,
* deneme observation dizisi,
* son anlamlı Evidence zamanı.

## 13.2 Mastery Update

Aggregate Evidence'tan:

* score,
* confidence,
* band

üretir.

Bu iki aşama aynı service içinde ardışık uygulanabilir; ancak semantik olarak birbirine karıştırılamaz.

Böylece Evidence'ın kendisi ile Evidence'tan çıkarılan pedagojik yorum ayrılmış olur.

---

# 14. OTURUM VE DENEME AYRIMI

## 14.1 Session Evidence

Öğrenci konuyu baştan bilir.

Session:

* çalışma süresi,
* pratik miktarı,
* topic-specific performance

üretir.

Transfer ölçmez.

## 14.2 Exam Evidence

Denemede öğrenci doğru konu/yöntemi kendisi tanımak zorundadır.

Deneme:

* topic performance,
* daha güçlü bağlamsal kanıt,
* transfer/tanıma sinyali

üretebilir.

## 14.3 Ağırlık

Exam Evidence'ın ilgili topic için session Evidence'tan daha güçlü olması ürün yönüdür.

Kesin katsayı `[BETA]`dır.

---

# 15. MASTERY MODELİ

`Mastery = { score, confidence }`

## 15.1 Score

Öğrencinin konu hâkimiyeti tahminidir.

Sürekli değerdir.

UI bandları:

1. başlanmadı,
2. öğreniliyor,
3. gelişiyor,
4. hâkim,
5. pekişmiş.

Sayısal eşikler `[BETA]`dır.

## 15.2 Confidence

Motorun score tahminine güven düzeyidir.

Score ile ayrı eksendir.

Örneğin:

`score = yüksek, confidence = düşük`

şu anlama gelir:

> Öğrenci güçlü görünüyor fakat kanıtımız bunu kesinleştirmek için yetersiz veya eskimiş.

## 15.3 Score ve Confidence karıştırılmaz

Düşük confidence score'u otomatik düşürmez.

Düşük score confidence'ı otomatik düşürmez.

## 15.4 Mastery değişebilir

Mastery:

* yükselebilir,
* korunabilir,
* düşebilir.

Tek kötü Evidence geçmiş modeli silmez.

Tek iyi Evidence pekişmiş ilan etmek için yeterli değildir.

---

# 16. CONFIDENCE VE TAZELİK

Confidence en az:

* Evidence miktarı,
* Evidence çeşitliliği,
* Evidence tazeliği

ile ilişkilidir.

Kesin formül `[BETA]`dır.

## 16.1 Freshness'ın rolü

Zaman geçti diye score doğrudan cezalandırılmaz.

Ana yol:

`Evidence eskir → Confidence azalır → Measurement ihtiyacı artabilir`

Yeni Evidence:

* eski score'u doğrulayabilir,
* veya gerçek performans düşüşünü gösterebilir.

## 16.2 Decay nerede uygulanır?

Confidence decay route generation sırasında state'i değiştiremez.

Temporal confidence refresh, State Update katmanının görevidir.

`StudentLearningSnapshot`:

* hangi `asOf` zamanında hesaplandığını,
* confidence'ın o zamana göre güncel olduğunu

taşır.

RouteEngine kendisine verilen snapshot üzerinde yeni decay yazmaz.

Gerekirse route öncesinde ayrı temporal state refresh çağrısı yapılır.

Böylece gizli state ve route-dependent mastery değişimi engellenir.

---

# 17. DÖRT ANA MASTERY BİLEŞENİ

Matematik mastery modeli:

1. `studyTime`
2. `practiceVolume`
3. `practicePerformance`
4. `examPerformance`

bileşenlerini taşır.

Ağırlıklar ve fonksiyon `[BETA]`dır.

İlk model:

* açık,
* konfigüre edilebilir,
* test edilebilir

olmalıdır.

Gereksiz matematiksel karmaşıklık kullanılmaz.

---

# 18. ONBOARDING PRIOR

Onboarding öğrenciyi boş state ile başlatmamak için düşük confidence prior üretebilir.

Ancak:

* gerçek Evidence değildir,
* `touched` yapmaz,
* yüksek-confidence konu mastery oluşturmaz.

Gerçek Evidence geldikçe prior'ın etkisi azalır.

---

# 19. ÖZ-DEĞERLENDİRME

Öğrenci algısı performanstan ayrı kanalda tutulur.

Sürüm 1 taban davranışı:

* mastery score'u doğrudan değiştirmez,
* prerequisite gate açmaz/kapatmaz,
* `perceived vs observed` farkı için koçluk sinyali üretir.

Difficulty adaptation'daki daha ileri rol `[AÇIK/BETA]`dır.

---

# 20. TRANSFER

Transfer:

> Konu belirtilmeden, karışık bağlamda doğru matematiksel bilgi veya yöntemi tanıyabilme becerisidir.

Transfer temel olarak deneme Evidence'ından beslenir.

## 20.1 Veri konumu

Transfer topic mastery içine sessizce eritilmez.

Konu-üstü ayrı state/aggregate olarak saklanır.

Bu karar şimdi sabittir.

## 20.2 Matematiksel rol

Transfer'in:

* ağırlıklı mastery bileşeni,
* mastery tavanı,
* çarpan,
* bağımsız koçluk metriği

olması `[AÇIK]`tır.

---

# 21. QUESTION LIBRARY SIGNAL

Yapılamayan/zorlanılan soruların aynı topic'te birikmesi akademik açık sinyalidir.

AI topic önerebilir.

Motor açısından kesin topic etiketi öğrencinin onayladığı etikettir.

Question Library Signal'ın:

* mastery Evidence'a mı,
* Repair candidate ranking'e mi,
* kontrollü biçimde ikisine mi

gireceği `[AÇIK]`tır.

İlk veri modeli sinyali ayrı saklar.

---

# 22. MASTERY BAND → HARD GATE SEMANTİĞİ

Mastery band ile gate aynı kavram değildir.

Ancak temel ilişki bağlayıcıdır:

* **untouched / başlanmadı → `Locked`**
* **touched + öğreniliyor → `BridgeRequired`**
* **touched + gelişiyor → `BridgeRequired`**
* **touched + hâkim → `BridgeRequired`**
* **pekişmiş + yeterli confidence → `Open`**
* **pekişmiş + düşük confidence → `OpenWithVerification`**

Burada `hâkim` ve `pekişmiş` bilinçli olarak ayrıdır.

Hard prerequisite'in koşulsuz serbest bırakılması için `pekişmiş` düzeyi aranır.

Sayısal score ve confidence eşikleri `[BETA]`dır.

---

# 23. GATE OUTCOME'LARI

## 23.1 `Locked`

Gerekli hard prerequisite altyapısında gerçek başlangıç yoktur.

Hedef motorun normal Progress task'ı olamaz.

## 23.2 `BridgeRequired`

Hard prerequisite çalışılmıştır fakat yeterince pekişmemiştir.

Hedef ancak bridge kuralları izin veriyorsa aynı rota içinde değerlendirilebilir.

## 23.3 `Open`

Hard prerequisite yeterince pekişmiştir ve confidence yeterlidir.

## 23.4 `OpenWithVerification`

Prerequisite pekişmiş görünür fakat confidence düşüktür.

Hedef tamamen kilitlenmez.

Motor:

* hedefe izin verebilir,
* uncertainty reason üretir,
* Measurement ihtiyacını artırabilir.

---

# 24. BİRDEN FAZLA HARD PREREQUISITE

Bir hedefin birden fazla hard prerequisite'i olabilir.

Gate birleşim kuralı:

1. **Herhangi bir hard prerequisite `Locked` ise hedef `Locked`.**
2. `Locked` yok fakat bir veya daha fazla prerequisite `BridgeRequired` ise hedef genel olarak `BridgeRequired`.
3. `Locked` ve `BridgeRequired` yok fakat en az biri `OpenWithVerification` ise hedef `OpenWithVerification`.
4. Hepsi `Open` ise hedef `Open`.

Yani en kısıtlayıcı hard prerequisite sonucu baskındır.

---

# 25. HARD + SOFT PREREQUISITE

Hard ve soft prerequisite aynı hedefte birlikte bulunabilir.

Önce hard gate sonucu hesaplanır.

Soft prerequisite:

* `Locked` oluşturamaz,
* hard gate'i açamaz,
* hard gate'in sonucunu daha serbest hale getiremez.

Hard gate açık olsa bile soft weakness:

* candidate ranking'i düşürebilir,
* reason oluşturabilir,
* opsiyonel destek önerisi üretebilir.

---

# 26. BRIDGE

Bridge:

> Zayıf fakat başlanmış hard prerequisite'i, hedef topic öncesinde tazeleyen küçük ve gerçek bir çalışma task'ıdır.

Bridge günlük slot tüketir.

## 26.1 Maksimum bridge derinliği

**Max Bridge Depth = 1.**

Bridge için ikinci bridge üretilmez.

Yani:

`Bridge → Bridge → Target`

zinciri günlük rota içinde kurulamaz.

## 26.2 Bridge'in kendi prerequisite'i kilitliyse

Bridge topic'in kendisi gerçek anlamda uygulanabilir değilse:

* alt-bridge üretilmez,
* hedef topic o rota için ilerletilmez,
* prerequisite zincirindeki en yakın uygulanabilir öğrenme ihtiyacı ayrı Progress/Repair adayı olarak değerlendirilebilir.

Bu durum hedef açısından `Locked for current route` sonucuna dönüşür.

## 26.3 Bir hedefte birden fazla BridgeRequired prerequisite

Bir hedefin aynı anda birden fazla hard prerequisite'i bridge gerektiriyorsa:

* hedef + çoklu bridge aynı günlük intent olarak üretilmez,
* o gün en fazla bir prerequisite güçlendirme işi seçilir,
* hedef topic sonraki state değerlendirmesine bırakılır.

Hangi prerequisite'in seçileceği ranking ile belirlenir.

Kesin ağırlık `[BETA]`dır.

Bu kural 4-slot sisteminin bridge'lerle dolmasını önler.

## 26.4 Ortak bridge

İki farklı hedef aynı prerequisite bridge'ini gerektiriyorsa aynı bridge iki kez üretilmez.

Tek bridge:

* tek task,
* tek slot

olarak tutulur.

Reason birden fazla linked target taşıyabilir.

---

# 27. PROGRESS

Öğrenme grafiğinde pedagojik olarak uygun sıradaki konuya ilerlemedir.

Progress prerequisite gate'e tabidir.

Net getirisi veya hedef önemi gate'i bypass edemez.

---

# 28. REPAIR

Mevcut akademik açığı kapatma işidir.

Sinyaller:

* düşük mastery,
* tekrarlayan deneme hataları,
* kronik zayıflık,
* gerçek performans düşüşü,
* ileride kararlaştırılırsa Question Library Signal.

---

# 29. REINFORCEMENT

Amaç öğrenilmiş bilgiyi **güçlendirmektir**.

Bir öğrenme işi üretir.

Örnek:

* kısa tekrar,
* konu uygulaması,
* pekiştirme soru seti.

---

# 30. MEASUREMENT

Measurement'ın birincil amacı öğrenmeyi güçlendirmek değil, **motorun belirsizliğini azaltmaktır**.

Örnek:

* kısa yoklama,
* planlı deneme,
* confidence doğrulaması.

## 30.1 Measurement planning signal'dır

Measurement önce ayrı bir planning intent/candidate source olarak doğar.

Öğrencinin yapacağı somut bir eylem gerekiyorsa final rotada `StudyTask` biçimine materialize olabilir.

Böylece:

> Measurement kavramsal olarak normal öğrenme kaynağı değildir; fakat uygulanması gereken durumda gerçek task olabilir.

---

# 31. CANDIDATE KAYNAKLARI

Motor dört kaynak üretir:

* Progress
* Repair
* Reinforcement
* Measurement

Candidate henüz final task değildir.

---

# 32. CANDIDATE DEDUPLICATION

Aynı `TopicId` için Progress, Repair ve Reinforcement aynı anda tetiklenebilir.

Final candidate havuzunda aynı topic için gereksiz paralel adaylar bulunamaz.

## 32.1 Candidate merge

Aynı topic'e ait adaylar tek bir birleşik candidate altında toplanır.

Candidate:

* birincil source,
* tüm tetikleyen source'ların kümesi,
* source-specific reason'lar,
* ilgili metric'ler

taşıyabilir.

Örnek:

`Fonksiyonlar → {Repair, Reinforcement}`

## 32.2 Skor birleşimi

Birden çok source skorunun:

* toplanması,
* maksimumunun alınması,
* ağırlıklı birleştirilmesi

gibi matematiksel yöntem `[BETA]`dır.

`ProgressScore + RepairScore` gibi tek bir formül ürün gerçeği olarak sabitlenmez.

## 32.3 Task deduplication

Aynı topic aynı rota içinde sırf farklı source'lardan geldi diye iki normal akademik task'a dönüşmez.

Farklı task türlerinin gerçekten ayrı olması pedagojik olarak gerekliyse bunun açık reason'ı bulunmalıdır.

Varsayılan tek topic → tek ana akademik task'tır.

---

# 33. KRONİK ZAYIFLIK

Tek kötü sonuç kronik zayıflık değildir.

Tekrarlı örüntüdür.

Potansiyel sinyaller:

* tekrar eden düşük deneme performansı,
* aynı topic'te hata sürekliliği,
* çalışma sonrası düzelmeme.

Minimum observation count ve zaman penceresi `[BETA]`dır.

---

# 34. TEK DENEME DAVRANIŞI

Tek bir deneme:

* mastery'yi sıfırlayamaz,
* doğrudan pekişmiş ilan edemez,
* kronik zayıflığı tek başına yaratamaz.

Yeni deneme Evidence'ı mevcut geçmişle birlikte ağırlıklandırılır.

Exact update fonksiyonu `[BETA]`dır.

Bu davranış scenario test ile korunur.

---

# 35. KANIT TAZELİĞİ VE YOKLAMA

ROTA:

> "Uzun zaman geçti, unuttun."

varsayımı yapmaz.

Doğru akış:

1. Evidence eskir,
2. confidence azalır,
3. Measurement ihtiyacı artabilir,
4. yeni kanıt önceki mastery'yi doğrular veya gerçek düşüşü gösterir.

---

# 36. PLANNING MODE'LARI

Dört semantik mode vardır:

* `Normal`
* `PreExam`
* `PostExam`
* `Avoidance`

İlk implementasyonda tek bir `primaryMode` seçilir.

---

# 37. NORMAL MODE

Varsayılan mode.

Progress, Repair, Reinforcement ve gerektiğinde Measurement dengelenir.

Kesin source oranları yoktur.

---

# 38. PRE-EXAM MODE

Yaklaşan planlı deneme tetikler.

Genel etki:

* geniş tekrar artar,
* ölçüm/deneme hazırlığı artar,
* yeni ağır topic açma azalır.

Kesin zaman penceresi `[BETA]`dır.

---

# 39. POST-EXAM MODE

Yeni deneme Evidence'ı sonrasında kısa süre çalışabilir.

Amaç denemenin ortaya çıkardığı açıkları değerlendirmektir.

Tek denemeye aşırı tepki verilmez.

Süre `[BETA]`dır.

---

# 40. AVOIDANCE MODE

Kaçınma kişilik değerlendirmesi değildir.

Davranış örüntüsüdür.

Tek erteleme mode oluşturmaz.

Tekrarlı örüntü gerekli.

Eşik `[BETA]`dır.

Mode:

* task tipini hafifletebilir,
* çalışma bariyerini düşürebilir,
* topic'i kısa süre dinlendirebilir.

Kesin dönüşüm `[BETA]`dır.

---

# 41. MODE RESOLUTION

Birden fazla mode sinyali aynı anda var olabilir.

İlk implementasyon için deterministik öncelik:

1. `PreExam`
2. `PostExam`
3. `Avoidance`
4. `Normal`

Yaklaşan öğrenci-planlı deneme sert sinyaldir.

PreExam bu nedenle Avoidance'ı geçici olarak bastırabilir.

Bu öncelik `[TEKNİK KARAR]`dır; gerçek kullanım verisi yeni bir ürün kararı gerektirirse değiştirilebilir.

Mode yalnız candidate önceliklerini değiştirir.

> **Kapasite/müsaitlik her zaman route selection'ın fiziksel son sınırıdır.**

---

# 42. CANDIDATE RANKING

Ranking yalnız gate'ten geçmiş/uygun candidate'lar arasında yapılır.

Potansiyel sinyaller:

* mastery weakness,
* confidence gap,
* chronic weakness,
* prerequisite readiness,
* exam importance / net potential,
* recent exam Evidence,
* reinforcement need,
* avoidance,
* hedef ilişkisi,
* bridge cost.

Formül `[BETA]`dır.

Bağlayıcı sıra:

> **Eligibility/Gate → Candidate Merge → Ranking → Capacity Selection**

---

# 43. NET GETİRİSİ

Net getirisi güçlü ranking sinyalidir.

Ancak prerequisite gate'i açamaz.

Pedagojik uygunluk önce gelir.

---

# 44. GÜNLÜK TASK SINIRI

Toplam görünür günlük çalışma listesi en fazla 4 task'tır.

Bu toplamın içinde:

* öğrenci task'ları,
* motor task'ları,
* bridge task'ları

yer alır.

Dört hedef değil tavandır.

---

# 45. SLOT ÖNCELİĞİ

Route güncellenirken kapasite çatışması varsa:

1. öğrencinin dokunulmaz/sabitlediği task'lar,
2. korunması gereken mevcut task'lar,
3. gerekli bridge ile ilişkili motor intent'leri,
4. diğer motor candidate'ları,
5. opsiyonel Measurement önerileri

değerlendirilir.

Ancak bir bridge yalnız hedef de aynı rotada uygulanabiliyorsa "gerekli bridge" olarak anlamlıdır.

Tek başına prerequisite güçlendirme gerekiyorsa task artık normal Progress/Repair niteliğiyle seçilebilir.

Motor dört slotu doldurmak zorunda değildir.

---

# 46. KAPASİTE, TERCİH VE GEREKLİLİK

Ayrı kavramlar:

* `capacity`
* `preference`
* `requiredPace`

Günlük plan öğrencinin:

* müsaitliği,
* tercih ettiği çalışma süresi

altında oluşturulur.

Required pace uyumsuzluğu görünür kılınabilir fakat günlük task sayısını zorla artırmaz.

---

# 47. TAKVİM VE ÇALIŞMA GÜNÜ

Engine input'u dış katmandan:

* gerçek müsait süre,
* planlı deneme,
* öğrenci tercih süresi,
* aktif `studyDay`,
* evaluation time

alır.

Takvim CRUD mantığı Engine'e ait değildir.

## 47.1 Takvim günü ≠ çalışma günü

Öğrenci gece yarısından sonra önceki çalışma gününü sürdürebilir.

Bu nedenle Engine kendi başına takvim gününü study day kabul etmez.

"Yeni güne geç" ve 08:00 otomatik fallback application layer davranışıdır.

Application hangi study day'in aktif olduğunu Engine'e açık verir.

---

# 48. KAÇIRILAN TASK

Tamamlanmayan task otomatik ertesi güne kopyalanmaz.

Kaçırılma Evidence/sinyal olarak saklanır.

Yeni rota sıfırdan değerlendirilir.

Backlog kartopu oluşturulmaz.

---

# 49. ERTELEME NEDENİ

UI'daki metinsel etiketler Engine'in konusu değildir.

Engine'e semantik kategori gelebilir:

* lackOfTime,
* difficulty,
* fatigue,
* lowMotivation

vb.

Bu sinyalin kesin motor ağırlıkları `[BETA]`dır.

Akademik-ötesi güvenlik değerlendirmesi Learning Engine'in görevi değildir.

---

# 50. STUDENT-ADDED TASK

Öğrenci kendi task'ını ekleyebilir.

Bu task prerequisite gate tarafından sessizce silinmez.

Öğrenci hard prerequisite'i karşılanmayan bir Matematik konusu eklerse:

* task kalabilir,
* motor bunu kendi pedagojik Progress önerisi saymaz,
* uygunluk uyarısı/reason üretilebilir,
* prerequisite alternatifi önerilebilir.

ROTA yönlendirir fakat öğrencinin kendi seçimini gizlice ortadan kaldırmaz.

---

# 51. DRAFT VE SABAH REFRESH

Akşam rota taslağı üretilebilir.

Sabah yeni state ile tazelenebilir.

Kurallar:

1. öğrencinin dokunduğu/sabitlediği task değiştirilemez,
2. öğrenci task'ı silinemez,
3. koç task'ı yalnızca **yeni state altında artık geçerli candidate değilse veya gate sonucu değişmişse** invalidated sayılır,
4. salt ranking'in birkaç puan değişmesi tek başına task'ı değiştirmek için yeterli değildir,
5. refresh task sayısını artırmaz,
6. yapılan değişiklik route audit'e yazılır.

Böylece "new data invalidated task" kriteri somutlaşır.

---

# 52. ROUTE OUTPUT

Final route en fazla 4 task içerir.

Her task en az:

* task ID,
* topic,
* task type,
* candidate source,
* ownership,
* bridge/target ilişkisi,
* TaskReason

taşır.

Route ayrıca:

* unresolvedNeeds,
* deferredCandidates,
* measurementSuggestions,
* warnings,
* RouteReasonSummary

taşıyabilir.

Rota sınırına sığmayan akademik ihtiyaç yok olmuş sayılmaz.

---

# 53. TASK REASON

TaskReason makine-okunabilir olmalıdır.

En az şu soruları cevaplayabilmelidir:

* Bu task hangi source'tan geldi?
* Hangi mode etkiliydi?
* Hangi metric/sinyal tetikledi?
* Hangi prerequisite ilişkisi rol oynadı?
* Bridge ise hangi target için?
* Measurement ise neden?
* Repair ise hangi açık nedeniyle?
* Birleşik candidate ise hangi source'lar etkiliydi?

---

# 54. ROUTE REASON SUMMARY

Audit yalnız task seviyesinde kalmaz.

`StudyRoute` route-level reason summary taşır.

Örnek semantik bilgiler:

* seçilen primary mode,
* günlük kapasite,
* neden 4'ten az task üretildiği,
* kaç candidate'ın ertelendiği,
* bridge nedeniyle değişen plan,
* refresh değişiklikleri,
* candidate conflict resolution.

AI açıklayıcı route özetini bu deterministik veriden türetir.

---

# 55. ENGINE USE-CASE CONTRACTLARI

İlk implementasyonda iki ana public davranış kontratı bulunur.

## 55.1 Update State

Kavramsal:

`UpdateStateInput → UpdateStateOutput`

Input:

* current snapshot/state,
* new Evidence,
* current time,
* engine config,
* graph version context.

Output:

* updated snapshot,
* update audit,
* expected validation/migration outcomes.

## 55.2 Generate Route

Kavramsal:

`GenerateRouteInput → GenerateRouteOutput`

Input:

* güncel StudentLearningSnapshot,
* prerequisite graph,
* EngineConfig,
* availability,
* preferences,
* exam context,
* studyDay,
* current draft route gerektiğinde.

Output:

* route,
* route audit/reason,
* deferred needs,
* expected non-success outcomes.

Kesin Dart sınıf adları implementasyon sırasında değişebilir; use-case ayrımı değişmez.

---

# 56. EXPECTED OUTCOME'LAR

Beklenen pedagojik veya veri durumları exception değildir.

Örneğin:

* route generated,
* no eligible candidate,
* graph invalid,
* graphVersion mismatch,
* insufficient input,
* migration required

tip güvenli outcome olmalıdır.

Dart `sealed class` gibi dil özellikleri kullanılabilir.

Harici dependency zorunlu değildir.

---

# 57. SERIALIZATION VE ISOLATE UYUMLULUĞU

Engine input/output'u serialize edilebilir saf veri yapıları olmalıdır.

Amaç:

* test kolaylığı,
* persistence sınırı,
* gerektiğinde isolate kullanımına uygunluk.

İlk sürümün isolate kullanması zorunlu değildir.

---

# 58. ENGINE CONFIG

Pedagojik sayısal değerler tek config kaynağında toplanmalıdır.

Örnek:

* mastery thresholds,
* confidence thresholds,
* Evidence weights,
* freshness decay,
* chronic weakness threshold,
* avoidance threshold,
* exam windows,
* candidate ranking weights,
* soft prerequisite effect,
* capacity thresholds.

Magic number dağınıklığı yasaktır.

Config version audit edilebilir olmalıdır.

---

# 59. DETERMINİZM VE ZAMAN

Engine doğrudan `DateTime.now()` kullanmaz.

Zaman input olarak enjekte edilir.

Bu:

* confidence freshness,
* exam proximity,
* evidence age,
* study day

hesaplarının test edilebilir olması için zorunludur.

---

# 60. ENGINE İŞLEM SIRASI

## State Update

1. input validation,
2. graph/version compatibility validation,
3. yeni Evidence aggregation,
4. temporal refresh,
5. mastery score update,
6. confidence update,
7. band update,
8. updated snapshot + audit.

## Route Generation

1. input validation,
2. graph validation/version compatibility,
3. planning mode resolution,
4. Progress candidate generation,
5. Repair candidate generation,
6. Reinforcement candidate generation,
7. Measurement signal generation,
8. prerequisite gate,
9. bridge evaluation,
10. candidate deduplication/merge,
11. ranking,
12. existing student/draft task protections,
13. capacity + availability,
14. maximum 4 task selection,
15. TaskReason + RouteReasonSummary generation.

---

# 61. INVARIANT'LAR

1. `Locked` hard prerequisite'i olan topic normal Progress task olamaz.
2. Soft prerequisite tek başına hard lock oluşturamaz.
3. Herhangi bir hard `Locked` prerequisite hedefi kilitler.
4. `BridgeRequired` hedef bridge kuralları karşılanmadan normal Progress olamaz.
5. Max Bridge Depth = 1.
6. Bridge için bridge üretilmez.
7. Birden çok zayıf hard prerequisite günlük bridge zincirine dönüştürülmez.
8. Ortak bridge gereksiz çoğaltılmaz.
9. Aynı topic farklı source'lardan geldi diye duplicate candidate/task oluşturulmaz.
10. Günlük toplam task sayısı 4'ü aşmaz.
11. Öğrenci task'ı sessizce silinmez.
12. Capacity daha düşük günlük tavan oluşturabilir.
13. Tek kötü deneme mastery'yi sıfırlamaz.
14. Tek iyi deneme doğrudan pekişmiş oluşturmaz.
15. Eski Evidence otomatik unutma demek değildir.
16. Düşük confidence düşük score demek değildir.
17. Untouched ile touched-but-uncertain ayrıdır.
18. Net getirisi gate'i bypass edemez.
19. Route generation state'i değiştiremez.
20. GraphVersion mismatch sessizce geçilemez.
21. AI deterministik akademik kararı değiştiremez.
22. Aynı input aynı output'u üretir.

---

# 62. SCENARIO TESTLERİ

## Scenario A — Untouched hard prerequisite

Beklenen:

* `Locked`.

## Scenario B — Öğreniliyor/gelişiyor hard prerequisite

Beklenen:

* `BridgeRequired`.

## Scenario C — Hâkim hard prerequisite

Beklenen:

* `BridgeRequired`.

## Scenario D — Pekişmiş + yeterli confidence

Beklenen:

* `Open`.

## Scenario E — Pekişmiş + düşük confidence

Beklenen:

* `OpenWithVerification`,
* Measurement ihtiyacı oluşabilir.

## Scenario F — Soft prerequisite zayıf

Beklenen:

* hedef hard-lock olmaz.

## Scenario G — Multiple hard prerequisite

Durum:

* biri `Open`,
* biri `BridgeRequired`,
* biri `Locked`.

Beklenen:

* hedef `Locked`.

## Scenario H — Tek kötü deneme

Beklenen:

* mastery ani çökmez.

## Scenario I — Tek iyi deneme

Beklenen:

* topic doğrudan pekişmiş olmaz.

## Scenario J — Tek erteleme

Beklenen:

* Avoidance oluşmaz.

## Scenario K — Tekrarlı erteleme

Beklenen:

* Avoidance tetiklenebilir.

## Scenario L — PreExam + Avoidance

Beklenen:

* PreExam primary mode.

## Scenario M — Düşük kapasite

Beklenen:

* motor 4 task doldurmaz.

## Scenario N — Kaçırılan task

Beklenen:

* task otomatik kopyalanmaz.

## Scenario O — Sabah refresh

Öğrencinin dokunduğu task vardır.

Beklenen:

* task korunur,
* sayı artmaz.

## Scenario P — İç içe bridge

Target bridge istiyor; bridge topic'in prerequisite'i `Locked`.

Beklenen:

* alt-bridge yok,
* target bu rota için ilerletilmez.

## Scenario Q — İki BridgeRequired hard prerequisite

Beklenen:

* target + iki bridge üretilmez,
* tek prerequisite güçlendirme ihtiyacı seçilir,
* target ertelenir.

## Scenario R — Ortak bridge

İki target aynı prerequisite'i istiyor.

Beklenen:

* bridge tek task,
* tek slot.

## Scenario S — Candidate deduplication

Aynı topic hem Progress hem Repair hem Reinforcement tetikliyor.

Beklenen:

* tek birleşik candidate,
* source reason'ları korunur.

## Scenario T — Öğrenci 3 task ekledi

Beklenen:

* motor toplamı 4'ü aşamaz,
* en fazla 1 ek görünür task seçilebilir.

## Scenario U — Öğrenci kilitli topic ekledi

Beklenen:

* task silinmez,
* motor bunu kendi Progress önerisi saymaz,
* prerequisite uyarısı verilebilir.

## Scenario V — Low score + low confidence fakat touched

Beklenen:

* untouched sayılmaz,
* doğrudan `Locked` semantiğine düşmez.

## Scenario W — Effective soft chain

Zincirde gerekli soft halka vardır.

Beklenen:

* sırf transitif ulaşılabilirlik nedeniyle hard lock oluşmaz.

## Scenario X — GraphVersion mismatch

Beklenen:

* route üretilmez,
* migration-required outcome.

## Scenario Y — Route generation determinism

Aynı snapshot/config/context iki kez verilir.

Beklenen:

* birebir aynı route/audit sonucu.

## Scenario Z — Confidence temporal refresh

Aynı state farklı `asOf` zamanı ile StateUpdater'a verilir.

Beklenen:

* confidence deterministik yenilenir,
* RouteEngine kendi başına decay uygulamaz.

---

# 63. TEST STRATEJİSİ

Testler implementasyon sonuna bırakılmaz.

* graph yazılınca graph tests,
* mastery yazılınca mastery tests,
* gate yazılınca Scenario A–G/V,
* bridge yazılınca P/Q/R,
* candidate merge yazılınca S,
* modes yazılınca J/K/L,
* route builder yazılınca M/N/O/T/U,
* graph migration/version yazılınca X,
* determinism/time yazılınca Y/Z.

Gate ilk aşamada elle hazırlanmış `StudentTopicState` fixture'larıyla test edilebilir.

Evidence aggregation'ın tamamlanmasını beklemek gerekmez.

---

# 64. İLK İMPLEMENTASYON SIRASI

## Ticket 1 — Graph Domain + Validation

* Topic
* PrerequisiteEdge
* PrerequisiteGraph
* GraphVersion
* gerçek TYT+AYT Matematik topic listesi
* hard/soft edge
* validation
* graph tests.

## Ticket 2 — State Domain

* Evidence
* Mastery
* StudentTopicState
* StudentLearningSnapshot
* touched/untouched
* score/confidence.

## Ticket 3 — Prerequisite Gate

* `Locked`
* `BridgeRequired`
* `Open`
* `OpenWithVerification`
* multiple hard prerequisite combination.

Scenario A–G/V.

## Ticket 4 — Bridge Rules

* Max Depth = 1
* locked bridge handling
* multiple bridge requirement
* shared bridge dedup.

Scenario P/Q/R.

## Ticket 5 — Candidate Model + Merge

* Progress
* Repair
* Reinforcement
* Measurement
* same-topic deduplication.

Scenario S.

## Ticket 6 — StateUpdater

* Evidence aggregation,
* mastery update,
* temporal confidence refresh,
* deterministic audit.

## Ticket 7 — Planning Mode + RouteEngine

* mode resolution,
* ranking,
* max 4,
* capacity,
* ownership protection,
* TaskReason,
* RouteReasonSummary.

## Ticket 8 — Graph Migration Skeleton

* version check,
* migration-required outcome,
* explicit migration mapping interface/contract.

İlk graph sürümünde gerçek migration gerekmese bile version mismatch davranışı baştan bulunur.

---

# 65. İLK KODLAMA KABUL KRİTERİ

İlk hedef bütün ROTA'yı yapmak değildir.

İlk somut kabul kriteri:

> **Gerçek TYT+AYT Matematik graph'ında farklı fixture öğrenci state'leri için gate sonucu deterministik ve pedagojik olarak doğru üretilebiliyor mu?**

Başlangıç kilometre taşı:

> **Graph + validation + StudentTopicState + gate + Scenario A–G/V.**

Bu doğrulanmadan:

* AI açıklama,
* backend,
* gelişmiş UI,
* animasyon,
* ödeme,
* mentör sistemi

motor geliştirmesinin önüne geçmez.

---

# 66. BETA'YA BIRAKILACAK DEĞERLER

Aşağıdakiler bilinçli olarak şimdi sabitlenmez:

* mastery bileşen ağırlıkları,
* mastery bandlarının sayısal eşikleri,
* confidence sayısal eşikleri,
* Evidence quantity etkisi,
* freshness decay formülü,
* session/exam katsayıları,
* chronic weakness observation eşiği,
* exam trend minimum observation count,
* avoidance tetikleme sayısı,
* PreExam/PostExam pencere uzunlukları,
* candidate ranking ağırlıkları,
* candidate source merge formülü,
* net-getirisi ağırlığı,
* soft prerequisite etkisi,
* capacity-preference conflict eşiği,
* mola/sürdürülebilirlik katsayıları,
* basit ders tekrar aralıkları.

---

# 67. AÇIK KARARLAR

## 67.1 Transfer'in matematiksel rolü

Veri yeri sabit; matematiksel rol açık.

## 67.2 Question Library Signal

Mastery / Repair / ikisi yönü açık.

## 67.3 Difficulty Signal

Güvenilir difficulty metadata kaynağı açık.

## 67.4 Deneme sonucunun ürün giriş biçimi

Motor topic-based exam Evidence tüketir.

Manuel/OCR/entegrasyon motor kararı değildir.

## 67.5 Problem-solving AI

Question Library fotoğraf okuma/çözme doğruluğu ayrı prototip konusu.

---

# 68. BASİT TAKİP DERSLERİ

Matematik dışındaki Sürüm 1 derslerinde derinlikli prerequisite/mastery motoru çalışmaz.

Zaman-temelli nazik tekrar kilometre taşları kullanılabilir.

Başlangıç örneği:

* 10 gün
* 27 gün
* 50 gün

Aralıklar `[BETA]`dır.

Bu:

> "Unuttun."

değil:

> "Bu konuya bir süredir dokunmadın; hâlâ güçlü müsün?"

sinyalidir.

---

# 69. SAFETY SINIRI

Safety sistemi Learning Engine'den ayrıdır.

Engine:

* kriz teşhisi koymaz,
* terapi üretmez,
* yardım kaynağı seçmez.

Güvenlik katmanı normal akademik response'u gerektiğinde bastırabilir.

Learning Engine güvenlik kararını kendi mastery modeline karıştırmaz.

---

# 70. AI SINIRI

## Coach Explainer AI

Reason ve öğrenci bağlamından doğal dil üretir.

Akademik kararı değiştiremez.

## Problem-solving AI

Soru çözebilir.

Learning Engine değildir.

---

# 71. BU SPEC'İN TANIMLAMADIĞI KONULAR

Bu belge aşağıdakileri tasarlamaz:

* Flutter ekran yapısı,
* renk/animasyon,
* Supabase şeması ayrıntıları,
* auth,
* ödeme,
* mentör,
* pazaryeri,
* AI sağlayıcısı,
* safety protokolünün uzman içeriği,
* OCR algoritması.

---

# 72. TANIMLAR

**Evidence:** Ham akademik gözlem.

**Aggregate Evidence:** Evidence geçmişinden deterministik üretilen özet.

**StudentTopicState:** Bir topic için türetilmiş öğrenci durumu.

**StudentLearningSnapshot:** Belirli graph/config/zaman bağlamında route üretmeye hazır öğrenci state bütünü.

**Score:** Hâkimiyet tahmini.

**Confidence:** Score tahminine güven.

**Untouched:** Gerçek akademik Evidence olmayan topic.

**Hard prerequisite:** Eksikliği ilerlemeyi engelleyebilen önkoşul.

**Soft prerequisite:** Destekleyici fakat tek başına kilitlemeyen ilişki.

**Gate:** Hedef topic'in pedagojik uygunluk değerlendirmesi.

**Bridge:** Başlanmış fakat yeterince pekişmemiş prerequisite'i tazeleyen küçük task.

**Progress:** Öğrenme haritasında ilerleme.

**Repair:** Açık kapatma.

**Reinforcement:** Bilgiyi güçlendirme.

**Measurement:** Belirsizliği azaltmak için kanıt toplama amacı.

**Candidate:** Final route öncesi değerlendirilen potansiyel çalışma intent'i.

**Candidate Merge:** Aynı topic için birden fazla source tetiklenmesini tek candidate altında birleştirme.

**Route:** Günlük görünür çalışma görevleri bütünü.

**TaskReason:** Tek task'ın deterministik karar izi.

**RouteReasonSummary:** Bütün günlük rotanın deterministik özet gerekçesi.

---

# 73. MOTOR FELSEFESİ

ROTA Learning Engine:

* öğrenciyi kontrol etmek için değil, yolu görünür kılmak için;
* çok iş üretmek için değil, doğru işi seçmek için;
* belirsizliği gizlemek için değil, yönetmek için;
* tek bir sonucu yargıya çevirmek için değil, örüntüyü görmek için;
* sınav getirisi uğruna öğrenme sırasını bozmak için değil, ikisini dengelemek için;
* AI'ın ikna edici diline güvenmek için değil, denetlenebilir pedagojik karar üretmek için

vardır.

Motorun başarı ölçütü yalnız:

> "Doğru topic'i önerdi mi?"

değildir.

Asıl ölçüt:

> **Önerdiği rota öğrencinin güncel kanıtlarıyla, prerequisite yapısıyla, belirsizlik düzeyiyle ve gerçek çalışma kapasitesiyle açıklanabilir, tekrar üretilebilir ve pedagojik olarak savunulabilir mi?**

---

# 74. v0.2 KAPANIŞ KARARI

Bu sürümle kodlamadan önce kapanması gereken temel davranışlar kapanmıştır:

* Flutter/Dart doğrudan geliştirme,
* state update ile route generation ayrımı,
* deterministik ve stateless Engine,
* TYT+AYT Matematik bütünleşik graph,
* graphVersion uyumu ve migration zorunluluğu,
* hard/soft prerequisite,
* touched/untouched ayrımı,
* `{score, confidence}`,
* freshness'ın confidence üzerinden işlemesi,
* dört mastery Evidence bileşeni,
* session/exam ayrılığı,
* confidence-duyarlı dört gate outcome,
* multiple prerequisite birleşim kuralı,
* Max Bridge Depth = 1,
* çoklu bridge davranışı,
* ortak bridge deduplication,
* Progress / Repair / Reinforcement / Measurement ayrımı,
* same-topic Candidate Merge,
* mode resolution,
* capacity'nin son fiziksel sınır olması,
* toplam maksimum dört task,
* öğrenci task özerkliği,
* refresh invalidation kriteri,
* TaskReason + RouteReasonSummary,
* scenario-first test disiplini.

Bu nedenle sıradaki iş spec tartışması değildir.

> **İlk coding ticket: Dart'ta `Topic`, `PrerequisiteEdge`, `PrerequisiteGraph` ve `GraphVersion` domain yapılarını kurmak; ardından gerçek TYT+AYT Matematik graph'ını ve `validateGraph()` testlerini yazmaktır.**

Sonraki ticket:

> **`StudentTopicState` + dört outcome'lu `PrerequisiteGate` ve Scenario A–G/V.**

---

**ROTA Learning Engine Specification · v0.2**
**Bu belge önceki `ROTA_ENGINE_SPEC.md` içeriklerinin tamamının yerine geçer.**
