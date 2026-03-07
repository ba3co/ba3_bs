import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_menu_item.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.accounts.tr),
          actions: [
            _buildAppBarButton(AppStrings.downloadAccounts.tr, () {
              read<AccountsController>().fetchAllAccountsFromLocal(context);
            }),
            _buildAppBarButton(AppStrings.downloadCustomers.tr, () {
              read<CustomersController>().fetchAllCustomersFromLocal(context);
            }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            children: [
              buildAppMenuItem(
                icon: Icons.account_balance_wallet,
                title: AppStrings.viewAccounts.tr,
                onTap: () {
                  read<AccountsController>()
                    ..fetchAccounts()
                    ..navigateToAllAccountsScreen(context);
                },
              ),
              buildAppMenuItem(
                icon: Icons.receipt_long,
                title: AppStrings.accountStatement.tr,
                onTap: () async {

                  await migrateLastTransactions();
                  // read<AccountsController>()
                  //
                  //   .showAccountFilterDialog(context: context);
                  // showDialog<String>(
                  //   context:context ,
                  //   builder: (BuildContext context) =>
                  //       showAccountFilterDialog(context),
                  // );
                  //  printHotMassageMaterial();

                },
              ),
              buildAppMenuItem(
                icon: Icons.person_add_alt,
                title: AppStrings.addAccount.tr,
                onTap: () {
                  read<AccountsController>()
                      .navigateToAddOrUpdateAccountScreen(context: context);
                },
              ),
              buildAppMenuItem(
                icon: Icons.insert_chart_outlined,
                title: AppStrings.finalAccounts.tr,
                onTap: () {
                  read<AccountsController>()
                      .navigateToFinalAccountsScreen(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: AppButton(
        title: title,
        width: 140,
        onPressed: onPressed,
      ),
    );
  }


  Future<void> printHotMassageMaterial() async {
    try {
      final querySnapshot = await FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: "test-eu")
          .collection('materials')
          .where('MatName', isEqualTo: 'HOT MASSAGE')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No material found with MatName = hot massage');
        return;
      }

      for (var doc in querySnapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Document Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error fetching material: $e');
    }
  }
  Future<void> migrateLastTransactions() async {

    debugPrint("called this function");
    final firestore =
    FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: "test-eu");

    final materialsSnapshot =
    await firestore.collection('materials').get();

    final total = materialsSnapshot.docs.length;

    int processed = 0;
    int updated = 0;
    int skipped = 0;
    int errors = 0;

    for (final materialDoc in materialsSnapshot.docs) {
      processed++;

      final materialId = materialDoc.id;
      final data = materialDoc.data();

      final existing = data['lastTransactions'];

      // ✅ Skip if already has 6 stored
      if (existing != null && existing is List && existing.length >= 6) {
        skipped++;
        continue;
      }

      try {
        final statementsSnapshot = await firestore
            .collection('materials_statements')
            .doc(materialId)
            .collection(materialId)
            .orderBy('date', descending: true)
            .limit(6)
            .get();

        if (statementsSnapshot.docs.isEmpty) {
          skipped++;
          continue;
        }

        final List<Timestamp> lastSixDates = [];

        for (final doc in statementsSnapshot.docs) {
          try {
            final rawDate = doc.data()['date'];

            if (rawDate == null) continue;

            if (rawDate is Timestamp) {
              lastSixDates.add(rawDate);
            } else if (rawDate is String) {
              final parsed = DateTime.tryParse(rawDate);
              if (parsed != null) {
                lastSixDates.add(Timestamp.fromDate(parsed));
              }
            } else if (rawDate is DateTime) {
              lastSixDates.add(Timestamp.fromDate(rawDate));
            }
          } catch (e) {
            debugPrint("⚠️ Bad date in statement ${doc.id}");
          }
        }

        if (lastSixDates.isEmpty) {
          skipped++;
          continue;
        }

        await firestore.collection('materials').doc(materialId).update({
          'lastTransactions': lastSixDates,
        });

        updated++;
      } catch (e) {
        errors++;
        debugPrint("❌ Error processing $materialId: $e");
      }

      // ✅ Progress tracking every 100
      if (processed % 100 == 0 || processed == total) {
        debugPrint(
            "Progress: $processed / $total | Updated: $updated | Skipped: $skipped | Errors: $errors");
      }
    }

    debugPrint("✅ Migration Complete");
    debugPrint("Total: $total");
    debugPrint("Updated: $updated");
    debugPrint("Skipped: $skipped");
    debugPrint("Errors: $errors");
  }

}