import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ghooks/ghooks.dart';

void main(List<String> arguments) {
  final runner =
      new CommandRunner("ghooks", "A tool to use git hooks described in Dart pubspec.yaml.")
        ..addCommand(new InstallCommand())
        ..addCommand(new RemoveCommand());

  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

class InstallCommand extends Command {
  final name = "install";
  final description = "Creates git hooks scripts in .git/hook .";

  InstallCommand() {
    argParser
      ..addFlag('precommit-sample', defaultsTo: false)
      ..addOption('hook', abbr: 'k', defaultsTo: 'all', allowMultiple: true);
  }

  Future<Null> run() async {
    if (!isGitProject()) {
      return;
    }
    install(argResults['hook']);
  }
}

class RemoveCommand extends Command {
  final name = "remove";
  final description = "Removes git hooks scripts in .git/hook .";

  RemoveCommand() {
    argParser
      ..addOption('hook', abbr: 'k', defaultsTo: 'all', allowMultiple: true);
  }

  Future<Null> run() async {
    if (!isGitProject()) {
      return;
    }
    remove(argResults['hook']);
  }
}

bool isGitProject() {
  if (!FileSystemEntity.isDirectorySync('.git')) {
    print('.git directory not found!');
    print('Did you forgot to initialize git in your project?');
    exitCode = 1;
    return false;
  }
  return true;
}
