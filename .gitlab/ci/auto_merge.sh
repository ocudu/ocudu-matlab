#!/bin/bash
#
# Copyright 2021-2024 Software Radio Systems Limited
#
# This file is part of srsRAN-matlab.
#
# srsRAN-matlab is free software: you can redistribute it and/or
# modify it under the terms of the BSD 2-Clause License.
#
# srsRAN-matlab is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# BSD 2-Clause License for more details.
#
# A copy of the BSD 2-Clause License can be found in the LICENSE
# file in the top-level directory of this distribution.
#

set -e

main() {
    # Check number of args
    if [ $# != 2 ] && [ $# != 3 ]; then
        echo >&2 "Please call script with source ref and target ref as argument"
        echo >&2 "E.g. ./auto_merge.sh <source_ref> <target_ref> [dryrun]"
        exit 1
    fi

    local source_ref=$1
    local target_ref=$2
    local mode="${3:-push}"

    # Create filtered ref of source ref
    echo "==================="
    echo "= Checkout source ="
    echo "==================="
    git fetch -q origin "$source_ref"
    git checkout -b "filtered_$source_ref" FETCH_HEAD
    echo "===================="
    echo "= Filtering source ="
    echo "===================="
    git filter-repo --refs "filtered_$source_ref" --path .gitlab-ci.yml --path .gitlab/ --path .gitattributes --path-glob "*.tar.gz" --invert-paths --force

    # Checkout target ref and merge
    echo "==================="
    echo "= Checkout target ="
    echo "==================="
    git fetch -q origin "$target_ref"
    git checkout -b "$target_ref" FETCH_HEAD
    echo "========="
    echo "= Merge ="
    echo "========="
    git merge --ff "filtered_$source_ref" -m "Update main"

    # Push
    if [ "$mode" = "push" ]; then
        git push origin "$target_ref"
    fi
}

main "$@"
