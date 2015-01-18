#!/bin/bash

# SSH only allowed to localhost/lo
cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | parallel -vj2 -k --joblog /tmp/jl-`basename $0` -L1
echo '### --hostgroup force ncpu'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.2{} ::: {1..8} | sort

echo '### --hostgroup two group arg'
  parallel -k --sshdelay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.3{} ::: {1..8}@g1+g2 | sort

echo '### --hostgroup one group arg'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g2/3/lo whoami\;sleep 0.2{} ::: {1..8}@g2

echo '### --hostgroup multiple group arg + unused group'
  parallel --delay 0.1 --hgrp -S @g1/1/parallel@lo -S @g1/3/lo -S @g3/100/tcsh@lo whoami\;sleep 0.2{} ::: {1..8}@g1+g2 | sort

echo '### --hostgroup two groups @'
  parallel -k --hgrp -S @g1/parallel@lo -S @g2/lo --tag whoami\;echo ::: parallel@g1 tange@g2

echo '### --hostgroup'
  parallel -k --hostgroup -S @grp1/lo echo ::: no_group explicit_group@grp1 implicit_group@lo

echo '### --hostgroup --sshlogin with @'
  parallel -k --hostgroups -S parallel@lo echo ::: no_group implicit_group@parallel@lo

echo '### --hostgroup -S @group'
  parallel -S @g1/ -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### --hostgroup -S @group1 -Sgrp2'
  parallel -S @g1/ -S @g2 -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### --hostgroup -S @group1+grp2'
  parallel -S @g1+g2 -S @g1/1/tcsh@lo -S @g1/1/localhost -S @g2/1/parallel@lo whoami\;true ::: {1..6} | sort

echo '### trailing space in sshlogin'
  echo 'sshlogin trailing space' | parallel  --sshlogin "ssh -l parallel localhost " echo

echo '### Special char file and dir transfer return and cleanup'
  cd /tmp; 
  mkdir -p d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  echo local > d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  ssh parallel@lo rm -rf d'*'/; 
  mytouch() { 
    cat d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`" > d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
    echo remote OK >> d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  }; 
  export -f mytouch; 
  parallel --env mytouch -Sparallel@lo --transfer 
  --return d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`" 
    mytouch 
    ::: d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  cat d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 


#  Should be changed to --return '{=s:/f:/g:=}' and tested with csh

EOF
