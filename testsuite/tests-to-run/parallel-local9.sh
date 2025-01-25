#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

PAR="nice nice parallel -j2 --pipe --keeporder --block 150000 --tmpdir=/dev/shm"
export PAR
XAP="nice nice parallel --xapply"
export XAP
NICEPAR="nice nice parallel"
export NICEPAR

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | stdout parallel -vj4 -k --joblog /tmp/jl-`basename $0` -L1 -r
echo 'bug #41412: --timeout + --delay causes deadlock';
  seq 10 | parallel -j10 --timeout 1 --delay 0.3 echo;
  parallel -j3 --timeout 1 --delay 2 echo ::: 1 2 3;
  parallel -j10 --timeout 2.2 --delay 3 "sleep {}; echo {}" ::: 1 2 7 8 9

echo '### Test --spreadstdin - more procs than args'; 
  rm -f /tmp/parallel.ss.*; 
  seq 1 5 | stdout $NICEPAR -j 10 --spreadstdin 'cat >/tmp/parallel.ss.$PARALLEL_SEQ' >/dev/null; 
  cat /tmp/parallel.ss.*; 
  rm -f /tmp/parallel.ss.*

echo '### Test --spreadstdin - more args than procs'; 
  rm -f /tmp/parallel.ss2.*; 
  seq 1 10 | stdout $NICEPAR -j 5 --spreadstdin 'cat >/tmp/parallel.ss2.$PARALLEL_SEQ' >/dev/null; 
  cat /tmp/parallel.ss2.*; 
  rm -f /tmp/parallel.ss2.*

nice nice seq 1 1000 | $NICEPAR -j1 --spreadstdin cat "|cat "|wc -c
nice nice seq 1 10000 | $NICEPAR -j10 --spreadstdin cat "|cat "|wc -c
nice nice seq 1 100000 | $NICEPAR -j1 --spreadstdin cat "|cat "|wc -c
nice nice seq 1 1000000 | $NICEPAR -j10 --spreadstdin cat "|cat "|wc -c

seq 1 10 | $NICEPAR --recend "\n" -j1 --spreadstdin gzip -9 >/tmp/foo.gz; 
  rm /tmp/foo.gz

echo '### Test --spreadstdin - similar to the failing below'; 
  nice seq 1 100000 | $NICEPAR --recend "\n" -j10 --spreadstdin gzip -9 >/tmp/foo2.gz; 
  diff <(nice seq 1 100000) <(zcat /tmp/foo2.gz |sort -n); 
  diff <(nice seq 1 100000|wc -c) <(zcat /tmp/foo2.gz |wc -c); 
  rm /tmp/foo2.gz

echo '### Test --spreadstdin - this failed during devel'; 
  nice seq 1 1000000 | md5sum; 
  nice seq 1 1000000 | $NICEPAR --recend "\n" -j10 --spreadstdin gzip -9 | zcat | sort -n | md5sum

echo '### Test --spreadstdin -k'; 
  nice seq 1 1000000 | $NICEPAR -k --recend "\n" -j10 --spreadstdin gzip -9 | zcat | md5sum

# --files requires TMPDIR does not contain \n
echo '### Test --spreadstdin --files'; 
  nice seq 1 1000000 | shuf | TMPDIR=/tmp $NICEPAR --files --recend "\n" -j10 --spreadstdin sort -n | parallel -Xj1 sort -nm {} ";"rm {} | md5sum

echo '### Test --tag ::: a ::: b'; 
  stdout $NICEPAR -k --tag -j1  echo stderr-{.} ">&2;" echo stdout-{} ::: a ::: b

echo '### Test --tag ::: a b'; 
  stdout $NICEPAR -k --tag -j1  echo stderr-{.} ">&2;" echo stdout-{} ::: a b

echo '### Test --tag -X ::: a b'; 
  stdout $NICEPAR -k --tag -X -j1  echo stderr-{.} ">&2;" echo stdout-{} ::: a b

echo '### Test bash redirection <()';
  $NICEPAR 'cat <(echo {}); echo b' ::: a

echo '### Test bug https://savannah.gnu.org/bugs/index.php?33352'

# produce input slowly to parallel so that it will reap a process
# while blocking in read()

# Having found the solution it is suddenly very easy to reproduce the
# problem - even on other hardware:
#
# perl -e '@x=1 .. 17000; for(1..30) { print "@x\n"}' | pv -qL 200000
# |parallel -j2 --pipe --keeporder --block 150000 cat | md5sum
#
# This gives different md5sums for each run.
#
# The problem is that read(STDIN) is being interrupted by a dead
# child. The chance of this happening is very small if there are few
# children dying or read(STDIN) never has to wait for data.
#
# The test above forces data to arrive slowly (using pv) which causes
# read(STDIN) to take a long time - thus being interrupted by a dead
# child.

echo "# md5sum - directly"
  nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | md5sum
echo "# parallel | md5sum"
  nice nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | pv -qL 1000000 | 
    $PAR cat | md5sum
echo "# --recend ''"
  nice nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | pv -qL 1000000 | 
    $PAR --recend '' cat | md5sum
echo "# --recend '' --files"
  nice nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | pv -qL 1000000 | 
    $PAR --recend '' --files cat | parallel -Xj1 cat {} ';' rm {} | md5sum
echo "# --recend '' --files --tmpdir"
  nice nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | pv -qL 1000000 | 
    $PAR --recend '' --files --tmpdir /dev/shm cat | parallel -Xj1 cat {} ';' rm {} | md5sum
echo "# --recend '' --files --halt-on-error"
  nice nice perl -e '@x=1 .. 17000; for(1..100) { print "@x\n"}' | pv -qL 1000000 | 
    $PAR --recend '' --files --halt-on-error 2 cat | parallel -Xj1 cat {} ';' rm {} | md5sum

echo '### Test ::::'
echo '### Change --arg-file-sep'
$XAP --arg-file-sep :::: -k echo {1} {2} :::: <(seq 1 10) <(seq 5 15)
$XAP --arg-file-sep .--- -k echo {1} {2} .--- <(seq 1 10) <(seq 5 15)
$XAP --argfilesep :::: -k echo {1} {2} :::: <(seq 1 10) <(seq 5 15)
$XAP --argfilesep .--- -k echo {1} {2} .--- <(seq 1 10) <(seq 5 15)

echo '### Test xapply --max-replace-args'
seq 0 7 | $XAP -k --max-replace-args=3 echo {3} {2} {1}
echo '### Test -N'
seq 1 5 | $XAP -kN3 echo {1} {2} {3}
echo '### Test -N with 0'
seq 0 7 | $XAP -kN3 echo {1} {2} {3}
echo '### Test :::: on nonexistent'
stdout $XAP -k echo {1} {2} {3} :::: nonexistent
echo '### Test :::: two files'
$XAP -k echo {1} {2} :::: <(seq 1 10) <(seq 5 15)
echo '### Test -d, ::::'
$XAP -kd, 'echo a{1} {2}b' :::: <(echo 1,2,3,) <(echo 5,6,7,8)
echo '### Test -d, :::: one file too much'
$XAP -kd, echo 'a{1}' '{2}b' :::: <(echo 1,2,3,) <(echo 5,6,7,8) <(echo 9,0)
echo '### Bug: did not quote'
$XAP echo {1} {2} :::: <(echo '>') <(echo b)
echo '### Quote test triplet 1'
$XAP -kv :::: <(echo 'echo a'; echo 'echo b')
$XAP -kv -a <(echo 'echo a'; echo 'echo b')
(echo 'echo a'; echo 'echo b') | $XAP -kv
echo '### Quote test triplet 2'
$XAP -kv echo :::: <(echo 'echo a'; echo 'echo b')
$XAP -kv -a <(echo 'echo a'; echo 'echo b') echo
(echo 'echo a'; echo 'echo b') | $XAP -kv echo
echo '### Quoting if there is a command and 2 arg files'
$XAP -kv echo :::: <(echo 'echo a') <(echo 'echo b')
echo '### Quoting if there is a command and 2 arg files of uneven length'
$XAP -kv echo :::: <(echo 'echo a';echo a1) <(echo 'echo b')
echo '### Quoting if there is no command and 2 arg files'
$XAP -kv :::: <(echo 'echo a') <(echo 'echo b')
echo '### Quoting if there is no command and 2 arg files of uneven length'
$XAP -kv :::: <(echo 'echo a';echo echo a1) <(echo 'echo b')

echo '### Test multiple -a'
$XAP -kv -a <(echo a) -a <(echo b) echo {2} {1}
$XAP -kv echo {2} {1} :::: <(echo a) <(echo b)
echo '### Multiple -a: An unused file'
$XAP -kv -a <(echo a) -a <(echo b) -a <(echo c) echo {2} {1}
$XAP -kv echo {2} {1} :::: <(echo a) <(echo b) <(echo c)
echo '### Multiple -a: nonexistent'
stdout $XAP -kv echo {2} {1} :::: nonexist nonexist2
stdout $XAP -kv -a nonexist -a nonexist2 echo {2} {1}

echo '### Test {#.}'
$XAP -kv -a <(echo a-noext) -a <(echo b-withext.extension) -a <(echo c-ext.gif) echo {3.} {2.} {1.}

echo "### Tests that failed for OO-rewrite"
parallel -u --semaphore --id local9 seq 1 10 '|' pv -qL 20; sem --id local9 --wait; echo done
echo a | parallel echo {1}
echo "echo a" | parallel
nice parallel -j1 -I :: -X echo 'a::b::^c::[.}c' ::: 1

echo '### Test -N'
seq 1 5 | $NICEPAR -kN3 echo {1} {2} {3}

echo '### Test --arg-file-sep with files of different lengths'
$XAP --arg-file-sep :::: -k echo {1} {2} :::: <(seq 1 1) <(seq 3 4)

echo '### Test respect -s'
$NICEPAR -kvm -IARG -s15 echo ARG ::: 1 22 333 4444 55555 666666 7777777 88888888 999999999

echo '### Test eof string after :::'
$NICEPAR -k -E ole echo ::: foo ole bar

echo '### Test -C and --trim rl'
$NICEPAR -k -C %+ echo '"{1}_{3}_{2}_{4}"' ::: 'a% c %%b' 'a%c% b %d'

echo '### Test empty input'
</dev/null $NICEPAR -j +0 echo

echo '### Test -m'
seq 1 2 | $NICEPAR -k -m echo

echo '### Test :::'
$NICEPAR echo ::: 1

echo '### Test context_replace'
echo a | $NICEPAR -qX echo  "'"{}"' "

echo '### Test -N2 {2}'
seq 1 4 | $NICEPAR -kN2 echo arg1:{1} seq:'$'PARALLEL_SEQ arg2:{2}

echo '### Test -E (should only output foo ole)'
(echo foo; echo '';echo 'ole ';echo bar;echo quux) | $NICEPAR -kr -L2 -E bar echo
$NICEPAR -kr -L2 -E bar echo ::: foo '' 'ole ' bar quux

echo '### Test -r (should only output foo ole bar\nquux)'
$NICEPAR -kr -L2 echo ::: foo '' 'ole ' bar quux

echo '### Test of tab as colsep'
printf 'def\tabc\njkl\tghi' | $NICEPAR -k --colsep '\t' echo {2} {1}
$NICEPAR -k -a <(printf 'def\tabc\njkl\tghi') --colsep '\t' echo {2} {1}

EOF

