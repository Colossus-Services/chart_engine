@TestOn('vm')

import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:path/path.dart' as path;
import 'package:swiss_knife/swiss_knife_vm.dart';
import 'package:test/test.dart';

class _PubSpec {
  final String? name;
  final String? version;

  _PubSpec(this.name, this.version);
}

_PubSpec? _readPubSpecVersion(File file) {
  var content = file.readAsStringSync();
  var lines = content.split(RegExp(r'[\r\n]+'));

  var nameLine = _findLine(lines, 'name');
  var versionLine = _findLine(lines, 'version');
  if (nameLine == null || versionLine == null) return null;

  var parts = versionLine.split(':');
  if (parts.length < 2) return null;

  var name = _parseLineValue(nameLine);
  var ver = _parseLineValue(versionLine);
  return _PubSpec(name, ver);
}

String? _parseLineValue(String line) {
  var parts = line.split(':');
  if (parts.length < 2) return null;
  var value = parts[1].trim();
  return value;
}

String? _findLine(List<String> lines, String key) =>
    lines.firstWhereOrNull((line) => line.startsWith('$key:'));

void main() {
  group('ChartEngine.VERSION', () {
    setUp(() {});

    test('Check Version', () async {
      var projectDirectory = Directory.current;

      print(projectDirectory);

      var pubspecFile = File(path.join(projectDirectory.path, 'pubspec.yaml'));

      print('pubspecFile: $pubspecFile');

      var pubSpec = _readPubSpecVersion(pubspecFile)!;

      print('PubSpec.name: ${pubSpec.name}');
      print('PubSpec.version: ${pubSpec.version}');

      var srcFile = File(
          path.join(projectDirectory.path, 'lib/src/chart_engine_base.dart'));

      print(srcFile);

      var src = await catFile(srcFile);

      var versionMatch = RegExp(r"VERSION\s*=\s*'(.*?)'").firstMatch(src)!;

      var srcVersion = versionMatch.group(1);

      print('srcVersion: $srcVersion');

      expect(pubSpec.version.toString(), equals(srcVersion),
          reason:
              'ChartEngine.VERSION[$srcVersion] != PubSpec.version[${pubSpec.version}]');
    });
  });
}
