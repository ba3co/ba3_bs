// lib/features/print/zpl/zpl_helpers.dart

/// 203dpi ≈ 8 dots لكل 1mm
int mmToDots(num mm) => (mm * 8).round();

String _zplSanitize(String s) {
  var out = s.replaceAll(RegExp(r'[\^~]'), ' ');
  out = out.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  return out;
}

bool _isAllDigits(String s) => RegExp(r'^\d+$').hasMatch(s);
bool _looksLikeEan13(String s) =>
    _isAllDigits(s) && (s.length == 12 || s.length == 13);

/// ليبل: "اسم (سطرين) ثم سعر ثم باركود ممتد بعرض اللصاقة مع هوامش هادئة"
/// - يمدد EAN-13 على كامل عرض منطقة الطباعة (مع ترك quiet zones).
/// - لغير EAN: Code128 بموديول مناسب ومُـوسَّط وهوامش هادئة.
/// - لا يطبع نص القيمة تحت الباركود (حسب طلبك).
String buildTitlePriceBarcodeFullWidthZpl({
  required String data,
  String? title,
  String? priceText,
  String? batteryText,

  // مقاس اللصاقة
  double labelWidthMm = 50,
  double labelHeightMm = 30,

  // نسخ/جودة
  int copies = 1,
  int darkness = 18,
  int printSpeed = 2,

  // هوامش إطار اللصاقة
  int marginLeftDots = 20,
  int marginRightDots = 20,
  int marginTopDots = 18,
  int marginBottomDots = 18,

  // هوامش هادئة حول الباركود (quiet zones) ~ 2mm افتراضياً
  double quietZoneMm = 2.0,

  // نصوص
  int titleFontHeight = 24, // أصغر شوي
  int titleLineSpacing = 2,
  int titleMaxLines = 2,
  int priceFontHeight = 22,
  int batteryFontHeight = 18,

  // ارتفاع الباركود
  int barcodeHeight = 110,
  // خط رقم الباركود تحت الشريط
  int barcodeNumberFontHeight = 18,
}) {
  final W = mmToDots(labelWidthMm);
  final H = mmToDots(labelHeightMm);
  final Q = mmToDots(quietZoneMm);

  final d = _zplSanitize(data);
  final t =
      (title != null && title.trim().isNotEmpty) ? _zplSanitize(title) : null;
  final p = (priceText != null && priceText.trim().isNotEmpty)
      ? _zplSanitize(priceText)
      : null;
  final b = (batteryText != null && batteryText.trim().isNotEmpty)
      ? _zplSanitize(batteryText)
      : null;

  final innerWidth = W - marginLeftDots - marginRightDots;

  int y = marginTopDots;
  final buf = StringBuffer()
    ..writeln('^XA')
    ..writeln('^PW$W')
    ..writeln('^LL$H')
    ..writeln('^LH0,0')
    ..writeln('^PR$printSpeed')
    ..writeln('^MD$darkness')
    ..writeln('^PQ$copies,0,1,N');

  // ---- الاسم (سطرين max) وسط
  if (t != null) {
    buf
      ..write('^CF0,$titleFontHeight')
      ..write(
          '^FO$marginLeftDots,$y^FB$innerWidth,$titleMaxLines,$titleLineSpacing,C,0^FD$t^FS\n');
    y += (titleMaxLines * (titleFontHeight + titleLineSpacing)) + 6;
  }

  // ---- السعر تحت الاسم مباشرة (وسط)
  if (p != null) {
    buf
      ..write('^CF0,$priceFontHeight')
      ..write('^FO$marginLeftDots,$y^FB$innerWidth,1,0,C,0^FD$p^FS\n');
    y += priceFontHeight + 8;
  }

  // ---- نسبة البطارية مع علامة بطارية (اختياري)
  if (b != null) {
    const batteryLabel =
        'Batt '; // علامة البطارية بجانب النسبة (ASCII لضمان الطباعة)
    final batteryLine = '$batteryLabel$b';
    buf
      ..write('^CF0,$batteryFontHeight')
      ..write(
          '^FO$marginLeftDots,$y^FB$innerWidth,1,0,C,0^FD$batteryLine^FS\n');
    y += batteryFontHeight + 6;
  }

  // ---- الباركود بعرض اللصاقة بالكامل مع هوامش هادئة
  final isEan = _looksLikeEan13(d);
  // منطقة الباركود الأفقية المتاحة = innerWidth - 2*Q
  final availBarcodeWidth = innerWidth - 2 * Q;

  buf.writeln(
      '^BY2,2,$barcodeHeight'); // الافتراضي، سنعدل الموديول لاحقًا حسب النوع

  if (isEan) {
    // EAN-13 ثابت 95 وحدة (بدون احتساب الهدوء الذي نتركه نحن)
    const eanModules = 95;
    int module = (availBarcodeWidth / eanModules).floor();
    if (module < 2) module = 2; // لا تنزل أقل من 2 لضمان جودة
    if (module > 4) module = 4; // لا ترفع كثيراً حتى لا يتجاوز الهدوء

    final eanWidthDots = module * eanModules;
    // ضع الباركود بحيث يترك Q يمين ويسار ويتمركز في innerWidth
    int barcodeX = marginLeftDots + ((innerWidth - eanWidthDots) / 2).round();
    // تأكد من وجود الهدوء
    if (barcodeX < marginLeftDots + Q) barcodeX = marginLeftDots + Q;
    final rightEdge = barcodeX + eanWidthDots;
    final maxRight = W - marginRightDots - Q;
    if (rightEdge > maxRight) {
      barcodeX = maxRight - eanWidthDots;
    }

    buf
      ..writeln('^BY$module,2,$barcodeHeight')
      ..writeln('^FO$barcodeX,$y^BEN,$barcodeHeight,N^FD$d^FS');
  } else {
    // Code128 — عرضه يعتمد على المحتوى، نحاول قدر الإمكان ونعطي هدوء
    // تقدير موديول بحيث لا يتجاوز المساحة المتاحة (تقريبي)
    // نبدأ من 2 ونرفع حتى 3 إذا أمكن حسب طول الداتا
    int module = 2;
    if (d.length <= 10 && availBarcodeWidth > 95 * 3) {
      module = 3;
    }
    // مركز الباركود تقريبياً داخل المنطقة مع الهدوء
    final left = marginLeftDots + Q;
    final right = W - marginRightDots - Q;
    final centerX = ((left + right) / 2).round();
    final approxWidth =
        (d.length * 11 + 35) * module; // تقدير تقريبي لعرض Code128
    int barcodeX = centerX - (approxWidth ~/ 2);
    if (barcodeX < left) barcodeX = left;
    if (barcodeX + approxWidth > right) barcodeX = right - approxWidth;

    buf
      ..writeln('^BY$module,2,$barcodeHeight')
      ..writeln('^FO$barcodeX,$y^BCN,$barcodeHeight,N,N,N^FD$d^FS');
  }

  y += barcodeHeight + 4;

  // ---- رقم الباركود تحت الشريط (مقروء)
  buf
    ..write('^CF0,$barcodeNumberFontHeight')
    ..write('^FO$marginLeftDots,$y^FB$innerWidth,1,0,C,0^FD$d^FS\n');
  y += barcodeNumberFontHeight + 6;

  // تحديث الطول لو احتجنا
  final minNeededWithNumber = y + marginBottomDots;
  if (minNeededWithNumber > H) buf.writeln('^LL$minNeededWithNumber');

  buf.writeln('^XZ');
  return buf.toString();
}
