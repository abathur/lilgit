# setup() {
#     {
#         TEST_TMP="$(mktemp -d)"
#         cp tests/*.{bats,bash,sh} "$TEST_TMP"/ > /dev/null
#         pushd "$TEST_TMP"
#     } > /dev/null
# }
# teardown() {
#     {
#         popd > /dev/null
#     } > /dev/null
# }

# status <num>
_expect_status() {
    if [[ $status != "$1" ]]; then
        return 1
    fi
}

# line (-)<num> equals|contains|begins|ends|!equals|!contains|!begins|!ends "value"
# CAUTION: one gotcha; blank lines not included; you have to
# adjust down for each one
_expect_line() {
    if [[ $1 -lt 0 ]]; then
        let lineno=$1
    else
        # adjust to 0-index
        let lineno=$1-1 || true # 1-0 causes let to return 1
    fi

    local line=${lines[$lineno]} kind=$2
    case $kind in
        equals)
            if [[ $line == "$3" ]]; then
                return 0
            else
                echo "  expected line $1:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        contains)
            if [[ $line == *"$3"* ]]; then
                return 0
            else
                echo "  expected line $1:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        begins)
            if [[ $line == "$3"* ]]; then
                return 0
            else
                echo "  expected line $1 to begin with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
        ends)
            if [[ $line == *"$3" ]]; then
                return 0
            else
                echo "  expected line $1 to end with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
        !equals)
            if [[ $line != "$3" ]]; then
                return 0
            else
                echo "  expected line $1:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        !contains)
            if [[ $line != *"$3"* ]]; then
                return 0
            else
                echo "  expected line $1:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        !begins)
            if [[ $line != "$3"* ]]; then
                return 0
            else
                echo "  expected line $1 to begin with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
        !ends)
            if [[ $line != *"$3" ]]; then
                return 0
            else
                echo "  expected line $1 to end with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
    esac
    # shouldn't get here
    echo "unexpected input: $@"
    return 2
}

timings(){
    : no timing in default mode for tests
}

clean() {
    timings
    source ${LILGIT:-lilgit.bash} 3>&-
    run __go_on_now_lilgit

    run _expect_line 0 "equals" " $1"

    printf "status: %s\n" $status
    printf "output:\n%s" "$output"

    echo ""
    echo "expected: $1"
    return $status
}

dirty() {
    timings
    source ${LILGIT:-lilgit.bash} 3>&-
    local expect
    printf -v expect $' \E[0m\E[0;31m%s\E[0m' "$1"
    run __go_on_now_lilgit

    run _expect_line 0 "equals" "$expect"

    printf "status: %s\n" $status
    printf "output:\n%s" "$output"

    echo ""
    echo "expected: $expect"
    return $status
}
