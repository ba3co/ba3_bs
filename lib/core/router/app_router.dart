import 'package:get/get.dart';

import '../../features/login/ui/screens/login_screen.dart';
import '../../features/login/ui/screens/splash_screen.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.userManagement, page: () => const SplashScreen()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
];