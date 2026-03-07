import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/models/query_filter.dart';
import '../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../data/models/mat_statement/mat_statement_model.dart';
import '../data/models/materials/material_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialLastTransactionService {
  final QueryableSavableRepository<MaterialModel> materialRemoteRepo;

  MaterialLastTransactionService(this.materialRemoteRepo);


  Future<void> updateFromStatements(
      List<MatStatementModel> statements,
      ) async {
    if (statements.isEmpty) return;

    // Group statements by matId
    final Map<String, List<MatStatementModel>> grouped = {};

    for (final s in statements) {
      if (s.matId == null || s.date == null) continue;
      grouped.putIfAbsent(s.matId!, () => []).add(s);
    }

    // Process each material independently
    for (final entry in grouped.entries) {
      final matId = entry.key;
      debugPrint("the mat id is : $matId");

      final matStatements = entry.value;

      final queryFilters = [
        QueryFilter(field: 'docId', value: matId),
      ];

      final materialResult =
      await materialRemoteRepo.fetchWhere(queryFilters: queryFilters);

      await materialResult.fold(
            (failure) async {
          throw Exception(
            'Failed to fetch material with ID $matId from Firebase: ${failure.message}',
          );
        },
            (materials) async {
          if (materials.isEmpty) return;

          final material = materials.first;

          // Existing dates (DateTime, safe if field missing)
          final List<DateTime> existingDates =
              material.lastTransactions?.cast<DateTime>() ?? [];

          // New dates from statements (DateTime only)
          final List<DateTime> newDates =
          matStatements.map((e) => e.date!).toList();

          // Merge, sort, and keep last 6
          final merged = [...existingDates, ...newDates]
            ..sort((a, b) => b.compareTo(a));

          final lastSix = merged.take(6).toList();

          // Firestore update (DateTime → Timestamp automatically)
          await FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: "test-eu",
          )
              .collection('materials')
              .doc(material.id)
              .update({
            'lastTransactions': lastSix,
          });

          debugPrint(
            'Updated lastTransactions for material ${material.id}',
          );
        },
      );
    }

    log('Successfully updated materials lastTransactions');
  }
}