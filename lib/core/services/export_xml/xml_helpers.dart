import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as xml;



class XmlHelpers{
  static  final  uuid = Uuid();
  xml.XmlElement buildElement(String name, String? value) {
    return value == null || value.isEmpty
        ? xml.XmlElement(xml.XmlName(name), [], [])
        : xml.XmlElement(xml.XmlName(name), [], [xml.XmlText(value)]);
  }

  static  xml.XmlElement element(String name, String? value) {
    return value == null
        ? xml.XmlElement(xml.XmlName(name), [], [])
        : xml.XmlElement(xml.XmlName(name), [], [xml.XmlText(value)]);
  }

  static  int calcVatRatio(double? vat, double? subtotal) {
    if (vat == null || vat == 0 || subtotal == null || subtotal == 0) return 0;
    return ((vat / subtotal) * 100).round();
  }
}