#!/bin/bash


# SSH only allowed to localhost/lo
cat <<'EOF' | parallel -vj100% --retries 3 -k --joblog /tmp/jl-`basename $0` -L1 -r
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
    --return {=s:/f:/g:=} 
    mytouch 
    ::: d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/f"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"; 
  cat d"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"/g"`perl -e 'print pack("c*",1..9,11..46,48..255)'`"

echo '### Uniq {=perlexpr=} in return - not used in command'
  cd /tmp; 
  rm -f /tmp/parallel_perlexpr.2Parallel_PerlexPr; 
  echo local > parallel_perlexpr; 
  parallel -Sparallel@lo --trc {=s/pr/pr.2/=}{=s/p/P/g=} echo remote OK '>' {}.2{=s/p/P/g=} ::: parallel_perlexpr; 
  cat /tmp/parallel_perlexpr.2Parallel_PerlexPr; 
  rm -f /tmp/parallel_perlexpr.2Parallel_PerlexPr /tmp/parallel_perlexpr

#  Should be changed to --return '{=s:/f:/g:=}' and tested with csh - is error code kept?

echo '### functions and --nice'
  myfunc() { echo OK $*; }; export -f myfunc; parallel --nice 10 --env myfunc -S parallel@lo myfunc ::: func

echo '### bug #45906: {= in header =}'
  rm -f returnfile45906; 
  parallel --rpl '{G} $_=lc($_)' -S parallel@lo --return {G} --cleanup echo {G} '>' {G} ::: RETURNFILE45906; 
  ls returnfile45906

echo "### bug #47608: parallel --nonall -S lo 'echo ::: ' blocks"
  parallel --nonall -S lo 'echo ::: '

echo '### exported function to csh but with PARALLEL_SHELL=bash'
  doit() { echo "$1"; }; 
  export -f doit; 
  stdout parallel --env doit -S csh@lo doit ::: not_OK; 
  PARALLEL_SHELL=bash parallel --env doit -S csh@lo doit ::: OK

echo '### bug #49404: "Max jobs to run" does not equal the number of jobs specified when using GNU Parallel on remote server?'
  echo should give 10 running jobs
  stdout parallel -S 16/lo --progress true ::: {1..10} | grep /.10
EOF

par_header_in_return() {
    echo '### bug #45907: --header : + --return {header}'
    rm returnfile45907
    parallel --header : -S parallel@lo --return {G} --cleanup echo {G} '>' {G} ::: G returnfile45907
    ls returnfile45907
}

par_trc_with_space() {
    echo '### Test --trc with space added in filename'
    cd
    mkdir -p tmp
    echo original > 'tmp/parallel space file'
    echo 'tmp/parallel space file' | stdout parallel --trc "{} more space" -S parallel@lo cat {} ">{}\\ more\\ space"
    cat 'tmp/parallel space file more space'
    rm 'tmp/parallel space file' 'tmp/parallel space file more space'
}

par_trc_with_special_chars() {
    echo '### Test --trc with >|< added in filename'
    cd
    mkdir -p tmp
    echo original > 'tmp/parallel space file2'
    echo 'tmp/parallel space file2' | stdout parallel --trc "{} >|<" -S parallel@lo cat {} ">{}\\ \\>\\|\\<"
    cat 'tmp/parallel space file2 >|<'
    rm 'tmp/parallel space file2' 'tmp/parallel space file2 >|<'
}

par_return_with_fixedstring() {
    echo '### Test --return with fixed string (Gave undef warnings)'
    touch a
    echo a | stdout parallel --return b -S parallel@lo echo ">b" && echo OK
    rm a b
}

par_quoting_for_onall() {
    echo '### bug #35427: quoting of {2} broken for --onall'
    echo foo: /bin/ls | parallel --colsep ' ' -S lo --onall ls {2}
}

par_hostgroup_only_on_args() {
    echo '### Auto add hostgroup if given on on argument'
    parallel --hostgroup ::: whoami@sh@lo
}

export -f $(compgen -A function | grep par_)
# Tested with -j1..8
# -j6 was fastest
#compgen -A function | grep par_ | sort | parallel --delay $D -j$P --tag -k '{} 2>&1'
compgen -A function | grep par_ | sort | parallel --delay 0.1 -j2 --tag -k '{} 2>&1'
