#!/bin/bash

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

# -L1 will join lines ending in ' '
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/\;s/\$SSHLOGIN1/$SSHLOGIN1/\;s/\$SSHLOGIN2/$SSHLOGIN2/ | parallel -vj10 -k --joblog /tmp/jl-`basename $0` -L1 -r
echo '### Test --onall'; 
  parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c ::: 1 2

echo '### Test | --onall'; 
  seq 3 | parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c :::: -

echo '### Test --onall -u'; 
  parallel --onall -S $SSHLOGIN1,$SSHLOGIN2 -u '(echo {1} {2}) | awk \{print\ \$2}' ::: a b c ::: 1 2 3 | sort

echo '### Test --nonall'; 
  parallel --nonall -k -S $SSHLOGIN1,$SSHLOGIN2 'hostname' | sort

echo '### Test --nonall -u - should be interleaved x y x y'; 
  parallel --nonall --sshdelay 2 -S $SSHLOGIN1,$SSHLOGIN2 -u 'hostname|grep -q centos && sleep 2; hostname;sleep 4;hostname;'

echo '### Test read sshloginfile from STDIN'; 
  echo $SSHLOGIN1 | parallel -S - --nonall hostname; 
  echo $SSHLOGIN1 | parallel --sshloginfile - --nonall hostname

echo '### Test --nonall --basefile'; 
  touch /tmp/nonall--basefile; 
  parallel --nonall --basefile /tmp/nonall--basefile -S $SSHLOGIN1,$SSHLOGIN2 ls /tmp/nonall--basefile\; rm  /tmp/nonall--basefile; 
  rm /tmp/nonall--basefile

echo '### Test --onall --basefile'; 
  touch /tmp/onall--basefile; 
  parallel --onall --basefile /tmp/onall--basefile -S $SSHLOGIN1,$SSHLOGIN2 ls {}\; rm {} ::: /tmp/onall--basefile; 
  rm /tmp/onall--basefile

echo '### Test --workdir .'; 
  ssh $SSHLOGIN1 mkdir -p mydir; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir . -S $SSHLOGIN1 ::: pwd

echo '### Test --wd .'; 
  ssh $SSHLOGIN2 mkdir -p mydir; 
  mkdir -p $HOME/mydir; cd $HOME/mydir; 
  parallel --workdir . -S $SSHLOGIN2 ::: pwd
EOF
