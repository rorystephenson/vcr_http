class YamlGenerator {
  static final RegExp _allowedKey = RegExp(r'^[a-zA-Z-]+$');
  static final RegExp _spaceBeforeLineEnd = RegExp(r'\s\n', multiLine: true);

  static String fromList(List list, {startIndent: 0}) {
    return _listToYaml(list, startIndent);
  }

  static String _listToYaml(List listNode, int level, {bool nested: false}) {
    var result = '';
    final firstItemPadding = nested ? '- ' : '  ' * level + '- ';
    final regularPadding = '  ' * level + '- ';
    bool firstItem = true;

    for (var value in listNode) {
      var padding = firstItem ? firstItemPadding : regularPadding;
      firstItem = false;

      if (value is Map) {
        result += value.isEmpty
            ? _emptyMapToYaml(padding: padding)
            : padding + _mapToYaml(value, level + 1, nested: true);
      } else if (value is List) {
        result += value.isEmpty
            ? _emptyListToYaml(padding: padding)
            : '- ' + _listToYaml(value, level + 1, nested: true);
      } else if (value is num) {
        result += _numToYaml(value, padding: padding);
      } else if (value is bool) {
        result += _boolToYaml(value, padding: padding);
      } else if (value == null) {
        result += _nullToYaml(padding: padding);
      } else {
        result += _dynamicToYaml(value, padding: padding);
      }
    }
    return result;
  }

  static String fromMap(Map map, {startIndent: 0}) {
    return _mapToYaml(map, startIndent);
  }

  static String _mapToYaml(Map mapNode, int level, {bool nested: false}) {
    var result = '';
    final firstItemPadding = nested ? '' : '  ' * level;
    final regularPadding = '  ' * level;
    bool firstElement = true;

    for (var key in mapNode.keys) {
      var padding = firstElement ? firstItemPadding : regularPadding;
      firstElement = false;
      result += padding + '${_escapeKey(key)}:';

      dynamic value = mapNode[key];

      if (value is Map) {
        result += value.isEmpty
            ? _emptyMapToYaml(padding: ' ')
            : '\n' + _mapToYaml(value, level + 1);
      } else if (value is List) {
        result += value.isEmpty
            ? _emptyListToYaml(padding: ' ')
            : '\n' + _listToYaml(value, level);
      } else if (value is num) {
        result += _numToYaml(value, padding: ' ');
      } else if (value is bool) {
        result += _boolToYaml(value, padding: ' ');
      } else if (value == null) {
        result += _nullToYaml(padding: ' ');
      } else {
        result += _dynamicToYaml(value, padding: ' ');
      }
    }
    return result;
  }

  static String _escapeKey(dynamic key, {bool forceQuotedStrings: false}) {
    if (!forceQuotedStrings && key is String && _allowedKey.hasMatch(key))
      return key;
    if (key is num) return key.toString();
    if (key is bool) return key ? "true" : "false";

    key = key
        .toString()
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\\"')
        .replaceAllMapped(_spaceBeforeLineEnd, (match) {
          return "\\" + match.input.substring(match.start, match.end);
        })
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');

    return '"$key"';
  }

  static String _emptyListToYaml({String padding: ''}) {
    return padding + '[]' + '\n';
  }

  static String _emptyMapToYaml({String padding: ''}) {
    return padding + '{}' + '\n';
  }

  static String _numToYaml(num value, {String padding: ''}) {
    return padding + value.toString() + '\n';
  }

  static String _boolToYaml(bool value, {String padding: ''}) {
    return padding + (value ? 'true' : 'false') + '\n';
  }

  static String _nullToYaml({String padding: ''}) {
    return padding + 'null' + '\n';
  }

  static String _dynamicToYaml(dynamic value, {String padding: ''}) {
    return padding + _escapeKey(value, forceQuotedStrings: true) + "\n";
  }
}
