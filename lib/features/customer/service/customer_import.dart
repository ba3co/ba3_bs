import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../data/models/customer_model.dart';

class CustomerImport extends ImportServiceBase<CustomerModel> {
  /// Converts the imported JSON structure to a list of CustomerModel
  @override
  List<CustomerModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  Future<List<CustomerModel>> fromImportXml(XmlDocument document) async {
    final customerNodes = document.findAllElements('Cu');

    final customerGccNodes = document.findAllElements('GCCCustomerTax');

    List<GccCusTax> gcc = customerGccNodes.map(
      (gccCus) {
        String getText(String tagName) {
          final elements = gccCus.findElements(tagName);
          return elements.isEmpty ? '' : elements.first.text;
        }

        return GccCusTax(
          vat: getText('GCCCustomerTaxCode'),
          guid: getText('GCCCustomerTaxCustGUID'),
        );
      },
    ).toList();

    DateFormat dateFormat = DateFormat('d-M-yyyy');

    final List<CustomerModel> customers = customerNodes
        .where(
      (customer) => customer.getElement('CustName')?.text != '',
    )
        .map((customer) {
      return CustomerModel(
        id: customer.getElement('cptr')?.text,
        name: customer.getElement('CustName')?.text ?? '',
        latinName: customer.getElement('CustLatinName')?.text,
        prefix: customer.getElement('CustPrefix')?.text,
        nation: customer.getElement('CustNation')?.text,
        phone1: customer.getElement('phone1')?.text,
        phone2: customer.getElement('phone2')?.text,
        fax: customer.getElement('Fax')?.text,
        telex: customer.getElement('Telex')?.text,
        note: customer.getElement('Note')?.text,
        accountGuid: customer.getElement('AcGuid')?.text ?? '',
        checkDate: dateFormat.tryParse(customer.getElement('CustCheckDate')?.text ?? ''),
        security: int.parse(customer.getElement('Security')?.text ?? '0'),
        type: int.parse(customer.getElement('CustType')?.text ?? '0'),
        discountRatio: double.parse(customer.getElement('DiscountRatio')?.text ?? '0'),
        defaultPrice: int.parse(customer.getElement('DefaultPrice')?.text ?? '0'),
        state: int.parse(customer.getElement('CustState')?.text ?? '0'),
        email: customer.getElement('CustEmail')?.text,
        homePage: customer.getElement('CustHomePage')?.text,
        suffix: customer.getElement('CustSuffix')?.text,
        mobile: customer.getElement('CustMobile')?.text,
        pager: customer.getElement('CustPager')?.text,
        hobbies: customer.getElement('CustHoppies')?.text,
        gender: customer.getElement('CustGender')?.text,
        certificate: customer.getElement('CustCertificate')?.text,
        defaultAddressGuid: customer.getElement('CustDefaultAddressGuid')?.text ?? '',
      );
    }).toList();

    updateCustomersVat(customers, gcc);

    return customers;
  }
}

class GccCusTax {
  final String vat;
  final String guid;

  GccCusTax({required this.vat, required this.guid});

  Map toJson() => {
        'vat': vat,
        'guid': guid,
      };

  GccCusTax copyWith({
    final String? vat,
    final String? guid,
  }) {
    return GccCusTax(
      vat: vat ?? this.vat,
      guid: guid ?? this.guid,
    );
  }
}

void updateCustomersVat(List<CustomerModel> customers, List<GccCusTax> gccList) {
  for (var i = 0; i < customers.length; i++) {
    var customer = customers[i];

    // Find the corresponding VAT value for the material
    final gcc = gccList.firstWhere(
      (gccItem) => gccItem.guid == customer.id,
      orElse: () => GccCusTax(vat: '4.00', guid: ''), // Default object with 0.00 VAT
    );
    CustomerModel updatedMaterial = customer; // Initialize with original material

    // Check if gcc is found and update the matVatGuid
    if (gcc.vat.isNotEmpty && gcc.guid.isNotEmpty) {
      double vatValue = double.tryParse(gcc.vat) ?? 0.00; // Parse vat to double safely

      if (vatValue == 1.00) {
        updatedMaterial = customer.copyWith(cusVatGuid: 'xtc33mNeCZYR98i96pd8');
      } else if (vatValue == 4.00) {
        updatedMaterial = customer.copyWith(cusVatGuid: 'kCfkUHwNyRbxTlD71uXV');
      }

      // Update the material in the list if modified
      if (updatedMaterial != customer) {
        customers[i] = updatedMaterial;
      }
    } else {
      // If no matching VAT, set default matVatGuid
      updatedMaterial = customer.copyWith(cusVatGuid: 'kCfkUHwNyRbxTlD71uXV');
      customers[i] = updatedMaterial;
    }
  }
}
