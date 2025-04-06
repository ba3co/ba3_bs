import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../controllers/migration_controller.dart';

class MigrationLayout extends StatelessWidget {
  const MigrationLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final MigrationController controller = read<MigrationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("عملية الترحيل"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "إضافة إصدار جديد",
            onPressed: controller.isMigrating.value
                ? null
                : () => _showAddVersionDialog(context, controller),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "الرجاء اختيار إصدار الترحيل والضغط على الزر لبدء العملية",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // 🔹 Show Loading Indicator while Fetching Versions
              Obx(() {
                if (controller.getMigrationVersionsRequestState.value ==
                    RequestState.loading) {
                  return const CircularProgressIndicator();
                }
                return DropdownButton<String>(
                  value: controller.selectedVersion.value.isNotEmpty
                      ? controller.selectedVersion.value
                      : null,
                  hint: const Text("اختر إصدار الترحيل"),
                  onChanged: controller.isMigrating.value
                      ? null
                      : (newValue) => controller.setMigrationVersion(newValue!),
                  items: controller.migrationVersions
                      .map((version) => DropdownMenuItem(
                            value: version,
                            child: Text("إصدار $version"),
                          ))
                      .toList(),
                );
              }),
              const SizedBox(height: 20),

              // 🔹 Migration Button
              Obx(
                () => SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: (){
                      if(controller.isMigrating.value) return;
                      controller.startMigration(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
                    ),
                    child: controller.isMigrating.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("ابدأ الترحيل"),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Migration Status
              Obx(
                () => Text(
                  controller.migrationStatus.value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Show Add New Migration Version Dialog
  void _showAddVersionDialog(
      BuildContext context, MigrationController controller) {
    TextEditingController versionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("إضافة إصدار جديد"),
        content: TextField(
          controller: versionController,
          decoration: const InputDecoration(
            labelText: "الإصدار الجديد",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.addMigrationVersionsRequestState.value ==
                        RequestState.loading
                    ? null
                    : () {
                        controller.migrationController.text =
                            versionController.text.trim();
                        controller.addMigrationVersion(context);
                      },
                child: controller.addMigrationVersionsRequestState.value ==
                        RequestState.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("إضافة"),
              )),
        ],
      ),
    );
  }
}