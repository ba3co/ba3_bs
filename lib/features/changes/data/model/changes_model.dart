class ChangesModel {
  String? changeId;
  String? changeNumber;
  ChangeType? changeType;
  ChangeCollection? changeCollection;
  List<String>? fags;

  ChangesModel({
    this.changeId,
    this.changeType,
    this.changeCollection,
    this.fags,
    this.changeNumber,
  });

  // fromJson
  factory ChangesModel.fromJson(Map<String, dynamic> json) {
    return ChangesModel(
      changeId: json['changeId'] ??'',
      changeNumber: json['changeNumber'] ??'',
      changeType: json['changeType'] != null ? ChangeType.values.byName(json['changeType']) : null,
      changeCollection: json['changeCollection'] != null ? ChangeCollection.values.byName(json['changeCollection']) : null,
      fags: List<String>.from(json['fags'] ?? []),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'changeId': changeId,
      'changeNumber': changeNumber,
      'changeType': changeType?.name,
      'changeCollection': changeCollection?.name,
      'fags': fags,
    };
  }

  // copyWith
  ChangesModel copyWith({
    String? changeId,
    String? changeNumber,
    ChangeType? changeType,
    ChangeCollection? changeCollection,
    List<String>? fags,
  }) {
    return ChangesModel(
      changeId: changeId ?? this.changeId,
      changeNumber: changeNumber ?? this.changeNumber,
      changeType: changeType ?? this.changeType,
      changeCollection: changeCollection ?? this.changeCollection,
      fags: fags ?? this.fags,
    );
  }
}

enum ChangeCollection { bills, accounts, bonds, cheques, users, materials }

enum ChangeType { add, remove, update }
