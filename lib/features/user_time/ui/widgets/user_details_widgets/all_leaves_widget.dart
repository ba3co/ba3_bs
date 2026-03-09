import 'dart:math';

import 'package:ba3_bs/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class AllLeavesWidget extends StatelessWidget {
  const AllLeavesWidget({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return 'تمت الموافقة';
      case LeaveStatus.rejected:
        return 'مرفوض';
      case LeaveStatus.pending:
        return 'قيد الانتظار';
    }
  }

  String _getLeaveTypeText(LeaveType leaveType) {
    switch (leaveType) {
      case LeaveType.sick:
        return 'إجازة مرضية';
      case LeaveType.unpaid:
        return 'إجازة بدون راتب';
      default:
        return 'إجازة مدفوعة';
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  int _calculateLeaveDays(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaves =
        userDetailsController.selectedUserModel?.userLeaveRequests ?? [];

    return OrganizedWidget(
      titleWidget: Center(
        child: Text(
          "طلبات الإجازات",
          style: AppTextStyles.headLineStyle2.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      bodyWidget: leaves.isEmpty
          ? Center(
              child: Text(
                "لا توجد طلبات إجازات",
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
              itemCount: leaves.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final leave = leaves[index];
                final days =
                    _calculateLeaveDays(leave.startDate, leave.endDate);

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
                        color: _getStatusColor(leave.status),
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
                                _getLeaveTypeText(leave.leaveType),
                                style: AppTextStyles.headLineStyle3.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}",
                                    style:
                                        AppTextStyles.headLineStyle4.copyWith(
                                      color: Colors.grey.shade600,
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
                                _getStatusColor(leave.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(leave.status)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusText(leave.status),
                            style: AppTextStyles.headLineStyle4.copyWith(
                              color: _getStatusColor(leave.status),
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
                            // Leave Details
                            _buildInfoRow(
                              icon: Icons.calendar_month,
                              label: 'المدة',
                              value: '$days يوم',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.access_time,
                              label: 'تاريخ البداية',
                              value: _formatDate(leave.startDate),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.access_time_filled,
                              label: 'تاريخ النهاية',
                              value: _formatDate(leave.endDate),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.description_outlined,
                              label: 'نوع الإجازة',
                              value: _getLeaveTypeText(leave.leaveType),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
