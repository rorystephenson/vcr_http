import 'dart:io';

import 'package:vcr_http/cassette.dart';

abstract class CassetteEncoder {
  String get fileExtension;

  void write(File cassetteFile, CassetteInteraction interaction) {
    if (!cassetteFile.existsSync()) {
      cassetteFile.createSync(recursive: true);
    }

    writeToExistingFile(cassetteFile, interaction);
  }

  void writeToExistingFile(File cassetteFile, CassetteInteraction interaction);

  List<CassetteInteraction> parseExistingFile(File cassetteFile);
}
