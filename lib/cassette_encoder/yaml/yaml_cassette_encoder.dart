import 'dart:io';

import 'package:http/http.dart';
import 'package:vcr_http/cassette.dart';
import 'package:vcr_http/cassette_encoder/cassette_encoder.dart';
import 'package:vcr_http/cassette_encoder/yaml/yaml_generator.dart';
import 'package:yaml/yaml.dart';

class YamlCassetteEncoder extends CassetteEncoder {
  static const String _extension = "yaml";

  @override
  String get fileExtension => _extension;

  @override
  void writeToExistingFile(File cassetteFile, CassetteInteraction interaction) {
    cassetteFile.writeAsStringSync(
      _encodeInteraction(interaction),
      mode: FileMode.append,
      flush: true,
    );
  }

  @override
  List<CassetteInteraction> parseExistingFile(File cassetteFile) {
    String fileContent = cassetteFile.readAsStringSync();

    YamlDocument document = loadYamlDocument(fileContent);

    YamlNode interactionList = document.contents;

    if (interactionList is YamlList) {
      return interactionList.map((node) {
        Request request =
            _parseRequest(node["interaction"]["request"] as YamlMap);
        Response response =
            _parseResponse(request, node["interaction"]["response"] as YamlMap);
        return CassetteInteraction(request, response);
      }).toList();
    }

    throw "Expected YamlList, found ${document?.runtimeType}";
  }

  String _encodeInteraction(CassetteInteraction interaction) =>
      YamlGenerator.fromList([
        {"interaction": interaction.toMap()}
      ]);

  Request _parseRequest(YamlMap node) {
    Request request = Request(node['method'], Uri.tryParse(node['url']));
    request.headers.addAll(Map<String, String>.from(node['headers'] ?? {}));
    if (node['body'] != null) request.body = node['body'];

    YamlMap clientSpecific = node['_clientSpecific'];
    request.persistentConnection = clientSpecific['persistentConnection'];
    request.followRedirects = clientSpecific['followRedirects'];
    request.maxRedirects = clientSpecific['maxRedirects'];
    if (request.finalized) {
      request.finalize();
    }

    return request;
  }

  Response _parseResponse(Request request, YamlMap node) => Response(
        node['body'],
        node['statusCode'],
        headers: Map<String, String>.from(node['headers']),
        request: request,
        reasonPhrase: node['reasonPhrase'],
        persistentConnection: node['persistentConnection'],
        isRedirect: node['isRedirect'],
      );
}
