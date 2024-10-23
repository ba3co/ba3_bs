import 'package:ba3_bs/core/utils/utils.dart';

class PatternModel {
  String? patName,
      patCode,
      patType,
      patPrimary,
      patId,
      patSecondary,
      patStore,
      patNewStore,
      patGiftAccount,
      patSecGiftAccount,
      patFullName,
      patPartnerFeeAccount;
  int? patColor;
  double? patPartnerRatio, patPartnerCommission;

  PatternModel({
    this.patName,
    this.patFullName,
    this.patCode,
    this.patType,
    this.patPrimary,
    this.patId,
    // this.patHasVat,
    // this.patVatAccount,
    this.patSecondary,
    this.patStore,
    this.patColor,
    this.patNewStore,
    this.patGiftAccount,
    this.patSecGiftAccount,
    this.patPartnerCommission,
    this.patPartnerRatio,
    this.patPartnerFeeAccount,
  });

  PatternModel.fromJson(Map<String, dynamic> json) {
    patName = json['patName'];
    patFullName = json['patFullName'];
    patPartnerFeeAccount = json['patPartnerFeeAccount'];
    patCode = json['patCode'];
    patType = json['patType'];
    patPrimary = json['patPrimary'];
    patSecondary = json['patSecondary'];
    patStore = json['patStore'];
    patId = json['patId'];
    patColor = json['patColor'];
    patNewStore = json['patNewStore'];
    patGiftAccount = json['patGiftAccount'];
    patSecGiftAccount = json['patSecGiftAccount'];
    patPartnerRatio = json['patPartnerRatio'] ?? 0.0;
    patPartnerCommission = json['patPartnerCommission'] ?? 0.0;
  }

  toJson() {
    return {
      'patName': patName,
      'patPartnerFeeAccount': patPartnerFeeAccount,
      'patFullName': patFullName,
      'patCode': patCode,
      'patType': patType,
      'patPrimary': patPrimary,
      'patId': patId,
      'patSecondary': patSecondary,
      'patStore': patStore,
      'patColor': patColor,
      'patNewStore': patNewStore,
      'patGiftAccount': patGiftAccount,
      'patSecGiftAccount': patSecGiftAccount,
      'patPartnerCommission': patPartnerCommission,
      'patPartnerRatio': patPartnerRatio,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': patId,
      'الرمز': patCode,
      'الاسم': patFullName,
      'الاختصار': patName,
      'النوع': Utils.getInvTypeFromEnum(patType ?? ''),
      'patPrimary': Utils.getAccountNameFromId(patPrimary),
      'patSecondary': Utils.getAccountNameFromId(patSecondary),
    };
  }
}
