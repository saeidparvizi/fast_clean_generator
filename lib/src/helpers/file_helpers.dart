// tool/helpers/file_helpers.dart
import 'dart:io';

Future<void> writeFile(
    String path,
    String content, {
      bool appendIfExists = false,
    }) async {
  final f = File(path);
  await f.create(recursive: true);

  // if (appendIfExists && await f.exists()) {
  //   final oldContent = await f.readAsString();
  //   if (!oldContent.contains(content.trim())) {
  //     final newContent = '${oldContent.trim()}\n\n${content.trim()}';
  //     await f.writeAsString(newContent);
  //   }
  // } else {
  //   await f.writeAsString(content);
  // }
  if (appendIfExists && f.existsSync()) {
    final oldContent = f.readAsStringSync();
    final trimmedNew = content.trim();
    // Append only if the exact block isn't already present
    if (!oldContent.contains(trimmedNew)) {
      final joined = [
        oldContent.trimRight(),
        '',
        trimmedNew,
      ].join('\n');
      f.writeAsStringSync('$joined\n'); // ensure trailing newline
    }
  } else {
    // Write fresh with trailing newline (nice for diffs)
    f.writeAsStringSync('${content.trimRight()}\n');
  }
}

String ensureImportOnce(String src, String importLine) {
  if (RegExp(
    // '^' + RegExp.escape(importLine) + r'\s*$',
    '^${RegExp.escape(importLine)}\\s*\$',
    multiLine: true,
  ).hasMatch(src)) {
    return src;
  }
  final importBlock = RegExp(
    "^(import\\s+['\"](.+?)['\"];\\s*)+",
    multiLine: true,
  );
  final match = importBlock.firstMatch(src);
  if (match != null) {
    final end = match.end;
    return '${src.substring(0, end)}$importLine\n${src.substring(end)}';
  }
  return '$importLine\n$src';
}
