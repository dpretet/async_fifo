#!/usr/bin/env bash

set -euo pipefail

SIM_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOG_FILE="${LOG_FILE:-svut.log}"

usage() {
    cat <<'EOF'
Usage: ./run.sh test|clean

Commands:
  test   Run directed, basic-FIFO, and bidirectional random suites.
  clean  Remove simulation waveforms, executables, and the test log.

Set LOG_FILE to override the default log path (relative paths are under sim/).
EOF
}

run_test() {
    local label="$1"
    shift

    printf 'Running: %s\n' "$label"
    printf '=== %s ===\n' "$label" >> "$LOG_FILE"
    "$@" >> "$LOG_FILE" 2>&1
}

run_tests() {
    local command_failed=0

    : > "$LOG_FILE"

    run_test "Directed tests" \
        svutRun -f files.f -t ./async_fifo_directed_unit_test.sv || command_failed=1
    run_test "Random test: write clock 1ns, read clock 2ns" \
        svutRun -f files.f -t ./async_fifo_random_unit_test.sv \
            -define "CLK_I=1;CLK_O=2" || command_failed=1
    run_test "Random test: write clock 2ns, read clock 1ns" \
        svutRun -f files.f -t ./async_fifo_random_unit_test.sv \
            -define "CLK_I=2;CLK_O=1" || command_failed=1
    run_test "Random test: write and read clocks 4ns" \
        svutRun -f files.f -t ./async_fifo_random_unit_test.sv \
            -define "CLK_I=4;CLK_O=4" || command_failed=1
    run_test "Bidirectional random: A clock 1ns, B clock 2ns" \
        svutRun -f bidir_files.f -t ./async_bidir_fifo_random_unit_test.sv \
            -define "CLK_A=1;CLK_B=2" || command_failed=1
    run_test "Bidirectional random: A clock 2ns, B clock 1ns" \
        svutRun -f bidir_files.f -t ./async_bidir_fifo_random_unit_test.sv \
            -define "CLK_A=2;CLK_B=1" || command_failed=1
    run_test "Bidirectional random: A and B clocks 4ns" \
        svutRun -f bidir_files.f -t ./async_bidir_fifo_random_unit_test.sv \
            -define "CLK_A=4;CLK_B=4" || command_failed=1
    run_test "External-RAM bidirectional random: A clock 1ns, B clock 2ns" \
        svutRun -f bidir_ramif_files.f -t ./async_bidir_ramif_fifo_random_unit_test.sv \
            -define "CLK_A=1;CLK_B=2" || command_failed=1
    run_test "External-RAM bidirectional random: A clock 2ns, B clock 1ns" \
        svutRun -f bidir_ramif_files.f -t ./async_bidir_ramif_fifo_random_unit_test.sv \
            -define "CLK_A=2;CLK_B=1" || command_failed=1
    run_test "External-RAM bidirectional random: A and B clocks 4ns" \
        svutRun -f bidir_ramif_files.f -t ./async_bidir_ramif_fifo_random_unit_test.sv \
            -define "CLK_A=4;CLK_B=4" || command_failed=1

    if (( command_failed )) || grep -Eiq 'ERROR:|FAILURE:|FATAL:|error:' "$LOG_FILE"; then
        printf 'FAIL: simulation reported an error (see %s)\n' "$LOG_FILE"
        cat "$LOG_FILE"
        return 1
    fi

    printf 'SUCCESS: all simulations passed (log: %s)\n' "$LOG_FILE"
}

clean() {
    rm -f ./*.vcd ./*.lxt* ./*.vvp* ./*.out "$LOG_FILE"
    printf 'SUCCESS: simulation artifacts and log removed\n'
}

if [[ $# -ne 1 ]]; then
    usage >&2
    exit 2
fi

cd "$SIM_DIR"
case "$1" in
    test)
        run_tests
        ;;
    clean)
        clean
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
