#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par_uninstalled_sshpass() {
    echo '### sshpass must be installed for --sshlogin user:pass@host'
    sshpass=$(command -v sshpass)
    sudo mv "$sshpass" "$sshpass".hidden
    parallel -S user:pass@host echo ::: must fail
    sudo mv "$sshpass".hidden "$sshpass"
}


export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
