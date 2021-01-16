parse_git_actionable() {
  # shellcheck disable=SC2155
  local status="$(git status 2> /dev/null)"
  # shellcheck disable=SC2155
  local branch="$(head -n1 <<< "$status" | grep -oE '\S+$')"
  if grep "detached" <<< "$status" &>/dev/null; then
    branch="detached @ $branch"
  fi

  if grep -F -e ahead -e behind -e diverged -e Changes <<< "$status" &>/dev/null; then
    printf ' \033[0m\033[0;31m%s\033[0m' "$branch"
  else
    printf ' %s' "$branch"
  fi
} &>/dev/null

while (( RUNS > 0 )); do
  parse_git_actionable
  ((RUNS--))
done

# we're slightly over-reporting; footprint
# will include itself here
/usr/bin/footprint -t -p $$ | tail -n 2 | awk '{print $1 $2}'
