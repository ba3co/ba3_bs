import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/features/user_loan_requests/data/model/loan_request_model.dart';
import 'package:ba3_bs/features/user_loan_requests/data/model/user_loan_request_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';

class LoanController extends GetxController {
  final FilterableDataSourceRepository<LoanRequestModel> _loanRepo;
  final RemoteDataSourceRepository<UserModel> _userRepo;

  LoanController(this._loanRepo, this._userRepo);

  RxList<LoanRequestModel> loans = <LoanRequestModel>[].obs;

  final Rx<RequestState> getLoansState = RequestState.initial.obs;
  final Rx<RequestState> addLoanState = RequestState.initial.obs;
  final Rx<RequestState> updateLoanState = RequestState.initial.obs;
  final Rx<RequestState> deleteLoanState = RequestState.initial.obs;

  final RxDouble amount = 0.0.obs;
  final RxString reason = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoans();
  }

  /// 🔥 Fetch loans
  Future<void> fetchLoans() async {
    getLoansState.value = RequestState.loading;

    final result = await _loanRepo.getAll();

    result.fold(
      (failure) {
        getLoansState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (data) {
        loans.assignAll(data);
        getLoansState.value = RequestState.success;
      },
    );
  }

  /// 🔥 Update Loan
  Future<void> updateLoanStatus(
    String loanId,
    LoanStatus newStatus,
    String userId,
  ) async {
    updateLoanState.value = RequestState.loading;

    final loan = loans.firstWhereOrNull((e) => e.id == loanId);

    if (loan == null) return;

    loan.status = newStatus;

    /// 1️⃣ Update loan_requests collection
    final loanResult = await _loanRepo.save(loan);

    await loanResult.fold(
      (failure) async {
        updateLoanState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        /// 2️⃣ Update user array
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            updateLoanState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            UserLoanRequestModel updatedLoan = UserLoanRequestModel(
              id: loanId,
              amount: loan.amount,
              status: newStatus,
            );
            print(user.userLoanRequests);

            List<UserLoanRequestModel>? updatedLoans = user.userLoanRequests
                ?.map((e) => (e.id == loanId ? updatedLoan : e))
                .toList();
            print(updatedLoans);
            UserModel updatedUser =
                user.copyWith(userLoanRequests: updatedLoans);

            await _userRepo.save(updatedUser);

            /// 3️⃣ refresh local list
            loans.refresh();

            updateLoanState.value = RequestState.success;

            AppUIUtils.onSuccess("تم تحديث حالة الطلب");
          },
        );
      },
    );
  }

  /// 🔥 Delete Loan
  Future<void> deleteLoan(String loanId, String userId) async {
    deleteLoanState.value = RequestState.loading;

    final deleteResult = await _loanRepo.delete(loanId);

    await deleteResult.fold(
      (failure) async {
        deleteLoanState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            deleteLoanState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            final updatedLoans =
                user.userLoanRequests?.where((e) => e.id != loanId).toList();

            final updatedUser = user.copyWith(userLoanRequests: updatedLoans);

            await _userRepo.save(updatedUser);

            loans.removeWhere((e) => e.id == loanId);

            deleteLoanState.value = RequestState.success;

            AppUIUtils.onSuccess("تم حذف طلب السلفة");
          },
        );
      },
    );
  }
}
