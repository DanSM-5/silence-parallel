#!/bin/bash

find {$TMPDIR,/var/tmp,/tmp}/{fif,tms,par[^a]}* -mmin -10 2>/dev/null | parallel rm
cd testsuite 2>/dev/null
rm -rf tmp
mkdir tmp
cd tmp
touch ~/.parallel/will-cite
echo '### test parallel_tutorial'
rm -f /tmp/runs
export SERVER1=parallel@lo
export SERVER2=csh@lo
export PARALLEL=-k
perl -ne '$/="\n\n"; /^Output/../^[^O]\S/ and next; /^  / and print;' ../../src/parallel_tutorial.pod |
  egrep -v 'curl|tty|parallel_tutorial|interactive|example.(com|net)|shellquote|works' |
  perl -pe 's/username@//;s/user@//;
            s/zenity/zenity --timeout=15/;
            s:/usr/bin/time:/usr/bin/time -f %e:;
            s:ignored_vars:ignored_vars|sort:;
            # Remove \n to join all joblogs into the previous block
            s:cat /tmp/log\n:cat /tmp/log;:;
            # Remove import (python code)
            s:import.*::;
            # When parallelized: Sleep to make sure the abc-files are made
            /%head1/ and $_.="sleep .3\n\n"x10;
' |
  stdout parallel --joblog /tmp/jl-`basename $0` -j6 -vd'\n\n' |
  perl -pe '$|=1;
            # --pipe --roundrobin wc
            s: \d{6}  \d{6} \d{7}: 999999  999999 9999999:;
            # --tmux
            s:(/tmp\S+)(tms).....:$1$2XXXXX:;
            # --files
            s:(/tmp\S+par).....(\....):$1XXXXX$2:;
            # --eta --progress
            s/ETA.*//g; s/local:.*//g;
            # Sat Apr  4 11:55:40 CEST 2015
            s/... ... .. ..:..:.. \D+ ..../DATE OUTPUT/;
            # Timestamp from --joblog
            s/\d{10}.\d{3}\s+..\d+/TIMESTAMP\t9.999/g;
            # Version
            s/201\d{5}/VERSION/g;
            # [123] [abc] [ABC]
            s/^[123] [abc] [ABC]$/123 abc ABC/g;
            # Remote script
            s/(PARALLEL_PID\D+)\d+/${1}000000/g;
            # sql timing
            s/,[a-z]*,\d+.\d+,\d+.\d+/,:,000000000.000,0.000/g;
            # /usr/bin/time -f %e
            s/^(\d+)\.\d+$/$1/;
            # Base 64 string
            s:[\\+/a-z0-9=]{50,}:BASE64:ig;
            # --workdir ...
            s:parallel/tmp/aspire-\d+-1:TMPWORKDIR:g;
            # + cat ... | (Bash outputs these in random order)
            s/\+ cat.*\n//;
            # + echo ... | (Bash outputs these in random order)
            s/\+ echo.*\n//;
            # + wc ... (Bash outputs these in random order)
            s/\+ wc.*\n//;
            # + command_X | (Bash outputs these in random order)
            s/.*command_[ABC].*\n//;
            # Due to multiple jobs "Second started" often ends up wrong
            s/Second started\n//;
            s/The second finished\n//;
            # Due to multiple jobs "tried 2" often ends up wrong
            s/tried 2\n//;
            # Due to order is often mixed up
            s/echo \d; exit \d\n/echo X; exit X\n/;
            # Race condition causes outdir to sometime exist
            s/(std(out|err)|seq): Permission denied/$1: No such file or directory/;
            # Race condition
            s/^4-(middle|end)\n//;
            # Timings are often off
            s/^(\d)$/9/;
            s/^(\d\d)$/99/;
	    # Sometime these vars are not present
            s/^PAM_KWALLET5*_LOGIN$//;
	    # Fails often due to race
	    s/cat: input_file: No such file or directory\n//;
	    s{rsync: link_stat ".*/home/parallel/input_file.out" .*\n}{};
	    s{rsync error: some files/attrs were not transferred .*\n}{};
' |
  uniq
# 3+3 .par files (from --files), 1 .tms-file from tmux attach
find {$TMPDIR,/var/tmp,/tmp}/{fif,tms,par[^a]}* -mmin -10 2>/dev/null | wc -l
find {$TMPDIR,/var/tmp,/tmp}/{fif,tms,par[^a]}* -mmin -10 2>/dev/null | parallel rm
