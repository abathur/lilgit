@test "${RUNS:-1}x clean @ master" {
  git checkout master
	clean "master"
}

@test "${RUNS:-1}x clean @ detached" {
	local target=$(git rev-parse --short=11 HEAD~1)
	git checkout $target
  clean "detached @ $target"
}

@test "${RUNS:-1}x clean @ new branch" {
  git checkout master
	git checkout -b yeehaw
  clean "yeehaw"
}

@test "${RUNS:-1}x dirty after rm" {
  rm default.nix
  dirty "yeehaw"
}

@test "${RUNS:-1}x clean after reset --hard" {
  git reset --hard HEAD
  clean "yeehaw"
}

@test "${RUNS:-1}x dirty after append" {
  echo aha >> default.nix
  dirty "yeehaw"
}

@test "${RUNS:-1}x dirty after stage" {
  git add default.nix
  dirty "yeehaw"
}

@test "${RUNS:-1}x clean after commit" {
  git commit -m "heh"
  clean "yeehaw"
}

@test "${RUNS:-1}x dirty after reset --soft w/o upstream" {
  git reset --soft HEAD~1
  dirty "yeehaw"
}

@test "${RUNS:-1}x clean after reset --hard w/o upstream" {
  git reset --hard HEAD
  clean "yeehaw"
}

@test "${RUNS:-1}x dirty after reset --soft w/ upstream" {
  git checkout master
  git reset --soft HEAD~1
  dirty "master"
}

@test "${RUNS:-1}x dirty after reset --hard w/ upstream" {
  # TODO: working around some kind of race condition?
  # test if it can be removed at the end...
  # until git reset --hard HEAD; do
  #   :
  # done
  git reset --hard HEAD
  dirty "master"
}
