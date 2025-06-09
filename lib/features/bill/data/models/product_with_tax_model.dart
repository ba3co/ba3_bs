import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

class ProductWithTaxModel extends PlutoAdaptable {
  final String materialName;
  final String materialCode;
  final String materialQuantity;
  final String materialTotalPrice;
  final bool isFreeTax;

  ProductWithTaxModel({
    required this.isFreeTax,
    required this.materialCode,
    required this.materialName,
    required this.materialQuantity,
    required this.materialTotalPrice,
  });

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      createAutoIdColumn(): '#',
      PlutoColumn(title: 'اسم المادة', field: 'materialName', type: PlutoColumnType.text()): '$materialCode - $materialName ',
      PlutoColumn(title: 'الضريبة', field: 'isFreeTax', type: PlutoColumnType.text()): isFreeTax?AppConstants.taxFreeAccountName.replaceAll('ضريبة القيمة المضافة', ''):AppConstants.taxLocalAccountName.replaceAll('ضريبة القيمة المضافة', ''),
      PlutoColumn(title: 'الكمية', field: 'materialQuantity', type: PlutoColumnType.text()): materialQuantity,
      PlutoColumn(title: 'الافرادي', field: 'materialPrice', type: PlutoColumnType.text()): (materialTotalPrice.toDouble/materialQuantity.toInt).toString(),
      PlutoColumn(title: 'الاجمالي', field: 'materialTotalPrice', type: PlutoColumnType.text()): materialTotalPrice,
    };
  }
}