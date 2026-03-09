import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/user_time/controller/leave_requests_controller.dart';
import 'package:ba3_bs/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs/features/user_time/ui/widgets/leave_card_widget.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatelessWidget {
  LeavePage({super.key});

  final LeaveController controller = Get.find<LeaveController>();
  final UserManagementController userManagementController =
      Get.find<UserManagementController>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "طلبات الإجازة",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchLeaves(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.getLeavesState.value == RequestState.loading ||
            controller.deleteLeaveState.value == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.leaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.beach_access,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "لا توجد طلبات إجازة",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "اضغط على زر + لإضافة طلب جديد",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.leaves.length,
          itemBuilder: (context, index) {
            final leave = controller.leaves[index];

            // تحديد لون الحالة
            Color statusColor;
            IconData statusIcon;
            String statusText;

            switch (leave.status) {
              case LeaveStatus.approved:
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                statusText = 'مقبولة';
                break;
              case LeaveStatus.rejected:
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                statusText = 'مرفوضة';
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
                statusText = 'قيد الانتظار';
            }

            // تحديد أيقونة نوع الإجازة
            IconData typeIcon;
            String typeText;

            switch (leave.leaveType) {
              case LeaveType.sick:
                typeIcon = Icons.sick;
                typeText = 'مرضية';
                break;
              case LeaveType.paid:
                typeIcon = Icons.attach_money;
                typeText = 'مدفوعة';
                break;
              case LeaveType.unpaid:
                typeIcon = Icons.money_off;
                typeText = 'غير مدفوعة';
                break;
            }

            return LeaveCardWidget(
                leave: leave,
                statusColor: statusColor,
                statusIcon: statusIcon,
                statusText: statusText,
                typeIcon: typeIcon,
                typeText: typeText,
                controller: controller);
          },
        );
      }),
    );
  }
}
