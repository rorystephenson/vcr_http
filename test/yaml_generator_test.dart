import 'dart:io';

import 'package:test/test.dart';

import 'helper/yaml_generate_compare.dart';

void main() {
  tearDown(() {
    Directory current = Directory.current;
    String finalPath =
        current.path.endsWith('/test') ? current.path : current.path + '/test';
    var directory = Directory('$finalPath/cassettes');
    if (directory.existsSync()) directory.delete(recursive: true);
  });

  Map<String, dynamic> yamlMap = {
    "nastyString": "\"':{}[],&*#?|-<>=!%@\\ \nàbla \rasd \n ",
    "emptyString": "",
    "null": null,
    "double": 4.2,
    "negativeDouble": -4.2,
    "int": 42,
    "negativeInt": -42,
    "emptyList": [],
    "emptyMap": {},
    "listWithNums": [1, 2, 3],
    "mapWithNums": {1: 1, 2: 2, -3: 3},
    "true": true,
    "false": false,
  };

  List<dynamic> yamlList = yamlMap.values.toList();

  Map<String, dynamic> nested = {
    "level": 0,
    "value": [
      "dummy element",
      {},
      {"a": 1, "b": 2},
      {
        "level": 1,
        "value": [
          {"level": 3},
          [],
          [1, 2],
        ]
      }
    ]
  };

  test('generates expected YAML from Map', () async {
    YamlGenerateCompare.generateParseCompare(yamlMap);
  });

  test('generates expected YAML from List', () async {
    YamlGenerateCompare.generateParseCompare(yamlList);
  });

  test('generates expected YAML from nested data', () async {
    YamlGenerateCompare.generateParseCompare(nested);
  });
}
