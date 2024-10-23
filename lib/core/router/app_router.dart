import 'package:ba3_bs/features/patterns/ui/screens/pattern_layout.dart';
import 'package:get/get.dart';

import '../../features/login/ui/screens/login_screen.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.splashScreen, page: () => const PatternLayout()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.patternsScreen, page: () => const PatternLayout()),
];
