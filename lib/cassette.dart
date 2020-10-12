import 'dart:io';

import 'package:http/http.dart';
import 'package:vcr_http/cassette_encoder/cassette_encoder.dart';

class StoredCassette {
  final List<CassetteInteraction> interactions;
  int _interactionIndex = 0;

  StoredCassette.fromFile(File cassetteFile, CassetteEncoder encoder)
      : this.interactions =
            List.unmodifiable(encoder.parseExistingFile(cassetteFile));

  CassetteInteraction pop() {
    CassetteInteraction cassetteInteraction = interactions[_interactionIndex];

    _interactionIndex += 1;

    return cassetteInteraction;
  }
}

class CassetteInteraction {
  final Request request;
  final Response response;

  CassetteInteraction(this.request, this.response);

  Map<String, dynamic> toMap() => {
        "request": RequestSerializer(request).serialize(),
        "response": ResponseSerializer(response).serialize(),
      };

  static CassetteInteraction fromMap(Map<String, dynamic> map) {
    Request request = RequestSerializer.deserialize(map['request']);
    Response response =
        ResponseSerializer.deserialize(request, map['response']);

    return CassetteInteraction(request, response);
  }

  bool requestMatches(Request other) =>
      request.url == other.url &&
      request.method == other.method &&
      request.headers?.toString() == other.headers?.toString() &&
      request.body == other.body &&
      request.persistentConnection == other.persistentConnection &&
      request.followRedirects == other.followRedirects &&
      request.maxRedirects == other.maxRedirects &&
      request.finalized == other.finalized;
}

class RequestSerializer {
  final Request request;

  RequestSerializer(this.request);

  Map<String, dynamic> serialize() => {
        'url': request.url.toString(),
        'method': request.method.toString(),
        'headers': request.headers,
        '_clientSpecific': {
          'contentLength': request.contentLength,
          'encoding': request.encoding,
          'persistentConnection': request.persistentConnection,
          'followRedirects': request.followRedirects,
          'maxRedirects': request.maxRedirects,
          'finalized': request.finalized,
        },
        'body': request.bodyBytes.length > 0 ? request.body : null,
      };

  static Request deserialize(Map<String, dynamic> serialized) {
    Request request = Request(serialized['method'], serialized['url']);
    request.headers.addAll(Map<String, String>.from(serialized['headers']));
    request.body = serialized['body'];

    Map<String, dynamic> clientSpecific = serialized['_clientSpecific'];
    request.contentLength = clientSpecific['contentLength'];
    request.encoding = clientSpecific['encoding'];
    request.persistentConnection = clientSpecific['persistentConnection'];
    request.followRedirects = clientSpecific['followRedirects'];
    request.maxRedirects = clientSpecific['maxRedirects'];
    if (request.finalized) {
      request.finalize();
    }

    return request;
  }
}

class ResponseSerializer {
  final Response response;

  ResponseSerializer(this.response);

  Map<String, dynamic> serialize() => {
        'statusCode': response.statusCode,
        'headers': response.headers ?? {},
        '_clientSpecific': {
          'persistentConnection': response.persistentConnection,
          'reasonPhrase': response.reasonPhrase,
          'isRedirect': response.isRedirect,
        },
        'body': response.bodyBytes.length > 0 ? response.body : null,
      };

  static Response deserialize(
          Request request, Map<String, dynamic> serialized) =>
      Response(
        serialized['body'],
        serialized['statusCode'],
        headers: Map<String, String>.from(serialized['headers']),
        request: request,
        reasonPhrase: serialized['reasonPhrase'],
        persistentConnection: serialized['persistentConnection'],
        isRedirect: serialized['isRedirect'],
      );
}
