source "$LILGIT"
while (( RUNS > 0 )); do
	__go_on_now_lilgit
	((RUNS--))
done &>/dev/null

/usr/bin/footprint -p $$ -p $COPROC_PID | tail -n 2 | awk '{print $1 $2}'
