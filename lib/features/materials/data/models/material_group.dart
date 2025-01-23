class MaterialGroupModel {
  final String matGroupGuid;
  final String groupCode;
  final String groupName;
  final String groupLatinName;
  final String parentGuid;
  final String groupNotes;
  final int groupSecurity;
  final int groupType;
  final double groupVat;
  final int groupNumber;
  final int groupBranchMask;

  MaterialGroupModel({
    required this.matGroupGuid,
    required this.groupCode,
    required this.groupName,
    required this.groupLatinName,
    required this.parentGuid,
    required this.groupNotes,
    required this.groupSecurity,
    required this.groupType,
    required this.groupVat,
    required this.groupNumber,
    required this.groupBranchMask,
  });

  // تحويل من JSON إلى كائن Dart
  factory MaterialGroupModel.fromJson(Map<String, dynamic> json) {
    return MaterialGroupModel(
      matGroupGuid: json['docId'] ?? '',
      groupCode: json['GroupCode'] ?? '',
      groupName: json['GroupName'] ?? '',
      groupLatinName: json['GroupLatinName'] ?? '',
      parentGuid: json['ParentGuid'] ?? '',
      groupNotes: json['GroupNotes'] ?? '',
      groupSecurity: json['GroupSecurity'] ?? 0,
      groupType: json['GroupType'] ?? 0,
      groupVat: (json['GroupVat'] ?? 0.0).toDouble(),
      groupNumber: json['GroupNumber'] ?? 0,
      groupBranchMask: json['GroupBranchMask'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': matGroupGuid,
      'GroupCode': groupCode,
      'GroupName': groupName,
      'GroupLatinName': groupLatinName,
      'ParentGuid': parentGuid,
      'GroupNotes': groupNotes,
      'GroupSecurity': groupSecurity,
      'GroupType': groupType,
      'GroupVat': groupVat,
      'GroupNumber': groupNumber,
      'GroupBranchMask': groupBranchMask,
    };
  }

  // نسخة جديدة مع تعديلات معينة باستخدام copyWith
  MaterialGroupModel copyWith({
    String? matGroupGuid,
    String? groupCode,
    String? groupName,
    String? groupLatinName,
    String? parentGuid,
    String? groupNotes,
    int? groupSecurity,
    int? groupType,
    double? groupVat,
    int? groupNumber,
    int? groupBranchMask,
  }) {
    return MaterialGroupModel(
      matGroupGuid: matGroupGuid ?? this.matGroupGuid,
      groupCode: groupCode ?? this.groupCode,
      groupName: groupName ?? this.groupName,
      groupLatinName: groupLatinName ?? this.groupLatinName,
      parentGuid: parentGuid ?? this.parentGuid,
      groupNotes: groupNotes ?? this.groupNotes,
      groupSecurity: groupSecurity ?? this.groupSecurity,
      groupType: groupType ?? this.groupType,
      groupVat: groupVat ?? this.groupVat,
      groupNumber: groupNumber ?? this.groupNumber,
      groupBranchMask: groupBranchMask ?? this.groupBranchMask,
    );
  }
}
