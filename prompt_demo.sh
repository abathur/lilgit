echo -e "\nHey, thanks for trying \033[1;34mlilgit\033[0m. Just '\033[1;33mexit\033[0m' when you're done.\n"

source "$LILGITBASH"

# override __lilgit to time each invocation
__lilgit='$(time __go_on_now_lilgit)'

# override 'time' format to just use wall time
TIMEFORMAT="__go_on_now_lilgit  took: %lR"

PS1="__go_on_now_lilgit wrote: '$__lilgit'\n\[\033[1;33m\]\w\[\033[0m\] $ "
