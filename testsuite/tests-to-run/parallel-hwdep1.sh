# SPDX-FileCopyrightText: 2021-2024 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Jobs that depend on the hardware
# (e.g number of CPU threads, terminal type)

par__environment_too_big_ash() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    len_var=60
    len_var_remote=43
    len_var_quote=31
    len_var_quote_remote=21
    len_fun=1
    len_fun_remote=1
    len_fun_quote=1
    len_fun_quote_remote=1
    
    . `which env_parallel.ash`;

    repeat() {
      # Repeat input string n*1000 times
      perl -e 'print ((shift)x(eval "1000*(".shift.")"))' "$@"
    }

    bigvar=$(repeat x $len_var)
    env_parallel echo ::: OK_bigvar
    bigvar=$(repeat x $len_var_remote)
    env_parallel -S lo echo ::: OK_bigvar_remote

    bigvar=$(repeat \" $len_var_quote)
    env_parallel echo ::: OK_bigvar_quote
    bigvar=$(repeat \" $len_var_quote_remote)
    env_parallel -S lo echo ::: OK_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat x $len_fun)"'"; };'
    env_parallel echo ::: OK_bigfunc
    eval 'bigfunc() { a="'"$(repeat x $len_fun_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_remote

    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote)"'"; };'
    env_parallel echo ::: OK_bigfunc_quote
    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_quote_remote
    bigfunc() { true; }

    echo Rest should fail - functions not supported in ash

    bigvar=$(repeat x $len_var+10)
    env_parallel echo ::: fail_bigvar
    bigvar=$(repeat x $len_var_remote+10)
    env_parallel -S lo echo ::: fail_bigvar_remote

    bigvar=$(repeat \" $len_var_quote+10)
    env_parallel echo ::: fail_bigvar_quote
    bigvar=$(repeat \" $len_var_quote_remote+10)
    env_parallel -S lo echo ::: fail_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat x $len_fun+10)"'"; };'
    env_parallel echo ::: fail_bigfunc-not-supported
    eval 'bigfunc() { a="'"$(repeat x $len_fun_remote+10)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_remote-not-supported

    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote+10)"'"; };'
    env_parallel echo ::: fail_bigfunc_quote-not-supported
    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote_remote+10)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_quote_remote-not-supported

    bigfunc() { true; }
_EOF
  )
  stdout ssh ash@lo "$myscript" | perl -pe 's/(\d)\d\d\d\d/${1}XXXX/g'
}

par__environment_too_big_dash() {
  myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'
    len_var=60
    len_var_remote=43
    len_var_quote=31
    len_var_quote_remote=21
    len_fun=1
    len_fun_remote=1
    len_fun_quote=1
    len_fun_quote_remote=1
    
    . `which env_parallel.dash`;

    repeat() {
      # Repeat input string n*1000 times
      perl -e 'print ((shift)x(eval "1000*(".shift.")"))' "$@"
    }

    bigvar=$(repeat x $len_var)
    env_parallel echo ::: OK_bigvar
    bigvar=$(repeat x $len_var_remote)
    env_parallel -S lo echo ::: OK_bigvar_remote

    bigvar=$(repeat \" $len_var_quote)
    env_parallel echo ::: OK_bigvar_quote
    bigvar=$(repeat \" $len_var_quote_remote)
    env_parallel -S lo echo ::: OK_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat x $len_fun)"'"; };'
    env_parallel echo ::: OK_bigfunc
    eval 'bigfunc() { a="'"$(repeat x $len_fun_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_remote

    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote)"'"; };'
    env_parallel echo ::: OK_bigfunc_quote
    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_quote_remote
    bigfunc() { true; }

    echo Rest should fail - functions not supported in dash

    bigvar=$(repeat x $len_var+10)
    env_parallel echo ::: fail_bigvar
    bigvar=$(repeat x $len_var_remote+10)
    env_parallel -S lo echo ::: fail_bigvar_remote

    bigvar=$(repeat \" $len_var_quote+10)
    env_parallel echo ::: fail_bigvar_quote
    bigvar=$(repeat \" $len_var_quote_remote+10)
    env_parallel -S lo echo ::: fail_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat x $len_fun+10)"'"; };'
    env_parallel echo ::: fail_bigfunc-not-supported
    eval 'bigfunc() { a="'"$(repeat x $len_fun_remote+10)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_remote-not-supported

    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote+10)"'"; };'
    env_parallel echo ::: fail_bigfunc_quote-not-supported
    eval 'bigfunc() { a="'"$(repeat \" $len_fun_quote_remote+10)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_quote_remote-not-supported

    bigfunc() { true; }
_EOF
  )
  stdout ssh dash@lo "$myscript" | perl -pe 's/(\d)\d\d\d\d/${1}XXXX/g'
}

par__environment_too_big_zsh() {
    myscript=$(cat <<'_EOF'
    echo 'bug #50815: env_parallel should warn if the environment is too big'

    # Zsh's default env is often too big. Remove all _* functions.
    print -l ${(k)functions}|grep ^_ | while read a; do unset -f "$a"; done

    . `which env_parallel.zsh`;

    len_var=16
    len_var_remote=$len_var
    len_var_quote=$len_var
    len_var_quote_remote=$len_var-15
    len_fun=18
    len_fun_remote=$len_fun-10
    len_fun_quote=$len_fun
    len_fun_quote_remote=$len_fun-5

    repeat_() {
      # Repeat input string n*1000 times
      perl -e 'print ((shift)x(eval "1000*(".shift.")"))' "$@"
    }

    bigvar=$(repeat_ x $len_var)
    env_parallel echo ::: OK_bigvar
    bigvar=$(repeat_ x $len_var_remote)
    env_parallel -S lo echo ::: OK_bigvar_remote

    bigvar=$(repeat_ \" $len_var_quote)
    env_parallel echo ::: OK_bigvar_quote
    bigvar=$(repeat_ \" $len_var_quote_remote)
    env_parallel -S lo echo ::: OK_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat_ x $len_fun)"'"; };'
    env_parallel echo ::: OK_bigfunc
    eval 'bigfunc() { a="'"$(repeat_ x $len_fun_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_remote

    eval 'bigfunc() { a="'"$(repeat_ \" $len_fun_quote)"'"; };'
    env_parallel echo ::: OK_bigfunc_quote
    eval 'bigfunc() { a="'"$(repeat_ \" $len_fun_quote_remote)"'"; };'
    env_parallel -S lo echo ::: OK_bigfunc_quote_remote
    bigfunc() { true; }

    echo Rest should fail

    # Add 10 or 100. It differs a bit from system to system
    bigvar=$(repeat_ x $len_var+20)
    env_parallel echo ::: fail_bigvar
    bigvar=$(repeat_ x $len_var_remote+10)
    env_parallel -S lo echo ::: fail_bigvar_remote

    bigvar=$(repeat_ \" $len_var_quote+20)
    env_parallel echo ::: fail_bigvar_quote
    bigvar=$(repeat_ \" $len_var_quote_remote+20)
    env_parallel -S lo echo ::: fail_bigvar_quote_remote

    bigvar=u
    eval 'bigfunc() { a="'"$(repeat_ x $len_fun+20)"'"; };'
    env_parallel echo ::: fail_bigfunc
    eval 'bigfunc() { a="'"$(repeat_ x $len_fun_remote+20)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_remote

    eval 'bigfunc() { a="'"$(repeat_ \" $len_fun_quote+20)"'"; };'
    env_parallel echo ::: fail_bigfunc_quote
    eval 'bigfunc() { a="'"$(repeat_ \" $len_fun_quote_remote+10)"'"; };'
    env_parallel -S lo echo ::: fail_bigfunc_quote_remote

    bigfunc() { true; }
_EOF
  )
    stdout ssh zsh@lo "$myscript" | perl -pe 's/(\d)\d\d\d\d/${1}XXXX/g'
}

par_progress() {
    (
	parallel --progress --use-sockets-instead-of-threads  true ::: a b c
	parallel --progress --use-cores-instead-of-threads    true ::: a b c
	parallel --progress --use-cpus-instead-of-cores       true ::: a b c
    ) 2>&1 | perl -pe 's/.*\r//; s/\d.\ds/9.9s/'
}

par__sockets_cores_threads() {
    echo '### Test --number-of-sockets/cores/threads'
    unset PARALLEL_CPUINFO
    unset PARALLEL_LSCPU
    parallel --number-of-sockets
    parallel --number-of-cores
    parallel --number-of-threads
    parallel --number-of-cpus

    echo '### Test --use-sockets-instead-of-threads'
    (seq 1 4 |
	 stdout parallel --use-sockets-instead-of-threads -j100% sleep) &&
	echo sockets done &
    (seq 1 4 | stdout parallel -j100% sleep) && echo threads done &
    wait
    echo 'Threads should complete first on machines with less than 8 sockets'
}

export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --timeout 10000% -j6 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
