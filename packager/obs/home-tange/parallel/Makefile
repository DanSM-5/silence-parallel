all:
	# Update sha256sum
	s=`sha256sum parallel-*.tar.bz2|field 1` perl -i -pe 's/(sha256sums=..)\w+(..)/$$1$$ENV{s}$$2/' PKGBUILD
	# Update version
	perl -i -pe 's/pkgver=.*/pkgver=$$ENV{YYYYMMDD}/' PKGBUILD
	osc diff
	osc up
	parallel osc add ::: *.spec *.dsc *.tar.gz *.tar.bz2 && echo Src added OK || true
	osc ci -m "New release"
	### Wait for "building" state to complete
	echo '### Wait for "building" state'
	sleep 3
	yes building | parallel -vj1 --delay 10 --halt now,success=1 'osc results|G -E {}'
	echo '### Wait for "building" state to end'
	echo '### Ignore RedHat_RHEL-6 and Univention_3.2 that are broken'
	yes building | parallel -vj1 --delay 10 --halt now,fail=1 'osc results|G -v RedHat_RHEL-6 -v Univention_3.2 -E {}' || true
	echo '### Wait for "finished" state of .deb'
	echo succeeded | parallel -vj1 --retries 30 --delay 10 --halt now,success=1 'osc results|G -E "(Debian|Ubuntu).*{}"'
	echo '### Wait for "finished" state of .rpm'
	echo succeeded | parallel -vj1 --retries 30 --delay 10 --halt now,success=1 'osc results|G -E "(SUSE|SLE|Scientific|RHEL|Fedora|CentOS).*{}"'
	echo 'Check:'
	echo 'https://build.opensuse.org/package/show/home:tange/parallel'
