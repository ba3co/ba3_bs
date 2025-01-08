import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/i_database_service.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/import/import_repo.dart';
import 'package:ba3_bs/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/data/datasources/remote/account_data_source.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_import.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_import.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/data/datasources/cheques_compound_data_source.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/datasources/remote/materials_data_source.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:ba3_bs/features/materials/service/material_export.dart';
import 'package:ba3_bs/features/print/controller/print_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/datasources/remote/sellers_data_source.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:ba3_bs/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs/features/users_management/data/datasources/roles_data_source.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../features/accounts/data/datasources/remote/entry_bonds_data_source.dart';
import '../../features/accounts/service/account_export.dart';
import '../../features/accounts/service/account_import.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_compound_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bil_export.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bonds_compound_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
import '../../features/bond/service/bond/bond_export.dart';
import '../../features/cheques/service/cheques_export.dart';
import '../../features/cheques/service/cheques_import.dart';
import '../../features/materials/service/material_import.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/sellers/service/seller_import.dart';
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
import '../services/json_file_operations/interfaces/export/i_export_service.dart';
import '../services/json_file_operations/interfaces/import/i_import_service.dart';
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
    final billImport = BillImport();
    final billExport = BillExport();
    final bondImport = BondImport();
    final bondExport = BondExport();
    final materialImport = MaterialImport();
    final materialExport = MaterialExport();
    final accountImport = AccountImport();
    final accountExport = AccountExport();
    final chequesImport = ChequesImport();
    final chequesExport = ChequesExport();
    final sellersImport = SellerImport();

// Initialize repositories
    final repositories = _initializeRepositories(
      fireStoreService: fireStoreService,
      compoundFireStoreService: compoundFireStoreService,
      translationService: translationService,
      billImportService: billImport,
      billExportService: billExport,
      bondExportService: bondExport,
      bondImportService: bondImport,
      materialExportService: materialExport,
      materialImportService: materialImport,
      accountExportService: accountExport,
      accountImportService: accountImport,
      chequesExportService: chequesExport,
      chequesImportService: chequesImport,
      sellersImportService: sellersImport,
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
    required IImportService<BillModel> billImportService,
    required IExportService<BillModel> billExportService,
    required IImportService<BondModel> bondImportService,
    required IExportService<BondModel> bondExportService,
    required IImportService<MaterialModel> materialImportService,
    required IExportService<MaterialModel> materialExportService,
    required IImportService<AccountModel> accountImportService,
    required IExportService<AccountModel> accountExportService,
    required IImportService<ChequesModel> chequesImportService,
    required IExportService<ChequesModel> chequesExportService,
    required IImportService<SellerModel> sellersImportService,
  }) {
    return _Repositories(
      translationRepo: TranslationRepository(translationService),
      patternsRepo: DataSourceRepository(PatternsDataSource(databaseService: fireStoreService)),
      billsRepo:
          CompoundDatasourceRepository(BillCompoundDataSource(compoundDatabaseService: compoundFireStoreService)),
      bondsRepo:
          CompoundDatasourceRepository(BondCompoundDataSource(compoundDatabaseService: compoundFireStoreService)),
      chequesRepo:
          CompoundDatasourceRepository(ChequesCompoundDataSource(compoundDatabaseService: compoundFireStoreService)),
      rolesRepo: DataSourceRepository(RolesDataSource(databaseService: fireStoreService)),
      usersRepo: FilterableDataSourceRepository(UsersDataSource(databaseService: fireStoreService)),
      entryBondsRepo: DataSourceRepository(EntryBondsDataSource(databaseService: fireStoreService)),
      accountsStatementsRepo: AccountsStatementsRepository(AccountsStatementsDataSource()),
      billImportExportRepo: ImportExportRepository(billImportService, billExportService),
      chequesImportExportRepo: ImportExportRepository(chequesImportService, chequesExportService),
      userTimeRepo: UserTimeRepository(),
      sellersRepo: BulkSavableDatasourceRepository(SellersDataSource(databaseService: fireStoreService)),
      materialsRepo: QueryableSavableRepository(MaterialsDataSource(databaseService: fireStoreService)),
      accountsRep: BulkSavableDatasourceRepository(AccountsDataSource(databaseService: fireStoreService)),
      bondImportExportRepo: ImportExportRepository(bondImportService, bondExportService),
      materialImportExportRepo: ImportExportRepository(materialImportService, materialExportService),
      accountImportExportRepo: ImportExportRepository(accountImportService, accountExportService),
      sellerImportRepo: ImportRepository(sellersImportService),
    );
  }

// Permanent Controllers Initialization
  void _initializePermanentControllers(SharedPreferencesService sharedPreferencesService, _Repositories repositories) {
    put(
      SellersController(repositories.sellersRepo, repositories.sellerImportRepo),
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
    lazyPut(AllBillsController(repositories.patternsRepo, repositories.billsRepo, repositories.billImportExportRepo));
    lazyPut(AllBondsController(repositories.bondsRepo, repositories.bondImportExportRepo));
    lazyPut(AllChequesController(repositories.chequesRepo, repositories.chequesImportExportRepo));
    lazyPut(BillDetailsPlutoController());
    lazyPut(AccountsController(repositories.accountImportExportRepo, repositories.accountsRep));
    lazyPut(PrintingController(repositories.translationRepo));
    lazyPut(BillSearchController());
    lazyPut(AccountStatementController(repositories.accountsStatementsRepo));
    lazyPut(UserTimeController(repositories.usersRepo, repositories.userTimeRepo));
    lazyPut(SellerSalesController(repositories.billsRepo, repositories.sellersRepo));
    lazyPut(MaterialController(repositories.materialImportExportRepo, repositories.materialsRepo));
  }
}

// Helper class to group repositories
class _Repositories {
  final TranslationRepository translationRepo;
  final DataSourceRepository<BillTypeModel> patternsRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> billsRepo;
  final CompoundDatasourceRepository<BondModel, BondType> bondsRepo;
  final CompoundDatasourceRepository<ChequesModel, ChequesType> chequesRepo;
  final DataSourceRepository<RoleModel> rolesRepo;
  final FilterableDataSourceRepository<UserModel> usersRepo;
  final DataSourceRepository<EntryBondModel> entryBondsRepo;
  final AccountsStatementsRepository accountsStatementsRepo;
  final ImportExportRepository<BillModel> billImportExportRepo;
  final ImportExportRepository<BondModel> bondImportExportRepo;
  final ImportExportRepository<MaterialModel> materialImportExportRepo;
  final ImportRepository<SellerModel> sellerImportRepo;
  final ImportExportRepository<AccountModel> accountImportExportRepo;
  final ImportExportRepository<ChequesModel> chequesImportExportRepo;
  final UserTimeRepository userTimeRepo;
  final BulkSavableDatasourceRepository<SellerModel> sellersRepo;
  final BulkSavableDatasourceRepository<AccountModel> accountsRep;
  final QueryableSavableRepository<MaterialModel> materialsRepo;

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
    required this.billImportExportRepo,
    required this.userTimeRepo,
    required this.sellersRepo,
    required this.bondImportExportRepo,
    required this.materialImportExportRepo,
    required this.sellerImportRepo,
    required this.accountImportExportRepo,
    required this.chequesImportExportRepo,
    required this.accountsRep,
    required this.materialsRepo,
  });
}
