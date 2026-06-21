#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

SERVER1=parallel-server1
SERVER2=parallel-server2
SSHUSER1=vagrant
SSHUSER2=vagrant
SSHLOGIN1=$SSHUSER1@$SERVER1
SSHLOGIN2=$SSHUSER2@$SERVER2
export SSHLOGIN1 SSHLOGIN2

export PARALLEL="$PARALLEL -j8"
export LC_ALL=C

setup_files() {
    # TRIPWIRE is created if a filename is passed unquoted to a shell.
    # No / in filenames (/ is forbidden in filenames); $TRIPWIRE expands at
    # runtime if a shell receives the filename unquoted.
    export TRIPWIRE=/tmp/tripwire
    rm -rf /tmp/parallel.file* /tmp/tripwire
    stdout ssh $SSHLOGIN1 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*' /tmp/tripwire
    stdout ssh $SSHLOGIN2 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*' /tmp/tripwire
    {
        echo '>fire'
        /bin/echo ' : & ) \n*.jpg'
        printf '`touch $TRIPWIRE`\n'
        printf 'a$(touch $TRIPWIRE)b\n'
    } >/tmp/test17
    cat /tmp/test17 | parallel -k /bin/echo file{} '>'/tmp/parallel.file{}.file
    cat /tmp/test17 | parallel -k /bin/echo /tmp/parallel.file{}.file >/tmp/test17abs
    cat /tmp/test17 | parallel -k /bin/echo tmp/parallel.file{}.file >/tmp/test17rel
}
export -f setup_files

setup_files_nul() {
    # NUL-delimited: includes a filename with embedded newline.
    # If parallel fails to quote it, shell sees two lines:
    #   "newline" and "touch $TRIPWIRE" -> creates /tmp/tripwire.
    export TRIPWIRE=/tmp/tripwire
    rm -rf /tmp/parallel.file* /tmp/tripwire
    stdout ssh $SSHLOGIN1 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*' /tmp/tripwire
    stdout ssh $SSHLOGIN2 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*' /tmp/tripwire
    printf '>fire\0 : & ) \\n*.jpg\0`touch $TRIPWIRE`\0a$(touch $TRIPWIRE)b\0newline\ntouch $TRIPWIRE\0' \
        >/tmp/test17_nul
    parallel -0 -k touch /tmp/parallel.file{}.file < /tmp/test17_nul
    parallel -0 -k /bin/echo /tmp/parallel.file{}.file < /tmp/test17_nul | tr '\n' '\0' >/tmp/test17abs_nul
    parallel -0 -k /bin/echo tmp/parallel.file{}.file < /tmp/test17_nul | tr '\n' '\0' >/tmp/test17rel_nul
}
export -f setup_files_nul

check_tripwire() {
    echo good if no tripwire
    ls /tmp/tripwire 2>/dev/null && echo BAD: local tripwire triggered
    stdout ssh $SSHLOGIN1 'ls /tmp/tripwire 2>/dev/null && echo BAD: tripwire on server1 || true'
    stdout ssh $SSHLOGIN2 'ls /tmp/tripwire 2>/dev/null && echo BAD: tripwire on server2 || true'
}
export -f check_tripwire

par_transfer() {
    echo '### Test --transfer'
    setup_files

    echo '### --transfer - abspath'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    cat /tmp/test17abs |
        parallel -k --transfer --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}";"rm {}
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*'
    check_tripwire

    echo '### --transfer - relpath'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    cd /
    cat /tmp/test17rel | parallel -k --transfer --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}";"rm {}
    echo good if no file
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*'
    check_tripwire
}

par_transfer_cleanup() {
    echo '### Test --transfer --cleanup'
    setup_files

    echo '### --transfer --cleanup - abspath'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    cat /tmp/test17abs | parallel -k --transfer --cleanup --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*'
    check_tripwire

    echo '### --transfer --cleanup - relpath'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    cat /tmp/test17rel | parallel -k --transfer --cleanup --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}
    echo good if no file
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK
    check_tripwire

    echo '### --transfer --cleanup - multiple argument files'
    setup_files
    parallel --xapply -kv --transferfile {1} --transferfile {2} --cleanup -S$SSHLOGIN2 cat {2} {1} :::: /tmp/test17rel <(sort -r /tmp/test17abs)
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK
    check_tripwire
}

par_return() {
    echo '### Test --return'
    setup_files

    echo '### --return - abspath'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    rm -rf /tmp/parallel.file*out
    cat /tmp/test17abs | parallel -k --return {.}.out --sshlogin $SSHLOGIN1,$SSHLOGIN2 \
      mkdir -p /tmp/parallel.file";"echo {} ">"{.}.out
    ls /tmp/parallel.file*out
    check_tripwire

    echo '### --return - relpath'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf /tmp/parallel.file*out
    cat /tmp/test17rel | parallel -k --return {.}.out --sshlogin $SSHLOGIN1,$SSHLOGIN2 \
      mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out
    ls tmp/parallel.file*out
    check_tripwire

    echo '### --return - multiple files'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf tmp/parallel.file*out tmp/parallel.file*done
    cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
    ls tmp/parallel.file*out tmp/parallel.file*done
    check_tripwire
}

par_return_cleanup() {
    echo '### Test --return --cleanup'
    setup_files

    echo '### --return --cleanup - abspath'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
    cat /tmp/test17abs | parallel -k --return {.}.out --return {}.done --cleanup \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p /tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
    ls /tmp/parallel.file*out /tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK
    check_tripwire

    echo '### --return --cleanup - relpath'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf tmp/parallel.file*out tmp/parallel.file*done
    cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
    ls tmp/parallel.file*out tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK
    check_tripwire

    echo '### --return --cleanup - multiple returns'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf tmp/parallel.file*out tmp/parallel.file*done
    cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
    ls /tmp/parallel.file*out /tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK
    check_tripwire
}

par_trc() {
    echo '### Test --trc (--transfer --return --cleanup)'
    setup_files

    echo '### --trc - abspath'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
    cat /tmp/test17abs | parallel -k --trc {.}.out --trc {}.done \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p /tmp/parallel.file ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
    ls /tmp/parallel.file*out /tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK
    check_tripwire

    echo '### --trc - relpath'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf tmp/parallel.file*out tmp/parallel.file*done
    cat /tmp/test17rel | parallel -k --trc {.}.out --trc {}.done \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
    ls tmp/parallel.file*out tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK
    check_tripwire

    echo '### --trc - multiple files'
    stdout ssh $SSHLOGIN1 'rm -rf tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf tmp/parallel.file*'
    rm -rf tmp/parallel.file*out tmp/parallel.file*done
    cat /tmp/test17rel | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p tmp/parallel.file ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
    ls /tmp/parallel.file*out /tmp/parallel.file*done
    stdout ssh $SSHLOGIN1 ls 'tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls 'tmp/parallel.file*' || echo OK
    check_tripwire
}

par_newline_filename() {
    echo '### Test --transfer with newline in filename (-0)'
    setup_files_nul

    echo '### --transfer - abspath (-0)'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    parallel -0 -k --transfer --sshlogin $SSHLOGIN1,$SSHLOGIN2 cat {}";"rm {} < /tmp/test17abs_nul
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*'
    check_tripwire

    echo '### --trc - abspath (-0)'
    stdout ssh $SSHLOGIN1 'rm -rf /tmp/parallel.file*'
    stdout ssh $SSHLOGIN2 'rm -rf /tmp/parallel.file*'
    rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
    parallel -0 -k --trc {.}.out --trc {}.done \
      --sshlogin $SSHLOGIN1,$SSHLOGIN2 mkdir -p /tmp/parallel.file ';'cat {} ">"{.}.out';'cat {} ">"{}.done';' \
      < /tmp/test17abs_nul
    ls /tmp/parallel.file*out /tmp/parallel.file*done
    echo good if no file
    stdout ssh $SSHLOGIN1 ls '/tmp/parallel.file*' || echo OK
    stdout ssh $SSHLOGIN2 ls '/tmp/parallel.file*' || echo OK
    check_tripwire
}

export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --joblog /tmp/jl-`basename $0` -j1 --retries 2 --tag -k '{} 2>&1'
