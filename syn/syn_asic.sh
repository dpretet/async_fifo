#!/usr/bin/env bash

set -euo pipefail

SYN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
target="${1:-async_fifo}"

case "$target" in
    async_fifo|async_bidir_fifo|async_bidir_ramif_fifo)
        design_dir="$SYN_DIR/$target"
        ;;
    *)
        echo "Unknown synthesis target: $target" >&2
        echo "Choose async_fifo, async_bidir_fifo, or async_bidir_ramif_fifo." >&2
        exit 2
        ;;
esac

if [[ ! -f "$design_dir/fifo.ys" ]]; then
    echo "Missing Yosys script: $design_dir/fifo.ys" >&2
    exit 1
fi

cd "$design_dir"
echo "INFO: Start Yosys synthesis for $target"
yosys -V
yosys fifo.ys
