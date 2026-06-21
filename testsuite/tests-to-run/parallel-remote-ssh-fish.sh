#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par__man_fish() {
    echo '### fish'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    env_parallel --session
    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    # multiline aliases does not work in fish

    function myfunc
      echo functions 'with  = & " !'" '" $argv;
    end
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    set myvar 'variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    set multivar 'multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    set myarray arrays 'with  = & " !'" '" work, too
    echo $myarray[1] $myarray[2] $myarray[3] $myarray[4]
    echo "# these 4 fail often. Race condition?"
    env_parallel -k echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k -S server echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k --env myarray echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k --env myarray -S server echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255 `sleep 1`
_EOF
	    )
    ssh fish@lo "$myscript"
    #| LC_ALL=C sort
}


export -f $(compgen -A function | grep par_)

par__man_fish() {
    echo '### fish'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    env_parallel --session
    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    # multiline aliases does not work in fish

    function myfunc
      echo functions 'with  = & " !'" '" $argv;
    end
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    set myvar 'variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    set multivar 'multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    set myarray arrays 'with  = & " !'" '" work, too
    echo $myarray[1] $myarray[2] $myarray[3] $myarray[4]
    echo "# these 4 fail often. Race condition?"
    env_parallel -k echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k -S server echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k --env myarray echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel -k --env myarray -S server echo '$myarray[{}]' ::: 1 2 3 4
    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255 `sleep 1`
_EOF
	    )
    ssh fish@lo "$myscript"
    #| LC_ALL=C sort
}

compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` --retries 3 -j50% --tag -k '{} 2>&1'
