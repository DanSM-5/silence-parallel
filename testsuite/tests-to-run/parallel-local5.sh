#!/bin/bash

# SPDX-FileCopyrightText: 2021-2024 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

echo '### Test --pipe'
# Make some pseudo random input that stays the same
seq 1 1000000 >/tmp/parallel-seq
shuf --random-source=/tmp/parallel-seq /tmp/parallel-seq >/tmp/blocktest

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj2 -k --joblog /tmp/jl-`basename $0` -L1 -r
echo '### Test 200M records with too small block'; 
  ( 
   echo start; 
   seq 1 44 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
   echo start; 
   seq 1 44 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
   echo start; 
   seq 1 44 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
  ) | stdout parallel -k --block 200m -j2 --pipe --recend 'end\n' wc -c | 
  egrep -v '^0$'

echo '### Test -N with multiple jobslots and multiple args'
seq 1 1 | parallel -j2 -k -N 3 --pipe 'cat;echo a'
seq 1 2 | parallel -j2 -k -N 3 --pipe 'cat;echo bb'
seq 1 3 | parallel -j2 -k -N 3 --pipe 'cat;echo ccc'
seq 1 4 | parallel -j2 -k -N 3 --pipe 'cat;echo dddd'
seq 1 5 | parallel -j2 -k -N 3 --pipe 'cat;echo eeeee'
seq 1 6 | parallel -j2 -k -N 3 --pipe 'cat;echo ffffff'
seq 1 7 | parallel -j2 -k -N 3 --pipe 'cat;echo ggggggg'
seq 1 8 | parallel -j2 -k -N 3 --pipe 'cat;echo hhhhhhhh'
seq 1 9 | parallel -j2 -k -N 3 --pipe 'cat;echo iiiiiiiii'
seq 1 10 | parallel -j2 -k -N 3 --pipe 'cat;echo jjjjjjjjjj'

echo '### Test -l -N -L and -n with multiple jobslots and multiple args'
seq 1 12 | parallel -kj20 -l 2 --block 8 --pipe "cat; echo a"
seq 1 5 | parallel -kj2 -N 2 --pipe "cat; echo b"
seq 1 5 | parallel -kj2 -n 2 --pipe "cat; echo d"

echo '### Test -L --pipe'
seq 1 5 | parallel -kj2 -L 2 --pipe "cat; echo c"

echo '### Test output is the same for different block size'
echo -n 01a02a0a0a12a34a45a6a | 
  parallel -k -j1 --blocksize 100 --pipe --recend a  -N 3  'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'
echo -n 01a02a0a0a12a34a45a6a | 
  stdout parallel -k -j1 --blocksize 1 --pipe --recend a  -N 3  'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'

echo '### Test 10M records with too big block'; 
  ( 
   echo start; 
   seq 1 1 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
   echo start; 
   seq 1 1 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
   echo start; 
   seq 1 1 | parallel -uj1 cat /tmp/blocktest\;true; 
   echo end; 
  ) | stdout parallel -k --block 10M -j2 --pipe --recstart 'start\n' wc -c | 
  egrep -v '^0$'

echo '### Test --rrs -N1 --recend single'; 
  echo 12a34a45a6 | 
  parallel -k --pipe --recend a -N1 --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'
echo '### Test --rrs -N1 --regexp --recend alternate'; 
  echo 12a34b45a6 | 
  parallel -k --pipe --regexp --recend 'a|b' -N1 --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'
echo '### Test --rrs -N1 --recend single'; 
  echo 12a34b45a6 | 
  parallel -k --pipe --recend 'b' -N1 --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'

echo '### Test --rrs --recend single'; 
  echo 12a34a45a6 | 
  parallel -k --pipe --recend a --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'
echo '### Test --rrs --regexp --recend alternate'; 
  echo 12a34b45a6 | 
  parallel -k --pipe --regexp --recend 'a|b' --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'
echo '### Test --rrs --recend single'; 
  echo 12a34b45a6 | 
  parallel -k --pipe --recend 'b' --rrs 'echo -n "$PARALLEL_SEQ>"; cat; echo; sleep 0.1'

echo '### Test -N even'; 
  seq 1 10 | parallel -j2 -k -N 2 --pipe cat";echo ole;sleep 0.\$PARALLEL_SEQ"

echo '### Test -N odd'; 
  seq 1 11 | parallel -j2 -k -N 2 --pipe cat";echo ole;sleep 0.\$PARALLEL_SEQ"

echo '### Test -N even+2'; 
  seq 1 12 | parallel -j2 -k -N 2 --pipe cat";echo ole;sleep 1.\$PARALLEL_SEQ"

echo '### Test --recstart + --recend'; 
  cat /tmp/blocktest | parallel --block 1M -k --recstart 44 --recend "44" -j10 --pipe sort -n |md5sum

echo '### Race condition bug - 1 - would block'; 
  seq 1 80  | nice parallel -j0 'seq 1 10| parallel --block 1 --recend "" --pipe cat;true' >/dev/null

echo '### Race condition bug - 2 - would block'; 
  seq 1 100 | nice parallel -j100 --block 1 --recend "" --pipe cat >/dev/null

echo '### Test --block size=1'; 
  seq 1 10| TMPDIR=/tmp parallel --block 1 --files --recend ""  --pipe sort -n | parallel -Xj1 sort -nm {} ";"rm {}

echo '### Test --block size=1M -j10 --files - more jobs than data'; 
  sort -n < /tmp/blocktest | md5sum; 
  cat /tmp/blocktest | TMPDIR=/tmp parallel --files --recend "\n" -j10 --pipe sort -n | parallel -Xj1 sort -nm {} ";"rm {} | md5sum

echo '### Test --block size=1M -j1 - more data than cpu'; 
  cat /tmp/blocktest | TMPDIR=/tmp parallel --files --recend "\n" -j1 --pipe sort -n | parallel -Xj1 sort -nm {} ";"rm {} | md5sum

echo '### Test --block size=1M -j1 - more data than cpu'; 
  cat /tmp/blocktest | TMPDIR=/tmp parallel --files --recend "\n" -j2 --pipe sort -n | parallel -Xj1 sort -nm {} ";"rm {} | md5sum

echo '### Test --pipe default settings'; 
  cat /tmp/blocktest | parallel --pipe sort | sort -n | md5sum

echo '### bug #44350: --tagstring should support \t'; 
  parallel -k --tagstring 'a\tb' echo ::: c
  parallel -k -d '\t' echo ::: 'a	b'
  parallel -k -d '"' echo ::: 'a"b'
EOF

rm /tmp/parallel-seq /tmp/blocktest
