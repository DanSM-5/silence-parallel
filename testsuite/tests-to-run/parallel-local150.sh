#!/bin/bash

rsync -Ha --delete input-files/segfault/ tmp/
cd tmp

median() { perl -e '@a=sort {$a<=>$b} <>;print $a[$#a/2]';} 
export -f median

# -L1 will join lines ending in ' '
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1 -r
echo '### bug #41565: Print happens in blocks - not after each job complete'
echo 'The timing here is important: a full second between each'
  perl -e 'for(1..30){print("$_\n");`sleep 1`}' | parallel -j3  'echo {#}' | timestamp -dd | perl -pe '$_=int($_+0.3)."\n"' | median
echo '300 ms jobs:'
  perl -e 'for(1..30){print("$_\n");`sleep .3`}' | parallel -j3 --delay 0.3 echo | timestamp -d -d | perl -pe 's/(.....).*/int($1*10+0.2)/e' | median

echo '### Test --tagstring'
  nice parallel -j1 -X -v --tagstring a{}b echo  ::: 3 4
  nice parallel -j1 -k -v --tagstring a{}b echo  ::: 3 4
  nice parallel -j1 -k -v --tagstring a{}b echo job{#} ::: 3 4
  nice parallel -j1 -k -v --tagstring ajob{#}b echo job{#} ::: 3 4

echo '### Bug in --load'; 
  nice parallel -k --load 30 sleep 0.1\;echo ::: 1 2 3

echo '### Test --timeout'
  nice parallel -j0 -k --timeout 2 echo {}\; sleep {}\; echo {} ::: 1.1 7.7 8.8 9.9

echo '### Test retired'
  stdout parallel -B foo
  stdout parallel -g
  stdout parallel -H 1
  stdout parallel -T
  stdout parallel -U foo
  stdout parallel -W foo
  stdout parallel -Y

echo '### Test --joblog followed by --resume --joblog'
  rm -f /tmp/joblog; 
  timeout -k 1 1 parallel -j2 --joblog /tmp/joblog sleep {} ::: 1.1 2.2 3.3 4.4 2>/dev/null; 
  parallel -j2 --resume --joblog /tmp/joblog sleep {} ::: 1.1 2.2 3.3 4.4; 
  cat /tmp/joblog | wc -lw; 
  rm -f /tmp/joblog;

echo '### Test --resume --joblog followed by --resume --joblog'; 
  rm -f /tmp/joblog2; 
  timeout -k 1 1 parallel -j2 --resume --joblog /tmp/joblog2 sleep {} ::: 1.1 2.2 3.3 4.4 2>/dev/null; 
  parallel -j2 --resume --joblog /tmp/joblog2 sleep {} ::: 1.1 2.2 3.3 4.4; 
  cat /tmp/joblog2 | wc -lw; 
  rm -f /tmp/joblog2;

echo '### Test --header'
  printf "a\tb\n1.2\t3/4.5" | parallel --colsep "\t" --header "\n" echo {b} {a} {b.} {b/} {b//} {b/.}

echo '### 64-bit wierdness - this did not complete on a 64-bit machine'; 
  seq 1 2 | parallel -j1 'seq 1 1 | parallel true'

echo "### BUG-fix: bash -c 'parallel -a <(seq 1 3) echo'"
  stdout bash -c 'parallel -k -a <(seq 1 3)  echo'

echo "### bug #35268: shell_quote doesn't treats [] brackets correctly"
  touch /tmp/foo1; 
  stdout parallel echo ::: '/tmp/foo[123]'; 
  rm /tmp/foo1

echo '### Test make .deb package'; 
  cd ~/privat/parallel/packager/debian; 
  stdout make | grep 'To install the GNU Parallel Debian package, run:'

echo '### Test of segfaulting issue'
  echo 'This gave ~/bin/stdout: line 3: 20374 Segmentation fault      "$@" 2>&1'; 
  echo 'before adding wait() before exit'; 
  seq 1 300 | stdout parallel ./trysegfault

echo '### Test basic --arg-sep'
  parallel -k echo ::: a b

echo '### Run commands using --arg-sep'
  parallel -kv ::: 'echo a' 'echo b'

echo '### Change --arg-sep'
  parallel --arg-sep ::: -kv ::: 'echo a' 'echo b'
  parallel --arg-sep .--- -kv .--- 'echo a' 'echo b'
  parallel --argsep ::: -kv ::: 'echo a' 'echo b'
  parallel --argsep .--- -kv .--- 'echo a' 'echo b'

echo '### Test stdin goes to first command only'
  echo via cat |parallel --arg-sep .--- -kv .--- 'cat' 'echo b'
  echo via cat |parallel -kv ::: 'cat' 'echo b'

echo '### Bug made 4 5 go before 1 2 3'
  parallel -k ::: "sleep 1; echo 1" "echo 2" "echo 3" "echo 4" "echo 5"

echo '### Bug made 3 go before 1 2'
  parallel -kj 1 ::: "sleep 1; echo 1" "echo 2" "echo 3"

echo '### Bug did not quote'
  echo '>' | parallel -v echo
  parallel -v echo ::: '>'
  (echo '>'; echo  2) | parallel -j1 -vX echo
  parallel -X -j1 echo ::: '>' 2

echo '### Must not quote'; 
  echo 'echo | wc -l' | parallel -v
  parallel -v ::: 'echo | wc -l'
  echo 'echo a b c | wc -w' | parallel -v
  parallel -kv ::: 'echo a b c | wc -w' 'echo a b | wc -w'

echo '### Test bug #35820: sem breaks if $HOME is not writable'
  echo 'Workaround: use another writable dir'; 
  rm -rf /tmp/.parallel || echo /tmp/.parallel wrong owner?; 
  HOME=/tmp sem echo OK; 
  HOME=/tmp sem --wait; 
  ssh lo 'HOME=/usr/this/should/fail stdout sem echo should fail'
EOF
