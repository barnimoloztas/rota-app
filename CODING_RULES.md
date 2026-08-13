# ROTA — Coding Rules

**Sürüm:** v0.2
**Durum:** Kabul adayı
**Amaç:** ROTA kod tabanında insan ve AI geliştiricilerin aynı teknik disiplinle çalışmasını sağlamak.

Bu belge şu soruyu cevaplar:

> **ROTA kodu nasıl yazılmalıdır?**

Mimari kararların kaynağı `ARCHITECTURE.md`dir.

Learning Engine'in akademik davranışları `ROTA_ENGINE_SPEC.md` içinde tanımlanacaktır.

Bu belge mimariyi veya motor davranışını yeniden tanımlamaz.

---

# 1. Karar Kaynakları ve Öncelik

Kodlama sırasında karar kaynaklarının öncelik sırası:

```text
Ürün belgeleri
      ↓
ARCHITECTURE.md
      ↓
ROTA_ENGINE_SPEC.md
      ↓
CODING_RULES.md
      ↓
Coding Ticket
      ↓
Implementasyon
```

Alt seviyedeki bir belge veya ticket üst seviyedeki kararı sessizce değiştiremez.

`ROTA_ENGINE_SPEC.md` henüz oluşturulmamış veya bir davranışı henüz kesinleştirmemişse AI eksik akademik davranışı kendi varsayımıyla tamamlamaz.

Gerekli karar mevcut belgelerden çıkarılamıyorsa bunu açıkça bildirir.

---

# 2. Bozulamaz Çekirdek

Aşağıdaki kurallar ROTA kod tabanının temel koruma sınırlarıdır.

## 2.1 Learning Engine saf Dart'tır

`domain/` ve `engine/`:

* Flutter,
* Riverpod,
* Supabase,
* AI SDK,
* network,
* local database

bağımlılığı içermez.

Özellikle:

```dart
package:flutter/...
package:flutter_riverpod/...
package:supabase_flutter/...
```

import edilmez.

## 2.2 Kritik akademik kararlar Engine'dedir

Şunlar Presentation, Provider, Notifier veya Infrastructure içine taşınmaz:

* mastery hesaplama,
* confidence hesaplama,
* prerequisite gate,
* bridge kararı,
* candidate üretimi,
* candidate ranking,
* planning mode,
* rota üretimi.

## 2.3 Engine deterministiktir

Aynı girdiler aynı çıktıyı üretmelidir.

Engine gizlice:

```dart
DateTime.now()
```

kullanmaz.

Zaman dışarıdan verilir.

Gelecekte rastgelelik gerekirse aynı ilke random kaynağı için de geçerlidir.

## 2.4 Engine kalıcı state tutmaz

Engine kullanıcı state'ini kendi içinde saklamaz.

Persistence dış katmanın sorumluluğudur.

## 2.5 Akademik sabitler dağınık tutulmaz

Kalibre edilecek eşikler, ağırlıklar ve katsayılar merkezi `EngineConfig` üzerinden yönetilir.

## 2.6 Kritik kararlar gerekçelendirilebilir olmalıdır

Motorun kritik çıktıları gerektiğinde tip güvenli `Reason` / `Decision Trail` üretebilmelidir.

AI gerçek motor gerekçesinin yerine kendi gerekçesini uyduramaz.

## 2.7 Safety, Learning Engine değildir

Safety mantığı akademik motor içine gömülmez.

## 2.8 Engine davranışı testsiz değiştirilmez

Akademik davranışı değiştiren Engine kodu ilgili test olmadan tamamlanmış sayılmaz.

---

# 3. Sadelik ve Değişiklik Kapsamı

Kodda öncelik sırası:

1. doğruluk
2. açıklık
3. test edilebilirlik
4. sadelik
5. performans
6. soyutlama

Gelecekte gerekebilir düşüncesiyle abstraction, framework veya dependency eklenmez.

Her coding ticket mümkün olduğunca tek bir mantıksal amacı gerçekleştirir.

Ticket sırasında:

* ilgisiz refactor yapılmaz,
* klasör yapısı sebepsiz değiştirilmez,
* çalışan kod sebepsiz yeniden yazılmaz,
* kullanılmayan abstraction oluşturulmaz,
* kapsam sessizce genişletilmez.

Beklenenden büyük mimari değişiklik gerekiyorsa önce durulur ve durum bildirilir.

---

# 4. Dart İsimlendirme ve Terminoloji

Dart standartları kullanılır.

Dosya:

```text
snake_case.dart
```

Class, enum ve type:

```text
PascalCase
```

Değişken ve fonksiyon:

```text
camelCase
```

Boolean isimleri mümkün olduğunca soru gibi okunmalıdır:

```dart
isLocked
hasEvidence
requiresBridge
canAdvance
```

Belirsiz isimlerden kaçınılır:

```text
data
thing
obj
temp
```

ROTA'nın ürün terminolojisi kodda korunur.

Örneğin ürün kavramı `Evidence` ise sebepsiz yere başka bir teknik isim üretilmez.

Aynı kavram için birden fazla terim oluşturulmaz.

---

# 5. Null Safety ve Tip Güvenliği

Bir alan domain açısından zorunluysa nullable yapılmaz.

Şu yaklaşım kabul edilmez:

> Şimdilik nullable yapalım, sonra bakarız.

`?` yalnızca verinin gerçekten bulunmayabileceği durumlarda kullanılır.

`!` mümkün olduğunca kullanılmaz.

Davranış belirleyen serbest string'ler yerine uygun olduğunda:

* enum,
* sealed class,
* value object

kullanılır.

Örneğin:

```dart
enum PlanningMode {
  normal,
  preExam,
  postExam,
  avoidance,
}
```

ham string kullanımına tercih edilir.

---

# 6. Immutability

Domain ve Engine modellerinde immutable yaklaşım tercih edilir.

Özellikle akademik state nesneleri dışarıdan sessizce mutate edilmemelidir.

Bir state değişikliğinde mümkün olduğunca yeni değer üretilir.

Ancak bu kural nedeniyle başlangıçta otomatik olarak:

* Freezed,
* equatable,
* başka code generation veya equality paketi

eklenmez.

Gerçek boilerplate veya hata riski ortaya çıkarsa dependency ayrıca değerlendirilir.

`copyWith` gibi mekanizmalar gerçek model ihtiyacına göre oluşturulur; bütün modeller için baştan zorunlu değildir.

---

# 7. Fonksiyon Sorumluluğu

Bir fonksiyon mümkün olduğunca tek anlaşılır sorumluluk taşımalıdır.

Örneğin aynı fonksiyon:

```text
Supabase'den veri çek
+ mastery hesapla
+ UI mesajı oluştur
+ state kaydet
```

işlerini birlikte yapmamalıdır.

Ancak yalnızca fonksiyonları kısa göstermek amacıyla gereksiz metot parçalama yapılmaz.

Hedef:

> **küçük fonksiyon değil, açık sorumluluk.**

Saf hesaplamalar sırf uygulamanın diğer bölümleri async olduğu için `Future` yapılmaz.

Örneğin saf Engine işlemi:

```dart
StudyRoute generateRoute(...)
```

senkron kalabilir.

Network/database işlemleri async olabilir.

---

# 8. Beklenen Sonuçlar ve Hatalar

Beklenen domain durumları programlama hatası değildir.

Örneğin:

* prerequisite nedeniyle ilerleyememe,
* yeterli evidence bulunmaması,
* uygun rota adayı oluşmaması

gibi durumlar `Exception` ile kontrol akışı olarak kullanılmamalıdır.

Bu tür durumlar gerektiğinde Dart'ın tip sistemiyle açık outcome modelleri olarak ifade edilir.

Örneğin kavramsal olarak:

```dart
sealed class GateOutcome {}

final class GateOpen extends GateOutcome {}

final class GateBlocked extends GateOutcome {
  // ...
}
```

Bu belge bütün Engine için tek bir genel:

```text
Result<T, E>
```

framework'ünü zorunlu tutmaz.

Üçüncü taraf `Either` / functional-programming paketi başlangıçta gerekli değildir.

Buna karşılık:

* bozuk graph,
* ihlal edilmiş invariant,
* gerçek programlama hatası

beklenen domain sonucu gibi sessizce gizlenmez.

Hatalar boş `catch` bloklarıyla yutulmaz.

---

# 9. Magic Number ve EngineConfig

Akademik davranışı belirleyen değerler algoritmanın farklı yerlerine dağılmaz.

Örneğin:

```dart
if (score > 0.72)
```

içindeki `0.72` kalibre edilecek bir akademik eşikse merkezi config'ten gelmelidir.

Örnek:

* mastery ağırlıkları,
* confidence eşikleri,
* prerequisite gate eşikleri,
* decay değerleri,
* planning mode eşikleri,
* tekrar parametreleri.

Başlangıç çözümü saf Dart `EngineConfig` yapısıdır.

Remote config başlangıç gereksinimi değildir.

---

# 10. Katman Sınırları

## Domain

Domain:

* temel veri yapıları,
* enum'lar,
* value object'ler,
* değişmez kavramlar

içindir.

Akademik hesaplama Domain'e dağıtılmaz.

## Engine

Engine akademik hesaplama ve karar üretir.

Engine dış servis bilmez.

## Application

Application ince orchestration katmanıdır.

Kavramsal görev:

```text
veriyi al
→ Engine'i çağır
→ sonucu persistence'a ilet
→ Presentation'a sonucu dön
```

Application akademik algoritma içermez.

## Infrastructure

Şunları izole eder:

* Supabase,
* local persistence,
* AI provider,
* network,
* serialization,
* dış servisler.

## Presentation

Presentation:

* UI,
* kullanıcı etkileşimi,
* UI state

içindir.

Akademik algoritma burada bulunmaz.

---

# 11. Riverpod Sınırı

Riverpod Presentation ve gerektiğinde Application tarafında kullanılabilir.

Riverpod:

* Domain'e,
* Engine'e

girmez.

Provider veya Notifier akademik hesaplama merkezi değildir.

Örneğin mastery formülü veya prerequisite gate bir Notifier içine yazılmaz.

Sürüm 1 başlangıcında Riverpod code generator zorunlu değildir.

Manuel provider/notifier kullanımı yeterlidir.

---

# 12. Supabase, Serialization ve DTO

Supabase sorguları Presentation içine yazılmaz.

Flutter widget'ları doğrudan:

```dart
supabase.from(...)
```

çağırmaz.

Supabase erişimi Infrastructure sınırında kalır.

Engine Supabase client almaz.

Dış veriler Engine'e ulaşmadan önce uygun biçimde doğrulanmalıdır.

Domain modelleri database schema'nın birebir kopyası olmak zorunda değildir.

Gerektiğinde:

```text
External Data
    ↓
DTO / Mapper
    ↓
Domain
```

ayrımı kullanılabilir.

Ancak her model için baştan DTO oluşturmak zorunlu değildir.

DTO yalnızca gerçek serialization veya boundary ihtiyacı olduğunda eklenir.

---

# 13. Dış Veri Doğrulama

Dış sistemden gelen veri güvenilir varsayılmaz.

Özellikle:

* Supabase verisi,
* JSON,
* OCR çıktısı,
* AI çıktısı,
* kullanıcı girdisi

uygun sınırda doğrulanmalıdır.

Learning Engine mümkün olduğunca geçerli ve yapılandırılmış domain verisiyle çalışır.

AI çıktısı doğrudan kritik akademik karar kabul edilmez.

---

# 14. Prerequisite Graph Kod Disiplini

Prerequisite graph'ın aktif makine-okunur implementasyonu Dart'tır.

Grafik:

* tek aktif implementasyona,
* stabil topic ID'lerine,
* version bilgisine,
* otomatik validation testlerine

sahip olmalıdır.

Topic'in kullanıcıya görünen adı değiştiğinde internal ID sebepsiz değiştirilmez.

Topic ID değişikliği migration etkisi yaratabilecek önemli değişiklik olarak değerlendirilir.

Graph'ın akademik semantiği ve validation davranışının ayrıntıları `ROTA_ENGINE_SPEC.md` ve ilgili graph belgesinde tutulur.

`CODING_RULES.md` bu algoritmaları yeniden tanımlamaz.

---

# 15. Reason / Decision Trail

Kritik motor kararlarının gerekçesi serbest metne indirgenmez.

Uygun yerlerde:

* enum,
* sealed class,
* yapılandırılmış domain modeli

kullanılır.

`ReasonTrail` ile teknik debug log aynı şey değildir.

Reason/Decision Trail:

* ürün açıklanabilirliği,
* audit,
* beta analizi,
* AI Coach açıklaması

için kullanılabilir.

AI Coach mümkün olduğunda motorun gerçek yapılandırılmış gerekçesinden konuşur.

---

# 16. Test Disiplini

Learning Engine testleri:

* Flutter widget,
* gerçek Supabase,
* internet,
* gerçek AI API

gerektirmemelidir.

Engine testleri hızlı ve deterministik olmalıdır.

Davranış değiştiren Engine kodunda ilgili test de değiştirilir veya eklenir.

Test türleri gerektiğinde şunları kapsar:

* unit test,
* graph validation test,
* scenario test,
* regression test.

Bir bug düzeltildiğinde mümkünse bug'ı önce yeniden üreten test yazılır.

Scenario testleri gerçek öğrenci durumlarını temsil eder ve motorun yalnızca teknik olarak değil eğitim mantığı açısından da beklenen sonucu üretip üretmediğini kontrol eder.

Sayısal test coverage yüzdesi başlangıçta zorunlu tutulmaz.

Amaç coverage sayısını yükseltmek değil, kritik karar dallarını gerçekten test etmektir.

Golden test Sürüm 1 başlangıcında zorunlu değildir.

---

# 17. Formatting ve Static Analysis

Kod Dart formatter ile formatlanmalıdır.

Commit öncesinde uygun olduğunda:

```bash
dart format .
flutter analyze
```

çalıştırılır.

Analyzer uyarıları sebepsiz ignore edilmez.

Başlangıçta standart Flutter/Dart analyzer ve lint kuralları kullanılır.

Gereksiz custom lint altyapısı şimdiden kurulmaz.

Domain/Engine import sınırları ilk aşamada:

* coding rule,
* review,
* test/analyzer kontrolü

ile korunur.

Tekrarlayan ihlal görülürse daha sonra otomatik import-boundary enforcement eklenebilir.

---

# 18. Dependency Disiplini

Yeni Dart/Flutter dependency eklenmeden önce şu sorular sorulur:

1. Bu ihtiyaç standart Dart/Flutter ile makul biçimde çözülebilir mi?
2. Paket gerçek bir problemi çözüyor mu?
3. Paket aktif ve sürdürülebilir mi?
4. Gereksiz vendor lock-in yaratıyor mu?
5. Domain/Engine saflığını etkiliyor mu?

Yeni dependency insan onayı olmadan eklenmez.

Bu kural AI geliştiriciler için de geçerlidir.

Özellikle:

* Freezed,
* equatable,
* fpdart,
* custom_lint,
* Riverpod generator

yalnızca gerçekten ihtiyaç oluşursa değerlendirilir.

---

# 19. Kod İçi Dokümantasyon, TODO ve Logging

Kod mümkün olduğunca kendini açıklamalıdır.

Şunu anlatan gereksiz yorum yazılmaz:

```dart
// score'u artır
score += 10;
```

Yorum özellikle **neden** sorusunu cevaplamak için kullanılır.

TODO belirsiz bırakılmaz.

Kötü:

```dart
// TODO fix later
```

Daha iyi:

```dart
// TODO(engine-calibration): Replace provisional threshold after beta calibration.
```

Kritik ürün davranışı TODO ile sessizce bypass edilmez.

Teknik log ile `ReasonTrail` birbirine karıştırılmaz.

Loglarda hassas veya gereksiz kişisel öğrenci verisi tutulmaz.

---

# 20. AI Geliştirici Protokolü

ChatGPT, Claude veya Gemini kod üretirken aşağıdaki kurallara uyar.

### 20.1 Ticket sahipliği

Bir coding ticket'ın implementasyonu tek bir AI'a atanır.

Diğer AI'lar gerektiğinde:

* review,
* test eleştirisi,
* bağımsız denetim

yapabilir.

Aynı ticket üzerinde birbirinden habersiz paralel implementasyon yapılmaz.

### 20.2 Dosya kapsamı

Her ticket mümkün olduğunca dokunulabilecek dosyaları veya kod alanını belirtir.

AI yalnızca gerekli dosyalara dokunur.

Ticket'ta açıkça belirtilmeyen başka bir dosyanın değiştirilmesi zorunlu hale gelirse AI bunu sessizce yapmaz.

Önce:

* hangi dosyanın,
* neden değişmesi gerektiğini,
* bunun ticket kapsamına etkisini

bildirir.

İzin/karar sonrasında kapsam genişletilir.

### 20.3 Açık kararda dur

Kodlama sırasında belgelerde kesinleştirilmemiş bir ürün veya mimari karara ihtiyaç duyulursa AI:

* tahmin etmez,
* kendi tercihine göre kesinleştirmez,
* sessiz default seçmez.

Durur ve kararı açıkça bildirir.

### 20.4 Büyük refactor yapma

Küçük bir ticket:

* mimariyi değiştirme,
* state management değiştirme,
* klasörleri yeniden kurma,
* backend değiştirme,
* dependency ekleme

yetkisi vermez.

### 20.5 Mevcut kodu koru

AI çalışan kodu yalnızca kendi tercih ettiği stile uydurmak için yeniden yazmaz.

### 20.6 Testi unutma

Ticket Engine davranışını değiştiriyorsa gerekli testler aynı işin parçasıdır.

### 20.7 Gerçekmiş gibi varsayma

AI görmediği:

* dosya,
* class,
* API,
* schema,
* fonksiyon

varmış gibi davranmaz.

Gerekirse önce mevcut kod kontrol edilir.

---

# 21. Ticket Tanımı

Kodlamadan önce ticket en az şu bilgileri taşımalıdır:

```text
Amaç
Kapsam
İlgili ürün/mimari kararı
Dokunulabilecek ana dosya/alanlar
Beklenen davranış
Test beklentisi
```

Küçük ticket için uzun belge gerekmez.

Ancak AI'ın görevin sınırlarını anlayabileceği kadar bağlam verilmelidir.

---

# 22. Ticket Sonu Kontrolü

Bir coding ticket tamamlandığında:

1. değişen dosyalar kontrol edilir,
2. testler çalıştırılır,
3. formatter çalıştırılır,
4. analyzer çalıştırılır,
5. `git diff` incelenir,
6. ticket dışı değişiklik olmadığı doğrulanır,
7. ancak bundan sonra commit edilir.

Kontrol sırasında en az şu sorular sorulur:

* Beklenen davranış gerçekleşti mi?
* Mimari sınırlar korundu mu?
* Domain/Engine'e yasak bağımlılık girdi mi?
* Yeni magic number oluştu mu?
* Açık karar yanlışlıkla kesinleştirildi mi?
* Gereksiz abstraction eklendi mi?
* Yeni dependency eklendi mi?
* Test gerekli miydi?
* Test gerçekten davranışı doğruluyor mu?

AI'ın:

> "çalışıyor"

demesi test yerine geçmez.

---

# 23. Git ve Commit Disiplini

Commit mümkün olduğunca tek mantıksal değişiklik içerir.

Örnek:

```text
docs: add coding rules

feat(engine): add prerequisite edge model

feat(engine): add graph validation

test(engine): add cycle detection tests

fix(engine): preserve soft prerequisite path
```

Commit öncesinde diff kontrol edilir.

Belge, feature, fix ve test değişiklikleri mümkün olduğunca anlaşılır commit mesajları taşır.

AI kendi başına commit veya push yapılmış olduğunu varsaymaz.

Git işlemleri gerçek terminal çıktısıyla doğrulanır.

---

# 24. Bu Belgenin Sınırı ve Değiştirilmesi

`CODING_RULES.md` şu soruya cevap verir:

> Kod nasıl yazılmalıdır?

Şu konuların ayrıntıları bu belgenin görevi değildir:

* mastery matematiği,
* confidence formülü,
* Evidence aggregation algoritması,
* self-assessment'in akademik etkisi,
* deneme/oturum katsayıları,
* Transfer'in matematiksel rolü,
* prerequisite gate'in kesin davranışı,
* bridge algoritması,
* candidate ranking formülü,
* planning mode eşikleri.

Bunlar `ROTA_ENGINE_SPEC.md` içinde ele alınacaktır.

`CODING_RULES.md` yaşayan bir teknik belgedir; ancak sessizce değiştirilmez.

Yeni bir kural gerçek bir:

* problem,
* tekrar eden hata,
* mimari ihtiyaç

nedeniyle eklenmelidir.

Bir AI yalnızca kendi tercihi nedeniyle bu belgeyi değiştiremez.

---

# 25. Kapanış İlkesi

ROTA kod tabanında hedef:

> **akıllı görünen kod değil, davranışı anlaşılabilen kod yazmaktır.**

Özellikle Learning Engine için kod:

* test edilebilir,
* tekrar üretilebilir,
* gerekçelendirilebilir,
* deterministik,
* dış servislerden bağımsız

olmalıdır.

Kodun görevi ürün kararlarını gizlemek değil, onları açık ve denetlenebilir biçimde gerçekleştirmektir.
