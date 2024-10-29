import 'package:get_it/get_it.dart';

import '../../features/patterns/data/models/bill_type_model.dart';

final getIt = GetIt.instance;

void setupModelDeserializationRegistry() {
  // Registering the fromJson, toJson functions for BillTypeModel
  getIt.registerLazySingleton<BillTypeModel Function(Map<String, dynamic>)>(
      () => (json) => BillTypeModel.fromJson(json));

  getIt.registerLazySingleton<Map<String, dynamic> Function(BillTypeModel)>(() => (model) => model.toJson());

  // TODO: Register other models as needed
}
