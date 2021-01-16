source "$GITSTATUS"

gitstatusd_actionable(){
  gitstatus_query
  local name dirty
  if [[ "$VCS_STATUS_LOCAL_BRANCH" == "" ]]; then
    printf -v name "detached @ %s" "${VCS_STATUS_COMMIT:0:11}"
  else
    name="$VCS_STATUS_LOCAL_BRANCH"
  fi
  if [[ "$VCS_STATUS_COMMITS_AHEAD$VCS_STATUS_COMMITS_BEHIND$VCS_STATUS_HAS_CONFLICTED$VCS_STATUS_HAS_STAGED$VCS_STATUS_HAS_UNSTAGED$VCS_STATUS_PUSH_COMMITS_AHEAD$VCS_STATUS_PUSH_COMMITS_BEHIND" != "0000000" ]]; then
    printf ' \033[0m\033[0;31m%s\033[0m' "$name"
  else
    printf ' %s' "$name"
  fi
} &>/dev/null

gitstatus_start

while (( RUNS > 0 )); do
	gitstatusd_actionable
	((RUNS--))
done
/usr/bin/footprint -p $$ -p gitstatusd | tail -n 2 | awk '{print $1 $2}'
# declare | grep STATUS
gitstatus_stop
