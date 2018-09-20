#!/bin/bash

SERVER1=parallel-server1
SERVER2=lo
SSHLOGIN1=parallel@parallel-server1
SSHLOGIN2=parallel@lo
SSHLOGIN3=parallel@parallel-server2

echo '### Test use special ssh'
echo 'TODO test ssh with > 9 simultaneous'
echo 'ssh "$@"; echo "$@" >>/tmp/myssh1-run' >/tmp/myssh1
echo 'ssh "$@"; echo "$@" >>/tmp/myssh2-run' >/tmp/myssh2
chmod 755 /tmp/myssh1 /tmp/myssh2
seq 1 100 | parallel --sshdelay 0.03 --retries 10 --sshlogin "/tmp/myssh1 $SSHLOGIN1,/tmp/myssh2 $SSHLOGIN2" -k echo

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/\;s/\$SSHLOGIN1/$SSHLOGIN1/\;s/\$SSHLOGIN2/$SSHLOGIN2/\;s/\$SSHLOGIN3/$SSHLOGIN3/ | parallel -vj3 -k -L1 -r
echo '### test --timeout --retries'
  parallel -j0 --timeout 5 --retries 3 -k ssh {} echo {} ::: 192.168.1.197 8.8.8.8 $SSHLOGIN1 $SSHLOGIN2 $SSHLOGIN3

echo '### test --filter-hosts with server w/o ssh, non-existing server'
  parallel -S 192.168.1.197,8.8.8.8,$SSHLOGIN1,$SSHLOGIN2,$SSHLOGIN3 --filter-hosts --nonall -k --tag echo

echo '### bug #41964: --controlmaster not seems to reuse OpenSSH connections to the same host'
  (parallel -S redhat9.tange.dk true ::: {1..20}; echo No --controlmaster - finish last) & 
  (parallel -M -S redhat9.tange.dk true ::: {1..20}; echo With --controlmaster - finish first) & 
  wait

echo '### --filter-hosts - OK, non-such-user, connection refused, wrong host'
  parallel --nonall --filter-hosts -S localhost,NoUser@localhost,154.54.72.206,"ssh 5.5.5.5" hostname

echo '### test --workdir . in $HOME'
  cd && mkdir -p parallel-test && cd parallel-test && 
    echo OK > testfile && parallel --workdir . --transfer -S $SSHLOGIN1 cat {} ::: testfile

echo '### TODO: test --filter-hosts proxied through the one host'

echo '### bug #43358: shellshock breaks exporting functions using --env'
  echo shellshock-hardened to shellshock-hardened; 
  funky() { echo Function $1; }; 
  export -f funky; 
  parallel --env funky -S parallel@localhost funky ::: shellshock-hardened

echo '2bug #43358: shellshock breaks exporting functions using --env'
  echo shellshock-hardened to non-shellshock-hardened; 
  funky() { echo Function $1; }; 
  export -f funky; 
  parallel --env funky -S centos3.tange.dk funky ::: non-shellshock-hardened

EOF
rm /tmp/myssh1 /tmp/myssh2 /tmp/myssh1-run /tmp/myssh2-run

