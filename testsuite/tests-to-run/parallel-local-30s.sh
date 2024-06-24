#!/bin/bash

# SPDX-FileCopyrightText: 2021-2024 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Simple jobs that never fails
# Each should be taking 30-100s and be possible to run in parallel
# I.e.: No race conditions, no logins

par__print_in_blocks() {
    echo '### bug #41565: Print happens in blocks - not after each job complete'
    median() { perl -e '@a=sort {$a<=>$b} <>;print $a[$#a/2]';}
    export -f median

    echo 'The timing here is important: a full second between each'
    perl -e 'for(1..30){print("$_\n");`sleep 1`}' |
	parallel -j3  'echo {#}' |
	timestamp -dd |
	perl -pe '$_=int($_+0.3)."\n"' |
	median
    echo '300 ms jobs:'
    perl -e 'for(1..30){print("$_\n");`sleep .3`}' |
	parallel -j3 --delay 0.3 echo |
	timestamp -d -d |
	perl -pe 's/(.....).*/int($1*10+0.2)/e' |
	median
}

par__keeporder_roundrobin() {
    echo 'bug #50081: --keep-order --round-robin should give predictable results'
    . `which env_parallel.bash`

    run_roundrobin() {
	random1G() {
	    < /dev/zero openssl enc -aes-128-ctr -K 1234 -iv 1234 2>/dev/null |
		head -c 1G;
	}
        random1G |
	    parallel $1 -j13 --block 1m --pipe --roundrobin 'echo {#} $(md5sum)' |
	    sort
    }
    env_parset a,b,c run_roundrobin ::: -k -k ''

    if [ "$a" == "$b" ] ; then
	# Good: -k should be == -k
	if [ "$a" == "$c" ] ; then
	    # Bad: without -k the command should give different output
	    echo 'Broken: a == c'
	    printf "$a\n$b\n$c\n"
	else
	    echo OK
	fi
    else
	echo 'Broken: a <> b'
	printf "$a\n$b\n$c\n"
    fi
}

par_retries_lb_jl() {
    echo Broken in 20240522
    tmp=$(mktemp)
    export tmp
    parallel-20240522 --lb --jl /dev/null --timeout 0.3 --retries 5 'echo should be 5 lines >> "$tmp";sleep {}' ::: 20
    cat "$tmp"
    > "$tmp"
    parallel --lb --jl /dev/null --timeout 0.3 --retries 5 'echo 5 lines >> "$tmp";sleep {}' ::: 20
    cat "$tmp"
    rm "$tmp"
}

par_reload_slf_every_second() {
    echo "### --slf should reload every second"
    tmp=$(mktemp)
    echo 1/lo >"$tmp"
    (
	sleep 3
	(echo 1/localhost
	 echo 1/127.0.0.1) >>"$tmp"
    ) &
    # This used to take 40 seconds (version 20220322) because the
    # updated --slf would only read after first job finished
    seq 3 |
	stdout /usr/bin/time -f %e parallel --slf "$tmp" 'true {};sleep 20' |
        perl -ne 'print(($_ < 40) ? "OK\n" : "Too slow: $_\n")'
    rm "$tmp"
}

par__groupby_big() {
    echo "### test --group-by on file bigger than block"
    groupcol() {
	export groupcol=$1
	export n=$2
	export sorted=$(mktemp)
	# Sort on grouping column
	parsort -k${groupcol}n "$testfile" > "$sorted"
	headtail() { (head -n1;tail -n1); }
	export -f headtail
	# wrapper functions for -v below to give headers in output
	_ppart() { headtail; }
	export -f _ppart
	_pipe() { headtail; }
	export -f _pipe
	pipepart() {
	    parallel -j8 $n -k --groupby $groupcol --colsep ' ' -v \
		     --pipepart -a "$sorted" _ppart
	}
	pipe() {
	    parallel -j8 $n -k --groupby $groupcol --colsep ' ' -v \
		     < "$sorted" _pipe
	}
	export -f pipepart pipe
	. $(which env_parallel.bash)
	# Do the same with --pipe and --pipepart
	parset a,b -k ::: pipe pipepart
	paste <(echo "$a") <(echo "$b")
	rm "$sorted"
    }
    export -f groupcol

    export testfile=$(mktemp)
    # 3 columns: 1..10, 1..100, 1..14
    seq 1 1000000 |
	awk '{print int(10*rand()),int(100*rand()),int(14*rand())}' > "$testfile"

    echo "--group-by on col 1..3, -n1..5"
    echo "_pipe and _ppart (pipepart) must return the same"
    parallel -k --tag groupcol ::: 1 2 3 ::: '' -n1 -n2 -n3 -n4 -n5
    rm "$testfile"
}

par_test_diff_roundrobin_k() {
    echo '### test there is difference on -k'
    . $(which env_parallel.bash)
    mytest() {
	K=$1
	doit() {
	    # Sleep random time ever 1k line
	    # to mix up which process gets the next block
	    perl -ne '$t++ % 1000 or select(undef, undef, undef, rand()/10);print' |
		md5sum
	}
	export -f doit
	seq 1000000 |
	    parallel --block 65K --pipe $K --roundrobin doit |
	    sort
    }
    export -f mytest
    parset a,b,c mytest ::: -k -k ''
    # a == b and a != c or error
    if [ "$a" == "$b" ]; then
	if [ "$a" != "$c" ]; then
	    echo OK
	else
	    echo error a c
	fi
    else
	echo error a b
    fi
}

par_bin() {
    echo '### Test --bin'
    seq 10 | parallel --pipe --bin 1 -j4 wc | sort
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin 2 -j4 wc | sort
    echo '### Test --bin with expression that gives 1..n'
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin '2 $_=$_%2+1' -j4 wc | sort
    echo '### Test --bin with expression that gives 0..n-1'
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin '2 $_%=2' -j4 wc | sort
    echo '### Blocks in version 20220122'
    echo 10 | parallel --pipe --bin 1 -j100% cat | sort
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin 2 cat | sort
}

par_perlexpr_repl() {
    echo '### {= and =} in different groups separated by space'
    parallel echo {= s/a/b/ =} ::: a
    parallel echo {= s/a/b/=} ::: a
    parallel echo {= s/a/b/=}{= s/a/b/=} ::: a
    parallel echo {= s/a/b/=}{=s/a/b/=} ::: a
    parallel echo {= s/a/b/=}{= {= s/a/b/=} ::: a
    parallel echo {= s/a/b/=}{={=s/a/b/=} ::: a
    parallel echo {= s/a/b/ =} {={==} ::: a
    parallel echo {={= =} ::: a
    parallel echo {= {= =} ::: a
    parallel echo {= {= =} =} ::: a

    echo '### bug #45842: Do not evaluate {= =} twice'
    parallel -k echo '{=  $_=++$::G =}' ::: {1001..1004}
    parallel -k echo '{=1 $_=++$::G =}' ::: {1001..1004}
    parallel -k echo '{=  $_=++$::G =}' ::: {1001..1004} ::: {a..c}
    parallel -k echo '{=1 $_=++$::G =}' ::: {1001..1004} ::: {a..c}

    echo '### bug #45939: {2} in {= =} fails'
    parallel echo '{= s/O{2}//=}' ::: OOOK
    parallel echo '{2}-{=1 s/O{2}//=}' ::: OOOK ::: OK
    true Dummy for emacs =}}}}}
}

par_shard() {
    echo '### --shard'
    # Each of the 5 lines should match:
    #   ##### ##### ######
    seq 100000 | parallel --pipe --shard 1 -j5  wc |
	perl -pe 's/(.*\d{5,}){3}/OK/'
    # Data should be sharded to all processes
    shard_on_col() {
	col=$1
	seq 10 99 | shuf | perl -pe 's/(.)/$1\t/g' |
	    parallel --pipe --shard $col -j2 --colsep "\t" sort -k$col |
	    field $col | sort | uniq -c
    }
    shard_on_col 1
    shard_on_col 2

    echo '### --shard'
    shard_on_col_name() {
	colname=$1
	col=$2
	(echo AB; seq 10 99 | shuf) | perl -pe 's/(.)/$1\t/g' |
	    parallel --header : --pipe --shard $colname -j2 --colsep "\t" sort -k$col |
	    field $col | sort | uniq -c
    }
    shard_on_col_name A 1
    shard_on_col_name B 2

    echo '### --shard'
    shard_on_col_expr() {
	colexpr="$1"
	col=$2
	(seq 10 99 | shuf) | perl -pe 's/(.)/$1\t/g' |
	    parallel --pipe --shard "$colexpr" -j2 --colsep "\t" "sort -k$col; echo c1 c2" |
	    field $col | sort | uniq -c
    }
    shard_on_col_expr '1 $_%=3' 1
    shard_on_col_expr '2 $_%=3' 2

    shard_on_col_name_expr() {
	colexpr="$1"
	col=$2
	(echo AB; seq 10 99 | shuf) | perl -pe 's/(.)/$1\t/g' |
	    parallel --header : --pipe --shard "$colexpr" -j2 --colsep "\t" "sort -k$col; echo c1 c2" |
	    field $col | sort | uniq -c
    }
    shard_on_col_name_expr 'A $_%=3' 1
    shard_on_col_name_expr 'B $_%=3' 2
    
    echo '*** broken'
    # Should be shorthand for --pipe -j+0
    #seq 200000 | parallel --pipe --shard 1 wc |
    #	perl -pe 's/(.*\d{5,}){3}/OK/'
    # Combine with arguments (should compute -j10 given args)
    seq 200000 | parallel --pipe --shard 1 echo {}\;wc ::: {1..5} ::: a b |
	perl -pe 's/(.*\d{5,}){3}/OK/'
}

par_exit_code() {
    echo 'bug #52207: Exit status 0 when child job is killed, even with "now,fail=1"'
    in_shell_run_command() {
	# Runs command in given shell via Perl's open3
	shell="$1"
	prg="$2"
	perl -MIPC::Open3 -e 'open3($a,$b,$c,"'$shell'","-c","'"$prg"'"); wait; print $?>>8,"\n"'
    }
    export -f in_shell_run_command

    runit() {
	doit() {
	    s=100
	    rm -f /tmp/mysleep
	    cp /bin/sleep /tmp/mysleep
	    
	    parallel -kj500% --argsep ,, --tag in_shell_run_command {1} {2} \
		     ,, "$@" ,, \
		     "/tmp/mysleep "$s \
		     "parallel --halt-on-error now,fail=1 /tmp/mysleep ::: "$s \
		     "parallel --halt-on-error now,done=1 /tmp/mysleep ::: "$s \
		     "parallel --halt-on-error now,done=1 /bin/true ::: "$s \
		     "parallel --halt-on-error now,done=1 exit ::: "$s \
		     "true;/tmp/mysleep "$s \
		     "parallel --halt-on-error now,fail=1 'true;/tmp/mysleep' ::: "$s \
		     "parallel --halt-on-error now,done=1 'true;/tmp/mysleep' ::: "$s \
		     "parallel --halt-on-error now,done=1 'true;/bin/true' ::: "$s \
		     "parallel --halt-on-error now,done=1 'true;exit' ::: "$s
	}
	echo '# Ideally the command should return the same'
	echo '#   with or without parallel'
	# These give the same exit code prepended with 'true;' or not
	OK="ash csh dash fish fizsh ksh2020 posh rc sash sh tcsh"
	# These do not give the same exit code prepended with 'true;' or not
	BAD="bash ksh93 mksh static-sh yash zsh"
	doit $OK $BAD
	# fdsh does not like weird TMPDIR with \n
	BROKEN="fdsh"
	TMPDIR=/tmp
	cd /tmp
	doit $BROKEN
    }
    export -f runit

    killsleep() {
	sleep 5
	while true; do killall -9 mysleep 2>/dev/null; sleep 1; done
    }
    export -f killsleep

    parallel -uj0 --halt now,done=1 ::: runit killsleep
}

par_internal_quote_char() {
    echo '### See if \257\256 \257<\257> is replaced correctly'
    echo '### See if \177\176 \177<\177> is replaced correctly'
    print_it() {
	parallel $2 ::: "echo $1"
	parallel $2 echo ::: "$1"
	parallel $2 echo "$1" ::: "$1"
	parallel $2 echo \""$1"\" ::: "$1"
	parallel $2 echo "$1"{} ::: "$1"
	parallel $2 echo \""$1"\"{} ::: "$1"
    }
    export -f print_it
    a257="$(printf "\257")"
    a256="$(printf "\256")"
    a177="$(printf "\177")"
    a176="$(printf "\176")"
    stdout parallel --tag -k print_it \
	     ::: "$a257" "$a177" "$a257$a256" "$a177$a176" \
	     "$a257$a257$a256" "$a177$a177$a176" \
	     "$a257<$a257<$a257>$a257" "$a177<$a177<$a177>$a177" \
	     ::: -X -q -Xq -k |
	# Upgrade old bash error to new bash error
	perl -pe 's/No such file or directory/Invalid or incomplete multibyte or wide character/g'
    # Bug in Perl's SQL::CSV module cannot handle dir with \n
    TMPDIR=/tmp
    TMPDIR=$(mktemp -d)
    cd "$TMPDIR"
    echo "Compare old quote char csv"
    parallel-20231222 --sqlmaster csv:///./oldformat.csv echo "$(printf "\257\257 \177\177")" ::: 1 2 3
    stdout parallel -k --sqlworker csv:///./oldformat.csv echo "$(printf "\257\257 \177\177")" ::: 1 2 3 |
	od -t x1z > old.out
    echo "with new quote char csv (must be the same)"
    parallel --sqlmaster csv:///./newformat.csv echo "$(printf "\257\257 \177\177")" ::: 1 2 3
    stdout parallel -k --sqlworker csv:///./newformat.csv echo "$(printf "\257\257 \177\177")" ::: 1 2 3 |
	od -t x1z > new.out
    diff old.out new.out && echo OK
    rm -f old.out new.out oldformat.csv newformat.csv
    rmdir "$TMPDIR"
}

par_groupby() {
    tsv() {
	printf "%s\t" a1 b1 C1; echo
	printf "%s\t" 2 2 2; echo
	printf "%s\t" 3 2 2; echo
	printf "%s\t" 3 3 2; echo
	printf "%s\t" 3 2 4; echo
	printf "%s\t" 3 2 2; echo
	printf "%s\t" 3 2 3; echo
	printf "%s\t" 3 1 3; echo
	printf "%s\t" 3 2 3; echo
	printf "%s\t" 3 3 3; echo
	printf "%s\t" 3 4 4; echo
	printf "%s\t" 3 5 4; echo
    }
    export -f tsv

    ssv() {
	# space separated
	printf "%s\t" a1 b1 C1; echo
	printf "%s " 2 2 2; echo
	printf "%s \t" 3 2 2; echo
	printf "%s\t " 3 3 2; echo
	printf "%s  " 3 2 4; echo
	printf "%s\t\t" 3 2 2; echo
	printf "%s\t  \t" 3 2 3; echo
	printf "%s\t  \t  " 3 1 3; echo
	printf "%s\t  \t " 3 2 3; echo
	printf "%s\t  \t" 3 3 3; echo
	printf "%s\t\t" 3 4 4; echo
	printf "%s\t \t" 3 5 4; echo
    }
    export -f ssv

    cssv() {
	# , + space separated
	printf "%s,\t" a1 b1 C1; echo
	printf "%s ," 2 2 2; echo
	printf "%s  ,\t" 3 2 2; echo
	printf "%s\t, " 3 3 2; echo
	printf "%s,," 3 2 4; echo
	printf "%s\t,,, " 3 2 2; echo
	printf "%s\t" 3 2 3; echo
	printf "%s\t, " 3 1 3; echo
	printf "%s\t," 3 2 3; echo
	printf "%s, \t" 3 3 3; echo
	printf "%s,\t," 3 4 4; echo
	printf "%s\t,," 3 5 4; echo
    }
    export -f cssv

    csv() {
	# , separated
	printf "%s," a1 b1 C1; echo
	printf "%s," 2 2 2; echo
	printf "%s," 3 2 2; echo
	printf "%s," 3 3 2; echo
	printf "%s," 3 2 4; echo
	printf "%s," 3 2 2; echo
	printf "%s," 3 2 3; echo
	printf "%s," 3 1 3; echo
	printf "%s," 3 2 3; echo
	printf "%s," 3 3 3; echo
	printf "%s," 3 4 4; echo
	printf "%s," 3 5 4; echo
    }
    export -f csv

    tester() {
	block="$1"
	groupby="$2"
	generator="$3"
	colsep="$4"
	echo "### test $generator | --colsep $colsep --groupby $groupby $block"
	$generator |
	    parallel --pipe --colsep "$colsep" --groupby "$groupby" -k $block 'echo NewRec; cat'
    }
    export -f tester
    # -N1 = allow only a single value
    # --block 20 = allow multiple groups of values
    parallel --tag -k tester \
	     ::: -N1 '--block 20' \
	     ::: '3 $_%=2' 3 's/^(.).*/$1/' C1 'C1 $_%=2' \
	     ::: tsv ssv cssv csv \
	     :::+ '\t' '\s+' '[\s,]+' ','

    # Test --colsep char: OK
    # Test --colsep pattern: OK
    # Test --colsep -N1: OK
    # Test --colsep --block 20: OK
    # Test --groupby colno: OK
    # Test --groupby 'colno perl': OK
    # Test --groupby colname: OK
    # Test --groupby 'colname perl': OK
    # Test space sep --colsep '\s': OK
    # Test --colsep --header : (OK: --header : not needed)
}

par__groupby_pipepart() {
    tsv() {
	# TSV file
	printf "%s\t" header_a1 head_b1 c1 d1 e1 f1; echo
	# Make 6 columns: 123456 => 1\t2\t3\t4\t5\t6
	seq 100000 999999 | perl -pe '$_=join"\t",split//' |
	    # Sort reverse on column 3 (This should group on col 3)
	    sort --parallel=8 -k3r
    }
    export -f tsv

    ssv() {
	# space separated
	tsv | perl -pe '@sep=("\t"," "); s/\t/$sep[rand(2)]/ge;'
    }
    export -f ssv

    cssv() {
	# , + space separated
	tsv | perl -pe '@sep=("\t"," ",","); s/\t/$sep[rand(2)].$sep[rand(2)]/ge;'
    }
    export -f cssv

    csv() {
	# , separated
	tsv | perl -pe 's/\t/,/g;'
    }
    export -f csv

    tester() {
	generator="$1"
	colsep="$2"
	groupby="$3"
	tmp=$(mktemp)
	
	echo "### test $generator | --colsep $colsep --groupby $groupby"
	$generator > "$tmp"
	parallel --header 1 --pipepart -k \
		 -a "$tmp" --colsep "$colsep" --groupby "$groupby" 'echo NewRec; wc'
    }
    export -f tester
    parallel --tag -k tester \
	     ::: tsv ssv cssv csv \
	     :::+ '\t' '\s+' '[\s,]+' ',' \
	     ::: '3 $_%=2' 3 c1 'c1 $_%=2' 's/^(\d+[\t ,]+){2}(\d+).*/$2/'
}

par_sighup() {
    echo '### Test SIGHUP'
    parallel -k -j5 sleep 15';' echo ::: {1..99} >/tmp/parallel$$ 2>&1 &
    A=$!
    sleep 29; kill -HUP $A
    wait
    LC_ALL=C sort /tmp/parallel$$
    rm /tmp/parallel$$
}

par_race_condition1() {
    echo '### Test race condition on 8 CPU (my laptop)'
    seq 1 5000000 > /tmp/parallel_race_cond
    seq 1 10 |
	parallel -k "cat /tmp/parallel_race_cond | parallel --pipe --recend '' -k gzip >/dev/null; echo {}"
    rm /tmp/parallel_race_cond
}

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
    if [ $small_max -lt $big ] ; then
	echo "Bad: Memleak likely."
    else
	echo "Good: No memleak detected."
    fi
}

par_slow_total_jobs() {
    echo 'bug #51006: Slow total_jobs() eats job'
    (echo a; sleep 15; echo b; sleep 15; seq 2) |
	parallel -k echo '{=total_jobs()=}' 2> >(perl -pe 's/\d/X/g')
}

par_memfree() {
    echo '### test memfree - it should be killed by timeout'
    parallel --memfree 1k echo Free mem: ::: 1k
    stdout parallel --timeout 20 --argsep II parallel --memfree 1t echo Free mem: ::: II 1t |
	grep -v TERM | grep -v ps/display.c
}

par_test_detected_shell() {
    echo '### bug #42913: Dont use $SHELL but the shell currently running'

    shells="ash bash csh dash fish fizsh ksh ksh93 mksh posh rbash rush rzsh sash sh static-sh tcsh yash zsh"
    test_unknown_shell() {
	shell="$1"
	tmp="/tmp/test_unknown_shell_$shell"
	# Remove the file to avoid potential text-file-busy
	rm -f "$tmp"
	cp $(which "$shell") "$tmp"
	chmod +x "$tmp"
	stdout $tmp -c 'parallel -Dinit echo ::: 1; true' |
	    grep Global::shell
	rm "$tmp"
    }
    export -f test_unknown_shell

    test_known_shell_c() {
	shell="$1"
	stdout $shell -c 'parallel -Dinit echo ::: 1; true' |
	    grep Global::shell
    }
    export -f test_known_shell_c

    test_known_shell_pipe() {
	shell="$1"
	echo 'parallel -Dinit echo ::: 1; true' |
	    stdout $shell | grep Global::shell
    }
    export -f test_known_shell_pipe

    stdout parallel -j2 --tag -k \
	   ::: test_unknown_shell test_known_shell_c test_known_shell_pipe \
	   ::: $shells |
	grep -Ev 'parallel: Warning: (Starting .* processes took|Consider adjusting)'
}

par_no_newline_compress() {
    echo 'bug #41613: --compress --line-buffer - no newline';
    pipe_doit() {
	tagstring="$1"
	compress="$2"
	echo tagstring="$tagstring" compress="$compress"
	perl -e 'print "O"'|
	    parallel "$compress" $tagstring --pipe --line-buffer cat
	echo "K"
    }
    export -f pipe_doit
    nopipe_doit() {
	tagstring="$1"
	compress="$2"
	echo tagstring="$tagstring" compress="$compress"
	parallel "$compress" $tagstring --line-buffer echo {} O ::: -n
	echo "K"
    }
    export -f nopipe_doit
    parallel -j1 -qk --header : {pipe}_doit {tagstring} {compress} \
	     ::: tagstring '--tagstring {#}' -k \
	     ::: compress --compress -k \
	     ::: pipe pipe nopipe
}

par_max_length_len_128k() {
    echo "### BUG: The length for -X is not close to max (131072)"
    (
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo {.} aa {}{.} {}{}d{} {}dd{}d{.} | head -n 1 | wc -c
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo a{}b{}c | head -n 1 | wc -c
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo | head -n 1 | wc -c
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo a{}b{}c {} | head -n 1 | wc -c
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo {}aa{} | head -n 1 | wc -c
	seq 1 60000 | perl -pe 's/$/.gif/' |
	    parallel -X echo {} aa {} | head -n 1 | wc -c
    ) |	perl -pe 's/(\d\d+)\d\d\d/${1}xxx/g'
}

par__plus_dyn_repl() {
    echo "Dynamic replacement strings defined by --plus"

    unset myvar
    echo ${myvar:-myval}
    parallel --rpl '{:-(.+)} $_ ||= $$1' echo {:-myval} ::: "$myvar"
    parallel --plus echo {:-myval} ::: "$myvar"
    parallel --plus echo {2:-myval} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2:-myval} ::: "wrong" ::: "$myvar" ::: "wrong"

    myvar=abcAaBdefCdefDdef
    echo ${myvar:2}
    parallel --rpl '{:(\d+)} substr($_,0,$$1) = ""' echo {:2} ::: "$myvar"
    parallel --plus echo {:2} ::: "$myvar"
    parallel --plus echo {2:2} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2:2} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${myvar:2:3}
    parallel --rpl '{:(\d+?):(\d+?)} $_ = substr($_,$$1,$$2);' echo {:2:3} ::: "$myvar"
    parallel --plus echo {:2:3} ::: "$myvar"
    parallel --plus echo {2:2:3} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2:2:3} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${#myvar}
    parallel --rpl '{#} $_ = length $_;' echo {#} ::: "$myvar"
    # {#} used for job number
    parallel --plus echo {#} ::: "$myvar"

    echo ${myvar#bc}
    parallel --rpl '{#(.+?)} s/^$$1//;' echo {#bc} ::: "$myvar"
    parallel --plus echo {#bc} ::: "$myvar"
    parallel --plus echo {2#bc} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2#bc} ::: "wrong" ::: "$myvar" ::: "wrong"
    echo ${myvar#abc}
    parallel --rpl '{#(.+?)} s/^$$1//;' echo {#abc} ::: "$myvar"
    parallel --plus echo {#abc} ::: "$myvar"
    parallel --plus echo {2#abc} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2#abc} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${myvar%de}
    parallel --rpl '{%(.+?)} s/$$1$//;' echo {%de} ::: "$myvar"
    parallel --plus echo {%de} ::: "$myvar"
    parallel --plus echo {2%de} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2%de} ::: "wrong" ::: "$myvar" ::: "wrong"
    echo ${myvar%def}
    parallel --rpl '{%(.+?)} s/$$1$//;' echo {%def} ::: "$myvar"
    parallel --plus echo {%def} ::: "$myvar"
    parallel --plus echo {2%def} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2%def} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${myvar/def/ghi}
    parallel --rpl '{/(.+?)/(.+?)} s/$$1/$$2/;' echo {/def/ghi} ::: "$myvar"
    parallel --plus echo {/def/ghi} ::: "$myvar"
    parallel --plus echo {2/def/ghi} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2/def/ghi} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${myvar//def/ghi}
    parallel --rpl '{//(.+?)/(.+?)} s/$$1/$$2/g;' echo {//def/ghi} ::: "$myvar"
    parallel --plus echo {//def/ghi} ::: "$myvar"
    parallel --plus echo {2//def/ghi} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2//def/ghi} ::: "wrong" ::: "$myvar" ::: "wrong"

    echo ${myvar^a}
    parallel --rpl '{^(.+?)} s/^($$1)/uc($1)/e;' echo {^a} ::: "$myvar"
    parallel --plus echo {^a} ::: "$myvar"
    parallel --plus echo {2^a} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2^a} ::: "wrong" ::: "$myvar" ::: "wrong"
    echo ${myvar^^a}
    parallel --rpl '{^^(.+?)} s/($$1)/uc($1)/eg;' echo {^^a} ::: "$myvar"
    parallel --plus echo {^^a} ::: "$myvar"
    parallel --plus echo {2^^a} ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo {-2^^a} ::: "wrong" ::: "$myvar" ::: "wrong"

    myvar=AbcAaAdef
    echo ${myvar,A}
    parallel --rpl '{,(.+?)} s/^($$1)/lc($1)/e;' echo '{,A}' ::: "$myvar"
    parallel --plus echo '{,A}' ::: "$myvar"
    parallel --plus echo '{2,A}' ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo '{-2,A}' ::: "wrong" ::: "$myvar" ::: "wrong"
    echo ${myvar,,A}
    parallel --rpl '{,,(.+?)} s/($$1)/lc($1)/eg;' echo '{,,A}' ::: "$myvar"
    parallel --plus echo '{,,A}' ::: "$myvar"
    parallel --plus echo '{2,,A}' ::: "wrong" ::: "$myvar" ::: "wrong"
    parallel --plus echo '{-2,,A}' ::: "wrong" ::: "$myvar" ::: "wrong"

    myvar=abcabcdefdef
    echo $myvar ${myvar/#abc/ABC}
    echo $myvar | parallel --plus echo {} {/#abc/ABC}
    echo $myvar ${myvar/%def/DEF}
    echo $myvar | parallel --plus echo {} {/%def/DEF}
    echo $myvar ${myvar/#abc/}
    echo $myvar | parallel --plus echo {} {/#abc/}
    echo $myvar ${myvar/%def/}
    echo $myvar | parallel --plus echo {} {/%def/}
}

par_test_ipv6_format() {
    # If not MaxStartups 100:30:1000 then this will fail
    ipv4() {
	ifconfig | perl -nE '/inet (\S+) / and say $1'
    }
    ipv6() {
	ifconfig | perl -nE '/inet6 ([0-9a-f:]+) .*(host|global)/ and say $1'
    }
    (ipv4; ipv6) |
	parallel ssh -oStrictHostKeyChecking=accept-new {} true 2>/dev/null
    echo '### Host as IPv6 address'
    (
	ipv6 |
            # Get IPv6 addresses of local server
            perl -nE '/([0-9a-f:]+)/ and
              map {say $1,$_,22; say $1,$_,"ssh"} qw(: . #  p q)' |
            # 9999::9999:9999:22 => [9999::9999:9999]:22
	    # 9999::9999:9999q22 => 9999::9999:9999
            perl -pe 's/(.*):(22|ssh)$/[$1]:$2/;s/q.*//;'
	ipv4 |
            # Get IPv4 addresses
            perl -nE '/(\S+)/ and
              map {say $1,$_,22; say $1,$_,"ssh"} qw(:  q)' |
            # 9.9.9.9q22 => 9.9.9.9
            perl -pe 's/q.*//;'
    ) |
	parallel -j200% --argsep , parallel -S {} true ::: 1 ||
	echo Failed
}

# was -j6 before segfault circus
export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | sort |
    #    parallel --delay 0.3 --timeout 1000% -j6 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
    parallel --delay 0.3 --timeout 3000% -j6 --lb --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
