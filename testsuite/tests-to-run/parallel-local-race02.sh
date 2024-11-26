#!/bin/bash

# SPDX-FileCopyrightText: 2021-2024 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# These fail regularly

env_underscore() {
    echo WHY DOES THIS FAIL?
    echo '### --env _'
    echo ignored_var >> ~/.parallel/ignored_vars
    unset $(compgen -A function | grep par_)
    ignored_var="ERROR IF COPIED"
    export ignored_var
    fUbAr="OK from fubar" parallel -S parallel@lo --env _ echo '$fUbAr $ignored_var' ::: test
    echo 'In csh this may fail with ignored_var: Undefined variable.'
    fUbAr="OK from fubar" parallel -S csh@lo --env _ echo '$fUbAr $ignored_var' ::: test

    echo '### --env _ with explicit mentioning of normally ignored var $ignored_var'
    ignored_var="should be copied"
    fUbAr="OK from fubar" parallel -S parallel@lo --env ignored_var,_ echo '$fUbAr $ignored_var' ::: test
    fUbAr="OK from fubar" parallel -S csh@lo --env ignored_var,_ echo '$fUbAr $ignored_var' ::: test
}
env_underscore

par_hostgroup() {
    echo '### --hostgroup force ncpu - 2x parallel, 6x me'
    parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo \
	     'whoami;sleep 0.4{}' ::: {1..8} | sort

    echo '### --hostgroup two group arg - 2x parallel, 6x me'
    parallel -k --sshdelay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo \
	     'whoami;sleep 0.3{}' ::: {1..8}@g1+g2 | sort

    echo '### --hostgroup one group arg - 8x me'
    parallel --delay 0.2 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo \
	     'whoami;sleep 0.4{}' ::: {1..8}@g2

    echo '### --hostgroup multiple group arg + unused group - 2x parallel, 6x me, 0x tcsh'
    parallel --delay 0.2 --hgrp -S @g1/1/parallel@lo -S @g1/3/lo -S @g3/30/tcsh@lo \
	     'whoami;sleep 0.8{}' ::: {1..8}@g1+g2 2>&1 | sort -u | grep -v Warning

    echo '### --hostgroup two groups @'
    parallel -k --hgrp -S @g1/parallel@lo -S @g2/lo --tag whoami\;echo ::: parallel@g1 tange@g2

    echo '### --hostgroup'
    parallel -k --hostgroup -S @grp1/lo echo ::: no_group explicit_group@grp1 implicit_group@lo

    echo '### --hostgroup --sshlogin with @'
    parallel -k --hostgroups -S parallel@lo echo ::: no_group implicit_group@parallel@lo

    echo '### --hostgroup -S @group - bad if you get parallel@lo'
    parallel -S @g1/ -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo \
	     'whoami;true' ::: {1..6} | sort -u

    echo '### --hostgroup -S @group1 -Sgrp2 - get all twice'
    parallel -S @g1/ -S @g2/ -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo \
	     'whoami;sleep 1;true' ::: {1..6} | sort

    echo '### --hostgroup -S @group1+grp2 - get all twice'
    parallel -S @g1+g2/ -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo \
	     'whoami;sleep 1;true' ::: {1..6} | sort
}

export -f $(compgen -A function | grep par_)
compgen -A function | G "$@" | grep par_ | sort |
    #    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
        parallel -o --joblog /tmp/jl-`basename $0` -j1 --tag -k '{} 2>&1'
