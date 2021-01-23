# shellcheck shell=bash

# osh doesn't like the named coproc syntax, but I don't want
# this to break if someone's using a coproc? I think maybe
# copying the FDs over to our own var is a fine compromise
coproc lilgitd
declare -a __lilgitter=("${COPROC[@]}")

__go_on_now_lilgit(){
  local dirty name

  echo "$PWD" 1>&"${__lilgitter[1]}"
  read -r -u "${__lilgitter[0]}" is_repo dirty name
  # only print if it's a repo
  if [[ $is_repo == "true" ]]; then
    if [[ $dirty == "true" ]]; then
      printf ' \033[0m\033[0;31m%s\033[0m' "$name"
    else
      printf ' %s' "$name"
    fi
  fi
}

# shellcheck disable=SC2034,SC2016
__lilgit='$(__go_on_now_lilgit)'
