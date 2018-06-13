library ghooks;

import 'dart:async';
import 'dart:io';
import 'package:command_wrapper/command_wrapper.dart';

Future<Null> install(List<String> hooksToAdd) async {
  if (hooksToAdd[0] == 'all') {
    hooks.forEach(createHook);
  }

  hooks.where((h) => hooksToAdd.contains(h)).forEach(createHook);
}

Future<Null> remove(List<String> hooksToRemove) async {
  if (hooksToRemove[0] == 'all') {
    return hooks.forEach(removeHook);
  }
  return hooks.where((h) => hooksToRemove.contains(h)).forEach(removeHook);
}

Future<Null> createHook(String hookName,
    {String hooksDirectory: '.git/hooks'}) async {
  print('Installing hook: $hookName');
  final hookFile = new File('$hooksDirectory/$hookName');

  if (!hookFile.existsSync()) {
    hookFile.create(recursive: true);
    print(hookFile.path);
  } else {
    final backup = new File('$hooksDirectory/$hookName.bak');
    if (!backup.existsSync()) {
      backup.writeAsStringSync(hookFile.readAsStringSync());
    }
  }
  final cmd = new CommandWrapper('bash');
  await cmd.run(['-c', 'chmod +x ${hookFile.path}']);

  hookFile.writeAsStringSync(getHookScript(hookName.replaceAll('-', '_')));
}

Future<Null> removeHook(String hookName,
    {String hooksDirectory: '.git/hooks'}) async {
  print('Removing hook: $hookName');
  final hookFile = new File('$hooksDirectory/$hookName');
  hookFile.deleteSync();
}

// TODO:stepancar replace with parse pubspec.yaml
getHookScript(String hookName) =>
'''
#!/bin/bash
# Created by ghooks
hookName=$hookName
''' + 
r'''

function parse_yaml() {
    local yaml_file=$1
    local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/\s*$//g;' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e  "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
                }
            }' |
            
        sed -e 's/_=/+=/g' \
            -e '/\..*=/s|\.|_|' \
            -e '/\-.*=/s|\-|_|'

    ) < "$yaml_file"
}

underscored_hook_name=$(echo $hookName | sed 's/-/_/g');
command=$(parse_yaml pubspec.yaml | grep ghooks_ | sed 's/ghooks\(_*\)//g' | grep $underscored_hook_name | sed "s/$underscored_hook_name=(\"/ /"  | sed 's/")//');
if [ -z "$command" ]; then
    echo 'Not found hook in pubspec.yaml'
    exit 0
else
    echo $command;
fi

echo "> Running ${hookName} hook..."

DART_EXIT_CODE=0
$command "$@"
DART_EXIT_CODE=$?


if [[ ${DART_EXIT_CODE} -ne 0 ]]; then
  echo ""
  echo "> Error detected in $hookName hook."
	exit 1
fi

''';

const hooks = const [
  "applypatch-msg",
  "pre-applypatch",
  "post-applypatch",
  "pre-commit",
  "prepare-commit-msg",
  "commit-msg",
  "post-commit",
  "pre-rebase",
  "post-checkout",
  "post-merge",
  "pre-push",
  "pre-receive",
  "update",
  "post-receive",
  "post-update",
  "push-to-checkout",
  "pre-auto-gc",
  "post-rewrite"
];

const dartPrecommitSample = '''

main(List<String> arguments) {
  print('This Dart script will run before a commit!');
}

''';
