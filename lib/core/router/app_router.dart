import 'package:ba3_bs/features/accounts/ui/screens/account_statement_screen.dart';
import 'package:ba3_bs/features/accounts/ui/screens/all_accounts_screen.dart';
import 'package:ba3_bs/features/bill/ui/screens/all_bills_screen.dart';
import 'package:ba3_bs/features/main_layout/ui/screens/main_screen.dart';
import 'package:ba3_bs/features/materials/ui/screens/all_materials_screen.dart';
import 'package:ba3_bs/features/patterns/ui/screens/add_pattern_page.dart';
import 'package:ba3_bs/features/patterns/ui/screens/pattern_layout.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/screens/bill_details_screen.dart';
import '../../features/bond/ui/screens/bond_details_screen.dart';
import '../../features/cheques/ui/screens/all_cheques_view.dart';
import '../../features/login/ui/screens/login_screen.dart';
import '../../features/patterns/ui/screens/all_pattern_page.dart';
import '../bindings/middlewares.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.splashScreen, page: () => const MainScreen()),
  GetPage(name: AppRoutes.mainLayout, page: () => const MainScreen()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.patternsScreen, page: () => const PatternLayout()),
  GetPage(name: AppRoutes.addPatternsScreen, page: () => const AddPatternPage()),
  GetPage(name: AppRoutes.showAllPatternsScreen, page: () => const AllPatternPage()),
  GetPage(name: AppRoutes.showAllMaterialsScreen, page: () => const AllMaterialsScreen()),
  GetPage(name: AppRoutes.showAllAccountsScreen, page: () => const AllAccountScreen()),
  GetPage(
    name: AppRoutes.showAllBillsScreen,
    page: () => const AllBillsScreen(),
  ),

  GetPage(
      name: AppRoutes.billDetailsScreen,
      middlewares: [LandscapeMiddleware()],
      page: () {
        final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
        return BillDetailsScreen(
          fromBillById: arguments['fromBillById'],
          billDetailsController: arguments['billDetailsController'],
          billDetailsPlutoController: arguments['billDetailsPlutoController'],
          billSearchController: arguments['billSearchController'],
          tag: arguments['tag'],
        );
      }),

  // GetPage(name: AppRoutes.entryBondDetailsScreen, page: () => const EntryBondDetailsScreen()),

  GetPage(
    name: AppRoutes.bondDetailsScreen,
    page: () {
      final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      return BondDetailsScreen(
        fromBondById: arguments['fromBondById'],
        bondDetailsController: arguments['bondDetailsController'],
        bondDetailsPlutoController: arguments['bondDetailsPlutoController'],
        bondSearchController: arguments['bondSearchController'],
        tag: arguments['tag'],
      );
    },
  ),

  GetPage(
    name: AppRoutes.bondDetailsScreen,
    page: () {
      final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      return BondDetailsScreen(
        fromBondById: arguments['fromBondById'],
        bondDetailsController: arguments['bondDetailsController'],
        bondDetailsPlutoController: arguments['bondDetailsPlutoController'],
        bondSearchController: arguments['bondSearchController'],
        tag: arguments['tag'],
      );
    },
  ),
  GetPage(name: AppRoutes.accountStatementScreen, page: () => const AccountStatementScreen()),
  GetPage(name: AppRoutes.showAllChequesScreen, page:   () {
    final bool arguments = Get.arguments as bool;
    return  AllCheques(onlyDues: arguments);
  }),


  // GetPage(
  //   name: AppRoutes.addBillScreen,
  //   page: () {
  //     final Map arguments = Get.arguments as Map;
  //     final BillTypeModel billTypeModel = arguments['billTypeModel'];
  //     final bool fromBillDetails = arguments['fromBillDetails'];
  //     final bool fromBillById = arguments['fromBillById'];
  //
  //     return AddBillScreen(
  //       billTypeModel: billTypeModel,
  //       fromBillDetails: fromBillDetails,
  //       fromBillById: fromBillById,
  //     );
  //   },
  // )
];
