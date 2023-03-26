#!/usr/bin/env bash

# get current script path (applicable even if is a symlink)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if [[ ! $(type svutRun) ]];
then
    svut_dir="$DIR/.svut"
    if [[ ! -d $svut_dir ]]; then
        echo "INFO: Install SVUT (https://github.com/dpretet/svut)"
        git clone "https://github.com/dpretet/svut.git" "$svut_dir"
    fi
    echo "INFO: Enable SVUT in PATH"
    export PATH=$svut_dir/:$PATH
fi
