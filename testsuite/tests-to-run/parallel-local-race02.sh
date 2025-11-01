#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# These fail regularly


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

par_totaljob_repl() {
    echo '{##} bug #45841: Replacement string for total no of jobs'

    parallel -k --plus echo {##} ::: {a..j};
    parallel -k 'echo {= $::G++ > 3 and ($_=$Global::JobQueue->total_jobs());=}' ::: {1..10}
    parallel -k -N7 --plus echo {#} {##} ::: {1..14}
    parallel -k -N7 --plus echo {#} {##} ::: {1..15}
    parallel -k -S 8/: -X --plus echo {#} {##} ::: {1..15}
    parallel -k --plus --delay 0.01 -j 10 'sleep 2; echo {0#}/{##}:{0%}' ::: {1..5} ::: {1..4}
}

par_semaphore() {
    echo '### Test if parallel invoked as sem will run parallel --semaphore'
    sem --id as_sem -u -j2 'echo job1a 1; sleep 3; echo job1b 3'
    sleep 0.5
    sem --id as_sem -u -j2 'echo job2a 2; sleep 3; echo job2b 5'
    sleep 0.5
    sem --id as_sem -u -j2 'echo job3a 4; sleep 3; echo job3b 6'
    sem --id as_sem --wait
    echo done
}

par_sql_CSV() {
    echo '### CSV write to the right place'
    rm -rf /tmp/parallel-CSV
    mkdir /tmp/parallel-CSV
    parallel --sqlandworker csv:///%2Ftmp%2Fparallel-CSV/OK echo ::: 'ran OK'
    ls /tmp/parallel-CSV
    stdout parallel --sqlandworker csv:///%2Fmust%2Ffail/fail echo ::: 1 |
	perl -pe 's/\d/0/g'
}

par_PARALLEL_RSYNC_OPTS() {
    echo '### test rsync opts'
    touch parallel_rsync_opts.test
    
    parallel --rsync-opts -rlDzRRRR -vv -S parallel@lo --trc {}.out touch {}.out ::: parallel_rsync_opts.test |
	perl -nE 's/(\S+RRRR)/say $1/ge'
    export PARALLEL_RSYNC_OPTS=-zzzzrldRRRR
    parallel -vv -S parallel@lo --trc {}.out touch {}.out ::: parallel_rsync_opts.test |
	perl -nE 's/(\S+RRRR)/say $1/ge'
    rm parallel_rsync_opts.test parallel_rsync_opts.test.out
    echo
}

par_retries_bug_from_2010() {
    echo '### Bug with --retries'
    seq 1 8 |
	parallel --retries 2 --sshlogin 8/localhost,8/: -j+0 "hostname; false" |
	wc -l
    seq 1 8 |
	parallel --retries 2 --sshlogin 8/localhost,8/: -j+1 "hostname; false" |
	wc -l
    seq 1 2 |
	parallel --retries 2 --sshlogin 8/localhost,8/: -j-1 "hostname; false" |
	wc -l
    seq 1 1 |
	parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false" |
	wc -l
    seq 1 1 |
	parallel --retries 2 --sshlogin 1/localhost,1/: -j9 "hostname; false" |
	wc -l
    seq 1 1 |
	parallel --retries 2 --sshlogin 1/localhost,1/: -j0 "hostname; false" |
	wc -l

    echo '### These were not affected by the bug'
    seq 1 8 |
	parallel --retries 2 --sshlogin 1/localhost,9/: -j-1 "hostname; false" |
	wc -l
    seq 1 8 |
	parallel --retries 2 --sshlogin 8/localhost,8/: -j-1 "hostname; false" |
	wc -l
    seq 1 1 |
	parallel --retries 2 --sshlogin 1/localhost,1/:  "hostname; false" |
	wc -l
    seq 1 4 |
	parallel --retries 2 --sshlogin 2/localhost,2/: -j-1 "hostname; false" |
	wc -l
    seq 1 4 |
	parallel --retries 2 --sshlogin 2/localhost,2/: -j1 "hostname; false" |
	wc -l
    seq 1 4 |
	parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false" |
	wc -l
    seq 1 2 |
	parallel --retries 2 --sshlogin 1/localhost,1/: -j1 "hostname; false" |
	wc -l
}

par_kill_hup() {
    echo '### Are children killed if GNU Parallel receives HUP? There should be no sleep at the end'

    parallel -j 2 -q bash -c 'sleep {} & pid=$!; wait $pid' ::: 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 &
    T=$!
    sleep 3.9
    pstree $$
    kill -HUP $T
    sleep 4
    pstree $$
}

par_resume_failed_k() {
    echo '### bug #38299: --resume-failed -k'
    tmp=$(mktemp)
    parallel -k --resume-failed --joblog "$tmp" echo job{#} val {}\;exit {} ::: 0 1 2 3 0 1
    echo try 2. Gives failing - not 0
    parallel -k --resume-failed --joblog "$tmp" echo job{#} val {}\;exit {} ::: 0 1 2 3 0 1
    echo with exit 0
    parallel -k --resume-failed --joblog "$tmp" echo job{#} val {}\;exit 0  ::: 0 1 2 3 0 1
    sleep 0.5
    echo try 2 again. Gives empty
    parallel -k --resume-failed --joblog "$tmp" echo job{#} val {}\;exit {} ::: 0 1 2 3 0 1
    rm "$tmp"
}

par_testhalt() {
    testhalt_false() {
	echo '### testhalt --halt '$1;
	(yes 0 | head -n 10; seq 10) |
	    stdout parallel -kj4 --delay 0.27 --halt $1 \
		   'echo job {#}; sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    }
    testhalt_true() {
	echo '### testhalt --halt '$1;
	(seq 10; yes 0 | head -n 10) |
	    stdout parallel -kj4 --delay 0.17 --halt $1 \
		   'echo job {#}; sleep {= $_=0.3*($_+1+seq()) =}; exit {}'; echo $?;
    };
    export -f testhalt_false;
    export -f testhalt_true;

    stdout parallel -k --delay 0.11 --tag testhalt_{4} {1},{2}={3} \
	::: now soon ::: fail success done ::: 0 1 2 30% 70% ::: true false |
	# Remove lines that only show up now and then
	perl -ne '/Starting no more jobs./ or print'
}

par__compress_prg_fails() {
    echo "### bug #41609: --compress fails"
    seq 12 | parallel --compress --compress-program gzip -k seq {} 10000 | md5sum
    seq 12 | parallel --compress -k seq {} 10000 | md5sum

    echo '### bug #44546: If --compress-program fails: fail'
    doit() {
	(parallel $* --compress-program false \
		  echo \; sleep 1\; ls ::: /no-existing
	echo $?) | tail -n1
    }
    export -f doit
    stdout parallel --tag -k doit ::: '' --line-buffer ::: '' --tag ::: '' --files |
	grep -v -- -dc
}

export -f $(compgen -A function | grep par_)
compgen -A function | G "$@" | grep par_ | sort |
    #    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
        parallel -o --joblog /tmp/jl-`basename $0` -j1 --tag -k '{} 2>&1'
