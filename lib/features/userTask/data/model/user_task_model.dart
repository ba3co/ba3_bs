import '../../../../core/helper/enums/enums.dart';

class UserTaskModel {
  String? docId;
  String? title;
  List<MaterialTaskModel>? materialTask;
  String? dueDate;
 TaskStatus? status;
  String? assignedTo;
  String? assignedBy;
  TaskType? taskType;
  String? taskImage;
  String? createdAt;
  String? updatedAt;

  UserTaskModel({
    this.docId,
    this.title,
    this.materialTask,
    this.dueDate,
    this.status,
    this.assignedTo,
    this.assignedBy,
    this.taskType,
    this.taskImage,
    this.createdAt,
    this.updatedAt,
  });

  /// تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'title': title,
      'materialTask': materialTask?.map((item) => item.toJson()) .toList(),
      'dueDate': dueDate,
      'status': status?.value,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'taskType': taskType,
      'taskImage': taskImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// تحويل JSON إلى كائن `UserTaskModel`
  factory UserTaskModel.fromJson(Map<String, dynamic> json) {
    return UserTaskModel(
      docId: json['docId'] as String?,
      title: json['title'] as String?,
      materialTask:json['materialTask']==null?[]: (json['materialTask'] as List<dynamic>)
          .map((materialTaskJson) => MaterialTaskModel.fromJson(materialTaskJson))
          .toList(),      dueDate: json['dueDate'] as String?,
      status:  TaskStatus.byValue(json['status'] ??'') ,
      assignedTo: json['assignedTo'] as String?,
      assignedBy: json['assignedBy'] as String?,
      taskType: TaskType.byValue(json['taskType'] ??''),// json['taskType'] as String?,
      taskImage: json['taskImage'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// إنشاء نسخة جديدة من الكائن مع إمكانيّة تعديل القيم
  UserTaskModel copyWith({
    String? docId,
    String? title,
    List<MaterialTaskModel>? materialTask,
    String? dueDate,
    TaskStatus? status,
    String? assignedTo,
    String? assignedBy,
    TaskType? taskType,
    String? taskImage,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserTaskModel(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      materialTask: materialTask ?? this.materialTask,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      taskType: taskType ?? this.taskType,
      taskImage: taskImage ?? this.taskImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// طباعة البيانات عند الحاجة
  @override
  String toString() {
    return 'UserTaskModel(docId: $docId, title: $title, materialTask: ${materialTask?.map((e) =>e.toJson() ,).toList()}, '
        'dueDate: $dueDate, status: $status, assignedTo: $assignedTo, assignedBy: $assignedBy, '
        'taskType: $taskType, taskImage: $taskImage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}


class MaterialTaskModel {
  String? docId;
  String? materialName;
  int? quantity;

  MaterialTaskModel({
    this.docId,
    this.materialName,
    this.quantity,
  });

  /// تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'materialName': materialName,
      'quantity': quantity,
    };
  }

  /// تحويل JSON إلى كائن `MaterialTaskModel`
  factory MaterialTaskModel.fromJson(Map<String, dynamic> json) {
    return MaterialTaskModel(
      docId: json['docId'] as String?,
      materialName: json['materialName'] as String?,
      quantity: json['quantity'] as int?,
    );
  }

  /// إنشاء نسخة جديدة مع إمكانية تعديل القيم
  MaterialTaskModel copyWith({
    String? docId,
    String? materialName,
    int? quantity,
  }) {
    return MaterialTaskModel(
      docId: docId ?? this.docId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
    );
  }

  /// طباعة البيانات عند الحاجة
  @override
  String toString() {
    return 'MaterialTaskModel(docId: $docId, materialName: $materialName, quantity: $quantity)';
  }
}