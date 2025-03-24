import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/accounts/data/models/account_model.dart';
import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/bond/data/models/bond_model.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../../features/customer/data/models/customer_model.dart';
import '../../../features/materials/data/models/materials/material_group.dart';
import '../../../features/materials/data/models/materials/material_model.dart';
import '../../../features/sellers/data/models/seller_model.dart';
import '../../helper/enums/enums.dart';
import 'bills_export.dart';
import 'bonds_export.dart';
import 'cheques_export.dart';
import 'accounts_export.dart';
import 'customers_export.dart';
import 'materials_export.dart';
import 'groups_export.dart';
import 'stores_export.dart';
import 'costs_export.dart';
import 'static_sections.dart';
import 'addresses_export.dart';

class ExportXmlService {
  final _bills = BillsExport();
  final _bonds = BondsExport();
  final _cheques = ChequesExport();
  final _accounts = AccountsExport();
  final _customers = CustomersExport();
  final _materials = MaterialsExport();
  final _groups = GroupsExport();
  final _stores = StoresExport();
  final _costs = CostsExport();
  final _static = StaticSections();
  final _addresses = AddressesExport();

  String generateFullXml({
    required Map<BillTypeModel, List<BillModel>> bills,
    required Map<BondType, List<BondModel>> bonds,
    required List<MaterialModel> materials,
    required List<ChequesModel> cheques,
    required List<CustomerModel> customers,
    required List<AccountModel> accounts,
    required List<MaterialGroupModel> groups,
    required List<StoreAccount> allStore,
    required List<SellerModel> sellers,
  }) {
    final builder = xml.XmlBuilder();

    builder.element('MainExp', nest: () {
      builder.element('Export', nest: () {
        _static.buildStaticSections(builder: builder, materials: materials, bonds: bonds, chequesList: cheques);
        builder.element('Accounts', nest: _accounts.exportAccounts(accounts).children);
        builder.element('Customers', nest: _customers.exportCustomers(customers).children);
        _addresses.buildAddresses(builder);
        builder.element('Groups', nest: _groups.exportGroups(groups).children);
        builder.element('Stores', nest: _stores.exportStores(allStore).children);
        builder.element('Cost1', nest: _costs.exportCosts(sellers).children);
        builder.element('Materials', nest: _materials.exportMaterials(materials).children);
        builder.element('Pay', nest: _bonds.exportBonds(bonds.values.expand((bonds) => bonds).toList()).children);
        builder.element('BillGuids', nest: _bills.exportBillGuids(bills.values.expand((bills) => bills).toList()).children);
        builder.element('BillTotCount', nest: bills.length.toString());
        for (var bill in _bills.exportBills(bills.values.expand((bills) => bills).toList())) {
          builder.element('Bill', nest: bill.children);
        }
        builder.element('Checks', nest: _cheques.exportChecks(cheques).children);
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }
}