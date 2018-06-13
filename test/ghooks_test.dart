import 'dart:io';
import 'package:ghooks/ghooks.dart';
import 'package:test/test.dart';

main() async {
  await testCreateHook();
}

testCreateHook() async {
  test('Should remove hook file', () async {
    final hookName = 'pre-commit';
    final tmp = await Directory.systemTemp.createTemp('ghooksa_git_temp_test');
    final file = new File('${tmp.path}/$hookName');
    file.createSync();

    await removeHook(hookName, hooksDirectory: tmp.path);
    expect(file.existsSync(), isFalse);

    await tmp.delete(recursive: true);
  });
}
