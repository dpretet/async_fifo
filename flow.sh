#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
set -e -o pipefail

# Current script path; doesn't support symlink
FIFO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# Bash color codes
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
# Reset
NC='\033[0m'

function printerror {
    echo -e "${Red}ERROR: ${1}${NC}"
}

function printwarning {
    echo -e "${Yellow}WARNING: ${1}${NC}"
}

function printinfo {
    echo -e "${Blue}INFO: ${1}${NC}"
}

function printsuccess {
    echo -e "${Green}SUCCESS: ${1}${NC}"
}

help() {
    echo -e "${Blue}"
    echo ""
    echo "NAME"
    echo ""
    echo "      Async FIFO Flow"
    echo ""
    echo "SYNOPSIS"
    echo ""
    echo "      ./flow.sh -h"
    echo ""
    echo "      ./flow.sh help"
    echo ""
    echo "      ./flow.sh syn"
    echo ""
    echo "      ./flow.sh sim"
    echo ""
    echo "DESCRIPTION"
    echo ""
    echo "      This flow handles the different operations available"
    echo ""
    echo "      ./flow.sh help|-h"
    echo ""
    echo "      Print the help menu"
    echo ""
    echo "      ./flow.sh syn"
    echo ""
    echo "      Launch the synthesis script relying on Yosys"
    echo ""
    echo "      ./flow.sh sim"
    echo -e "${NC}"
}


run_sims() {
	printinfo "Start simulation"
	cd "$FIFO_DIR"/sim
	svutRun -f files.f -test async_fifo_unit_test.sv -sim icarus
	return $?
}

run_syn() {
	printinfo "Start synthesis"
	cd "$FIFO_DIR/syn"
	./syn_asic.sh
	return $?
}


run_lint() {
	set +e

	printinfo "Start lint"
	verilator --lint-only +1800-2017ext+sv \
		-Wall -Wpedantic \
		-Wno-VARHIDDEN \
		-Wno-PINCONNECTEMPTY \
		-Wno-PINMISSING \
		./rtl/async_fifo.v \
		./rtl/fifomem.v \
		./rtl/rptr_empty.v \
		./rtl/sync_r2w.v \
		./rtl/sync_w2r.v \
		./rtl/wptr_full.v \
		--top-module async_fifo 2> lint.log

	set -e

	ec=$(grep -c "%Error:" lint.log)

	if [[ $ec -gt 1 ]]; then
		printerror "Lint failed, check ./lint.log for further details"
		return 1
	else
		printsuccess "Lint ran successfully"
		return 0
	fi

}

check_setup() {

    source script/setup.sh

    if [[ ! $(type iverilog) ]]; then
        printerror "Icarus-Verilog is not installed"
        exit 1
    fi
    if [[ ! $(type verilator) ]]; then
        printerror "Verilator is not installed"
        exit 1
    fi
}


main() {

    echo ""
    printinfo "Start Aync FIFO Flow"

    # If no argument provided, preint help and exit
    if [[ $# -eq 0 ]]; then
        help
        exit 1
    fi

    # Print help
    if [[ $1 == "-h" || $1 == "help" ]]; then
        help
        exit 0
    fi

    if [[ $1 == "lint" ]]; then
		run_lint
		exit $?
    fi

    if [[ $1 == "sim" ]]; then
        check_setup
		run_sims
        exit $?
    fi

    if [[ $1 == "syn" ]]; then
		run_syn
        return $?
    fi
}


main "$@"
