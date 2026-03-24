import 'package:ba3_bs/features/user_loan_requests/data/model/loan_request_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class AllLoansWidget extends StatelessWidget {
  const AllLoansWidget({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.approved:
        return Colors.green;
      case LoanStatus.rejected:
        return Colors.red;
      case LoanStatus.pending:
        return Colors.orange;
      case LoanStatus.repaid:
        return Colors.blue;
    }
  }

  String _getStatusText(LoanStatus status) {
    switch (status) {
      case LoanStatus.approved:
        return 'تمت الموافقة';
      case LoanStatus.rejected:
        return 'مرفوض';
      case LoanStatus.pending:
        return 'قيد الانتظار';
      case LoanStatus.repaid:
        return 'تم السداد';
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final loans =
        userDetailsController.selectedUserModel?.userLoanRequests ?? [];

    return OrganizedWidget(
      titleWidget: Center(
        child: Text(
          "طلبات السلف",
          style: AppTextStyles.headLineStyle2.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      bodyWidget: loans.isEmpty
          ? Center(
              child: Text(
                "لا توجد طلبات سلف",
                style: AppTextStyles.headLineStyle2.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 4),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: loans.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final loan = loans[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                    color: Colors.white,
                  ),
                  child: ExpansionTile(
                    collapsedIconColor: Colors.grey.shade700,
                    iconColor: Colors.grey.shade700,
                    leading: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(loan.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'طلب سلفة',
                                style: AppTextStyles.headLineStyle3.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.price_change,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatAmount(loan.amount),
                                    style:
                                        AppTextStyles.headLineStyle4.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(loan.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  _getStatusColor(loan.status).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusText(loan.status),
                            style: AppTextStyles.headLineStyle4.copyWith(
                              color: _getStatusColor(loan.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.monetization_on,
                              label: 'المبلغ المطلوب',
                              value: _formatAmount(loan.amount),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.info_outline,
                              label: 'حالة الطلب',
                              value: _getStatusText(loan.status),
                              valueColor: _getStatusColor(loan.status),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.headLineStyle2.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.headLineStyle2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
