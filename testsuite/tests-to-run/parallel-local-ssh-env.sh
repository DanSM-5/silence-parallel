#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par_space() {
    echo '### Test --env  - https://savannah.gnu.org/bugs/?37351'
    export TWOSPACES='  2  spaces  '
    export THREESPACES=" >  My brother's 12\" records  < "
    echo a"$TWOSPACES"b 1
    stdout parallel --env TWOSPACES echo 'a"$TWOSPACES"b' ::: 1
    stdout parallel -S localhost --env TWOSPACES echo 'a"$TWOSPACES"b' ::: 1
    stdout parallel -S csh@localhost --env TWOSPACES echo 'a"$TWOSPACES"b' ::: 1
    stdout parallel -S tcsh@localhost --env TWOSPACES echo 'a"$TWOSPACES"b' ::: 1

    echo a"$TWOSPACES"b a"$THREESPACES"b 2
    stdout parallel --env TWOSPACES --env THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 2
    stdout parallel -S localhost --env TWOSPACES --env THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 2
    stdout parallel -S csh@localhost --env TWOSPACES --env THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 2
    stdout parallel -S tcsh@localhost --env TWOSPACES --env THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 2

    echo a"$TWOSPACES"b a"$THREESPACES"b 3
    stdout parallel --env TWOSPACES,THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 3
    stdout parallel -S localhost --env TWOSPACES,THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 3
    stdout parallel -S csh@localhost --env TWOSPACES,THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 3
    stdout parallel -S tcsh@localhost --env TWOSPACES,THREESPACES echo 'a"$TWOSPACES"b' 'a"$THREESPACES"b' ::: 3
}


par_space_quote() {
    export MIN="  \'\""
    echo a"$MIN"b 4
    stdout parallel --env MIN echo 'a"$MIN"b' ::: 4
    stdout parallel -S localhost --env MIN echo 'a"$MIN"b' ::: 4
    stdout parallel -S csh@localhost --env MIN echo 'a"$MIN"b' ::: 4
    stdout parallel -S tcsh@localhost --env MIN echo 'a"$MIN"b' ::: 4
}


export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j300% --tag -k '{} 2>&1'
