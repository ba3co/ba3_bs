import 'package:ba3_bs/features/accounts/ui/screens/all_accounts_screen.dart';
import 'package:ba3_bs/features/invoice/ui/screens/all_bills_screen.dart';
import 'package:ba3_bs/features/invoice/ui/screens/bill_details_screen.dart';
import 'package:ba3_bs/features/main_layout/ui/screens/main_screen.dart';
import 'package:ba3_bs/features/materials/ui/screens/all_materials_screen.dart';
import 'package:ba3_bs/features/patterns/ui/screens/add_pattern_page.dart';
import 'package:ba3_bs/features/patterns/ui/screens/pattern_layout.dart';
import 'package:get/get.dart';

import '../../features/bond/ui/screens/entry_bond_details_view.dart';
import '../../features/login/ui/screens/login_screen.dart';
import '../../features/patterns/ui/screens/all_pattern_page.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.splashScreen, page: () => const MainScreen()),
  GetPage(name: AppRoutes.mainLayout, page: () => const MainScreen()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.patternsScreen, page: () => const PatternLayout()),
  GetPage(name: AppRoutes.addPatternsScreen, page: () => const AddPatternPage()),
  GetPage(name: AppRoutes.showAllPatternsScreen, page: () => const AllPatternPage()),
  GetPage(name: AppRoutes.entryBondDetailsView, page: () => const EntryBondDetailsView()),
  GetPage(name: AppRoutes.showAllMaterialsScreen, page: () => const AllMaterialsScreen()),
  GetPage(name: AppRoutes.showAllAccountsScreen, page: () => const AllAccountScreen()),
  GetPage(name: AppRoutes.showAllBillsScreen, page: () => const AllBillsScreen()),
  GetPage(name: AppRoutes.billDetailsScreen, page: () => const BillDetailsScreen()),
];
