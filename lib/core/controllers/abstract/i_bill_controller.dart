import '../../../features/accounts/data/models/account_model.dart';
import '../../helper/enums/enums.dart';

abstract class IBillController {
  void updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value);
}
