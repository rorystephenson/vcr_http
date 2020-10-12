import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart' as Path;
import 'package:test/test.dart';
import 'package:vcr_http/vcr_client.dart';
import 'package:yaml/yaml.dart';

void main() {
  Directory _cassettesDirectory() => Directory(
        Path.join(Directory.current.path, "test", "cassettes"),
      );

  String _cassettePath() => Path.join("github", "user_repos");

  File _file() => File(
        Path.join(
          _cassettesDirectory().path,
          _cassettePath() + ".yaml",
        ),
      );

  YamlDocument _readFile() {
    String fileString = _file().readAsStringSync();
    return loadYamlDocument(fileString);
  }

  void fileExists(bool exists) {
    expect(_file().existsSync(), exists ? isTrue : isFalse);
  }

  void interactionsInFile(int size) {
    YamlNode fileYaml = _readFile().contents;

    if (fileYaml is YamlList) {
      expect(fileYaml.length, size);
    } else {
      throw "Unexpected data in yaml file.";
    }
  }

  tearDown(() {
    if (_cassettesDirectory().existsSync()) {
      _cassettesDirectory().delete(recursive: true);
    }
  });

  test('makes http request and stores it when there is no cassette', () async {
    fileExists(false);
    VcrClient client = VcrClient(cassettePath: _cassettePath());

    Response response =
        await client.get('https://api.github.com/users/rorystephenson/repos');

    expect(response.statusCode, 200);

    interactionsInFile(1);
  });

  test('uses the stored cassette if there is one', () async {
    fileExists(false);
    VcrClient client = VcrClient(cassettePath: _cassettePath());

    Response firstResponse =
        await client.get('https://api.github.com/users/rorystephenson/repos');
    expect(firstResponse.statusCode, 200);
    interactionsInFile(1);

    client = VcrClient(cassettePath: _cassettePath());
    expect(client.cassetteFile.existsSync(), isTrue);

    Response secondResponse =
        await client.get('https://api.github.com/users/rorystephenson/repos');
    expect(secondResponse.statusCode, 200);
    interactionsInFile(1);

    expect(firstResponse.headers, secondResponse.headers);
    expect(firstResponse.body, secondResponse.body);
    expect(firstResponse.statusCode, secondResponse.statusCode);
  });

  test('appends multiple requests to the same cassette', () async {
    fileExists(false);
    VcrClient client = VcrClient(cassettePath: _cassettePath());

    Response response =
        await client.get('https://api.github.com/users/rorystephenson/repos');
    expect(response.statusCode, 200);
    interactionsInFile(1);

    response = await client.get('https://api.github.com/users/rorystephenson');
    expect(response.statusCode, 200);
    interactionsInFile(2);
  });

  test('raises an error if the stored cassette requests do not match',
      () async {
    fileExists(false);

    VcrClient client = VcrClient(cassettePath: _cassettePath());

    Response firstResponse =
        await client.get('https://api.github.com/users/rorystephenson/repos');
    expect(firstResponse.statusCode, 200);
    interactionsInFile(1);

    client = VcrClient(cassettePath: _cassettePath());

    bool requestFailed = false;
    try {
      await client.post('https://api.github.com/users/rorystephenson/repos');
    } catch (err) {
      requestFailed = true;
      expect(
        err,
        equals(
            "Request mismatch for request: POST https://api.github.com/users/rorystephenson/repos"),
      );
    }

    expect(requestFailed, isTrue);
  });
}
