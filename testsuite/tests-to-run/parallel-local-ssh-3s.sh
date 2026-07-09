#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par_sshdelay() {
    echo '### test --sshdelay'
    stdout /usr/bin/time -f %e parallel -j0 --sshdelay 0.5 -S localhost true ::: 1 2 3 |
	perl -ne 'print($_ > 1.30 ? "OK\n" : "Not OK\n")'
}


export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
