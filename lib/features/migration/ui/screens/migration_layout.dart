import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../controllers/migration_controller.dart';

class MigrationLayout extends StatelessWidget {
  const MigrationLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final MigrationController controller = read<MigrationController>();

    return Scaffold(
      appBar: AppBar(title: const Text("عملية الترحيل")),
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
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // 🔹 Dropdown to select migration version
              Obx(() => DropdownButton<String>(
                    value: controller.selectedVersion.value,
                    onChanged: controller.isMigrating.value
                        ? null // Disable while migrating
                        : (newValue) => controller.setMigrationVersion(newValue!),
                    items: controller.migrationVersions
                        .map((version) => DropdownMenuItem(
                              value: version,
                              child: Text("إصدار $version"),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 20),

              // 🔹 Migration Button
              Obx(
                () => SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: controller.isMigrating.value ? null : controller.startMigration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    ),
                    child: controller.isMigrating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text("ابدأ الترحيل"),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Migration Status
              Obx(() => Text(
                    controller.migrationStatus.value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
