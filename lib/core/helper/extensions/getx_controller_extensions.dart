import 'package:get/get.dart';

extension GetXControllerExtensions on GetInterface {
  T putIfAbsent<T extends GetxController>(T controllerBuilder) {
    if (!Get.isRegistered<T>()) {
      Get.put(controllerBuilder);
    }
    return Get.find<T>();
  }
}
