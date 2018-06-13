# dart ghooks

A library to easily use git hooks from Dart

## Install

To start using ghooks, add it to your `dev_dependencies` and run `pub get`

To install hooks in your project, run:

    $ pub run ghooks install
        
Add your hook to pubspec.yaml
    
Example:
    
```
    ghooks:
        pre-commit: ./lint.sh && ./test.sh
```

## Remove

To remove all hooks in your project, run:

    $ pub run ghooks remove
    
Or if you want to remove a specific hook:
    
    $ pub run ghooks remove -k pre-commit -k commit-msg

## Git Hooks

Git hooks are scripts that run automatically every time a particular event occurs in a Git repository. 
ghooks supports all git hooks (https://git-scm.com/docs/githooks)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/stepancar/ghooks/issues
