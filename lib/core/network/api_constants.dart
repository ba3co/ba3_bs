import 'package:ba3_bs/core/constants/app_config.dart';

class ApiConstants {
  static const String translationApiKey = 'AIzaSyAil4Csq27_oCC_BzF7ZMetUEyNM665VqQ';
  static const String translationBaseUrl = 'https://translation.googleapis.com/language/translate/v2';

  static String year = AppConfig.instance.year;

  /// COLLECTIONS
  // static const String bills = '${year}_bills';
  // static const String patterns = '${year}_bill_types';

  static String bonds = '${year}bonds';

  // static const String bondsCheques = '${year}_bondsCheques';
  // static const String entryBonds = '${year}_entry_bonds';
  // static const String accountsStatements = '${year}_accounts_statements';
  // static const String cheques = '${year}_cheques';
  // static const String roles = '${year}_roles';
  // static const String users = '${year}_users';
  // static const String sellers = '${year}_sellers';
  // static const String taxes = '${year}_texes';
  // static const String accounts = '${year}_accounts';
  // static const String materials = '${year}_materials';
  // static const String dashBoardAccounts = '${year}_dashBoardAccounts';
  // static const String materialsSerialNumbers = '${year}_materials_serial_numbers';
  // static const String materialGroup = '${year}_materialGroup';
  // static const String changes = '${year}_changes';
  // static const String sequentialNumbers = '${year}_sequential_numbers';
  // static const String guestUser = '${year}_guest_user';
  // static const String customers = '${year}_customers';
  // static const String storeCart = '${year}_StoreCart';
  // static const String materialsStatements = '${year}_materials_statements';
  // static const String largeBills = '${year}_large_bills';

  static const String patterns = 'bill_types';

  static const String bills = 'bills';

  // static const String bonds = 'bonds';
  static const String bondsCheques = 'bondsCheques';
  static const String entryBonds = 'entry_bonds';
  static const String accountsStatements = 'accounts_statements';
  static const String cheques = 'cheques';
  static const String roles = 'roles';
  static const String users = 'users';
  static const String sellers = 'sellers';
  static const String taxes = 'texes';
  static const String accounts = 'accounts';
  static const String materials = 'materials';
  static const String dashBoardAccounts = 'dashBoardAccounts';
  static const String materialsSerialNumbers = 'materials_serial_numbers';
  static const String materialGroup = 'materialGroup';
  static const String changes = 'changes';
  static const String sequentialNumbers = 'sequential_numbers';
  static const String guestUser = 'guest_user';
  static const String customers = 'customers';
  static const String storeCart = 'StoreCart';
  static const String materialsStatements = 'materials_statements';
  static const String largeBills = 'large_bills';

  /// Documents
  static const String guest = 'guest';

  /// FIELDS
  static const String status = 'status';
  static const String userPassword = 'userPassword';
  static const String billDate = 'billDetails.billDate';
  static const String billSellerId = 'billDetails.billSellerId';
  static const String type = 'type';
  static const String lastNumber = 'lastNumber';

  static const String billNumber = 'billDetails.billNumber';

  static const String orderNumber = 'billDetails.orderNumber';
  static const String customerPhone = 'billDetails.customerPhone';
  static const String bondNumber = 'PayNumber';
  static const String metaValue = 'metaValue';

  static String userTask='user_task';
}