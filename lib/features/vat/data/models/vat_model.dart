class VatModel {
  final String? vatGuid;
  final double? vatRatio;
  final String? vatName;


  VatModel({
    this.vatGuid,
    this.vatRatio,
     this.vatName,
  });

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'vatGuid': vatGuid,
      'vatRatio': vatRatio,
      'vatName':vatName
    };
  }

  // Create RoleModel object from JSON
  factory VatModel.fromJson(Map<String, dynamic> json) {
    return VatModel(
      vatGuid: json['vatGuid'],
      vatRatio: json['vatRatio'],
      vatName: json['vatName'],

    );
  }

  // CopyWith method to create a new RoleModel with specific changes
  VatModel copyWith({
    String? vatGuid,
    String? vatName,
    double? vatRatio,
  }) {
    return VatModel(
      vatGuid: vatGuid ?? this.vatGuid,
      vatName: vatName ?? this.vatName,
      vatRatio: vatRatio ?? this.vatRatio,
    );
  }
}

VatModel withVat = VatModel(
  vatGuid: '1',
  vatRatio: 5.0,
  vatName: 'ضريبة القيمة المضافة في رأس الخيمة',
);
VatModel withOutVat = VatModel(
  vatGuid: '2',
  vatRatio: 0,
  vatName: 'معفى',
);
