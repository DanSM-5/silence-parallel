
Summary:	Shell tool for executing jobs in parallel
Name: 		parallel
Version: 	20200122
Release: 	1.3
License: 	GPL-3.0-or-later
Group: 		Productivity/File utilities
URL: 		ftp://ftp.gnu.org/gnu/parallel
Source0: 	%{name}_%{version}.tar.gz
BuildArch:	noarch
BuildRoot: 	%{_tmppath}/%{name}-%{version}-buildroot

%description
GNU Parallel is a shell tool for executing jobs in parallel using one
or more computers. A job can be a single command or a small script
that has to be run for each of the lines in the input. The typical
input is a list of files, a list of hosts, a list of users, a list of
URLs, or a list of tables. A job can also be a command that reads from
a pipe. GNU Parallel can then split the input and pipe it into
commands in parallel.

If you use xargs and tee today you will find GNU Parallel very easy to
use as GNU Parallel is written to have the same options as xargs. If
you write loops in shell, you will find GNU Parallel may be able to
replace most of the loops and make them run faster by running several
jobs in parallel.

GNU Parallel makes sure output from the commands is the same output as
you would get had you run the commands sequentially. This makes it
possible to use output from GNU Parallel as input for other programs.

For each line of input GNU Parallel will execute command with the line
as arguments. If no command is given, the line of input is
executed. Several lines will be run in parallel. GNU Parallel can
often be used as a substitute for xargs or cat | bash.

%prep
if [ "${RPM_BUILD_ROOT}x" == "x" ]; then
        echo "RPM_BUILD_ROOT empty, bad idea!"
        exit 1
fi
if [ "${RPM_BUILD_ROOT}" == "/" ]; then
        echo "RPM_BUILD_ROOT is set to "/", bad idea!"
        exit 1
fi
%setup -q

%build
./configure
make

%install
rm -rf $RPM_BUILD_ROOT
make install prefix=$RPM_BUILD_ROOT%{_prefix} exec_prefix=$RPM_BUILD_ROOT%{_prefix} \
    datarootdir=$RPM_BUILD_ROOT%{_prefix} docdir=$RPM_BUILD_ROOT%{_docdir} \
    mandir=$RPM_BUILD_ROOT%{_mandir}

rm $RPM_BUILD_ROOT%{_docdir}/parallel.html
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.html
rm $RPM_BUILD_ROOT%{_docdir}/niceload.html
rm $RPM_BUILD_ROOT%{_docdir}/sem.html
rm $RPM_BUILD_ROOT%{_docdir}/sql.html
rm $RPM_BUILD_ROOT%{_docdir}/parcat.html
rm $RPM_BUILD_ROOT%{_docdir}/parset.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel.texi
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.texi
rm $RPM_BUILD_ROOT%{_docdir}/niceload.texi
rm $RPM_BUILD_ROOT%{_docdir}/sem.texi
rm $RPM_BUILD_ROOT%{_docdir}/sql.texi
rm $RPM_BUILD_ROOT%{_docdir}/parcat.texi
rm $RPM_BUILD_ROOT%{_docdir}/parset.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel.pdf
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.pdf
rm $RPM_BUILD_ROOT%{_docdir}/niceload.pdf
rm $RPM_BUILD_ROOT%{_docdir}/sem.pdf
rm $RPM_BUILD_ROOT%{_docdir}/sql.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parcat.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parset.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_cheat_bw.pdf

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/bin/*
/usr/share/man/man1/*
/usr/share/man/man7/*
%doc README NEWS src/parallel.html src/env_parallel.html src/parallel_tutorial.html src/parallel_design.html src/parallel_alternatives.html src/parallel_book.html src/sem.html src/sql.html src/parcat.html src/parset.html src/niceload.html src/parallel.texi src/env_parallel.texi src/parallel_tutorial.texi src/parallel_design.texi src/parallel_alternatives.texi src/parallel_book.texi src/niceload.texi src/sem.texi src/sql.texi src/parcat.texi src/parset.texi src/parallel.pdf src/env_parallel.pdf src/parallel_tutorial.pdf src/parallel_design.pdf src/parallel_alternatives.pdf src/parallel_book.pdf src/niceload.pdf src/sem.pdf src/sql.pdf src/parcat.pdf src/parset.pdf src/parallel_cheat_bw.pdf

%changelog
* Sat Jan 22 2011 Ole Tange
- Upgrade to 20110122
* Wed Dec 22 2010 Ole Tange
- Upgrade to 20101222
* Wed Sep 22 2010 Ole Tange
- Upgrade to 20100922
* Mon Sep 06 2010 Ole Tange
- Upgrade to current git-version of source. Tested on build.opensuse.org 
* Fri Aug 27 2010 Ole Tange
- Untested upgrade to current git-version of source.

