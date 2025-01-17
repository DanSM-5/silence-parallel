all: update upload monitorbuild
	true

update:
	# Update sha256sum
	s1=`sha256sum parallel-*.tar.bz2|field 1` \
	s2=`sha256sum parallel-*.tar.bz2.sig|field 1` \
        perl -i -pe 's/(sha256sums=..)\w+(...)\w+(..)/$$1$$ENV{s1}$$2$$ENV{s2}$$3/' PKGBUILD
	# Update version
	perl -i -pe 's/pkgver=.*/pkgver=$$ENV{YYYYMMDD}/' PKGBUILD
	osc diff

upload:
	osc up
	parallel osc add ::: *.spec *.dsc *.tar.gz *.tar.bz2 *.sig && echo Src added OK || true
	osc ci -m "New release"

monitorbuild:
	### Wait for "building" state to complete
	echo '### Wait for "building" state'
	sleep 3
	yes building | parallel -vj1 --delay 10 --halt now,success=1 'osc results|G -E {}'
	echo '### Wait for "building" state to end'
	echo '### Ignore RedHat_RHEL-6 and Univention_3.2 that are broken'
	yes building | parallel -vj1 --delay 10 --halt now,fail=1 'osc results|G -v RedHat_RHEL-6 -v Univention_3.2 -v SLE_12_SP._Backports -E {}' || true
	echo '### Wait for "finished" state of .deb'
	echo succeeded | parallel -vj1 --retries 30 --delay 10 --halt now,success=1 'osc results|G -E "(Debian|Ubuntu).*{}"'
	echo '### Wait for "finished" state of .rpm'
	echo succeeded | parallel -vj1 --retries 30 --delay 10 --halt now,success=1 'osc results|G -E "(SUSE|SLE|Scientific|RHEL|Fedora|CentOS).*{}"'
	echo 'Check:'
	echo 'https://build.opensuse.org/package/show/home:tange/parallel'
