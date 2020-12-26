# shellcheck shell=bash
# TODO: eval not necessary, but osh doesn't like
# the coproc syntax, so I'm hiding it from resholve
eval "coproc __lilgitter (lilgitd)"

__go_on_now_lilgit(){
  local dirty name
  # shellcheck disable=SC2154
  echo "$PWD" 1>&"${__lilgitter[1]}"
  read -r -u "${__lilgitter[0]}" is_repo dirty name
  # only print if it's a repo
  if [[ $is_repo == "True" ]]; then
    if [[ $dirty == "True" ]]; then
      printf ' \033[0m\033[0;31m%s\033[0m' "$name"
    else
      printf ' %s' "$name"
    fi
  fi
}

# shellcheck disable=SC2034,SC2016
__lilgit='$(__go_on_now_lilgit)'