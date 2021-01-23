setup_file(){
  TEST_TMP="$(mktemp -d)"
  cp tests/*.{bats,bash} "$TEST_TMP"/
  pushd "$TEST_TMP"
  PATH="$TEST_TMP:$PATH"
  mkdir a b
  pushd a
  git init
  git config user.email "you@example.com"
  git config user.name "Your Name"
  echo blah > filec
  echo blah > filed
  git add file{c,d}
  git commit -m "cool stuff"
  echo hehe >> filed
  echo hehe > default.nix
  git add file{c,d} default.nix
  git commit -m "oops"
  popd
  git clone a b
  pushd b
  git config user.email "you@example.com"
  git config user.name "Your Name"
} > /dev/null

teardown_file(){
  popd
  popd
}
