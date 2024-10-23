import 'package:ba3_bs/core/utils/utils.dart';

class PatternModel {
  String? patName;
  String? patCode;
  String? patType;
  String? patPrimary;
  String? patId;
  String? patSecondary;
  String? patStore;
  String? patNewStore;
  String? patGiftAccount;
  String? patSecGiftAccount;
  String? patFullName;
  String? patPartnerFeeAccount;
  int? patColor;
  double? patPartnerRatio;
  double? patPartnerCommission;

  PatternModel({
    this.patName,
    this.patFullName,
    this.patCode,
    this.patType,
    this.patPrimary,
    this.patId,
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

  // Factory constructor for creating an instance from JSON
  factory PatternModel.fromJson(Map<String, dynamic> json) {
    return PatternModel(
      patName: json['patName'],
      patFullName: json['patFullName'],
      patPartnerFeeAccount: json['patPartnerFeeAccount'],
      patCode: json['patCode'],
      patType: json['patType'],
      patPrimary: json['patPrimary'],
      patSecondary: json['patSecondary'],
      patStore: json['patStore'],
      patId: json['patId'],
      patColor: json['patColor'],
      patNewStore: json['patNewStore'],
      patGiftAccount: json['patGiftAccount'],
      patSecGiftAccount: json['patSecGiftAccount'],
      patPartnerRatio: json['patPartnerRatio'] ?? 0.0,
      patPartnerCommission: json['patPartnerCommission'] ?? 0.0,
    );
  }

  // Convert the object into a JSON representation
  Map<String, dynamic> toJson() {
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

  // Convert the object into a map
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

  // Copy with method for creating a new instance with some modified fields
  PatternModel copyWith({
    String? patName,
    String? patFullName,
    String? patCode,
    String? patType,
    String? patPrimary,
    String? patId,
    String? patSecondary,
    String? patStore,
    int? patColor,
    String? patNewStore,
    String? patGiftAccount,
    String? patSecGiftAccount,
    double? patPartnerRatio,
    double? patPartnerCommission,
    String? patPartnerFeeAccount,
  }) {
    return PatternModel(
      patName: patName ?? this.patName,
      patFullName: patFullName ?? this.patFullName,
      patCode: patCode ?? this.patCode,
      patType: patType ?? this.patType,
      patPrimary: patPrimary ?? this.patPrimary,
      patId: patId ?? this.patId,
      patSecondary: patSecondary ?? this.patSecondary,
      patStore: patStore ?? this.patStore,
      patColor: patColor ?? this.patColor,
      patNewStore: patNewStore ?? this.patNewStore,
      patGiftAccount: patGiftAccount ?? this.patGiftAccount,
      patSecGiftAccount: patSecGiftAccount ?? this.patSecGiftAccount,
      patPartnerRatio: patPartnerRatio ?? this.patPartnerRatio,
      patPartnerCommission: patPartnerCommission ?? this.patPartnerCommission,
      patPartnerFeeAccount: patPartnerFeeAccount ?? this.patPartnerFeeAccount,
    );
  }
}
