#!/usr/bin/env bash

# Scripts based on template.sh should behave as expected under various scenarios.

POSIXLY_CORRECT=1 set -o errexit && set -o nounset && set -o pipefail && unset POSIXLY_CORRECT

echo Test simple echo
script="$(mktemp)"
chmod 744 "$script"
cat ~/bash-template/template.sh > $script
echo 'echo foo bar' >> $script
$script > /dev/null
exit_code=$?
rm $script
test $exit_code -eq 0

echo Test referencing unset variable
script="$(mktemp)"
chmod 744 "$script"
cat ~/bash-template/template.sh > $script
echo 'echo $some_variable_that_does_not_exist' >> $script
$script > /dev/null 2>&1 || exit_code=$?
rm $script
test $exit_code -eq 1

echo Test pipeline error
script="$(mktemp)"
chmod 744 "$script"
cat ~/bash-template/template.sh > $script
echo 'echo foo | foobarbaz | echo' >> $script
$script > /dev/null 2>&1 || exit_code=$?
rm $script
test $exit_code -eq 127

echo Test script exits upon error
script="$(mktemp)"
chmod 744 "$script"
cat ~/bash-template/template.sh > $script
echo 'echo before error' >> $script
echo 'foobarbaz' >> $script  # some non-existent command that will make the script exit immediately
# If the script exits upon error than the line "after error" will be never printed to stdout
echo 'echo after error' >> $script
diff --brief <($script 2>/dev/null) <(echo before error) && exit_code=$? || exit_code=$?
rm $script
test $exit_code -eq 0


echo 'Test that `set` builtin is run instead of shell function'
script="$(mktemp)"
chmod 744 "$script"
echo '#!/usr/bin/env bash' > $script
echo 'set() { echo foo; }' >> $script
echo 'set' >> $script
# Print all but the first line (shebang)
tail -n +2 ~/bash-template/template.sh >> $script
echo 'set' >> $script
diff --brief <($script) <(echo foo; echo foo) > /dev/null && exit_code=$? || exit_code=$?
rm $script
test $exit_code -eq 0

