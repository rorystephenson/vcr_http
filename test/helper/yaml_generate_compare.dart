import 'package:test/test.dart';
import 'package:vcr_http/cassette_encoder/yaml/yaml_generator.dart';
import 'package:yaml/yaml.dart';

class YamlGenerateCompare {
  static void generateParseCompare(dynamic value) {
    String generatedYaml = value is Map
        ? YamlGenerator.fromMap(value)
        : YamlGenerator.fromList(value);

    dynamic parsedYaml = loadYaml(generatedYaml);

    if (parsedYaml is YamlMap) {
      _yamlMapEquals(value, parsedYaml);
    }
    if (value is Map) {
    } else {
      value = value as List;
      YamlGenerator.fromList(value);
    }
  }

  static void _yamlEquals(dynamic expected, dynamic result) {
    if (expected is Map) {
      _yamlMapEquals(expected, result);
    } else if (expected is List) {
      _yamlListEquals(expected, result);
    } else {
      expect(expected, equals(result));
    }
  }

  static void _yamlMapEquals(Map expected, YamlMap result) {
    expect(expected.length, equals(result.length));

    for (var key in expected.keys) {
      var value = expected[key];
      var otherValue = result[key];

      return _yamlEquals(value, otherValue);
    }
  }

  static void _yamlListEquals(List expected, List result) {
    expect(expected.length, equals(result.length));

    for (int i = 0; i < expected.length; i++) {
      var value = expected[i];
      var otherValue = result[i];

      return _yamlEquals(value, otherValue);
    }
  }
}
