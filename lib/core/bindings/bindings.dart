import 'package:ba3_bs/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/i_database_service.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/json_import_export_repo.dart';
import 'package:ba3_bs/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_json_import.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_json_import.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/data/datasources/cheques_data_source.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/print/controller/print_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/datasources/remote/sellers_data_source.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:ba3_bs/features/sellers/data/repositories/sellers_repository.dart';
import 'package:ba3_bs/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs/features/users_management/data/datasources/roles_data_source.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../features/accounts/data/datasources/remote/entry_bonds_data_source.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_compound_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bill_json_export.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bond_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
import '../../features/bond/service/bond/bond_json_export.dart';
import '../../features/materials/data/repositories/materials_repository.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/user_time/controller/user_time_controller.dart';
import '../../features/users_management/controllers/user_management_controller.dart';
import '../../features/users_management/data/datasources/users_data_source.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../network/api_constants.dart';
import '../services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../services/firebase/implementations/repos/datasource_repo.dart';
import '../services/firebase/implementations/services/compound_firestore_service.dart';
import '../services/firebase/implementations/services/firestore_service.dart';
import '../services/firebase/interfaces/i_compound_database_service.dart';
import '../services/get_x/shared_preferences_service.dart';
import '../services/json_file_operations/interfaces/export/i_json_export_service.dart';
import '../services/json_file_operations/interfaces/import/i_json_import_service.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation_service.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_api_client.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
// Initialize services
    final dioClient = _initializeDioClient();
    final sharedPreferencesService = await _initializeSharedPreferencesService();
    final fireStoreService = _initializeFireStoreService();
    final compoundFireStoreService = _initializeCompoundFireStoreService();
    final translationService = _initializeTranslationService(dioClient);
    final billJsonImport = BillJsonImport();
    final billJsonExport = BillJsonExport();
    final bondJsonImport = BondJsonImport();
    final bondJsonExport = BondJsonExport();

// Initialize repositories
    final repositories = _initializeRepositories(
        fireStoreService: fireStoreService,
        compoundFireStoreService: compoundFireStoreService,
        translationService: translationService,
        billJsonImportService: billJsonImport,
        billJsonExportService: billJsonExport,
    bondJsonExportService: bondJsonExport,
      bondJsonImportService: bondJsonImport
    );

// Permanent Controllers
    _initializePermanentControllers(sharedPreferencesService, repositories);

// Lazy Controllers
    _initializeLazyControllers(repositories);
  }

// Initialize external services
  IAPiClient _initializeDioClient() => DioClient<Map<String, dynamic>>(Dio());

  Future<SharedPreferencesService> _initializeSharedPreferencesService() => putAsync(SharedPreferencesService().init());

  IDatabaseService<Map<String, dynamic>> _initializeFireStoreService() => FireStoreService();

  ICompoundDatabaseService<Map<String, dynamic>> _initializeCompoundFireStoreService() => CompoundFireStoreService();

  ITranslationService _initializeTranslationService(IAPiClient dioClient) => GoogleTranslationService(
        baseUrl: ApiConstants.translationBaseUrl,
        apiKey: ApiConstants.translationApiKey,
        client: dioClient,
      );

// Repositories Initialization
  _Repositories _initializeRepositories({
    required IDatabaseService<Map<String, dynamic>> fireStoreService,
    required ICompoundDatabaseService<Map<String, dynamic>> compoundFireStoreService,
    required ITranslationService translationService,
    required IJsonImportService<BillModel> billJsonImportService,
    required IJsonExportService<BillModel> billJsonExportService,
    required IJsonImportService<BondModel> bondJsonImportService,
    required IJsonExportService<BondModel> bondJsonExportService,
  }) {
    return _Repositories(
      translationRepo: TranslationRepository(translationService),
      patternsRepo: DataSourceRepository(PatternsDataSource(databaseService: fireStoreService)),
      billsRepo:
          CompoundDatasourceRepository(BillCompoundDataSource(compoundDatabaseService: compoundFireStoreService)),
      bondsRepo: DataSourceRepository(BondsDataSource(databaseService: fireStoreService)),
      chequesRepo: DataSourceRepository(ChequesDataSource(databaseService: fireStoreService)),
      rolesRepo: DataSourceRepository(RolesDataSource(databaseService: fireStoreService)),
      usersRepo: FilterableDataSourceRepository(UsersDataSource(databaseService: fireStoreService)),
      entryBondsRepo: DataSourceRepository(EntryBondsDataSource(databaseService: fireStoreService)),
      accountsStatementsRepo: AccountsStatementsRepository(AccountsStatementsDataSource()),
      billJsonImportExportRepo: JsonImportExportRepository(billJsonImportService, billJsonExportService),
      userTimeRepo: UserTimeRepository(),
      sellersRepo: BulkSavableDatasourceRepository(SellersDataSource(databaseService: fireStoreService)),
      bondJsonImportExportRepo: JsonImportExportRepository(bondJsonImportService, bondJsonExportService),
    );
  }

// Permanent Controllers Initialization
  void _initializePermanentControllers(SharedPreferencesService sharedPreferencesService, _Repositories repositories) {
    put(
      SellersController(SellersLocalRepository(), repositories.sellersRepo),
      permanent: true,
    );
    put(
      UserManagementController(repositories.rolesRepo, repositories.usersRepo, sharedPreferencesService),
      permanent: true,
    );
  }

// Lazy Controllers Initialization
  void _initializeLazyControllers(_Repositories repositories) {
    lazyPut(PlutoController());
    lazyPut(EntryBondController(repositories.entryBondsRepo, repositories.accountsStatementsRepo));
    lazyPut(PatternController(repositories.patternsRepo));
    lazyPut(
        AllBillsController(repositories.patternsRepo, repositories.billsRepo, repositories.billJsonImportExportRepo));
    lazyPut(AllBondsController(repositories.bondsRepo ,repositories.bondJsonImportExportRepo));
    lazyPut(AllChequesController(repositories.chequesRepo));
    lazyPut(BillDetailsPlutoController());
    lazyPut(MaterialController(MaterialRepository()));
    lazyPut(AccountsController(AccountsRepository()));
    lazyPut(PrintingController(repositories.translationRepo));
    lazyPut(BillSearchController());
    lazyPut(AccountStatementController(repositories.accountsStatementsRepo));
    lazyPut(UserTimeController(repositories.usersRepo, repositories.userTimeRepo));
    lazyPut(SellerSalesController(repositories.billsRepo, repositories.sellersRepo));
  }
}

// Helper class to group repositories
class _Repositories {
  final TranslationRepository translationRepo;
  final DataSourceRepository<BillTypeModel> patternsRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> billsRepo;
  final DataSourceRepository<BondModel> bondsRepo;
  final DataSourceRepository<ChequesModel> chequesRepo;
  final DataSourceRepository<RoleModel> rolesRepo;
  final FilterableDataSourceRepository<UserModel> usersRepo;
  final DataSourceRepository<EntryBondModel> entryBondsRepo;
  final AccountsStatementsRepository accountsStatementsRepo;
  final JsonImportExportRepository<BillModel> billJsonImportExportRepo;
  final JsonImportExportRepository<BondModel> bondJsonImportExportRepo;
  final UserTimeRepository userTimeRepo;
  final BulkSavableDatasourceRepository<SellerModel> sellersRepo;

  _Repositories({
    required this.translationRepo,
    required this.patternsRepo,
    required this.billsRepo,
    required this.bondsRepo,
    required this.chequesRepo,
    required this.rolesRepo,
    required this.usersRepo,
    required this.entryBondsRepo,
    required this.accountsStatementsRepo,
    required this.billJsonImportExportRepo,
    required this.userTimeRepo,
    required this.sellersRepo,
    required this.bondJsonImportExportRepo
  });
}
