# bash-template

[![Tests status badge](https://github.com/Dmitrii-I/bash-template/workflows/tests/badge.svg)](https://github.com/Dmitrii-I/bash-template/actions?query=workflow%3Atests)

A template for robust Bash scripts.

## Usage

### Web browser
Open [https://www.bash-template.com](https://www.bash-template.com), then copy and paste.

### wget
`wget -O - bash-template.com -o /dev/null`

### HTTPie
`http -b GET bash-template.com`

### curl
`curl bash-template.com`

## Explanation
With `POSIXLY_CORRECT=1` we ensure that `set` executes the Bash builtin `set` and not some other shell function. This is because in POSIX mode, "builtins are found before shell functions" ([3], point 15). After `set` commands, we return to default non-POSIX mode with `unset POSIXLY_CORRECT`.

With `set -o errexit` the script will exit immediately with non-zero return code upon error [1].

With `set -o nounset` referencing unset variables will result in an error [1]. For example if no arguments were provided to a script, then `$1` is not set and referencing it will result in error.

With `set -o pipefail` a pipeline of commands will succeed (return code zero) only if all commands in the pipeline succeeded [1], not just the last one.

## References
[1] https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin

[2] https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins

[3] https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html#Bash-POSIX-Mode

