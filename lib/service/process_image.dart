import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class ProcessImage {
  Future<String> getImageUrl(
      {required var backgroundColor, required var buttonColor}) async {
    String path = "";
    try {
      List<String> pictures = [];
      try {
        pictures = await CunningDocumentScanner.getPictures(
                buttonColor, backgroundColor) ??
            [];
      } catch (exception) {
        rethrow;
      }
      path = pictures.first.toString();
    } catch (e) {
      rethrow;
    }
    return path;
  }
}
