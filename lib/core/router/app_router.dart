import 'package:ba3_bs/features/main_layout/ui/screens/main_screen.dart';
import 'package:ba3_bs/features/patterns/ui/screens/add_pattern_page.dart';
import 'package:ba3_bs/features/patterns/ui/screens/pattern_layout.dart';
import 'package:get/get.dart';

import '../../features/login/ui/screens/login_screen.dart';
import '../../features/patterns/ui/screens/all_pattern_page.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.splashScreen, page: () => const MainScreen()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.patternsScreen, page: () => const PatternLayout()),
  GetPage(name: AppRoutes.addPatternsScreen, page: () => const AddPatternPage()),
  GetPage(name: AppRoutes.showAllPatternsScreen, page: () => const AllPatternPage()),
];
