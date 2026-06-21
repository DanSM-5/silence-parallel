#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

SERVER1=parallel-server1
SERVER2=parallel-server2
SERVER3=parallel-server3
SSHUSER1=vagrant
SSHUSER2=vagrant
SSHUSER3=vagrant
export SSHLOGIN1=$SSHUSER1@$SERVER1
export SSHLOGIN2=$SSHUSER2@$SERVER2
export SSHLOGIN3=$SSHUSER3@$SERVER3

#SERVER1=parallel-server1
#SERVER2=lo
#SSHLOGIN1=parallel@parallel-server1
#SSHLOGIN2=parallel@lo
#SSHLOGIN3=parallel@parallel-server2

par_force_number_of_cpu() {
    echo '### Check forced number of CPUs being respected'
    echo 'ssh is slow, so should only get 7. : should get the rest'
    seq 1 20 |
	stdout parallel -k -j+0  -S 1/:,7/$SSHLOGIN1 "hostname; echo {} >/dev/null" |
	sort | uniq -c | sort | field 1
}

par_special_ssh() {
    echo '### Test use special ssh'
    echo 'TODO test ssh with > 9 simultaneous'
    echo 'ssh "$@"; echo "$@" >>/tmp/myssh1-run' >/tmp/myssh1
    echo 'ssh "$@"; echo "$@" >>/tmp/myssh2-run' >/tmp/myssh2
    chmod 755 /tmp/myssh1 /tmp/myssh2
    seq 1 100 | parallel --sshdelay 0.03 --retries 10 --sshlogin "/tmp/myssh1 $SSHLOGIN1,/tmp/myssh2 $SSHLOGIN2" -k echo
}

par__filter_hosts_different_errors() {
    echo '### --filter-hosts - OK, non-such-user, connection refused, wrong host'
    hostname=$(hostname)
    stdout parallel --nonall --filter-hosts -S localhost,NoUser@localhost,154.54.72.206,"ssh 5.5.5.5" hostname |
	grep -v 'parallel: Warning: Removed' |
	perl -pe "s/$hostname/myhostname/g"
}

par_timeout_retries() {
    echo '### test --timeout --retries'
    # 8.8.8.8 is up but does not allow login - should timeout
    # 8.8.8.9 is down - should timeout
    # 172.27.27.197 is down but on our subnet - should no route to host
    stdout parallel -j0 --timeout 16 --retries 3 -k ssh {} echo {} \
	   ::: 172.27.27.197 8.8.8.8 8.8.8.9 $SSHLOGIN1 $SSHLOGIN2 $SSHLOGIN3 |
	grep -v 'Warning: Permanently added' | puniq
}

par__filter_hosts_no_ssh_nxserver() {
    echo '### test --filter-hosts with server w/o ssh, non-existing server'
    # make them warm so they do not timeout
    ssh $SSHLOGIN1 true
    ssh $SSHLOGIN2 true
    ssh $SSHLOGIN3 true
    stdout parallel -S 192.168.1.197,8.8.8.8,8.8.8.9,$SSHLOGIN1,$SSHLOGIN2,$SSHLOGIN3 --filter-hosts --nonall -k --tag echo |
	grep -v 'parallel: Warning: Removed'
}

par_workdir_in_HOME() {
    echo '### test --workdir . in $HOME'
    cd && mkdir -p parallel-test && cd parallel-test && 
	echo OK > testfile &&
	stdout parallel --workdir . --transfer -S $SSHLOGIN1 cat {} ::: testfile |
	    grep -v 'Permanently added'
}

par_nonall_u() {
    SSHLOGIN1=vagrant@parallel-server1
    SSHLOGIN2=vagrant@parallel-server2
    echo '### Test --nonall -u - should be interleaved x y x y'
    echo 'thus making uniq -c return 1 four times'
    parallel --nonall --sshdelay 2 -S $SSHLOGIN1,$SSHLOGIN2 -u \
	     'hostname|grep -q rhel && sleep 2; hostname;sleep 4;hostname;' |
	uniq -c | sort
}

par__sshlogin_with_comma() {
    echo "### --sshlogin with \,"
    parallel -S 'ssh -J lo\,localhost 127.0.0.1' echo ::: OK
    echo "### --sshlogin with ,,"
    parallel -S 'ssh -J lo,,localhost 127.0.0.1' echo ::: OK
    echo "### Both , and ,, in -S"
    parallel -S'1/ssh -oProxyJump=vagrant@parallel-server1,,vagrant@parallel-server2 vagrant@parallel-server3,1/vagrant@parallel-server1' ::: hostname hostname |
	sort
    parallel --nonall -S'1/ssh -oProxyJump=vagrant@parallel-server1,,vagrant@parallel-server2 vagrant@parallel-server3,1/vagrant@parallel-server1' hostname |
        sort
    parallel --onall -S'1/ssh -oProxyJump=vagrant@parallel-server1,,vagrant@parallel-server2 vagrant@parallel-server3,1/vagrant@parallel-server1' ::: hostname |
        sort
}

par__man_bash() {
    echo '### bash'

    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.bash`;
    shopt -s expand_aliases&>/dev/null;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    # multiline aliases with when followed by newline
    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    multiline work
    env_parallel 'multiline {};
      echo but only when followed by a newline' ::: work
    env_parallel -S server 'multiline {};
      echo but only when followed by a newline' ::: work
    env_parallel --env multiline 'multiline {};
      echo but only when followed by a newline' ::: work
    env_parallel --env multiline -S server 'multiline {};
      echo but only when followed by a newline' ::: work
    alias multiline="dummy"

    myfunc() { echo functions 'with  = & " !'" '" $*; }
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    myarray=(arrays 'with = & " !'" '" work, too)
    echo "${myarray[0]}" "${myarray[1]}" "${myarray[2]}" "${myarray[3]}"
    env_parallel -k echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k -S server echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray -S server echo '"${myarray[{}]}"' ::: 0 1 2 3

    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh bash@lo "$myscript"
}

par__man_csh() {
    echo '### csh'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

#    source `which env_parallel.csh`;

    alias myecho 'echo aliases with \= \& \"'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    # Functions not supported

    # TODO This does not work
    # set myvar='variables with = & "'" '"
    set myvar='variables with \= \& \"'
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    # Space is not supported in arrays

    set myarray=(arrays with\=\&\""'" work, too)
    env_parallel -k echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k -S server echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k --env myarray echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k --env myarray -S server echo \$'{myarray[{}]}' ::: 1 2 3 4

    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255 `sleep 1`
_EOF
	    )
    # Sometimes the order f*cks up
    stdout ssh csh@lo "$myscript" |
	grep -v "Tange" | grep -v "Zenodo" | LC_ALL=C sort
}

par__man_dash() {
    echo '### dash'

    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.dash`;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    multiline work
    env_parallel multiline ::: work
    env_parallel -S server multiline ::: work
    env_parallel --env multiline multiline ::: work
    env_parallel --env multiline -S server multiline ::: work
    alias multiline="dummy"

    # Functions are not supported in dash

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    # Arrays are not supported in dash

    # Exporting of functions is not supported
    # env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh dash@lo "$myscript"
}

par__man_ksh() {
    echo '### ksh'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.ksh`;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    multiline work
    env_parallel multiline ::: work
    env_parallel -S server multiline ::: work
    env_parallel --env multiline multiline ::: work
    env_parallel --env multiline -S server multiline ::: work
    alias multiline='dummy'

    myfunc() { echo functions 'with  = & " !'" '" $*; }
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    myarray=(arrays 'with = & " !'" '" work, too)
    echo "${myarray[0]}" "${myarray[1]}" "${myarray[2]}" "${myarray[3]}"
    env_parallel -k echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k -S server echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray -S server echo '"${myarray[{}]}"' ::: 0 1 2 3

    echo This may never work
    echo https://unix.stackexchange.com/questions/457031/extract-full-function-definitions
    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel 2>&1 |
	perl -pe 's/line \d*/line 9/g'

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh ksh@lo "$myscript"
}

par__man_mksh() {
    echo '### mksh'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.mksh`;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    multiline work
    env_parallel multiline ::: work
    env_parallel -S server multiline ::: work
    env_parallel --env multiline multiline ::: work
    env_parallel --env multiline -S server multiline ::: work
    alias multiline='dummy'

    myfunc() { echo functions 'with  = & " !'" '" $*; }
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    myarray=(arrays 'with = & " !'" '" work, too)
    echo "${myarray[0]}" "${myarray[1]}" "${myarray[2]}" "${myarray[3]}"
    env_parallel -k echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k -S server echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray echo '"${myarray[{}]}"' ::: 0 1 2 3
    env_parallel -k --env myarray -S server echo '"${myarray[{}]}"' ::: 0 1 2 3

    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh mksh@lo "$myscript"
}

par__man_sh() {
    echo '### sh'

    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.sh`;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    multiline work
    env_parallel multiline ::: work
    env_parallel -S server multiline ::: work
    env_parallel --env multiline multiline ::: work
    env_parallel --env multiline -S server multiline ::: work
    alias multiline="dummy"

    # Functions not supported

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    # Arrays are not supported

    # Exporting of functions is not supported
    # env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh sh@lo "$myscript"
}

par__man_tcsh() {
    echo '### tcsh'
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

#    source `which env_parallel.tcsh`

    alias myecho 'echo aliases with \= \& \"'
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    echo Functions not supported

    # TODO This does not work
    # set myvar='variables with = & "'" '"
    set myvar='variables with \= \& \"'
    env_parallel echo '$myvar' ::: work
    env_parallel -S server echo '$myvar' ::: work
    env_parallel --env myvar echo '$myvar' ::: work
    env_parallel --env myvar -S server echo '$myvar' ::: work

    # Space is not supported in arrays

    set myarray=(arrays with\=\&\""'" work, too)
    env_parallel -k echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k -S server echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k --env myarray echo \$'{myarray[{}]}' ::: 1 2 3 4
    env_parallel -k --env myarray -S server echo \$'{myarray[{}]}' ::: 1 2 3 4

    echo 'Segmentation faults? Are you running bsd-csh version 20110502-3?'
    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $status should be 2

    env_parallel --no-such-option >/dev/null
    echo exit value $status should be 255 `sleep 1`
_EOF
	    )
    ssh -tt tcsh@lo "$myscript"	|
 	grep -v "Tange" | grep -v "Zenodo"
}

par__man_zsh() {
    echo '### zsh'
    # eval is needed make aliases work
    myscript=$(cat <<'_EOF'
    echo "### From man env_parallel"

    . `which env_parallel.zsh`;

    alias myecho='echo aliases with \= \& \" \!'" \'"
    # eval is needed make aliases work
    eval myecho work
    env_parallel myecho ::: work
    env_parallel -S server myecho ::: work
    env_parallel --env myecho myecho ::: work
    env_parallel --env myecho -S server myecho ::: work

    alias multiline='echo multiline
      echo aliases with \= \& \" \!'" \'"
    eval multiline work
    # Zsh-5.4.2 requires additional quoting when multiline
    # Looks like a bug
    alias multiline='echo multiline
      echo aliases with \\= \\& \\" \\!'" \\\'"
    # eval is needed make aliases work
    env_parallel multiline ::: work
    env_parallel -S server multiline ::: work
    env_parallel --env multiline multiline ::: work
    env_parallel --env multiline -S server multiline ::: work
    alias multiline="dummy"

    myfunc() { echo functions 'with  = & " !'" '" $*; }
    myfunc work
    env_parallel myfunc ::: work
    env_parallel -S server myfunc ::: work
    env_parallel --env myfunc myfunc ::: work
    env_parallel --env myfunc -S server myfunc ::: work

    myvar='variables with  = & " !'" '"
    echo "$myvar" work
    env_parallel echo '"$myvar"' ::: work
    env_parallel -S server echo '"$myvar"' ::: work
    env_parallel --env myvar echo '"$myvar"' ::: work
    env_parallel --env myvar -S server echo '"$myvar"' ::: work

    multivar='multiline
    variables with  = & " !'" '"
    echo "$multivar" work
    env_parallel echo '"$multivar"' ::: work
    env_parallel -S server echo '"$multivar"' ::: work
    env_parallel --env multivar echo '"$multivar"' ::: work
    env_parallel --env multivar -S server echo '"$multivar"' ::: work

    myarray=(arrays 'with = & " !'" '" work, too)
    # zsh counts from 1 - not 0
    echo "${myarray[1]}" "${myarray[2]}" "${myarray[3]}" "${myarray[4]}"
    env_parallel -k echo '"${myarray[{}]}"' ::: 1 2 3 4
    env_parallel -k -S server echo '"${myarray[{}]}"' ::: 1 2 3 4
    env_parallel -k --env myarray echo '"${myarray[{}]}"' ::: 1 2 3 4
    env_parallel -k --env myarray -S server echo '"${myarray[{}]}"' ::: 1 2 3 4

    env_parallel --argsep --- env_parallel -k echo ::: multi level --- env_parallel

    env_parallel ::: true false true false
    echo exit value $? should be 2

    env_parallel --no-such-option 2>&1 >/dev/null
    # Sleep 1 to delay output to stderr to avoid race
    echo exit value $? should be 255 `sleep 1`
_EOF
	    )
    ssh zsh@lo "$myscript"
}


export -f $(compgen -A function | grep par_)
compgen -A function | G "$@" par_ | LC_ALL=C sort |
    parallel --timeout 3000% --delay 1 -j6 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1' |
    perl -pe 's:/usr/bin:/bin:g'

  
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/\;s/\$SSHLOGIN1/$SSHLOGIN1/\;s/\$SSHLOGIN2/$SSHLOGIN2/\;s/\$SSHLOGIN3/$SSHLOGIN3/ | parallel -vj100% -k -L1 -r




echo '### TODO: test --filter-hosts proxied through the one host'


EOF
rm /tmp/myssh1 /tmp/myssh2 /tmp/myssh1-run /tmp/myssh2-run

