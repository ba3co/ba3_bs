import '../../../features/accounts/data/models/account_model.dart';
import '../../constants/app_constants.dart';

extension AccountEntityExtension on AccountEntity {
  bool get isFreeTaxAccount {
    return id==AppConstants.taxFreeAccountId;
  }
  bool get isLocalTaxAccount {
    return id==AppConstants.taxLocalAccountId;
  }
}