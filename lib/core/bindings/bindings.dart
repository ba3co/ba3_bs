import 'package:ba3_bs/core/classes/base/i_translation_service.dart';
import 'package:ba3_bs/core/classes/concrete/firebase_repo_concrete.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs/features/bond/controllers/bond_controller.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/print/controller/print_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/repositories/sellers_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import '../../features/invoice/data/datasources/invoices_data_source.dart';
import '../../features/invoice/data/models/bill_model.dart';
import '../../features/invoice/services/bill_json_export.dart';
import '../../features/login/controllers/nfc_cards_controller.dart';
import '../../features/login/controllers/user_management_controller.dart';
import '../../features/login/data/datasources/user_management_service.dart';
import '../../features/login/data/repositories/user_repo.dart';
import '../../features/materials/data/repositories/materials_repository.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/print/data/datasources/dio_client.dart';
import '../../features/print/data/datasources/google_translation.dart';
import '../../features/print/data/datasources/http_client.dart';
import '../../features/print/data/repositories/translation_repository.dart';
import '../classes/base/i_api_client.dart';
import '../classes/base/i_firebase_repo.dart';
import '../classes/concrete/json_export_repository.dart';
import '../network/api_constants.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize Firestore instance
    var firestore = FirebaseFirestore.instance;

    // Initialize repositories
    final userManagementRepo = UserManagementRepository(UserManagementService());

    // Instantiate PatternsDataSource and FirebaseRepositoryConcrete of BillTypeModel
    final IFirebaseRepository<BillTypeModel> patternsFirebaseRepo = FirebaseRepositoryConcrete(
      PatternsDataSource(firestore),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BillModel
    final IFirebaseRepository<BillModel> billsFirebaseRepo = FirebaseRepositoryConcrete(
      InvoicesDataSource(firestore),
    );

    // Instantiate Api client, GoogleTranslationDataSource and TranslationRepository
    final IAPiClient httpClient = HttpClient<Map<String, dynamic>>(Client());
    final IAPiClient dioClient = DioClient<Map<String, dynamic>>(Dio());

    final ITranslationService googleTranslation = GoogleTranslation(
        baseUrl: ApiConstants.translationBaseUrl, apiKey: ApiConstants.translationApiKey, client: dioClient);

    final TranslationRepository translationRepo = TranslationRepository(googleTranslation);

    final billJsonExportRepo = JsonExportRepository<BillModel>(BillJsonExport());

    // Lazy load controllers
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => BondController(), fenix: true);

    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);
    Get.lazyPut(() => PatternController(patternsFirebaseRepo), fenix: true);
    Get.lazyPut(() => InvoiceController(patternsFirebaseRepo, billsFirebaseRepo, billJsonExportRepo), fenix: true);

    Get.lazyPut(() => MaterialController(MaterialRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => SellerController(SellersRepository()), fenix: true);

    Get.lazyPut(() => PrintingController(translationRepo), fenix: true);
  }
}
