import 'package:ba3_bs/core/services/firebase/implementations/firebase_repo_without_result_impl.dart';
import 'package:ba3_bs/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bond_controller.dart';
import 'package:ba3_bs/features/bond/controllers/bond_details_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/print/controller/print_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/repositories/sellers_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bill_json_export.dart';
import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';
import '../../features/materials/data/repositories/materials_repository.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../network/api_constants.dart';
import '../services/firebase/implementations/firebase_repo_with_result_impl.dart';
import '../services/json_file_operations/implementations/export/json_export_repo.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation.dart';
import '../services/translation/implementations/http_client.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_api_client.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize Firestore instance
    var firestore = FirebaseFirestore.instance;

    // Initialize repositories
    final userManagementRepo = UserManagementRepository(UserManagementService());

    // Instantiate PatternsDataSource and FirebaseRepositoryConcrete of BillTypeModel
    final FirebaseRepositoryWithoutResultImpl<BillTypeModel> patternsFirebaseRepo = FirebaseRepositoryWithoutResultImpl(
      PatternsDataSource(firestore),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BillModel
    final FirebaseRepositoryWithResultImpl<BillModel> billsFirebaseRepo = FirebaseRepositoryWithResultImpl(
      BillsDataSource(firestore),
    );

    // Instantiate Api client, GoogleTranslationDataSource and TranslationRepository
    final IAPiClient httpClient = HttpClient<Map<String, dynamic>>(Client());
    final IAPiClient dioClient = DioClient<Map<String, dynamic>>(Dio());

    final ITranslationService googleTranslation = GoogleTranslation(
        baseUrl: ApiConstants.translationBaseUrl, apiKey: ApiConstants.translationApiKey, client: dioClient);

    final TranslationRepository translationRepo = TranslationRepository(googleTranslation);

    Get.lazyPut(() => translationRepo, fenix: true);

    Get.lazyPut(() => billsFirebaseRepo, fenix: true);

    final billJsonExportRepo = JsonExportRepository<BillModel>(BillJsonExport());

    // Lazy load controllers
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => BondController(), fenix: true);

    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);

    Get.lazyPut(() => PatternController(patternsFirebaseRepo), fenix: true);

    // Get.lazyPut(() => BillDetailsController(billsFirebaseRepo), fenix: true);

    Get.lazyPut(() => AllBillsController(patternsFirebaseRepo, billsFirebaseRepo, billJsonExportRepo), fenix: true);

    Get.lazyPut(() => BillDetailsPlutoController(), fenix: true);

    Get.lazyPut(() => MaterialController(MaterialRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => SellerController(SellersRepository()), fenix: true);

    Get.lazyPut(() => PrintingController(translationRepo), fenix: true);

    Get.lazyPut(() => BillSearchController(), fenix: true);
    Get.lazyPut(() => BondDetailsController(), fenix: true);
  }
}
