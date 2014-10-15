#!/bin/bash

## load function to test
source git-helpers.sh


## tests

test_repo_dir_extraction() {
  local func="_extract_repo_dir"

  local args="http://github.com/example/test.git"
  local expected="test"
  assertArgs

  local args="http://github.com/example/test"
  local expected="test"
  assertArgs

  local args="../path/to/test.git"
  local expected="test"
  assertArgs

  local args="/full/path/to/test"
  local expected="test"
  assertArgs

  local args="git@github.com:menski/test.git"
  local expected="test"
  assertArgs
}

test_target_dir() {
  local func="_get_git_clone_params"

  local args="http://github.com/example/test.git"
  local expected="http://github.com/example/test.git test"
  assertArgs

  args="http://github.com/example/test"
  expected="http://github.com/example/test test"
  assertArgs

  args="http://github.com/example/other test"
  expected="http://github.com/example/other test"
  assertArgs

  args="http://github.com/example/other test/"
  expected="http://github.com/example/other test/other"
  assertArgs

  args="http://github.com/example/other test/an"
  expected="http://github.com/example/other test/an"
  assertArgs

  args="http://github.com/example/other test/an/"
  expected="http://github.com/example/other test/an/other"
  assertArgs
}

test_generate_git_clone_params() {
  local func="_generate_git_clone_params"

  input="http://github.com/example/test.git"
  expected="http://github.com/example/test.git test"
  assertInput

  input="a b\nc\nd e/\nf g/h"
  expected="a b\nc c\nd e/d\nf g/h"
  assertInput

  writeTestFile "$input"
  assertInput

  input="# comment"
  expected=""
  assertInput

  input=""
  expected=""
  assertInput

  input="#a\n\n \nb\n\t \n#c"
  expected="b b"
  assertInput

  input="a\n# comment\nb"
  expected="a a\nb b"
  assertInput
}

test_gclone() {
  # setup
  local test_dir=$SHUNIT_TMPDIR/gclone-test
  mkdir -p "$test_dir"
  cp example-gclone.txt $test_dir
  cd $test_dir

  # execute method
  assertTrue 'gclone example-gclone.txt'

  # test result
  assertTrue '[ -d git-helper ]'
  assertTrue '[ -f git-helper/.git/HEAD ]'
  assertTrue '[ -d helper ]'
  assertTrue '[ -f helper/.git/HEAD ]'
  assertTrue '[ -d my/git-helper ]'
  assertTrue '[ -f my/git-helper/.git/HEAD ]'

  # return to original directory
  cd -
}


## test helpers

assertActual() {
  expected=$(echo -e "$expected")
  assertEquals "$expected" "$actual"
}

assertArgs() {
  local actual=$($func $args)
  assertActual
}

assertInput() {
  local actual
  if [ -f "$input" ]; then
    actual=$($func < $input)
  else
    actual=$(echo -e $input | $func)
  fi
  assertActual
}

writeTestFile() {
  input=$SHUNIT_TMPDIR/test.txt
  echo -e "$1" > $input
}


## execute tests
. /usr/bin/shunit2
