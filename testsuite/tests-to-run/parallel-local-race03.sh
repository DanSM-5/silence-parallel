#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# These fail regularly if run in parallel
# If they fail: Move them to race02.sh

ctrlz_should_suspend_children() {
    echo 'bug #46120: Suspend should suspend (at least local) children'
    echo 'it should burn 1.9 CPU seconds, but no more than that'
    echo 'The 5 second sleep will make it be killed by timeout when it fgs'

    run() {
	cmd="$1"
	sleep="$2"
	error="$3"
	input_source_pipe() {
	    echo 1 | stdout /usr/bin/time -f CPUTIME=%U parallel --timeout 5 -q perl -e "while(1){ }" | \grep -q CPUTIME=1
	}
	input_source_cmdline() {
	    stdout /usr/bin/time -f CPUTIME=%U parallel --timeout 5 -q perl -e "while(1){ }" ::: 1 | \grep -q CPUTIME=1
	}
	# $cmd is input_source_pipe or input_source_cmdline
	$cmd &
	echo $cmd
	sleep $sleep
	kill -TSTP -$!
	sleep 5
	fg
	echo $error $?
    }    
    export -f run
    clean() {
	grep -v '\[1\]' | grep -v 'SHA256'
    }
    
    stdout bash -i -c 'run input_source_pipe 1.9 Zero=OK' | clean
    stdout bash -i -c 'run input_source_cmdline 1.9 Zero=OK' | clean
    echo "Control case: This should run 2.9 seconds"
    stdout bash -i -c 'run input_source_cmdline 2.9 1=OK' | clean
}
ctrlz_should_suspend_children

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

par_change_content_--jobs_filename() {
    echo '### Test of -j filename with file content changing (missing -k is correct)'
    echo 1 >/tmp/jobs_to_run2
    (sleep 3; echo 10 >/tmp/jobs_to_run2) &
    parallel -j /tmp/jobs_to_run2 -v sleep {} ::: 3.3 2.{1..5} 0.{1..7}
}

par_nonall_u() {
    SSHLOGIN1=vagrant@parallel-server1
    SSHLOGIN2=vagrant@parallel-server2
    echo '### Test --nonall -u - should be interleaved x y x y'
    parallel --nonall --sshdelay 2 -S $SSHLOGIN1,$SSHLOGIN2 -u \
	     'hostname|grep -q rhel && sleep 2; hostname;sleep 4;hostname;' |
	uniq -c | sort
}

par_more_than_9_relative_sshlogin() {
    echo '### Check more than 9(relative) simultaneous sshlogins'
    seq 1 11 | stdout parallel -k -j10000% -S "ssh vagrant@freebsd13" echo |
	grep -v 'parallel: Warning:'
}

par_continuous_output() {
    # After the first batch, each jobs should output when it finishes.
    # Old versions delayed output by $jobslots jobs
    doit() {
	echo "Test delayed output with '$1'"
	echo "-u is optimal but hard to reach, due to non-mixing"
	seq 11 |
	    parallel -j1 $1 --delay 1.5 -N0 echo |
	    parallel -j4 $1 -N0 'sleep 0.2;date' |
	    timestamp -dd |
	    perl -pe 's/(.).*/$1/' |
	    # The first number is flaky: Skip it
	    tail -n +2
    }
    export -f doit
    parallel -k doit ::: '' -u
}

export -f $(compgen -A function | grep par_)
compgen -A function | G "$@" | grep par_ | sort |
    #    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
        parallel -o --joblog /tmp/jl-`basename $0` -j1 --tag -k '{} 2>&1'
