import '../../domain/prerequisite.dart';
import '../../domain/topic.dart';
import 'prerequisite_graph.dart';

const tytAytMathGraph = PrerequisiteGraph(
  subjectId: 'mathematics',
  version: '1.0.0',
  topics: [
    // A — Temel Cebir
    Topic(id: 'temel_kavramlar', title: 'Temel Kavramlar'),
    Topic(id: 'bolme_bolunebilme', title: 'Bölme–Bölünebilme'),
    Topic(id: 'ebob_ekok', title: 'EBOB–EKOK'),
    Topic(id: 'rasyonel_sayilar', title: 'Rasyonel Sayılar'),
    Topic(id: 'basit_esitsizlikler', title: 'Basit Eşitsizlikler'),
    Topic(id: 'mutlak_deger', title: 'Mutlak Değer'),
    Topic(id: 'uslu_sayilar', title: 'Üslü Sayılar'),
    Topic(id: 'koklu_sayilar', title: 'Köklü Sayılar'),
    Topic(id: 'carpanlara_ayirma', title: 'Çarpanlara Ayırma'),
    Topic(id: 'oran_oranti', title: 'Oran–Orantı'),
    Topic(id: 'denklem_cozme', title: 'Denklem Çözme'),

    // B — Problemler
    Topic(id: 'sayi_problemleri', title: 'Sayı Problemleri'),
    Topic(
      id: 'kesir_yas_yuzde_kar_zarar',
      title: 'Kesir/Yaş/Yüzde/Kâr-Zarar',
    ),
    Topic(id: 'hareket_hiz', title: 'Hareket–Hız'),
    Topic(id: 'isci_havuz', title: 'İşçi–Havuz'),

    // C — Sayma & Mantık
    Topic(id: 'mantik', title: 'Mantık'),
    Topic(id: 'kumeler', title: 'Kümeler'),
    Topic(id: 'permutasyon', title: 'Permütasyon'),
    Topic(id: 'kombinasyon', title: 'Kombinasyon'),
    Topic(id: 'olasilik', title: 'Olasılık'),
    Topic(id: 'istatistik', title: 'İstatistik'),

    // D — Fonksiyon–Polinom
    Topic(id: 'fonksiyonlar', title: 'Fonksiyonlar'),
    Topic(
      id: 'ikinci_derece_denklemler_parabol',
      title: '2. Derece Denklemler/Parabol',
    ),
    Topic(id: 'polinomlar', title: 'Polinomlar'),
    Topic(id: 'karmasik_sayilar', title: 'Karmaşık Sayılar'),
    Topic(id: 'logaritma', title: 'Logaritma'),

    // E — Trigonometri
    Topic(id: 'trigonometri', title: 'Trigonometri'),

    // F — Analiz & Diziler
    Topic(id: 'diziler', title: 'Diziler'),
    Topic(
      id: 'limit_ve_sureklilik',
      title: 'Limit ve Süreklilik',
    ),
    Topic(id: 'turev', title: 'Türev'),
    Topic(id: 'integral', title: 'İntegral'),

    // G — Geometri
    Topic(id: 'temel_geometri', title: 'Temel Geometri'),
    Topic(id: 'ucgenler', title: 'Üçgenler'),
    Topic(
      id: 'dortgenler_ve_cokgenler',
      title: 'Dörtgenler ve Çokgenler',
    ),
    Topic(id: 'cember_ve_daire', title: 'Çember ve Daire'),
    Topic(id: 'analitik_geometri', title: 'Analitik Geometri'),
    Topic(id: 'kati_cisimler', title: 'Katı Cisimler'),
    Topic(
      id: 'donusum_geometrisi',
      title: 'Dönüşüm Geometrisi',
    ),
  ],
  edges: [
    // A — Temel cebir içi
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'bolme_bolunebilme',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'rasyonel_sayilar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'bolme_bolunebilme',
      targetTopicId: 'ebob_ekok',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'uslu_sayilar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'uslu_sayilar',
      targetTopicId: 'koklu_sayilar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'basit_esitsizlikler',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'mutlak_deger',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'basit_esitsizlikler',
      targetTopicId: 'mutlak_deger',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'oran_oranti',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'rasyonel_sayilar',
      targetTopicId: 'oran_oranti',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'denklem_cozme',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'uslu_sayilar',
      targetTopicId: 'carpanlara_ayirma',
      type: PrerequisiteType.hard,
    ),

    // B — Problemler
    PrerequisiteEdge(
      prerequisiteTopicId: 'oran_oranti',
      targetTopicId: 'sayi_problemleri',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'sayi_problemleri',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'oran_oranti',
      targetTopicId: 'kesir_yas_yuzde_kar_zarar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'kesir_yas_yuzde_kar_zarar',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'oran_oranti',
      targetTopicId: 'hareket_hiz',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'hareket_hiz',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'oran_oranti',
      targetTopicId: 'isci_havuz',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'isci_havuz',
      type: PrerequisiteType.soft,
    ),

    // C — Sayma & Mantık
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'permutasyon',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'kombinasyon',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'kombinasyon',
      targetTopicId: 'olasilik',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'permutasyon',
      targetTopicId: 'olasilik',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'olasilik',
      targetTopicId: 'istatistik',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_kavramlar',
      targetTopicId: 'istatistik',
      type: PrerequisiteType.hard,
    ),

    // D — Fonksiyon–Polinom
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'fonksiyonlar',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'carpanlara_ayirma',
      targetTopicId: 'ikinci_derece_denklemler_parabol',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'denklem_cozme',
      targetTopicId: 'ikinci_derece_denklemler_parabol',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'ikinci_derece_denklemler_parabol',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'carpanlara_ayirma',
      targetTopicId: 'polinomlar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'polinomlar',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'ikinci_derece_denklemler_parabol',
      targetTopicId: 'karmasik_sayilar',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'uslu_sayilar',
      targetTopicId: 'logaritma',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'logaritma',
      type: PrerequisiteType.hard,
    ),

    // E — Trigonometri
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'trigonometri',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'oran_oranti',
      targetTopicId: 'trigonometri',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'carpanlara_ayirma',
      targetTopicId: 'trigonometri',
      type: PrerequisiteType.soft,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'ucgenler',
      targetTopicId: 'trigonometri',
      type: PrerequisiteType.soft,
      isCrossDomain: true,
    ),

    // F — Analiz & Diziler
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'diziler',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'limit_ve_sureklilik',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'limit_ve_sureklilik',
      targetTopicId: 'turev',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'turev',
      targetTopicId: 'integral',
      type: PrerequisiteType.hard,
    ),

    // G — Geometri
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_geometri',
      targetTopicId: 'ucgenler',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'ucgenler',
      targetTopicId: 'dortgenler_ve_cokgenler',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'ucgenler',
      targetTopicId: 'cember_ve_daire',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'ucgenler',
      targetTopicId: 'analitik_geometri',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'dortgenler_ve_cokgenler',
      targetTopicId: 'kati_cisimler',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'temel_geometri',
      targetTopicId: 'donusum_geometrisi',
      type: PrerequisiteType.hard,
    ),
    PrerequisiteEdge(
      prerequisiteTopicId: 'analitik_geometri',
      targetTopicId: 'donusum_geometrisi',
      type: PrerequisiteType.soft,
    ),

    // G3 — Matematik → Geometri sınır istisnası
    PrerequisiteEdge(
      prerequisiteTopicId: 'fonksiyonlar',
      targetTopicId: 'analitik_geometri',
      type: PrerequisiteType.hard,
      isCrossDomain: true,
    ),
  ],
);