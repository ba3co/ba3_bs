import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/customer/data/models/customer_model.dart';

class CustomersExport {
  /// Generates the Customers section of the export XML
  xml.XmlElement exportCustomers(List<CustomerModel> customers) {
    final customerElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('CustomersCount'), [], [xml.XmlText(customers.length.toStringAsFixed(2))]),
      ...customers.map((c) => _buildCustomerElement(c)),
    ];

    return xml.XmlElement(xml.XmlName('Customers'), [], customerElements);
  }
  xml.XmlElement _buildCustomerElement(CustomerModel customer) {
    return xml.XmlElement(
      xml.XmlName('Cu'),
      [],
      [
        XmlHelpers.element('cptr', customer.id),
        XmlHelpers.element('CustName', customer.name),
        XmlHelpers.element('CustLatinName', customer.latinName),
        XmlHelpers.element('CustPrefix', customer.prefix),
        XmlHelpers.element('CustNation', customer.nation),
        XmlHelpers.element('phone1', customer.phone1),
        XmlHelpers.element('phone2', customer.phone2),
        XmlHelpers.element('Fax', customer.fax),
        XmlHelpers.element('Telex', customer.telex),
        XmlHelpers.element('Note', customer.note),
        XmlHelpers.element('AcGuid', customer.accountGuid),
        XmlHelpers.element('CustCheckDate', customer.checkDate?.toIso8601String()),
        XmlHelpers.element('Security', customer.security?.toString()),
        XmlHelpers.element('CustType', customer.type?.toString()),
        XmlHelpers.element('DiscountRatio', customer.discountRatio?.toString()),
        XmlHelpers.element('DefaultPrice', customer.defaultPrice?.toString()),
        XmlHelpers.element('CustState', customer.state?.toString()),
        XmlHelpers.element('CustEmail', customer.email),
        XmlHelpers.element('CustHomePage', customer.homePage),
        XmlHelpers.element('CustSuffix', customer.suffix),
        XmlHelpers.element('CustMobile', customer.mobile),
        XmlHelpers.element('CustPager', customer.pager),
        XmlHelpers.element('CustHoppies', customer.hobbies),
        XmlHelpers.element('CustGender', customer.gender),
        XmlHelpers.element('CustCertificate', customer.certificate),
        XmlHelpers.element('CustDefaultAddressGuid', customer.defaultAddressGuid ?? '00000000-0000-0000-0000-000000000000'),
      ],
    );
  }
}