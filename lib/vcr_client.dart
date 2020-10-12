library vcr;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as Path;
import 'package:vcr_http/cassette.dart';
import 'package:vcr_http/cassette_encoder/cassette_encoder.dart';
import 'package:vcr_http/cassette_encoder/yaml/yaml_cassette_encoder.dart';

class VcrClient extends BaseClient {
  final File cassetteFile;
  final CassetteEncoder encoder;
  final BaseClient innerClient;

  final StoredCassette cassette;

  VcrClient._({
    this.cassetteFile,
    this.encoder,
    this.innerClient,
  }) : cassette = cassetteFile.existsSync()
            ? StoredCassette.fromFile(cassetteFile, encoder)
            : null {
    cassetteFile.createSync(recursive: true);
  }

  factory VcrClient({
    String cassettesDirectory,
    String cassettePath,
    CassetteEncoder encoder,
    BaseClient innerClient,
  }) {
    cassettesDirectory ??= Path.join("test", "cassettes");
    encoder ??= YamlCassetteEncoder();
    innerClient ??= Client();

    if (!cassettePath.endsWith(".${encoder.fileExtension}")) {
      cassettePath += ".${encoder.fileExtension}";
    }

    return VcrClient._(
      cassetteFile: _loadFile(cassettesDirectory, cassettePath),
      encoder: encoder,
      innerClient: innerClient,
    );
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (cassette != null) return storedRequest(request);

    return sendAndStoreRequest(request);
  }

  Future<StreamedResponse> sendAndStoreRequest(Request request) async {
    StreamedResponse streamedResponse = await innerClient.send(request);
    Response response = await Response.fromStream(streamedResponse);

    encoder.write(
        cassetteFile, CassetteInteraction(response.request, response));

    return StreamedResponse(
      Stream.fromIterable([utf8.encode(response.body)]),
      response.statusCode,
      contentLength: response.contentLength,
      headers: response.headers,
      request: response.request,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<StreamedResponse> storedRequest(BaseRequest request) async {
    CassetteInteraction interaction = cassette.pop();

    if (!interaction.requestMatches(request)) {
      throw "Request mismatch for request: $request";
    }

    Response response = interaction.response;

    return StreamedResponse(
      Stream<List<int>>.fromIterable([response.bodyBytes]),
      response.statusCode,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
      contentLength: response.contentLength,
    );
  }

  static File _loadFile(String cassettesDirectory, String cassettePath) {
    String fullPath = Path.join(
      Directory.current.path,
      cassettesDirectory,
      cassettePath,
    );

    return File(fullPath);
  }
}
