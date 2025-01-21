import 'package:ba3_bs/features/bill/services/bill/bill_pdf_generator.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_pdf_generator.dart';

import '../../../../features/bill/data/models/bill_model.dart';
import '../../../../features/bond/data/models/bond_model.dart';
import '../interfaces/i_pdf_generator.dart';

class PdfGeneratorFactory {
  static IPdfGenerator resolveGenerator<T>(T model) {
    if (model is List<BillModel>) {
      // Handles multiple strategies for ChequesModel
      return BillComparisonPdfGenerator();
    } else if (model is BillModel) {
      // Returns a single BillEntryBondCreator wrapped in a list
      return BillPdfGenerator();
    } else if (model is BondModel) {
      // Returns a single BondEntryBondCreator wrapped in a list
      return BondPdfGenerator();
    }
    throw UnimplementedError("No EntryBondCreator implementation for model of type ${model.runtimeType}");
  }
}
