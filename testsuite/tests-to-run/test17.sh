#!/bin/bash

# SPDX-FileCopyrightText: 2021-2025 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

SERVER1=parallel-server1
SERVER2=parallel-server2
SSHUSER1=vagrant
SSHUSER2=vagrant
SSHLOGIN1=$SSHUSER1@$SERVER1
SSHLOGIN2=$SSHUSER2@$SERVER2

#SERVER1=parallel-server1
#SERVER2=parallel-server2
#SSHLOGIN1=parallel@$SERVER1
#SSHLOGIN2=parallel@$SERVER2

export PARALLEL="$PARALLEL -j0"
#export PARALLEL="--sshdelay 0.3"
# Make sure sort order is the same
export LC_ALL=C

echo '### Test --transfer --return --cleanup'

rm -rf /tmp/parallel.file*
stdout ssh $SSHLOGIN1 rm -rf 'tmp/parallel.file*'  '/tmp/parallel.file*'
stdout ssh $SSHLOGIN2 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*'
# (seq 1 3;echo '>fire';seq 5 10; /bin/echo ' : & ) \n*.jpg'; echo '/./sub dir'; seq 13 20) >/tmp/test17
(echo '>fire';/bin/echo ' : & ) \n*.jpg') >/tmp/test17
echo '# Create some weirdly files in /tmp'
cat /tmp/test17 | parallel -k /bin/echo file{} '>'/tmp/parallel.file{}.file
cat /tmp/test17 | parallel -k /bin/echo /tmp/parallel.file{}.file >/tmp/test17abs
cat /tmp/test17 | parallel -k /bin/echo tmp/parallel.file{}.file >/tmp/test17rel

echo '### --transfer - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
cat /tmp/test17abs | parallel -k --transfer --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}";"rm {}
# One of these should give the empty dir /tmp/parallel.file
echo good if no file
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*'
# The other: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*'

echo '### --transfer - relpath'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
cd /
cat /tmp/test17rel | parallel -k --transfer --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}";"rm {}
# Should give: No such file or directory
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*'
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*'

echo '### --transfer --cleanup - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
cat /tmp/test17abs | parallel -k --transfer --cleanup --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}
echo good if no file
# Should give: No such file or directory
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*'
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*'

echo '### --transfer --cleanup - relpath'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
cat /tmp/test17rel | parallel -k --transfer --cleanup --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}
# Should give: No such file or directory
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK

echo '### --return - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
rm -rf /tmp/parallel.file*out
cat /tmp/test17abs | parallel -k --return {.}.out --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p /tmp/parallel.file";"echo {} ">"{.}.out
stdout ls /tmp/parallel.file*out

echo '### --return - relpath'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf /tmp/parallel.file*out
cat /tmp/test17rel | parallel -k --return {.}.out --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out
stdout ls tmp/parallel.file*out

echo '### --return - multiple files'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf tmp/parallel.file*out tmp/parallel.file/*out tmp/parallel.file*done tmp/parallel.file/*done
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
stdout ls tmp/parallel.file*out tmp/parallel.file*done

echo '### --return --cleanup - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
rm -rf /tmp/parallel.file*out /tmp/parallel.file/*out /tmp/parallel.file*done /tmp/parallel.file/*done
cat /tmp/test17abs | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p /tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK

echo '### --return --cleanup - relpath'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
stdout ls tmp/parallel.file*out tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK

echo '### --return --cleanup - multiple returns'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*'
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*'

echo '### --transfer --return --cleanup - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK

echo '### --transfer --return --cleanup - relpath'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK

echo '### --transfer --return --cleanup - multiple files'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK

echo '### --trc - abspath'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK

echo '### --trc - relpath'
stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls tmp/parallel.file*out tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK

echo '### --trc - multiple files'
stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
stdout ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK

echo '### --transfer --cleanup - multiple argument files'
parallel --xapply -kv --transferfile {1} --transferfile {2} --cleanup -S$SSHLOGIN2 cat {2} {1} :::: /tmp/test17rel <(sort -r /tmp/test17abs)
# Should give: No such file or directory
stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK

