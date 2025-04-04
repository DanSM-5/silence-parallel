#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# These fail regularly

par_ll_asian() {
    echo '### --ll with Asian wide chars mess up display'
    echo 'bug #63878: Wide East Asian chars in --latest-line'
    p="parallel --ll --color --tag"
    echo Oops: the first adds '>' too early
    COLUMNS=50 $p echo tag fits, line fits a{}b{}c \
	   ::: ヌー平
    COLUMNS=50 $p echo tag fits, line too long a{}b{}c \
	   ::: ヌー平行ヌー平行ヌー平行ヌー平行ヌ
    COLUMNS=50 $p echo tag too long a{}b{}c \
	   ::: ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行ヌー平行a
}

par_mbswidth() {
    echo '### characters with screen width > 1'
    perl -e '@a=qw(ヌ ー 平 行.);
	 print map {
	     (join"",map{ $a[$_% $#a] } (1..$_))."\n".
	     "a".(join"",map{ $a[$_% $#a] } (1..$_))."\n"
	 } (1..40)' |
	COLUMNS=50 parallel -k --ll --color --tag echo
}

par_ll_tag() {
	parallel --tag --ll -q printf "a\n{}\n" ::: should-be-tagged-A
	parallel --tag --ll -q printf "a\n\r{}\n" ::: should-be-tagged-B
	parallel --color --tag --ll true ::: ERROR-should-not-be-printed
	parallel --color --tag --ll 'echo;true {}' ::: empty-line 
	parallel --color --tag --ll 'echo {};true {}' ::: full-line
}

par_ll_lb_color() {
    echo '### This should give the same output with color and without'
    echo 'bug #62386: --color (--ctag but without --tag)'
    echo 'bug #62438: See last line from multiple jobslots'
    # This is a race condition
    #  # delay modulo 4 seconds
    #  perl -MTime::HiRes -E 'Time::HiRes::usleep(1000000*(((time|3)+1)-Time::HiRes::time()));'
    #  # delay modulo 2 seconds
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(1-time+(time|1)));say time;'
    #  # delay modulo 1 second
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(1-time+(time|0)));say time;'
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(1-time+(time*4|0)/4));say time;'
    #  # delay modulo 1/4 second
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(-time+(1+time*3|0)/3));say time;';
    #  # delay modulo 1/4 second + 100 ms
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(0.1-time+(1+time*3|0)/3));say time;';
    #  # delay modulo 1 second + 200 ms
    #  perl -E 'use Time::HiRes qw(usleep time); usleep(1000000*(0.2-time+(1+time*1|0)/1));say time;';
    #  # delay modulo 1 second + delta ms
    #  perl -E 'use Time::HiRes qw(usleep time); $d=shift; for(1..shift){
    #           usleep(1000000*($d-time+(1+time*1|0)/1));say;}' 0.2 6;
    _offset_seq() { 
	perl -E 'use Time::HiRes qw(usleep time); $|=1;$d=shift; for(1..shift){
             usleep(1000000*($d-time+(1+time*1|0)/1));say;}' $@;
    }
    offset_seq() { 
	perl -E 'use Time::HiRes qw(usleep time); $|=1;usleep(shift); for(1..shift){
             usleep(1000000);say;}' $@;
    }
    export -f offset_seq
    run() {
	seq 4 -1 1 | parallel -j0 $@ offset_seq '{= $_=seq()*170000 =}' {}
    }
    export -f run
    
    parallel --delay 0.07 -vkj0 run \
	     ::: --lb --ll '' ::: -k '' ::: '--tagstring {}{}' --tag '' ::: '' --color
}

export -f $(compgen -A function | grep par_)
compgen -A function | grep par_ | sort |
    #    parallel --joblog /tmp/jl-`basename $0` -j10 --tag -k '{} 2>&1'
        parallel --joblog /tmp/jl-`basename $0` -j0 --tag -k '{} 2>&1'
