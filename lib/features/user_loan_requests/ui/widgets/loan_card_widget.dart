import 'package:ba3_bs/features/floating_window/managers/overlay_entry_with_priority_manager.dart';
import 'package:ba3_bs/features/user_loan_requests/controller/loan_request_controller.dart';
import 'package:ba3_bs/features/user_loan_requests/data/model/loan_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanCardWidget extends StatelessWidget {
  const LoanCardWidget({
    super.key,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.loan,
    required this.controller,
  });

  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final LoanRequestModel loan;
  final LoanController controller;

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: الحالة
            Row(
              children: [
                Text("مقدم بواسطة : ",
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                Text(
                  loan.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                // المبلغ
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'المبلغ: ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${loan.amount.toStringAsFixed(0)} ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // السبب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'السبب:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loan.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // تاريخ الطلب وأزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // تاريخ الطلب
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(loan.createdAt.toString()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ...[
              if (loan.status == LoanStatus.approved ||
                  loan.status == LoanStatus.pending)
                const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (loan.status == LoanStatus.pending)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              'قبول الطلب',
                              'هل أنت متأكد من قبول طلب السلفة هذا؟',
                              () {
                                controller.updateLoanStatus(
                                    loan.id, LoanStatus.approved, loan.userId);
                              },
                            );
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('قبول'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              'رفض الطلب',
                              'هل أنت متأكد من رفض طلب السلفة هذا؟',
                              () {
                                controller.updateLoanStatus(
                                    loan.id, LoanStatus.rejected, loan.userId);
                              },
                            );
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('رفض'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (loan.status == LoanStatus.approved)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              'قبول الطلب',
                              'هل أنت متأكد من تسديد طلب السلفة هذا؟',
                              () {
                                controller.updateLoanStatus(
                                    loan.id, LoanStatus.repaid, loan.userId);
                              },
                            );
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('تسديد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (loan.status == LoanStatus.rejected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'مرفوض',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    final overlay = Overlay.of(context);

    OverlayEntryWithPriorityManager.instance.displayOverlay(
      overlay: overlay,
      title: title,
      width: 400,
      height: 220,
      priority: 0,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  OverlayEntryWithPriorityManager.instance.dispose();
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  OverlayEntryWithPriorityManager.instance.dispose();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      title.contains('قبول') ? Colors.green : Colors.red,
                ),
                child: Text(title.contains('قبول') ? 'قبول' : 'رفض'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
