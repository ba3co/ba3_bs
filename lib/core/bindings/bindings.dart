import 'package:ba3_bs/core/services/firebase/interfaces/i_database_service.dart';
import 'package:ba3_bs/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/print/controller/print_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/repositories/sellers_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bill_json_export.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bond_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
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
import '../services/accounts_statements_data_source.dart';
import '../services/entry_bonds_data_source.dart';
import '../services/firebase/implementations/datasource_repo.dart';
import '../services/firebase/implementations/firestore_service.dart';
import '../services/json_file_operations/implementations/export/json_export_repo.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_api_client.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize RemoteApiService instance
    IDatabaseService<Map<String, dynamic>> fireStoreService = FireStoreService();

    // Initialize repositories
    final userManagementRepo = UserManagementRepository(UserManagementService());

    // Instantiate PatternsDataSource and FirebaseRepositoryConcrete of BillTypeModel
    final DataSourceRepository<BillTypeModel> patternsFirebaseRepo = DataSourceRepository(
      PatternsDataSource(databaseService: fireStoreService),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BillModel
    final DataSourceRepository<BillModel> billsFirebaseRepo =
        DataSourceRepository(BillsDataSource(databaseService: fireStoreService));

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final DataSourceRepository<BondModel> bondsFirebaseRepo = DataSourceRepository(
      BondsDataSource(databaseService: fireStoreService),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final DataSourceRepository<EntryBondModel> entryBondsFirebaseRepo = DataSourceRepository(
      EntryBondsDataSourceDataSource(databaseService: fireStoreService),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final AccountsStatementsRepository accountsStatementsRepo = AccountsStatementsRepository(
      AccountsStatementsDataSource(),
    );

    // Instantiate Api client, GoogleTranslationDataSource and TranslationRepository
    // final IAPiClient httpClient = HttpClient<Map<String, dynamic>>(Client());
    final IAPiClient dioClient = DioClient<Map<String, dynamic>>(Dio());

    final ITranslationService googleTranslation = GoogleTranslation(
        baseUrl: ApiConstants.translationBaseUrl, apiKey: ApiConstants.translationApiKey, client: dioClient);

    final TranslationRepository translationRepo = TranslationRepository(googleTranslation);

    Get.lazyPut(() => translationRepo, fenix: true);

    Get.lazyPut(() => billsFirebaseRepo, fenix: true);

    Get.lazyPut(() => bondsFirebaseRepo, fenix: true);

    final billJsonExportRepo = JsonExportRepository<BillModel>(BillJsonExport());

    // Lazy load controllers
    Get.lazyPut(() => NfcCardsController(), fenix: true);
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => EntryBondController(entryBondsFirebaseRepo, accountsStatementsRepo), fenix: true);
    //Get.lazyPut(() => EntryBondController(), fenix: true);

    Get.lazyPut(() => UserManagementController(userManagementRepo), fenix: true);

    Get.lazyPut(() => PatternController(patternsFirebaseRepo), fenix: true);

    // Get.lazyPut(() => BillDetailsController(billsFirebaseRepo), fenix: true);

    Get.lazyPut(() => AllBillsController(patternsFirebaseRepo, billsFirebaseRepo, billJsonExportRepo), fenix: true);
    Get.lazyPut(() => AllBondsController(bondsFirebaseRepo /*bondJsonExportRepo*/), fenix: true);

    Get.lazyPut(() => BillDetailsPlutoController(), fenix: true);

    Get.lazyPut(() => MaterialController(MaterialRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => SellerController(SellersRepository()), fenix: true);

    Get.lazyPut(() => PrintingController(translationRepo), fenix: true);

    Get.lazyPut(() => BillSearchController(), fenix: true);
    Get.lazyPut(() => AccountStatementController(), fenix: true);
    // Get.lazyPut(() => BondDetailsController(), fenix: true);
    // Get.lazyPut(() => BondRecordPlutoController(), fenix: true);
  }
}
