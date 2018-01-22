#!/bin/bash

# -L1 will join lines ending in ' '
cat <<'EOF' | sed -e 's/;$/; /;s/$SERVER1/'$SERVER1'/;s/$SERVER2/'$SERVER2'/' | stdout parallel -vj0 -k --joblog /tmp/jl-`basename $0` -L1
echo '### bug #38354: -J profile_name should read from `pwd`/profile_name before ~/.parallel/profile_name'
  echo "echo echo from ./local_test_profile" > local_test_profile; 
  parallel --profile local_test_profile echo ::: 1; 
  rm local_test_profile

echo "### Test --delay"
seq 9 | /usr/bin/time -f %e  parallel -j3 --delay 0.57 true {} 2>&1 | 
  perl -ne '$_ > 3.3 and print "More than 3.3 secs: OK\n"'

echo '### test --sshdelay'
  stdout /usr/bin/time -f %e parallel -j0 --sshdelay 0.5 -S localhost true ::: 1 2 3 | perl -ne 'print($_ > 1.30 ? "OK\n" : "Not OK\n")'

echo "bug #37694: Empty string argument skipped when using --quote"
  parallel -q --nonall perl -le 'print scalar @ARGV' 'a' 'b' ''

echo '### Test -k 5'; 
  sleep 5

echo '### Test -k 3'; 
  sleep 3

echo '### Test -k 4'; 
  sleep 4

echo '### Test -k 2'; 
  sleep 2

echo '### Test -k 1'; 
  sleep 1

echo "### Computing length of command line"
  seq 1 2 | parallel -k -N2 echo {1} {2}
  parallel --xapply -k -a <(seq 11 12) -a <(seq 1 3) echo
  parallel -k -C %+ echo '"{1}_{3}_{2}_{4}"' ::: 'a% c %%b' 'a%c% b %d'
  parallel -k -C %+ echo {4} ::: 'a% c %%b'

echo "### test08"
  cd input-files/test08; 
  ls | parallel -q  perl -ne '/_PRE (\d+)/ and $p=$1; /hatchname> (\d+)/ and $1!=$p and print $ARGV,"\n"' | sort

seq 1 10 | parallel -j 1 echo | sort
seq 1 10 | parallel -j 2 echo | sort
seq 1 10 | parallel -j 3 echo | sort

echo "bug #37956: --colsep does not default to '\t' as specified in the man page."
  printf "A\tB\n1\tone" | parallel --header : echo {B} {A}

echo '### Test --tollef'
  stdout parallel -k --tollef echo -- 1 2 3 ::: a b c | sort

echo '### Test --tollef --gnu'
  stdout parallel -k --tollef --gnu echo ::: 1 2 3 -- a b c

echo '### Test --gnu'
  parallel -k --gnu echo ::: 1 2 3 -- a b c

echo '### Test {//}'
  parallel -k echo {//} {} ::: a a/b a/b/c
  parallel -k echo {//} {} ::: /a /a/b /a/b/c
  parallel -k echo {//} {} ::: ./a ./a/b ./a/b/c
  parallel -k echo {//} {} ::: a.jpg a/b.jpg a/b/c.jpg
  parallel -k echo {//} {} ::: /a.jpg /a/b.jpg /a/b/c.jpg
  parallel -k echo {//} {} ::: ./a.jpg ./a/b.jpg ./a/b/c.jpg

echo '### Test {1//}'
  parallel -k echo {1//} {} ::: a a/b a/b/c
  parallel -k echo {1//} {} ::: /a /a/b /a/b/c
  parallel -k echo {1//} {} ::: ./a ./a/b ./a/b/c
  parallel -k echo {1//} {} ::: a.jpg a/b.jpg a/b/c.jpg
  parallel -k echo {1//} {} ::: /a.jpg /a/b.jpg /a/b/c.jpg
  parallel -k echo {1//} {} ::: ./a.jpg ./a/b.jpg ./a/b/c.jpg

echo '### Test --dnr'
  parallel --dnr II -k echo II {} ::: a a/b a/b/c

echo '### Test --dirnamereplace'
  parallel --dirnamereplace II -k echo II {} ::: a a/b a/b/c

echo '### Test https://savannah.gnu.org/bugs/index.php?31716'
  seq 1 5 | stdout parallel -k -l echo {} OK
  seq 1 5 | stdout parallel -k -l 1 echo {} OK

echo '### -k -l -0'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -l -0 echo {} OK

echo '### -k -0 -l'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -l echo {} OK

echo '### -k -0 -l 1'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -l 1 echo {} OK

echo '### -k -0 -l 0'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -l 0 echo {} OK

echo '### -k -0 -L -0 - -0 is argument for -L'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -L -0 echo {} OK

echo '### -k -0 -L 0 - -L always takes arg'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -L 0 echo {} OK

echo '### -k -0 -L 0 - -L always takes arg'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -L 0 -0 echo {} OK

echo '### -k -e -0'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -e -0 echo {} OK

echo '### -k -0 -e eof'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -e eof echo {} OK

echo '### -k -i -0'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -i -0 echo {} OK

echo '### -k -0 -i repl'
  printf '1\0002\0003\0004\0005\000' | stdout parallel -k -0 -i repl echo repl OK

echo '### Negative replacement strings'
  parallel -X -j1 -N 6 echo {-1}orrec{1} ::: t B X D E c
  parallel -N 6 echo {-1}orrect ::: A B X D E c
  parallel --colsep ' ' echo '{2} + {4} = {2} + {-1}=' '$(( {2} + {-1} ))' ::: "1 2 3 4"
  parallel --colsep ' ' echo '{-3}orrect' ::: "1 c 3 4"

echo 'bug #38439: "open files" with --files --pipe blocks after a while'
  ulimit -n 20; yes "`seq 3000`" |head -c 20M | parallel --pipe -k echo {#} of 21

echo 'bug #34241: --pipe should not spawn unneeded processes - part 2'
  seq 500 | parallel --tmpdir . -j10 --pipe --block 1k --files wc >/dev/null; 
  ls *.par | wc -l; rm *.par; 
  seq 500 | parallel --tmpdir . -j10 --pipe --block 1k --files --dry-run wc >/dev/null; 
  echo No .par should exist; 
  stdout ls *.par

echo "bug: --gnu was ignored if env var started with space: PARALLEL=' --gnu'"
  export PARALLEL=" -v" &&  parallel echo ::: 'space in envvar OK'

EOF
