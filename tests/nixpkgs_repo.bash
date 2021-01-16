setup_file(){
  echo "test,status-provider,time,footprint" >> "$out/timings"
  # set -x
  export TEST_TMP="$(mktemp -d)"
  cp tests/*.{bats,bash} "$TEST_TMP"/ > /dev/null
  mkdir "$TEST_TMP/nixpkgs"
  git clone $NIXPKGS "$TEST_TMP/nixpkgs"
  pushd "$TEST_TMP"
  PATH="$TEST_TMP:$PATH"
  pushd nixpkgs
  git config --local feature.manyFiles true
  git checkout master
  git clean -f
  # git config --local core.fsmonitor $RSGITFSMON
  git config user.email "you@example.com"
  git config user.name "Your Name"
  # echo blah > filec
  # echo blah > filed
  # git add file{c,d}
  # git commit -m "cool stuff"
  # echo hehe >> filed
  # echo hehe > filee
  # git add file{c,d,e}
  # git commit -m "oops"
} &> /dev/null

teardown_file(){
  popd
  # echo $LILGIT $GITSTATUS
  # return 2
  # cp $TEST_TMP/timings $out/timings
}

function __describe_duration()
{
  local d="$1"
  # new version, save time, direct math:
  if   ((d >  3600000000)); then                 # >1   hour
    local m=$(((((d/1000) / 1000) / 60) % 60))
    local h=$((((d/1000) / 1000) / 3600))
    printf "%dh%dm" $h $m
  elif ((d >  60000000)); then                   # >1   minute
    local s=$((((d/1000) / 1000) % 60))
    local m=$(((((d/1000) / 1000) / 60) % 60))
    printf "%dm%ds" $m $s
  elif ((d >= 10000000)); then                   # >=10 seconds
    local ms=$(((d/1000) % 1000))
    local s=$((((d/1000) / 1000) % 60))
    printf "%d.%ds" $s $((ms / 100))
  elif ((d >=  1000000)); then                    # > 1  second
    local ms=$(((d/1000) % 1000))
    local s=$((((d/1000) / 1000) % 60))
    printf "%d.%ds" $s $((ms / 10))
  elif ((d >=  100000)); then                    # > 100  ms
    local ms=$(((d/1000) % 1000))
    printf "%dms" $ms
  elif ((d >=  20000)); then                    # > 20  ms
    local ms=$(((d/1000)))
    # printf "%dms" $ms
    printf "%d.%dms" $ms $((d % 10))
  elif ((d >=  10000)); then                    # > 10  ms
    local ms=$(((d/1000)))
    # printf "%dms" $ms
    printf "%d.%dms" $ms $((d % 100))
  elif ((d >=  1000)); then                    # > 1  ms
    local ms=$(((d/1000)))
    # printf "%dms" $ms
    printf "%d.%dms" $ms $((d % 1000))
  else                                              # < 1  ms (1000 µs)
    printf "%dµs" "$d"
  fi
}

timeit(){
  local result duration end start="${EPOCHREALTIME/.}"
  # bash --norc --noprofile -i "$TEST_TMP/$1"
  # TODO: move the timing into the scripts to avoid measuring
  # the time to run footprint/tail/awk?
  result="$(bash --norc --noprofile -i "$TEST_TMP/$1")"
  end="${EPOCHREALTIME/.}"
  duration=$((end - start))
  echo "'$BATS_TEST_DESCRIPTION',$1,$(__describe_duration $duration),$result" >> "$out/timings"
} # 2>/dev/null # obviously, disable to debug...

timings(){
  echo "----,----,----,----" >> "$out/timings"
  timeit "lilgit.bash"
  timeit "gitstatus.bash"
  timeit "gitparse.bash"
}
