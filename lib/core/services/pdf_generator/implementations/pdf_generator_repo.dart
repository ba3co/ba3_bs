import '../interfaces/i_pdf_generator.dart';

class PdfGeneratorRepository<T> {
  final IPdfGenerator<T> _pdfGenerator;

  PdfGeneratorRepository({required IPdfGenerator<T> pdfGenerator})
      : _pdfGenerator = pdfGenerator;

  Future<String> savePdf(T itemModel, String fileName,
      {String? logoSrc, String? fontSrc}) async {
    return await _pdfGenerator.generatePdf(itemModel, fileName,
        logoSrc: logoSrc, fontSrc: fontSrc);
  }
  Future<String> savePdfInLocation(T itemModel, String fileName,
      {String? logoSrc, String? fontSrc}) async {
    return await _pdfGenerator.generatePdfInLocation(itemModel, fileName,
        logoSrc: logoSrc, fontSrc: fontSrc,);
  }
}