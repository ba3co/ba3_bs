import '../../../models/date_filter.dart';

abstract class ICompoundDatabaseService<T> {
  Future<T> add({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required T data,
  });

  Future<List<T>> fetchAll({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
  });

  Future<List<Map<String, dynamic>>> fetchWhere<V>({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    required String field,
    required V value,
    DateFilter? dateFilter,
  });

  Future<T> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
  });

  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required T data,
  });

  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
  });
}
