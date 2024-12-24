#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Simple jobs that never fails
# Each should be taking 30-100s and be possible to run in parallel
# I.e.: No race conditions, no logins

par__memory_leak() {
    a_run() {
	seq $1 |time -v parallel true 2>&1 |
	grep 'Maximum resident' |
	field 6;
    }
    export -f a_run
    echo "### Test for memory leaks"
    echo "Of 300 runs of 1 job at least one should be bigger than a 3000 job run"
    . env_parallel.bash
    parset small_max,big ::: 'seq 300 | parallel a_run 1 | jq -s max' 'a_run 3000'
    # Perl 5.38.2 has a small leak (~300KB) - not present in 5.2X.X
    # TODO find out which perl version introduces this
    echo "`date` [ $small_max < $big ]" >> /tmp/parallel-mem-leak.out
    if [ $(($small_max+500)) -lt $big ] ; then
	echo "Bad: Memleak likely. [ $small_max < $big ]"
    else
	echo "Good: No memleak detected."
    fi
}
export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | sort |
    parallel --delay 0.3 --timeout 300% -j6 --lb --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
