class UserModel {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRole;
  final String? userSellerId;
  final List<DateTime>? userDateList;

  final List<DateTime>? logInDateList;

  final List<DateTime>? logOutDateList;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRole,
    this.userSellerId,
    this.userDateList,
    this.logInDateList,
    this.logOutDateList,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRole': userRole,
      "userDateList": userDateList,
      "logOutDateList": logOutDateList,
      "logInDateList": logInDateList,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> userDateList = [];
    List<DateTime> logInDateList = [];
    List<DateTime> logOutDateList = [];
    List<int> userTimeList = [];
    if (json['userDateList'] != null) {
      for (var element in (json['userDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          userDateList.add(element);
        } else {
          userDateList.add(element.toDate());
        }
      }
    }
    if (json['logInDateList'] != null) {
      for (var element in (json['logInDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          logInDateList.add(element);
        } else {
          logInDateList.add(element.toDate());
        }
      }
    }
    if (json['logOutDateList'] != null) {
      for (var element in (json['logOutDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          logOutDateList.add(element);
        } else {
          logOutDateList.add(element.toDate());
        }
      }
    }

    if (json['userTimeList'] != null) {
      for (var element in (json['userTimeList'] as List<dynamic>)) {
        userTimeList.add(int.parse(element.toString()));
      }
    }

    return UserModel(
      userId: json['userId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPassword: json['userPassword'],
      userRole: json['userRole'],
      userDateList: userDateList,
      logInDateList: logInDateList,
      logOutDateList: logOutDateList,
    );
  }
}
