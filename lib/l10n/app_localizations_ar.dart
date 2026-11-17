// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'كورة بالانس';

  @override
  String get brandName => 'كورة';

  @override
  String get brandTagline => 'موازن الفرق';

  @override
  String homeIntro(int rosterSize, int teamCount, int teamSize) {
    return 'قيّم لاعبيك الـ$rosterSize من 1 إلى 6 واحصل على $teamCount فرق متكافئة، في كل فريق $teamSize لاعبين. وداعًا للمباريات غير المتكافئة.';
  }

  @override
  String get statPlayers => 'لاعبين';

  @override
  String get statTeams => 'فرق';

  @override
  String get statSkillRanks => 'مستويات';

  @override
  String get start => 'ابدأ';

  @override
  String get continueReady => 'متابعة – التشكيلة جاهزة';

  @override
  String continueSelected(int selected, int required) {
    return 'متابعة ($selected/$required مختار)';
  }

  @override
  String playersSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لاعب محفوظ على هذا الجهاز',
      many: '$count لاعبًا محفوظًا على هذا الجهاز',
      few: '$count لاعبين محفوظين على هذا الجهاز',
      two: 'لاعبان محفوظان على هذا الجهاز',
      one: 'لاعب واحد محفوظ على هذا الجهاز',
    );
    return '$_temp0';
  }

  @override
  String get switchLanguage => 'English';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get playersTitle => 'اللاعبون';

  @override
  String get menuMore => 'المزيد';

  @override
  String get menuFillSample => 'إضافة لاعبين تجريبيين';

  @override
  String get menuSortBySkill => 'ترتيب حسب المستوى';

  @override
  String get menuClearSelection => 'إلغاء الاختيار';

  @override
  String get menuDeleteAll => 'حذف كل اللاعبين';

  @override
  String selectionLimitReached(int required) {
    return 'تم اختيار $required لاعبًا بالفعل. ألغِ اختيار أحدهم أولًا.';
  }

  @override
  String playerDeleted(String name) {
    return 'تم حذف $name من القائمة';
  }

  @override
  String get undo => 'تراجع';

  @override
  String sampleAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count لاعب تجريبي.',
      many: 'تمت إضافة $count لاعبًا تجريبيًا.',
      few: 'تمت إضافة $count لاعبين تجريبيين.',
      two: 'تمت إضافة لاعبَين تجريبيَّين.',
      one: 'تمت إضافة لاعب تجريبي واحد.',
      zero: 'لم تتم إضافة لاعبين.',
    );
    return '$_temp0';
  }

  @override
  String get deleteAllTitle => 'حذف كل اللاعبين؟';

  @override
  String deleteAllMessage(int count) {
    return 'سيتم حذف كل اللاعبين المحفوظين ($count) من هذا الجهاز.';
  }

  @override
  String get deleteAllConfirm => 'حذف الكل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get noPlayersMatch => 'لا يوجد لاعبون مطابقون.';

  @override
  String get searchPlayers => 'ابحث عن لاعب';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String filterAll(int count) {
    return 'الكل $count';
  }

  @override
  String filterSelected(int count) {
    return 'المختارون $count';
  }

  @override
  String filterBench(int count) {
    return 'غير المختارين $count';
  }

  @override
  String get poolHint =>
      'اضغط على اللاعب لاختياره أو إلغاء اختياره · اسحب للحذف';

  @override
  String get add => 'إضافة';

  @override
  String get generateTeams => 'كوّن الفرق';

  @override
  String generateProgress(int selected, int required) {
    return 'تكوين الفرق ($selected/$required)';
  }

  @override
  String get emptyTitle => 'لا يوجد لاعبون بعد';

  @override
  String emptyMessage(int required) {
    return 'أضف كل من يلعب معك وقيّمه من 1 (الأقوى) إلى 6. وفي كل مباراة اختر $required منهم.';
  }

  @override
  String get addFirstPlayer => 'أضف أول لاعب';

  @override
  String get trySample => 'أو جرّب تشكيلة تجريبية';

  @override
  String get delete => 'حذف';

  @override
  String editPlayerTooltip(String name) {
    return 'تعديل $name';
  }

  @override
  String get sameName => 'اسم مكرر';

  @override
  String get sameNameTooltip =>
      'يوجد لاعب آخر بنفس الاسم. سيتم ترقيمهما في الفرق.';

  @override
  String skillSummary(String label, int points) {
    return '$label · $points نقاط';
  }

  @override
  String get lineupReadyTitle => 'التشكيلة جاهزة!';

  @override
  String lineupReadyMessage(int required, int poolSize) {
    return 'تم اختيار $required من أصل $poolSize لاعبًا. جاهزون لصافرة البداية.';
  }

  @override
  String get buildPoolTitle => 'كوّن قائمة لاعبيك';

  @override
  String buildPoolMessage(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'أضف $missing لاعب آخر. يمكنك حفظ أي عدد تريده.',
      many: 'أضف $missing لاعبًا آخر. يمكنك حفظ أي عدد تريده.',
      few: 'أضف $missing لاعبين آخرين. يمكنك حفظ أي عدد تريده.',
      two: 'أضف لاعبَين آخرَين. يمكنك حفظ أي عدد تريده.',
      one: 'أضف لاعبًا واحدًا آخر. يمكنك حفظ أي عدد تريده.',
    );
    return '$_temp0';
  }

  @override
  String get pickPlayersTitle => 'اختر لاعبي اليوم';

  @override
  String pickPlayersMessage(int missing, int poolSize) {
    return 'اختر $missing آخرين من قائمتك ($poolSize لاعبًا).';
  }

  @override
  String rankCount(int rank, int count) {
    return 'م$rank ×$count';
  }

  @override
  String get addPlayerTitle => 'إضافة لاعب';

  @override
  String get editPlayerTitle => 'تعديل لاعب';

  @override
  String get editPlayerSubtitle => 'عدّل الاسم أو المستوى.';

  @override
  String get addPlayerSubtitle => 'سيُحفظ في قائمة لاعبيك للمباريات القادمة.';

  @override
  String get playerNameLabel => 'اسم اللاعب';

  @override
  String duplicateNameHelper(String name) {
    return 'هذا الاسم موجود بالفعل، ولا مشكلة في ذلك – سيتم ترقيمه، مثل «$name (2)».';
  }

  @override
  String get skillLevelLabel => 'المستوى';

  @override
  String get saveAndAddNext => 'حفظ وإضافة التالي';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String playerAdded(String name) {
    return 'تمت إضافة $name إلى القائمة';
  }

  @override
  String get nameErrorEmpty => 'من فضلك أدخل اسم اللاعب';

  @override
  String nameErrorTooLong(int max) {
    return 'يجب ألا يزيد الاسم عن $max حرفًا';
  }

  @override
  String get skillErrorMissing => 'اختر مستوى من 1 (الأقوى) إلى 6';

  @override
  String get skillHint => '1 = الأقوى  ·  6 = الأضعف';

  @override
  String skillSelectedSummary(int rank, String label, int points) {
    return 'المستوى $rank · $label · $points نقاط قوة';
  }

  @override
  String skillSemantics(int rank, String label) {
    return 'المستوى $rank، $label';
  }

  @override
  String get skillElite => 'نجم';

  @override
  String get skillExcellent => 'ممتاز';

  @override
  String get skillGood => 'جيد';

  @override
  String get skillAverage => 'متوسط';

  @override
  String get skillDeveloping => 'متطور';

  @override
  String get skillBeginner => 'مبتدئ';

  @override
  String get matchDay => 'يوم المباراة';

  @override
  String get editPlayers => 'تعديل اللاعبين';

  @override
  String get copyTeams => 'نسخ الفرق';

  @override
  String get teamsCopied => 'تم نسخ الفرق';

  @override
  String get resetTitle => 'اختيار تشكيلة جديدة؟';

  @override
  String resetMessage(int required) {
    return 'سيتم إلغاء اختيار اللاعبين الـ$required الحاليين لتختار من جديد. لاعبوك المحفوظون سيبقون كما هم.';
  }

  @override
  String get reset => 'إعادة ضبط';

  @override
  String get edit => 'تعديل';

  @override
  String get regenerate => 'إعادة التوزيع';

  @override
  String get swapHint => 'اضغط على لاعب، ثم على لاعب من فريق آخر لتبديلهما.';

  @override
  String swapPickTarget(String name) {
    return 'اضغط الآن على لاعب من فريق آخر لتبديله مع $name.';
  }

  @override
  String playersSwapped(String first, String second) {
    return 'تم تبديل $first ↔ $second';
  }

  @override
  String get cancelSwap => 'إلغاء التبديل';

  @override
  String get copyHeader => '⚽ كورة – يوم المباراة';

  @override
  String copyTeamLine(String team, int strength) {
    return '$team (القوة $strength)';
  }

  @override
  String copyPlayerLine(String name, int rank) {
    return '$name – المستوى $rank';
  }

  @override
  String get generationFailed => 'تعذّر تكوين الفرق. راجع اللاعبين المختارين.';

  @override
  String issuePoolTooSmall(int missing, int required, int teamCount) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other:
          'أضف $missing لاعب آخر – مطلوب $required لاعبًا لتكوين $teamCount فرق.',
      many:
          'أضف $missing لاعبًا آخر – مطلوب $required لاعبًا لتكوين $teamCount فرق.',
      few:
          'أضف $missing لاعبين آخرين – مطلوب $required لاعبًا لتكوين $teamCount فرق.',
      two: 'أضف لاعبَين آخرَين – مطلوب $required لاعبًا لتكوين $teamCount فرق.',
      one:
          'أضف لاعبًا واحدًا آخر – مطلوب $required لاعبًا لتكوين $teamCount فرق.',
    );
    return '$_temp0';
  }

  @override
  String issueSelectMore(int missing, int selected, int required) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'اختر $missing لاعب آخر ($selected/$required مختار).',
      many: 'اختر $missing لاعبًا آخر ($selected/$required مختار).',
      few: 'اختر $missing لاعبين آخرين ($selected/$required مختار).',
      two: 'اختر لاعبَين آخرَين ($selected/$required مختار).',
      one: 'اختر لاعبًا واحدًا آخر ($selected/$required مختار).',
    );
    return '$_temp0';
  }

  @override
  String issueTooMany(int extra, int required) {
    return 'ألغِ اختيار $extra لاعب – المطلوب $required لاعبًا بالضبط.';
  }

  @override
  String get issueInvalidName => 'أحد اللاعبين المختارين لديه اسم غير صالح.';

  @override
  String get drawingTitle => 'جارٍ موازنة الفرق…';

  @override
  String get drawingSubtitle => 'نقارن كل التوزيعات العادلة';

  @override
  String teamName(String letter) {
    return 'الفريق $letter';
  }

  @override
  String teamLetter(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'أ',
      '1': 'ب',
      '2': 'ج',
      '3': 'د',
      '4': 'هـ',
      'other': '؟',
    });
    return '$_temp0';
  }

  @override
  String teamSubtitle(String average, int count) {
    return 'متوسط المستوى $average · $count لاعبين';
  }

  @override
  String get strengthLabel => 'القوة';

  @override
  String get ratingPerfectTitle => 'توازن مثالي';

  @override
  String get ratingPerfectDescription => 'كل الفرق لها نفس القوة تمامًا.';

  @override
  String get ratingExcellentTitle => 'توازن ممتاز';

  @override
  String get ratingExcellentDescription => 'الفارق بين الفرق نقطة واحدة فقط.';

  @override
  String get ratingGoodTitle => 'توازن جيد';

  @override
  String get ratingGoodDescription => 'فارق بسيط في القوة بين الفرق.';

  @override
  String get ratingBestPossibleTitle => 'أفضل توازن ممكن';

  @override
  String get ratingBestPossibleDescription =>
      'مستويات هذه التشكيلة لا تسمح بتوزيع أقرب من ذلك.';

  @override
  String get ratingUnevenTitle => 'فرق غير متكافئة';

  @override
  String get ratingUnevenDescription =>
      'تعديلاتك تركت فارقًا كبيرًا في القوة. أعد التوزيع للحصول على أعدل تقسيم.';

  @override
  String get balanceLabel => 'التوازن';

  @override
  String strengthGap(int spread) {
    String _temp0 = intl.Intl.pluralLogic(
      spread,
      locale: localeName,
      other: 'فارق القوة: $spread نقطة · أفضل توزيع ممكن رياضيًا',
      few: 'فارق القوة: $spread نقاط · أفضل توزيع ممكن رياضيًا',
      two: 'فارق القوة: نقطتان · أفضل توزيع ممكن رياضيًا',
      one: 'فارق القوة: نقطة واحدة · أفضل توزيع ممكن رياضيًا',
      zero: 'فارق القوة: صفر · أفضل توزيع ممكن رياضيًا',
    );
    return '$_temp0';
  }

  @override
  String strengthGapEdited(int spread) {
    String _temp0 = intl.Intl.pluralLogic(
      spread,
      locale: localeName,
      other: 'فارق القوة: $spread نقطة · معدّل يدويًا',
      few: 'فارق القوة: $spread نقاط · معدّل يدويًا',
      two: 'فارق القوة: نقطتان · معدّل يدويًا',
      one: 'فارق القوة: نقطة واحدة · معدّل يدويًا',
      zero: 'فارق القوة: صفر · معدّل يدويًا',
    );
    return '$_temp0';
  }

  @override
  String get sampleNames =>
      'أحمد,عمر,يوسف,كريم,مصطفى,حسن,علي,محمود,طارق,عمرو,خالد,زياد,حمزة,آدم,نور,سيف,ياسين,مروان,هشام,شريف,فادي,باسم,وليد,إبراهيم,مازن,هادي,رامي,سامح';
}
