#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par_controlmaster_is_faster() {
    echo '### bug #41964: --controlmaster not seems to reuse OpenSSH connections to the same host'
    echo '-M should finish first - eventhough there are 2x jobs'
    export SSHLOGIN1=sh@lo
    nl="$(printf "\n\n.")"
    export TMPDIR="/tmp/ctrl_master/$nl'$nl"
    mkdir -p "$TMPDIR"
    (parallel -S $SSHLOGIN1 true ::: {1..20};
     echo No --controlmaster - finish last) &
    (parallel -M -S $SSHLOGIN1 true ::: {1..40};
     echo With --controlmaster - finish first) &
    wait
    rm -r "/tmp/ctrl_master"
}

export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
