load helpers
load minimal_repo

@test "unmodified nixpkgs" {
	clean "master"
}

@test "detached nixpkgs" {
	local target=$(git rev-parse --short=11 HEAD~1)
	git checkout $target
  clean "detached @ $target"
}

@test "new branch" {
  git checkout master
	git checkout -b yeehaw
  clean "yeehaw"
}

@test "modified nixpkgs" {
  rm filed
  dirty "yeehaw"
}

@test "reset to discard changes" {
  git reset --hard HEAD
  clean "yeehaw"
}

@test "append to file" {
  echo aha >> filec
  dirty "yeehaw"
}

@test "stage change" {
  git add filec
  dirty "yeehaw"
}

@test "commit" {
  git commit -m "heh"
  clean "yeehaw"
}

@test "undo commits on branch w/o upstream" {
  git reset --soft HEAD~1
  dirty "yeehaw"
}

@test "clear staged changes on branch w/o upsteram" {
  git reset --hard HEAD
  clean "yeehaw"
}

@test "undo commits on branch w/ upstream" {
  git checkout master
  git reset --soft HEAD~1
  dirty "master"
}

@test "clear staged changes on branch w/ upstream" {
  git reset --hard HEAD
  dirty "master"
}
