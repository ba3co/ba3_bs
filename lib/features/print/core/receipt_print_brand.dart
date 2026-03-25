import '../../../core/constants/app_assets.dart';

/// Which legal entity / branding to print on thermal receipts.
enum ReceiptPrintBrand {
  mobilePhones,
  carAccessories,
}

/// Header/footer values per brand (shared address & phone per your spec).
extension ReceiptPrintBrandConfig on ReceiptPrintBrand {
  String get logoAsset => switch (this) {
        ReceiptPrintBrand.mobilePhones => AppAssets.ba3Logo,
        ReceiptPrintBrand.carAccessories => AppAssets.ba3CarLogo,
      };

  String get businessName => switch (this) {
        ReceiptPrintBrand.mobilePhones => 'Burj Al Arab Mobile Phones',
        ReceiptPrintBrand.carAccessories =>
          'Al Burj BA3 Trading & Car Accessories',
      };

  String get trn => switch (this) {
        ReceiptPrintBrand.mobilePhones => '100369311400003',
        ReceiptPrintBrand.carAccessories => '105369111700003',
      };

  /// Shown in the receipt footer "Powered by:" line.
  String get poweredByLine => businessName;
}
