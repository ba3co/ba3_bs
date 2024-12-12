// import 'package:get/get.dart';
//
// class FloatingScreenControllersInitialization {
//   T getParam<T>(Map<String, dynamic> params, String key) {
//     final value = params[key];
//     if (value is T) return value;
//     throw ArgumentError('Expected parameter of type $T for key "$key", but got ${value.runtimeType}');
//   }
//
//   T initializeController<T extends GetxController>(String tag, T Function() controllerBuilder) {
//     if (!Get.isRegistered<T>(tag: tag)) {
//       Get.create<T>(controllerBuilder, permanent: false, tag: tag);
//     }
//     return Get.find<T>(tag: tag);
//   }
// }
