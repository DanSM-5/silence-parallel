#!/bin/bash

# SPDX-FileCopyrightText: 2021-2023 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Simple jobs that never fails
# Each should be taking 3-10s and be possible to run in parallel
# I.e.: No race conditions, no logins

par__test_cpu_detection_topology() {
    pack() { zstd -19 | mmencode; }
    unpack() { mmencode -u | zstd -d; }
    repack() { tmp=$(mktemp -d); cd "$tmp" && unpack | tar x && tar c . | pack; }
    export -f unpack
    # ssh s "(cd /sys/devices/system/cpu; tar c cpu*/topology)" | pack | repack
    # repack due to: File shrank by 4093 bytes; padding with zeros

    cpu18() {
	echo '1-4-8-4 Lenovo E540 i7-4712MQ'
	echo '
	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
	2w==
	'
    }
    export -f $(compgen -A function | grep ^cpu)
    
    test_one() {
	eval $1 | head -n1
	export PARALLEL_CPUPREFIX=$(mktemp -d)
	cd "$PARALLEL_CPUPREFIX" && eval $1 | tail -n +2 | unpack | tar xf -
	echo $(parallel --number-of-sockets) \
	     $(parallel --number-of-cores) \
	     $(parallel --number-of-threads) \
	     $(parallel --number-of-cpus)
	rm -r "$PARALLEL_CPUPREFIX"
    }
    export -f test_one
    compgen -A function | grep ^cpu | sort | parallel -j0 -k test_one
    rm ~/.parallel/tmp/sshlogin/*/cpuspec 2>/dev/null
}

par__test_cpu_detection_cpuinfo() {
    pack() { zstd -19 | mmencode; }
    unpack() { mmencode -u | zstd -d; }
    export -f unpack
    # ssh server cat /proc/cpuinfo | pack

    cpu1() {
	echo '2-8-8-8 Xeon 8 core server in Germany'
	echo '
	KLUv/QRYbRIARmlzIxBtqgDhSWTqT86MkL9zqf+EhavXzwbElKKZVR0oAgBg5J4gcQBiAGEA
	sLnXDwczA4YzTNLcWTvx+utwzbFmQQYUDEZyZ60JhQYkubMk+Zi3NptQSECQAeUFvwJhFAiH
	cDh4wAOAnBvxgAeAO2tjk1+UO2vBhWZkzZ31gC+26BM7BrfKhZVvkptwZ0HvoROSSzHkzqKz
	e92kzALNss2vjU/N6N5c/Ep8Sms8b5+gcl8Xv41PO951/TZ/oW+kPnF0Z62WGmQJtiR3Flxq
	4aE3sZPzVV5X7TNxxHofd9aaOGLIncP26pPPPW5Lp/vEbkHvS6djzJ3Vknyw8ZohD81Bjw7i
	U67Vm6RyX7a7r8T6KlKH7J6GTmd9csYzTW+F/iQfmlN6eOm7Nt6N5csZI7r8OBxtd12fKltt
	Od0jfCUPYXP96G+DH+ur491XtvvbfdpV9CrGP3btXaE7eoIRdA/MYrEsFE2jNIxCkSgUhkES
	ZlmWZVEURUGSJEmYU+XGlZps8XQlJjPYpkofxVzgXV/jBN1LIagxprmzqtwopQfbw7AFMoAw
	GMud1fzilGaDPeqj81GuFkZ/UVKXmFBz9EO5PsIncjT4pVpXTx5mux83IFADQJsOKpW46nns
	Is7U2ZTFVYV3C3OmxEovTmU8sZyTYlYqcdTzmEUsR6PYOlV4tzAnSqz04lTGE8s5KWalEkc9
	j1nEqahrvJxROjsHSSvQhQq1tpf4zCUJFtpLU3TfUioW5HyRY49kj+F7XHNrWzFtIuMXRNui
	cMxHAZLOSIU=
	' | unpack
    }
    cpu2() {
	echo '1-4-8-4 Core i7-3632QM Acer laptop'
	echo '
	KLUv/QRYBRkANvyjJDBtnADAQSgjJ0We2YiUIhYo1GYrjfN9LZSRbXi0c1gXhgBQJaUAjQCQ
	AFstjEt/y7WLjrldy3NJYZ2SHbJMae46JVsalxR2RPcoxwvjbzHHk8cuBwx/Hia6pGiF4+uD
	LbZEjWjxPA9zSVEqFBoYjYRxSdEmmZzMwaXgkuKIbleblwqFBEazaG5wCQeENzw0TuQMELgH
	NEQA6JQID4AAuKQoXPEN6JKiPG0SLtElZfIcXNUhy5anHRc0OkjUhEtKc9OULWpkYVxSpmRW
	JucuAfLJlS35WxnfpHRMq/Pc1JnSfZSwmrrTg811xj11XM1RssP3ZdxtXhL/3mI84Su1h/1+
	nPmNMl+ZP1lSXQLh3bJ17vYHQ1712CNHed9rH5GQfTF4deznbPhVfkPCrgxe134yPOO+8l7b
	FUYO2eqSorBjvaVYHOaS8jSi781BlkXpepVJdIJstbBOLikKJA6u3txG3quftJvSzZXoq+5g
	jJxCtvXgaW5/Kdd8ail3npR7o5jvek+tvh9kVRN8U/VY7y2u2eZZxFSXRNY1slhy1vWp0PWk
	0b22tE2M+x3Zyj1zuxrJG2Z6lPnNsT1kbT+3JY8YCbujzPwG9pv1Ehj5WzZx+5TtooR/ItZu
	n2gTDwIf27u4r6buWtkcZfzEEQQETgMtGA5BFDlQg1k8EBRBEEMALSDoeZpGAbRoGo/jNAWN
	RcHjNA3DMNCCYZ6GYSDoWTCPwyxSR4XqWHHBT6WQu7wF6ekijecC53bUI+eSwsw6W1vLE11S
	OiqMDvfW9CxPs2AUOOugdEhqqZp5Z147oSadsnlqmMiks5kuP1LI1k/hBFkGoZbGvOnc+/j2
	veb6au5w6qPbeyWc+lXIV14UBzsgIKMZ0jAPK+HdMhUFdRtVjCeXO5JNULexYjxRJq2g2EaV
	8O7CRoIUlGysjsfKBCko2ag6HruIkWyCuo0V44ky2YRS1xX8jOLIPpdShdsmd5zFkNBhyRjs
	jWqiDxsGiQbeb74N2hniRTgqfc6PK/sOQHV9UrS1UtKWyvnmCMjuOeEbaVqYTWLEy8KHcwab
	fNdt
	' | unpack
    }
    cpu3() {
	echo '1-2-4-2 Core i5-2410M laptop firewall'
	echo '
	KLUv/QRYTRUAdrWRJCBtLACzSvaJv8mdRORLLoVMJ3pdprIRArYowWEZLgRCIHoEDZEAfQCA
	ALM94qbc+9LZVuOOaol8MPJ6MQ5Ze00x4WWw8MXBYO6orXj9nTTWluJ4LCCQRrmjVEUCA1Mm
	xh21brZJ24vLcUdJ5GPe2qsiAYHBLJYXHKLh4AwMpbEMELwHMDwALJ0HD3AAuKM2MvmlcUcp
	uG7G1dxRFPBFBj3ituBWqbDyRXIR7ij3HjqdXGkx7ig6u7dNyitytkd4bl0d/SQPIWtN0d8I
	P9bXybu/bPe3+7Qn6FOMf9zYu7pPOoIQbG+YbX5lfGnGdtbiV8KntMbz9h9T+7b4ZXza8a3r
	t/nrvlF6xNAdpVrCIE8sRrmj4EoL717ETc5Xedu0T8TQ6qW4o1TE0GLcOWSvPvnaY7aWO6qX
	Bo/wgSYMfpLYV2I9vZedbnz1WfmgY+ue1vVVNp789pgt0xflaWz33Wv82Byfcp3eKFM7s939
	JdbX3k9ROuT2tDud9ckZ32h6q7uEk4BRhI3/JD9iiK6E7SG6zLO2nPIUkgknzzod8pR3c0oe
	XvqukXdk+XJGiC4/k0bZW9enSlY7DONoIIvFQcAsiwJhIAvHY1EUAgZj8WiU5VS5cSVMsni6
	E5MXZFGlT3o0LvCuL/KGuaO6e6lzbDWaO6rKjVLyIHsazXoQLCAPAn5xSmZkLYr0LK1tuS8n
	pqtw4xNxiyKrK19CfmWUnbn3SHdS3StP91h65T1FfXQ+ytNC6C9K6RPTsUk/lOvp9mMRj/AG
	JSDQIqIi7LRUwrvFZJLUAVuxPLHcLdUEdcBUDE/UqSanrs9zRmXkcaNU+bZlG7hrcxA2mUBy
	T8tuUnd4augwnjSRdwOqb6To3FJWLMn5yBHIbnjCtm86kCEx8rLwgZ4B68GiZg==
	' | unpack
    }
    cpu4() {
	echo '1-2-2-2 AMD Opteron 244 dual core laptop(?)'
	echo '
	KLUv/QRYvQoANtlJIkBprACDMMQtkTstiphu+tF3RsomRkcLaiECKgDo7qgtvyZCAEQAOQCP
	WWerZUFc4QE7AaJ0dHLCDRiLr6TL4r9SgsrIVQLJV2KAb5n7w00ZMBbtzaiO+Sy+EvMajmSi
	Qgr5So7s1iYdVgErQYUUnnkPtyjfZG2RNh52qpXhK6WHHVvZHIK4CR1Kxq/UPAsN6DFOFSB8
	QWjD66ujsaYGFOWgQBTJV0oNBwwk+UpNDE5H7tHuHf1AB9sTijZ/Mj4kt521vTZ8x5l71n57
	zK6I2rXtlfGd3ree1+Yrc13oD7uvlLphkB8qeQvBIZEonvPMg848955fM+pqwyLbO/qQrJaE
	GlAOBElC+UrNb2UjF9SM9CEjo3zhZ6TR7qN4CFlrhj5Cu6/dDxAAAieJgnrpvudbNgNUIOzA
	MqSoSuBmxjF3/rkp5oAwr3m0DVcImxgIDpyVKKrENj8=
	' | unpack
    }
    cpu5() {
	echo '2-24-48-24 24-core (maxwell?)'
	echo '
	KLUv/QRYdSQAGkNoCyQADcMCI0TLks4mlR/lnQWq4v01q/9MCZihKMz3R7P+/yfjrxe5AKIA
	pAAKdnLCyuueNSgYcfRSeGMYCkYcyJs7DVYooYPcjoTeGL10uivYGQ9+6XTHSm+MTkjoHGAf
	yJ3mYFNY4MMAgyNJQdQbYyvA/i645o6FGAIMk6Q3hlFBQYNkIeiNsW+6SR2Mx3pjJCRk3tpH
	BQUJEIVAeoGnxRUmSQMYgkNwcOABHgCQcyM8wAMAb4yNTT4lbwzD2TfjkbwxKDgwNsQV7A5n
	q1ywEirkJnhjPGig88ldHMgbg87udZPyERXKGb+S3vou4UlwFNFxfCj5CkbQTbQ9gi7zrC2n
	PIXEdCbP+vzNmTDw0nc9vA/LlzMi6LJhwdF219VQZastp3t0zq7roz8k0PLjP/KO01xT6O+B
	H+vrwruftvvbfdoP4k+Mh+zau74vtMJBOO6J2ubXxl/M6N5c/Cb4lNZ43v7yuK+L38anHe+6
	fpu/7xsXVzDijWF0ojk84VDojeHsYp0/GMdK3hhVbpQJ6DRDcqSFAMMo9sZohnEm5uHoSPe8
	sb/dDp1oxB/kxSvvKVRIJ6T8rIM4jHLxCfO1hTZQrl8Jncl16WHlR7oL9b0rXzr8yvPA+9po
	e3vw0TEgFprzJxt99C5BiD+L9l20ft7bTjfCalgJndf2GVzXV+l48h3klp4nZFjb/ebeH3T8
	6B6fcn2eoMddbXc/xfra+yf2n7i4w87Q73QGDGOYojCFJYwxxpZiii3EEGMUwyxJKYbQQmsh
	i2EUoyhpUQohRSmFEiUpibHE0lJJJaVQQikphBikEFoQhRjDMGtRFKUwlhKFkIQQsha2MJWw
	hKXFFkMpscSQhDCEMcyyLEtKTEEWslayLIolSVprIbUkpRCEUkIpIYSYlNCCEKMgtCQIMbYs
	ayWJUmullBJCR1Plxk002eLpTph8OE1RKVws6wLeFR6erDdGdy99rwWA56ixqCwgIiKDAAhC
	MCMAACxsAhKoQBgGIBAIxsEIwTkOEfxPwgUfLJZYP9vKZrhEZep2u7k7XFK1ZLTlxfNql0Dp
	yIyLNj3Wy9LeMRJXK8cgHu09Fq1Yq8b0XW09VsBqLc3ckYn047pXflSABeQzkYdcPcePl78l
	oEW3htyWDCvcopK7b0uGSt6uFhO7XBKlKikuaCWPOa6tcXOiBR1jXNPFta0FfQxn6O1mJGr5
	2Luq5WO+pnaPdalaeiyWdukXgH8mpTAUl1kS47K2M8j8mHlcElJyq2RtiZDCbSm5+7ZkGJQZ
	l7eixcwul0SpiowL2tRYJ0t7x0hcrRyDeLT3WLSiVo7pM9pyrIDRyjFUlvv8H/M+JvuQKzUY
	kM7MMXFBQ7TYyblwJnts2KkJO02wk27ZTOpjv06V+jple920PkaXcca67lrtscV1V9y9WuCx
	xLUirn8t9NjMkJcZXC01dpO13hjFq01jyqKWjd272jEWZke+Xv7966LvqzZTC0zEIma1yNpX
	ketyZer/0g6AFe7sFs2nePnngUV+Cv9cPO6zftzOuDDzXMWe+8I/vwr+ll9K
	' | unpack
    }
    cpu6() {
	echo '1-2-2-2 HP Laptop Compaq 6530b'
	echo '
	KLUv/QRY1Q8A1iZsIyBvqwA3o23SyJIQjJ06dkMYGMYDOkA5MLcI3iHqFTCAyKAwaQBhAFkA
	BstXShcNEAYKi5SvtE7UKLU9pSxfKQIb885WFw0MioNgOcKvKEpj4hQRCl8ZFQYcgxYeIAEA
	o1y3Cl9pH4NvML5ScuvEp5qvZOHaY88hVuV2QoeFDYLL8JWc9pDRgTtRyleSsXs1SlYBy/iy
	37Xnt/nrfN/kED9fKXWEOa5QjeUruZ2su9MgVhjb5NVoHxA/qtfiKyWIH6V83bE2G2zamK2M
	eog1Oe0royrGV+oIbA7SWil3TFtbSFglPJxh7EXrr0SZqoVhCAoOAjudN8h/5DK74wjfE/KG
	LB/G98jlh0Qlu/Z8TMhmw6h/7hG8c0zbor8Q/pufknefsd3f7suOnkfvvbGy93Quacg9Tt80
	tvmT8Sfx6Zm+b4Qv5Xzn7Tsi/ep7y7Isak24byMMsne5FZGVY9CUbeJgLvCeDfKme6XjMMU0
	X2nCfTDSHHswjXI4CJSDgsZXam4vRiJEQRD15Eqm8+cej4S574R19KcOX/KM3iyRvrHdfcab
	d6yPdi7jbDC+M00HGgDJQBXgHVgYGFDCduKMmpHxiUzAByptDXwxQm8Orkb8MKwzCJ2GRGOh
	S1UsIOebOfYk2efwPdf8XqtmFQx7uDu4QYQPJQq2DBQj
	' | unpack
    }
    cpu7() {
	echo '1-8-8-8 Huawei P Smart Octa-core (4x2.36 GHz Cortex-A53 & 4x1.7 GHz Cortex-A53)'
	echo '
	KLUv/QRYZQUAwkkgH1BnrABA24MVyJENxj4WLhwSzxygdYSSvS59MzORDgyGAoEto0jsDTHx
	9XOWl0pYpXrUG5qMPlbneFtuptv5FMdasGcns3AXCd8HEEQylmN3Q5V+oUp/WRoo36uHPHs6
	+wS+1kuCN9TLzdRNJHYM1hsSQAACYkE8JPWGOHaviyxTDgAkQAkMUAcDFIMBSmCAOhigGAwo
	4Wbu07xD5gw177vZqo64sbtwFDXaE3w=
	' | unpack
    }
    cpu8() {
	echo '1-4-4-4 x96 quad-core Android TV-box'
	echo '
	KLUv/QRY5QcAhlE1H1BnKwDIkoetw1FHvrd6TW5nqI4+EQedzut9ABQptb4rACoALAD72HTS
	yk/im3vpzs7kbugyATqUkc6ORAG7AF+v3P8qKK0RiLPTzJzcmE4E9W9C+qMuDC+XM+FLV09h
	E+lcd0VsFHoHV7lcXB2t29Uq88Yq8xA2UX5yb77KfaSkV6aEdHbosq+3Gs64G9qYPqX1GiuB
	6cKRoYzvB4kBdLr1Je+rShcoKVYc2jpeAaUQZCHItkI6rJSUYZOhzs6B+5oNUHsIDIyIs8O9
	i6S3AKF1dhYmDgA0xZA5Q837braqI67uHZjSlgNrgIOBQ8Q8pCcNnhe5YjIBX0edag==
	' | unpack
    }
    cpu9() {
	echo '1-6-6-6 Kramses 200 USD laptop 6-core'
	echo '
	KLUv/QRYlQcAgk8uH1AJrABITeNdwrPRAqt9X9oa+rr/FE0XsNM0A4oUUSIDBmKowyiQcm/F
	1bpHYhKJN2Fil2uzj1AMCHmi+/CivJxl8wjF8EIlVtlpUwbbQgjFcONYdrmRTnyRTjxjT4OP
	mm/LkVuvCdm5F7OevZiFVEfGPxo2fffUHUZGD5s+s6dxzOYK7XH4DUsn6j6caoBSEkDUkz9B
	OTi8hVeAAhjSAFdvXeVIHxAInlxbujNlXkPpyffFqMtbiAIVAC1AFUAfSJgbUAKU9wNU9gNU
	+QH1Gq2EwfCdq39vKWe7c6q/wBoyA0HbuS0w7lMlg1sHMAcaacWR
	' | unpack
    }
    cpu10() {
	echo '4-48-48-48 Dell R815 4 CPU 48-core'
	echo '
	KLUv/QRYRSEApj+vIjBLLADDcJR4ZOmSMcbRLoFyVLE7QWmYAUkyhG4uXRgCwJ2sAJ0ApQDz
	j2zYCFV5LceJnYZVIM0Qb46jYRWIevMJ5ZWQjNJCjmp8w8bjkeeoRoStN0cvIDkTshH1CaNs
	CIZFChDO1ntzcITsMyPCiDSlBpRi7M1xRBwoMI9SSq1JvTn4qbFGUVJkvTkWkLSWbyNOWckZ
	HkAvAFQjvnbhBgoEbw6mEDrz5jgmP5UiyXpzQExJoeINGxEDBYIoL8SM2yB4czzSieoDsYSo
	N0dUuznWyCIBh4hwwdOxNJ5OR8GA8xeKttona4qP6pVQpZeQPY2P81B457kT23obqtCnrdCf
	WheO5eixr3MheBuq8Xfihwo97XTexr5P9MRisX3sr63OnXii9BP0OWFsiP5lnHH3uftRT4pP
	lJ7RjamY8Unjtr/QXqo0HkZ6XthH0aW33F+meI70DO2jpo99z23Pz5lKb1jFm+PoBZz2AXlv
	jskSB7BxIykJvK9MfOnm6Hkg4pI3x4WYOi5BmhfQHsHdMbUKEhoQ594cbSWti5pA2JIcjm5k
	219wO3M2oHd0L3S6nctRQ/QdIE+HJdiT4ox4IaVOYt5GAon4TqngbkB7lmA7VkbQHWKdDpX6
	UpSYv5ZS6Xzhbes8MB41dR7JT4V+n4dfCUmHfifkH6SuZ8TLCo4sd0MLOWFLeui4+zQBlyg+
	SgvvxKdSB4rylCRxyXvtOcdca6sxpthabymmmFOOYRqzLGxRlKUkK1lqJa29x5hza7WmnHKM
	Mcxay6JUU5THJIlb3muKcyxpbT3GGmuKOYZ5bVkcU5S2koQp9t5inFNLa09hzCWvPfXUY865
	1dZizqm23lpuMUxjloUtirKUJFHJe+8551xrrTHG2FprIQ+Mt+XbEQyq1Hq8fXpv733fNxdi
	ygsIQfqIH6pFZoDlqEGwFQAEQA4AEAACcBMAAAgGEshgGAgBCAKCSSQgOCYK/2sGH+oAS++e
	VqS/F4zU7z0u9T1GSvVeu1K9N6t0c0/yY6Xag3up98Qm5T0PSZX3+IzOLfeqIuUexEu952Ap
	4T2fk3T3ICSle8dR6vZaKf29IEi/53FS7xlISvesJW0mAjIpo27dS5JU7yEm/T1VkH5vEJK6
	vYOlfc9AqdxjqzT3ZpSK1AAym0h99z5VpS1TIwAH5ABuGkB5CC7/HDKKQAjgbgBaw+LsTyLv
	1Z/UMvrTdJ7On3T45E9q/GnKFP7IHmOV1p6oStVeqErXXlRKa0/USmsvVKVqL1altScqpbU3
	qlJbGwD2iO3o4vIdhC9r3/gEqm4WaLhveaVn2a/WmtxlZf1r5amu/n8Oqy5VPeifi7Z8D+pV
	HtHLu3cB1t7Q82P9mJ5lzZxZiTsc5NfnI+/+/t8Hj/tsF7ZZhZabKpETW3DxywH3CuPZ
	' | unpack
    }
    cpu11() {
	echo '1-4-8-4 4-core/8 thread Lenovo T480'
	echo '
	KLUv/QRYvRIA5mt4IyBvKwATk8iUn9xdIuJLbC8JrUxyQsMubiQkFCUoEAiB6BE0eABoAGcA
	qSHywcdrlRyy9toiwirB4QyjNF9pL15/I401lSQJQZIYXDA8JMpXgsjHvLXVBcNC0hAoR/gE
	hMInksZiMNB4D3iQAFg6FR4QAfCVNjL5hVG+UoLrZlTNV7KALzLnDzcFt8qGle+Ru/CV3HPQ
	6eRCKvlKdHZvm5RVjxt7V/dIP9CB7Q1jm18ZH5qxnbX4hfAprfG8fYOofVv8Mj7t+Nb12/x1
	3wj9YecrpYYwyBVqWb4SXGjh3Xu4yfkqb4vW8bCjei2+UnrYUcnXIXv1ydceM8V8pV462x9u
	yb0vnU0ZfAX8yvPB+8ooO3PvETqcCIN3klFH3xrFeQSxnl+IdfRe9iobT/4+oBnfHrMl+qI4
	mO1+bI5PuUZvlKidReeM7e4vsb72PorQITdHu9NZn5zxTNNb3Z/k74Mf62vk3V+2+9t92pHz
	KMYHBQUFTcNoGo0GwywMg8FYFmVRFEWtKjcuhEkWT7disoLsqfRBBswF3vU9fsD4St291Dmm
	mOYrVblRQh5kDkZVnsxiP3LsbrcdfcTx7jWG5HtHul9efJw39pcIYldefLz2Q+GYgz0a0s4j
	3Uh178qXMC8gICMhGnYpKuGdGMVqqIR3FoZMSQ3V8ZiYkhqq4zGLIFFXQ8V6IkZdDRXzxHJI
	FKuhEt6JTTFr7sHFkbEspWq3gcg4GEnCDRHCLERgJRyDNg6inUEsukGicXWpWC7nkyOR3f6E
	T9+IZeJitNtyLQ6A1ShkK/65
	' | unpack
    }
    cpu12() {
	echo '4-64-64-64 Dell R815 4 CPU 64-core'
	echo '
	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
	/q05b9gEeqJ524Ixfxz8jbBi
	' | unpack
    }
    cpu13() {
	echo '1-2-2-2 AMD Neo N36L Dual-Core Processor'
	echo '
	KLUv/QRoPRQA9iRoIyCPmwBAIy3LSinV2zbLlasWEvo1qQe/YpQhuFH+WyAIGgB4ZgBYAFoA
	rN2p1bjy7LIA8UeDkReNn89SaykAuHCQiCwGQ1lNF4fz2m42LxTPCBkInIIaHgFxTBzmxB8e
	LqAd8KB7WuGp6h3AJYO6QJiKa6okh3YtDRIKq/XLpyEF1lKE7GW0MJ4AECFzLhg3XxbfOEwu
	W5iakpR3xxV+P28kM0VyiuofhpzErUMcrfYR1HXlxNZv8iOU9Vz6VPvI+sX95H2yp0ZnR7md
	LAYuo3Rn7cHWm4uSibMCraR1e221VWtpsGsaBw01S0aK07b4brGgS1Fs3HtVo2dvmjyJtWTN
	Jrfgc9M+iRj+WZ2SjKse2qhIXBrxK0s56dLqSpJHufdbC/cQJsJuD+rb2ye2cOE7g9BJmzH1
	U80Prk/gY46rCwzDOJhl4YtHv5qv/e0+P6WPuzgFdWzRwLlb88iDOSNjql/qc5pT6QFZOB21
	h3gsRFQskIMCAwSDbQod2CwNJkoZe+XyGYxHJqbqTnJyDnrn2K0Sc+qMFiqZlZRqalxnKDAE
	iFNnHPIyW6sjBSmjVv2fZQzcoCUQPqCxgIN0gPYK4Id9CK2Xrhh+6pczlgJU1dW5V1wXneBN
	Dso0OEHQ1BAQD8hEOKPSSEqqnbiUo9qSNWNCSqPFwUg3GEdg597rYovkh/VDJS4Jc2hsDA3N
	hu0BT8rqVWmlI7y1M7cQWtFBkCZ5dJEVHCEfnkAcxowh8tfz/1gcq4N0e/Ln4LoBaCTxpDA/
	K9wEOcdPpxqOgLHqXpMH0AQrQRswgv0G5nqaeJrhzIzcgz0m/QlzxxEQGeDTfXJ21z8GJGDt
	hOfZ08YsNAENX1FX
	' | unpack
    }
    cpu14() {
	echo '1-1-1-1 Intel Xeon X5675 (mandriva.p)'
	echo '
 	KLUv/QRo1QwABt5WJBCNWAGjFDHykUWSQEvNjTGJMp1z5pZCA7MA9TKhFAAAEwwAAlEASgBI
	AI5SkwOF5Y6KYGPe2WtyYNBQJBYf+BmNhuHwhoUCGNfhAQwAd9Q+Bs8wd5RyC8W3mjtK4tpj
	j0usy+2ECAubBNfgjoLaIyMEN7IUd5SM3atRcmcRX8r5ztvXxuyOSb/6vowv+117fpu/0PdF
	LvGjI+Y4YiluI+sONYkVxjZ5ddqnVyLxYxEk3OFYFuWO2knrL0SZrsaiSTgYisUD3X0ZZ4Px
	HQKCcNJzym+QOcJLougixzkdijF6eOVZuvZ8JmSzYdQ/d9aekPwE7xzTlvQn5Mt2X/b0+PTe
	IS25h9M3i8n4kfg0azkT7tuIQfYuNyLyckyaskUczAUc09YSCL9ne7iC6V4JQWzCfTBqjj1M
	sxpLoqEozR3V3F6M4sN67nlAmHsv+4TKkb8oD7Pdb5RJv9gYKBAixjTqEIhm1AHKWTCgrkEE
	YstArr0BOSgXJ4Xmpu4j9PRpQcgRCckdf4fcSFol9GuGecuj5uBxngHakML8
	' | unpack
    }
    cpu15() {
	echo '1-1-1-1 Intel(R) Celeron(R) M (eee900)'
	echo '
	KLUv/QRo5Q0ABp9XIkBrqwCI2LZJIts7o1loU/RrgCM1Bkm4qbLeX6WzKj6uMAFQAE8ARwAL
	JHEgV0hbZFGyfUlxhRq4zDo7PSwsEOTgX8Ao1WnCAxwArpC+BU+AuELIaYsvGVyhh9u3mDvM
	ktMJGRSuA1XhCrVVZGxQn4RcIRm7lUXJAdxIyRVy+qh7W4cZjDtZmUOV1ofD60XGIAiTIrxC
	jbMozzbmbu1cuGx5XSGVkSXEFeoGrlu2294ttv1gcEJoeIJIPGxfGWyxlEiQAYXQw0KHjdim
	06c4zJwl7eT3XO6A14X/5rufaPdlO5g73vsyW+/ZzmjHMY79iY99NXwp5ztrX+FgV/auiy/7
	nfW8Nl/b9T13mOlmuSmpCfVps+B6l9qInNxyptxH4D13eULQrbK1NaE+2KxbSoFBSiADCKLg
	fbGJS5rL2Omcpyxu7rvh1eh3e2cmwr178WNRVMbZSoJ4FJWTKXcnKADAIKuqBxBI54gcFYp3
	xUIMqhrUyHoLjYPwgszI7eGRdSUOFMYQlpP0pOoEAV0WM1zTXUey4OeJUEZtb+UNcgLSAYUj
	iyXJQ3TVfIX50ANedGFbHwEc/JQzJup4YQ==
	' | unpack
    }
    cpu16() {
	echo '2-12-24-12 Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz (vh4)'
	echo '
	KLUv/QRoXSQA2kAECyUQTWMdEfORapSl6hpfhdTvIB2fCbydyAB94J9MxTuCiACAvIMbrACZ
	AJ0AsZ09tMbz9g9R+7b4ZXza8a3rt/nrvhF6PwzyggEXWnj35HyVt0W7ehcKRhyyV5987THr
	pbMZ/cgHndfuHbL2epFg40CDHwuibIXX30RjzViOxaAgKlVY4KBJonWzTdpeNNQLAHjkY97a
	RoUFCo7EoG7gCPRDLYqAkuARHiCQcyVcAIQAG5k8AgCum9FYFvBFhriCmwG3SgYrn0KuAvcW
	nU4uZBwvAIDO7m2TcisfdGzdal1fZePJXweaUUVXaSXbfdbc3Wv82Byfco2+pKidRcQfx/WR
	7d5HsR9F6JDbanc665MzPll6qzsFRwEqImz8J/mMp/zimXDyrNEhT3k357N46bs6b2f5ckYE
	XV6JRtmqktWWsz3Cc+vq6J0nLTt+JA8ha73or8OP9TXx7qvtPu0I8SjGP27sXd0TrYAI2L4g
	lfGhGe/9MFvot4tH1ATfzXjhzNpLJWgtrW25Lxemq3DjUjiGS3CdsoVtufiufAkpO3PvkW6i
	Ola0NhuEq/KMFNo70r3ijX2VXnReWzGBOf004o4t9xh65f2iPjof5Wgh4i9K6AvTsUQvyvW1
	77Dz3tR5d0731/ur/IWPfL0g+e7wvkIFQ6zosEe4EAkG7ySjjr4tCfEIYl+IdfRedrrx1RXM
	0SyIUphGKSQxKh2KMjSHapLD0iSGORpDWpBDUhTTNEmTDktiGKRJiqKWhCBJWZCUlDKkRKm0
	KAlRUpIgTHIkhTBKo5Q6HFJKSTFMYzgckJSOdCyIoWGQJSUFORblcEhSoyTLgjDHgiSJUkql
	hlEMhyYlwyiwD5Msnu7CZAMyRaUPOiQf8K7P+dK91DlW5Ub5PMhWstw4NAakYRJ+cT7TMVhl
	bi1ktdd8Mb6+xKtQEZcDa4DDqMFgxYzIjEiSgiQFSQfARoZG0yQHYsA0SQAhCAFCcIYihEFI
	eEU4FDgnBg/CvfDTFEdfCnzKp/dGFGcRJTBac/VP682IZ7JNS8a8Qlfee2qAsyGbznwFCy/m
	U1ALcxbXtKQvWrgyn3pamLNRTRuTMDy3ws1ZhXNbn0zs/KfjswDmAk60ueL78UwnwrzC2pwG
	8XKdA8G4QlXzjctfmU6/IHBeOaU+Mi2DiV5xvoW/1lQ9L8N6AE/hzUXgVu/lIk5iDv1pu4k5
	RtkHE4KPT2MhGjqcCQQPp9nTTpOA087fSVowhrBufLpp4ppGv6jkrAkYzqNwbyg8FOzwJTe/
	uFlcfjE0RytY1n2BzX1wHq3S3EPR87qJk8A3bdEymQU4if9RYRQUH0JH1v4o5Y+HZ4/Jcx+p
	6C67cHK/roV6KRX5eh5fZ5zfBAGIcypOQhRdDjoqorlsIRh4MyFFCa/+w9rnqQ9IhTJSxUEj
	J/m5uPWXdiT61TaAn85i7vm/JHEVLykNoOaGbE6PZXMCHEOy4iJ6P6vgAOxE/spU7N53w3RU
	pvPDpg6++vY602wMoPOM5mjPE/5E9C+1WNOag5ef9fYNxh+A4wfWolSv
	' | unpack
    }
    cpu17() {
	echo '1-6-12-6 AMD Ryzen 5 4600G with Radeon Graphics (ai)'
	echo '
	KLUv/QRoxSEA6kH0CiUwS1sdaPiIsqmQTVuLLykLrtQOna/tY8caFQPfvvvkgYUF54EBqgCc
	AJkAyXde06cCxnbefuLRr7Zv8mG3a8dv81d9m/NWJGPGgWDrLLta7q3Iq8+i3saCmbNccbml
	i/NALHx6KM3SarXOUlc3Gj4KJLiSHCKs/jaaeiAIIgBBDEkEBAsUkCTx6IO62pEo3GLe2Efr
	ajjhgbu3Khm8iYvxAwiCMPxwtxEaDL4t3REKANiq145FabDVkvmC9TCwgICu6LaJCwJqIfiU
	W+dAPgAAfN2rD3LJLXyKYNTHL341PirGIfQ7rTOcfm80LrOQGc+p5dvtFItlr/ZsKRNQm9Nv
	aCqWIW6IaZJduYQKXhGJk18n+3lvPjrlx9+kPFcSZEAkjz4b82X7xeVe+4JaYIvGlL8cn3HC
	NwYu55Hi5874uav3FIgXougytnv6xs7aUcEnRbKs+JEfis8+7oyldqMfmyvbfdgP86e1N71g
	DNMjlhgOcq7LySv2ml7YRIYPN7LFbC+S37FXd656uupqdTbSXS5TlLQ5X5baSDse8YLuEJy+
	AxN7ZPeYMK/MeuW49VxifAFZwcPIcOH6gxuB6WMs44uopcYL1Zc4Ka7iuS6HsuknBlPO1n9U
	Xu12oragV3hbX0lWS9/O1IpmWnMe+4kbpvVM7SrFjM2I0bDSLwzF1CfWP3Elo10Z4/RLkiSH
	REEhQeFwSCxLQpIgCMQhSQ6HBRFwQCyJIZEwLMoiAFmSZTEYFEVRkuQ4HhgeLImDP4gWFjKI
	YZbRvMVzjO/4AS7b4TIeHywXES4nwDuu9IShe6FSGd02ZEAcvYrkJzBcSUCWAgoaHAqJhObV
	nuKl4zXsp4YotmYpLnx3ciO92EhJYHzDGBN1o7iwG71IR2rrw6e66DtPFyLGYwxc510tXm1x
	BqMiXW5mKZyrfKwFgKGowTykkDGkRkRGZKRJOoBExqg4GQ5COUGLMEUERrgzJMbE/0wgQaYH
	7rSgB1fM/kMSWx8VlA5S0OKNuWI8OR/359dtGFxgAconnVldLp+9a9V7SFk+bs+OtlyqzwrK
	xcHda6arrSv0SUHpjILKezeeFaB80pjp9b4rw/lQiyR/K5yP+vP9LYeOwRWAt+ciFnSiLUur
	rq4cAM/MprXU19jHLpLvmiWBe6zHzaIqO1sZ35yOXlqIa29j88LhLeMSOPNflUdcL2cNG6ti
	NPWjEbKXtIVeflMMLyjsWLuCUcxPFBWGmna3DgpIJmairUxU9OPb1XINMjCrs+PJbgrQARvc
	19rY5t2tN8ulUxMyLr9RA4/vay9o8CfTq00/5AalMO6Kxg8B8HlNZ18ej/83Xw8IP+brlaoW
	nemRDRyMrTRoNR6FdbT66kV1nQt2zfQ7krZmj6IJ9/O6aXGMPXcancqeawY7QJtwnNUtOMQ0
	DPeXb9dzDOgUh0ST3w==
	' | unpack
    }
    cpu18() {
	echo '1-4-8-4 Lenovo E540 i7-4712MQ'
	echo '
	KLUv/QRobR0A5ricJCBPrAOD/6k2Kdd940OW+jV8IowHH1LHEyOAj3wFiBJCBBssApkAhwCK
	APGt67f5676ReksM8kXiMHCphXdPzld5W7WrF2Pi6JC9+uRrj1nyLJ0tyQeh1+4dsvYaI8IJ
	QsOfh9mM199IY85DeSBNk7HgUNBUbdL2YuJI8jFv7SRjQWFxlOYHn3hIOIRDwzwegse7gINE
	wNKZcIGIgI1MfgGA62ZMHBjwRRZ94pbArZJh5ZvkKri36HRyqWS5AQCd3dsm5TyZapj1uNf4
	sTk+ZQdTxegS5Pq9ryJ1yG21O531/XH0VncLZwGnCBv/ST6Tx5AmnDxrdchT3s0pLV76rtAb
	Wr6cMaLLK9IoW1Wy2nK2R3hu9JDELDt+JQ8ha40B8WN9jbzZ7tOuolcx/nFj7+oe6QlGsN3h
	VManZmxnEq3xvP2Cqn1b/DI+7Y/WXion6lGN1Ot2FE0MKOeq4i5lg8QxcJ2yhW25+Bcl9a58
	CSk7c++R6mZHum94Y79hXoRee6JgUEsd3bHlHlOvvMeoj85HuVoY/WI6Fun12k2hdwd1/1X+
	Qkm+XpR8h3hf4cSiFSH2CFcUYfBOMurom4OJXlHsS7Gu3stON766Vj7o2LrVur7KFo/HsizK
	sjjOw+FwChiI0mgeR6PRNIvyLI7G8zQOA1EejcfjOI0HRHEcx2kaxtFolAUCaRjmeSDKszSY
	JDFYiUkWT/dicgLZVOmjCp4PvOuDDnG6lzrHqtwopQfZehKmoUAKGvzilCaUyAo5rflihGi/
	vsircIoLgvW9JWYX/XbxUWXguxljQLP2ahhqLa1tuS8r3LgmKNneSVpuawuAjKjxOKIMMozN
	BAVJkkI6gETIqDoH8ik1TcCMERAi5sRS/A8FFS4dG3CFtZwlIk6YcimJDtgk5wR1XK4Zk8Un
	sMVDxBNion/C2hcU+QlCJ9TqKYENn+w6gVqWVtxECfmm9FkYX4KDEonAOWU2hJsM6RMh0U0p
	7+Zac3GHjyoclWW/p4WGjMjik0uVQdh2h0oi5FLuqKQfPYjKWrQQKCqYjDPIvFVSzilypEW1
	nRlB9gFqeGTDqWsdgBaiLwZvZEI8R/Gn0z21lUPE919W+l3pW3zYoa67/7ma7JfvqXav1TPR
	VPD4FxvYvY+QCPdXlYD+97NAYZox/vWovIVyerIbhrErTRTiye/tcPmHerjHhz10g4iteO9n
	zdoA+1KxJ8/shJsDnYcJTIaXxS7ju0nnln2fbenY0DSGz5+q
	' | unpack
    }
    export -f $(compgen -A function | grep ^cpu)
    
    test_one() {
	eval $1 | head -n1
	export PARALLEL_CPUINFO="$(eval $1 | tail -n +2)"
	echo $(parallel --number-of-sockets) \
	     $(parallel --number-of-cores) \
	     $(parallel --number-of-threads) \
	     $(parallel --number-of-cpus)
    }
    export -f test_one
    compgen -A function | grep ^cpu | sort | parallel -j0 -k test_one
    rm ~/.parallel/tmp/sshlogin/*/cpuspec 2>/dev/null
}

par__test_cpu_detection_lscpu() {
    pack() { zstd -19 | mmencode; }
    unpack() { mmencode -u | zstd -d; }
    export -f unpack
    # ssh server lscpu | pack
    
    cpu1() {
	echo '2-8-8-8 Xeon 8 core server in Germany'
	echo '
	KLUv/QRodQYA8solITAL5gF7YbnaqsSsYkliK98HHFiNI3FSwNumyBYOykA5Aew4x163Zw87
	7XAqwtiSPYwAiCZa/8LET3hd+xO/ZCDAJQlLGEACjIF+VflN4KP1dFkhfg/zHeDC9Esbp39R
	LyBo2lZJfWLmstJeIOmA2/WGWC23lWFWY1uv2rAKCd1SESOtGFYhITDsnsJDEK24vW70+1S0
	SxQgQIII9QEdLfxiBElVRWsZDqgLA+oSr9kgrmS70kDZt2WvOkEnODfAiaJIAWgWoteFUwLs
	8nwc
	' | unpack
    }
    cpu2() {
	echo '1-4-8-4 Core i7-3632QM Acer laptop'
	echo '
	KLUv/QRoxR8AukKICyngcGoTEJCWSciVLZJIKEXuzdZEplGI3JgV4DZJLMuEV2COJ8wwH2L4
	BcEAsgChABMIwcjiqQJCoZiUW0AsFAUYGxxMCkBPd7MpzAYHDRQMCMYPfDKB0Xg0HgjoA0wq
	D0ABQDr1HjHgLRmcMI9LU6eeZz9JPo1eNlAgeYTs5cQ7gkmFCMyCwjg6MSzIGWEChgHXYy5T
	GS0VhsCDolnbn0/bw5PARDQVdVQpwnGHppbyxbLnVuePBucG5TNnZAwB85Syt+DZuhVCTBYl
	PPsSYRyPO7Q6D4xGAAaQDLqHha8gkYBxPJpHxHRIxqhXtlpWRBAx+yncNw3H1BiVc4ZWaWAB
	l4UrJkeQhfSMvQ6ulXz21FuvuFcqnbGyRyhPSVu1CMKs9uI8I2z+yqVIIE8DZN3SAMd8nsiJ
	KluCQ5hNskmvTCh34LRw1J43pezB9QuTCY4pPckXVCRu4OkFBE5I7ROKLG9tS4G0dXLIZOJB
	q0W7Re5Oa8kvrU0dFfO1aOKKR2Nyhkb0wSMYaVlqnS0gMNNDZeJBbbVBJ5jGAkJRoOGgSEgC
	beE7gxBqNuO5nbOT+wfdE3Mby4qq6aeaXfuu+Om9NbX4wk9n7/ptOfMZyfzI0/PJuesudW72
	tv5otNpL0K0raB9ju2/yl656xLSeyz3VPrL74n7yPtnTSY/2OYQh1RgwLHvl86g3jBCho77e
	hdUnrjC4YFzqDiMcks2J0NPW9HmEQqFCuYMFBg2FQkQiIrlDPm1wO+OXxnwJvbWIAaP1KX4M
	W7TmUWVbDXPn3r+2bxXVFdO7mJZm74Uu5jedchji50xXem9GqHGnbM/VPekaIFMWbuL219Hm
	O+voOTp65jBfe+9svluknsa15rGoFln8eiyeT5J6Soqnc6rHdNoNU8mafmvhMqYzFo2D6dq7
	xfZxe/pjMa03kjk/OeltV8PsEbY+6O54cDZ7BpahRa6tvb69OtNo18L3CwQbXNjTA3IgUABA
	FFkPLUa8gdKoM6utIHa/NrtPEu5DQv8gyge6RJ2RmegWA2w0olDY/5lu43u3KLpQpvV9DWB7
	CFzd08L6NLcg3DK2Iii4oCIi1jNIE2hkLi8wQYrBQthc9idpAuBaroQWpoIwMqR3NNkECfJu
	sp2IAOACZSd4BLmUzVHl0rV1Cx0Tz3XrtPBCCl8Kvi0Wusx4XxBktMyMQbkszXzEs4pfZzPl
	aJcthoylYAaKfS4KyazRcAhc3IKx7ShmMdAXiKvD0NxyiR0chavOhoeEWuhRXAvYVR9j44TQ
	yFRTQMEnwBmtgAoLU0YIijDMvRARZYMpA4smUrtjrICOHpSiNYqBXUcja59JvwK0LWESpwSv
	+wJQ
	' | unpack
    }
    cpu3() {
	echo '1-2-4-2 Core i5-2410M laptop firewall'
	echo '
	KLUv/QRobR0AFj+vJvCyNgHQEZLJrWwzBCOlyJ2IXthpoGeK2U1oGVrADy9eHBY/BkIIsgCr
	AJsAlEmEYJJAgT4kMAcbuFJqZ54PiQiIhAD6wjGQyAQaMNgHYDQPwABQisFDrzx1EfNQOm8p
	Nl0bXhRuBTXC4fIZHVQNeAZMRsUTybRytMg6Y8MDxfap0jGdHM0jGYA07/sV7huAFs/ksarn
	WgiTCzzWljscee6VTpGwfiyfWadzDA9k6+DD9XUvxStT3bS4dsfyTCgX6JUGIEkAA6iL1ICM
	z7hoeCaUiIJwvaKz6qa9nDYZAg03ykcRT905mXTeSObBBR0Z21SuKhHrOltSsTXlO8j+uk15
	ttYdr7slc7W22asqzEx2pOuMzW8qM5cK9Iiun2KsazCZK/DUaaqkyfQ1vMIOA+PyVAte/qC5
	uMJmezFTRyj0vYLRmOjlbL+KuvT68k7vW4lNha/SOMSymEskUMTg0Fp24hOKchprdxGK5xrQ
	aMC4zT5W44ESDCaZiwsmbqIFAS6EAAJJgC5GBfPc0llSeRipaaqMOG2yqCFrpt5l43bzF/x7
	rHGHr5I81W/OIWX+5Gv6RVFf2di53Tlcvem1UyTN5K1ItbON/JxNXSq/rWRHuNq1UVcmP5l6
	476yvLorZb2S0yu8YQ/icdpNp4m9Y8WMEnuDHWa/WLOB+95Ot2QwNJkLbEBEGYzH1sHYbrmw
	XC6gcF+UrfNtp0Ld/L0KAuqFjD81j4u8qEWOOrc8fPLNJjtze2oqp91bRrfSekudcae89E1f
	Clr3iI5xOJqyL6VtviSlPU9p7yTmb8tLUk+9aOKw98tiV4vxdVb2qdR25Ji66A2bjBK6DkWi
	idsmTzUnP2Vfp0Sudoky8yHWX5T1J1vE7jP2wkh9QmFt9w7X8SrqNfmF8uxuK9lkhO9s4osy
	9vUnI7yLcRNJDWMgUASALDIelxSA43If9uHpvXHEbfAybA5yiTzjJGNsNEJhrP/trvE9thy4
	EPWxBL9Ev+3Tc4V4y+yIoASj88gBPDh1YC0Hj+9SAIGlXIksTAVhZEDvaLMJEPRuqp2YAOQC
	TScOHg0AZWaC3ta8uvJY+7RdpnWcJnqpGYJyWZn52M42vTHmkCoi6xGLgGI6qJBMGjmMBMaA
	xU0EY9tRzDJQ4nY0BW6JnRuEi+6GBsRfsKN4C1hVzzGGYiil6i4wwSfBmRYAFSBTdAhduMYs
	pN+yYcqIRXOpXTBSQCcPSsga9cCuhh7z/9NC2xMmKUr4tsTH
	' | unpack
    }
    _cpu4() {
	echo '1-2-2-2 dual core laptop(?)'
	echo '
	' | unpack
    }
    _cpu5() {
	echo '2-24-48-24 24-core (maxwell?)'
	echo '
	' | unpack
    }
    _cpu6() {
	echo '1-2-2-2 HP Laptop Compaq 6530b'
	echo '
	' | unpack
    }
    cpu7() {
	echo '1-8-8-8 Huawei P Smart Octa-core (4x2.36 GHz Cortex-A53 & 4x1.7 GHz Cortex-A53)'
	echo '
	KLUv/QRoTQgAgk8yJCCN6AGBEUmyQvipyGwhCMTqQifa7nWt/lvbXsAxLGVACC2ABrswzRtD
	KImUazOO/vUjml18lTF9qBAGEXY5CsYxMaQJmQvlLPmUUkqxNMwykSDxhEWqHCIfpf2OZQgg
	ZdLvM+rIJC+G7aa00gJkwGCfTnbDLo5dzM83RJu1fUY7MBt7U8faIwxboCh+vj7I3PJBRTbW
	eUzRSvacPOCG/0+BH2/nDe6XWOxqWOCfg7IwARWg3YwKnfyYol1NpDlj/LRLvvW/SHMoGAAr
	Q5AWDg9qGEBiofABuk3KGsauTvhpnhsa5HVShxsS93JpFOfBzhP4ZgBCDQ0XCuEub/2VgAiV
	mwwoAdUl+VI=
	' | unpack
    }
    cpu8() {
	echo '1-4-4-4 x96 quad-core Android TV-box'
	echo '
	KLUv/QRo/QgAtpE4JBCNWAHfG9LkksIm0BaMBALBz/jVBGlPVDQCo6NyBAUAwCBwEC4ALwAv
	AE3Pdb/CdQp8qMWbgAkggTgKsm3Q4Oq6V+ENa+PHtSUIlBuYHrM3ylI/2hs93AgNJUKbo6OP
	wb9x2qJDORYaBQnn2KA2qCXS+vDEqRwdtcTnrLIx5YhBMcoCQQ+1/s5JT34q++OePenb28ku
	oTlh7mAtuGutJaBYGMsEguMR7F0CcdRCLp7AlVI7ohhGqqdtezZt2y92uj4zwajwcja9hKa3
	k15PBt3hSVEfciy6hLiCefi5YmHRfBgggCQg1HBWDGNRBoJsaT4B1kZtNKSQAf5kC+J/a19p
	9jscIBj33n2UBCmUphwBwqU/HBDKFhi+RQnSA8zN
	' | unpack
    }
    _cpu9() {
	echo '1-6-6-6 Kramses 200 USD laptop 6-core'
	echo '
	' | unpack
    }
    _cpu10() {
	echo '4-48-48-48 Dell R815 4 CPU 48-core'
	echo '
	' | unpack
    }
    Venter_cpu11() {
	echo '1-4-8-4 4-core/8 thread Lenovo T480'
	echo '
	' | unpack
    }
    cpu12() {
	echo '4-64-64-64 Dell R815 4 CPU 64-core'
	echo '
	KLUv/QRoNR8A2kBECygQbcYJiNmWkVvZhZlEnSKWBFp0GRq85wI/vMgYA62BnzagCgCAQaAg
	tQCvAKEAjwPx4OCIj9hIGkchwCHQLBUUOBIPuFJqQyQPQ/N8RmZlcT48wGsAME5t6eD6FrzT
	Fh3JwkTcviUdcDSwbahTUw0HHD5jgyoBvsERoUHiQCSL1gksss5oIGEi+1TZls4JQtI8SqJ5
	3a9wnQIdJG5RPbdacIstRyZ57o2+cFgrLJ9ZZ2sNCVzbIIKr614GU9t0cO1II3GeL/RGCtME
	YADa4lNkfIQHA4nzQM8CcoZOqpn2Tmw2BAmYXrj4UxtulIcgnrpzruj8kCuCB0RkZFOZWqrr
	bPkiY8pvcN01m/Jrqzd10eJtb0Bcq+3lqAKP7XWcwbxkJLrO2HymEoIBI2Jrp2dwc0i9MGja
	TCVpvWOD3mnbUe+Ra4dHet1Gayp0lIRkaRSHYWCUZ3maR3kUCoVCWTgMjpJwGgKNwjSMYlEW
	C4OSeGLhNM5zxnFmG7vgzKLQiS32tjBIJCgMGLdXhZWQMI2ARCK9ML5TaBQc9RyTXyj/pKly
	/bEGtbfeFmoN0belJJMR3skI32J8QFIn1HA1P3fJuNt89FhUNvmWEWqIQuCdW4wj/J7OKPMn
	Q6RD3vvElJMc+9P0kq/iY18P+Tn7XSqfrVxfQNiVveuSn/zOuK8sr+36qlNS4sdyCRg9Y7TO
	YITXIQyBwS2aD7jOrfQGxIMvQIDYBiN746Hh8AWF66Jsnc5RAUlzcWKdU0vyU9utpEwteW5e
	5qUtMm1vyysSHS51DIqYQowbkjvhJ7DooGpG7i3he831ZV/0XvVIRvsW9WqWUMT0SLJHUGdk
	0GwWZey/qKG2yvpOt4j3wp3AlxFyjvYRFcdPrFXSKSMibM2VGT7WLd739aK1mOxV/AhbD3WQ
	fJA0LXf2LNIh1bpWiyFnXW/IZJRnFsh5Fgj7etIb5Rh2IIAAYJCsDt0Itwf3dUHgOS8IC3/b
	cx+tCmlszVYPLUY2cy6k32i2tsTCachLepZh+yFZ+9QZqUTqQcGisUgRvvEwh9VHGLSDCXO7
	4229V2jZPh1WaFKMZmTN3FKTRx/WIhwGNK8IzwuWRBf5u7SCYK6uBC1MtTDiFrOijJL+3UQ7
	keVCzWv4iQk9sM2ASaSnUIZnvcRUvcJqZcM5YIQfVShhtbI0nFeGKOysSdUYXLuFbGw5uKQI
	9TqKlwFgqMGU058zcDgdl7WAndaEy5TLvwFg5aqP4zgAYc3lakmdkAAuoQCsBrIlQlAIw4he
	PFE6mEJmPV3qB3YDIAGdPCihNatiXaWRte+lXwO0mTBJUQLQlar+
	' | unpack
    }
    cpu13() {
	echo '1-2-2-2 AMD Neo N36L Dual-Core Processor'
	echo '
	KLUv/QRolRgAtnKPJQCPWACgNvIHK2l1aPsb21+AYWrULM1pbgXRH0X4Tira///c/16KAI4A
	fQCRyR+um5YG4mTgi0xasEzaa7lUV5OFyut0ci/kJxaLiMa5NE8vRpu8dSo0zmyvSx3bSlU0
	TsPR/OC/8kEBKdE8kFVdn9WArD3OUPTcL3qkgDfj8Zm3OjdpJHtOMnxh94O4pK6rEt/OUJoC
	yBv9IoHnEcAA62YUoPMWEwpNAQSCRK5Ltlbdth/V6iQJ0+tncaxvbQkzo5mo+W3pRSIx0zXc
	S9hZpHYg3HZbSWLvGdGPeg2r+Ah25Zl+8EWsroTVxR2UZ/nz51HewyPPUo21OweiuRCQyPma
	ZbyLBnIwYIBg8FwmKpY5TUpEvodzsehwOAYcjkiGg+UxyUfp9qWpk3nbrBMXgKxaOATkEfG5
	Ea9UHhAbQE5I9eQbTf1Z5le+pF8xnuIKSrAd8mhGb83Yzib6WjueLr89yh652rfFL6OvHN+4
	v0y/7hutV1TiicEGSdcZsTeZYfaLKyTsojrJB+GTTrlQvOEWRoyf+wSlUnF5Y+WDk/ZWCKuG
	p59k/Lot36SHoDvJznVfrSw6T5RhmCBDZ6vL1QPNWowh+qo8RpsQsmoE3zRG69usmUIYCnKv
	Heb95MPgc/SOsXiear3SVsoKYsQitT1a/Exj00KIxvYIIYli8C0bnfQQ52qvs5+c8U/Suwe5
	u1fRRqc8pFPezTlBdCvUkjXL2Y6Z0j0e4WnjdvXR5Cx19E0n1Nde8hCyxhl+ViBABMAoqhrs
	g7Hf/B/GILKuc2SwMcJQiDgBwi/gjABrg9JzmNOqR1vTDhyWM8swRNQfQlP0aR5ABZrRgKxQ
	LLVBwPczF9136UFQQFcRWm8ZQoe1KIqmjbAGHt6QXhiuOxL3tMSZcblsxP24SlsticeSMQPw
	nwvt4I9uNEhBXFEJoUWnhtbCEDvYBbOhnR6FO++GRBrkG7DW9Rm5AoWQy9RySiElwBmtgAoL
	UzgEXRjGXoiIssGUkUUTqd0xvoBOHpTCmkWxrpQel//TQhslTAKUqRruSw==
	' | unpack
    }
    cpu14() {
	echo '1-1-1-1 Intel Xeon X5675 (mandriva.p)'
	echo '
	KLUv/QRonQYAwsolIjBpzABoi2gVcBKev0FN8WI7YcCuNoTmTbB1dAmqC8N6MAf9xOhcS6B+
	oOLc0Qb145avJCV9NqgRCTRE5ZAsLCJ3UOm9nwP6Pbd+2qihgkUvysD6XJ2vNKuvSDiO7aw/
	UJ2JJoBuk5QfQVrssW26Wen4rx+YManHlUC3TAuQBw/M+Gkv5FqfpKYfJIAxwZfHWZafaSUx
	ExcgQEik8g6fj08zd4EHssVA93AJ8C7xnA3qlYxXshyLBYN1XHECyZgjRUkKjzkkLOUQtuV4
	YQqnBNP0ggo=
	' | unpack
    }
    cpu15() {
	echo '1-1-1-1 Intel(R) Celeron(R) M (eee900)'
	echo '
	KLUv/QRohQoANpVBJCDJVgAHS35yk/0LNr7il7y4NiXZTi5J2xh8EMPkH0ICUAugATkAOAA5
	AFDzg//KBxEyshyKJFqSPScHvrD7GRyq62rk2xnH6ldBJBQHNqybEUHnKZJoMR7GO7S16rb9
	LK0GBJfkrAs3+uHAsJHJKw7BdVNajAx8kU1wW0JWvkpugQDkdTq5CcuZ9Cq0yVtntJzZXpc6
	ttWCsJoH7dvil9FXjm/cX6Zf942XV3RiikGCtXiciQQiTWo61iLRADRNY+EhPZR8lG5P1sJD
	appGnczbZqUB6zW9exVt564cI78V+thnfmKZXxkzHRPjH23s3O4WruAE2y8ztjOKvtaOp8tv
	j7I/mB0gQIaMujr8eNMPYIxoDLDgY+WX46hwjTmVzU7HpqEtYHxLTLzqx8jKta+0nIvY4e1q
	oiCpQLqitFXU0Fyo+a4q4SvbmVMCr0burQ==
	' | unpack
    }
    cpu16() {
	echo '2-12-24-12 Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz (vh4)'
	echo '
	KLUv/QRovSMA6kiMDCngcIhzFH4Td8ruJqLZFq6rg/LAmM8J4PRtw8ZYAfijNgkAOE2YISXG
	hNQAwgCwABJRul4TTmKBFGhoFCDgoDw4TGQkJUx0jAYGo2lUCw5oIA2QAgwz4WDSRNHtalOW
	CQcNGI6G5gfeoM5oHs1iwIIotcIDQABQuOIbT5ucLI/Kc3BB144OGt0UtYECh0/ZokrEI5hM
	iLA0lOXReoFJ1ikTLI1kn7pt6ZQilkazYDS792t0bxElLI7mramnoyCOK95ijivSnts9fzhY
	JxyfWWdrCJa4XIsLrq/bQZjapoRrVySL43FFu2fRNAIwAG0SLlZ+wkOCxfFwHpDqEZ1TM20n
	sYkgc67nHO3KwAIqK9lUniIMdZ29UDKm/BbXX7O5X456Y9cuoVwp1+tNEea1lec6ZfOZLqWp
	vqcVIqJvNV866JBBtn5qgKdC0PTMpS/BI9wm+qhHTChXsEo8PehvuRYle4WJBE+losMXRDzc
	ANQMBNZo7TWapC8lcu0mj0wkHjjJ9Zvgn9cOTZspBK23jPAWLv7q1T5V6tXglXbPPWtqfJME
	hFEwzOLBEGAWDaMYsGCcwWhM3jiJe3AHpKESW+yNgbBUi4h3PFi7HUPD8Cb42N7F/Xpz07KV
	8ZVIPrmyq7+V8U3KyFmd537Oj+6jhNDUdSQ2l9NxNcP3Zdxt/okY3bav4t9bjCt8ffaw39KZ
	3yjzJ1fQKwjvlq1ztz/2R6PXnpKQfUX7ORt+lc/crkMqdmXwuvaT4Rn3lffarpD6tNAjHK3H
	INJTPussVni94ohn6kLycMVz0CUUiAjKFRQYOBQIyYPEIbont2kXF39qRyf3jsNTXUtjnsOc
	Bs+9j2+ur+YOp0rddmJMsvecXgkxsDOc+mYV8hvGwefNk4W2lNfDEUNvy2luqffqlG5upQ+6
	g5F6BtmWxM7cfvOffdx5Pu7tYX50u867672+KDp2qOj+rL7ftCAHPuvwOZC03mzz7MFAr6h1
	pRZXZ12fCl07bWlzOrKVe30oCZvqDeM4lPmLtTfH9pC1/dyu/mAq9gWhR0/jN5RZ+RWk/pY5
	3D5luyhhgIsgQIQYg8joAUWIgGFyHo+2H9H0VAgUhrODQJiKFAXV8DW+RBm3SVsDCbC8Bq07
	KGXGx0zhrEhoL0TC+UumTeUY9jUCrBkKh/0502187xaJLlwUWm0uUXXytESfDgGEb4NkqRnw
	hh6SeWGWHUwwKJLAJgOwcJUAICETFDQ9MStQHwsQlNeVyIXBLgwRq/f1bAUN4i6zXZkAGNbF
	r4UWmZ8oYXG08h4R4SqgQ6xUaE5ULo1bw9Cx8rk6OS10SMFLxNtSqZeTOx8HMOMzSrwtUXV6
	BdvV5WraGwmfuVpoygqX6zRBbFeLmaObBRLPgJFBqKCMJobTUMYomLcjxSwECvUOqMBBukMM
	4bbPXtAAm2D9K7ytqjEnBktqmyprOEzwz3FpK3A7w6IQoSGMJHxRorxI5ZT116mlsbsI0wBc
	tYwCxsaqkbWS1O8AhakwClACiAG09g==
	' | unpack
    }
    cpu17() {
	echo '1-6-12-6 AMD Ryzen 5 4600G with Radeon Graphics (ai)'
	echo '
	KLUv/QRoDScASlLADSnwjGjbQLXf7SEiYhXDl17bzy9x/Sd+rgMwdzVDfBFY6exTLCwOI7dP
	BeMAxADHALmu6P54Pbmv7K7puqJDzmEKqgUMAw4FJhIRkkZpEA0NtgwCGBgKPCIXDSS34Eqq
	GmTa3FrzSzKFLPQteITC1jntCaMxYUBaK7KxvoaA4Wj5py6hvoeCATHwh+OidqHDuY/Dx+Cs
	acKJP72VM2BggDScwJleXCauC9mVpiZhJJA85DbTp6GHBBF/LTGdwGg0FhiaV/3KVi2wCAxH
	g+EmpuCquvfB0/QiXPsCwVAI9dtIQWEuXx53vkMD68XymfWl9MBogFyht1lwPAIwAE1tLbh2
	CRIIGA0QBuJgeUQf1Km9T76HTGO+cXlLL1bWUynXvGH6WjKvs7nW1+x3qryXbQWfm30l4vYn
	Wx19rtJYelyZGWUV8q7jatDh5Yr4l0SKKsYtxnlQPTF86T0hjQivEbLlrPhm6Zq7Ng7LHQ2m
	AdKw5HE5fyi3XtbWLZKFgpZK92XuyuH7cp46ZFJb9Gkhl66xK9fYU2sUxuljmmEza/ml7pI7
	vTeUhrrk3q4xbVELu1KYfOH3c4cy/7HFuWWtPwwpR+Uhj0b3qK08Utzf63Wn/FyHd7DkNY4N
	wJp7CIBDrIM7DOiTmE+NB4wJC6xt48VOYGCuTIgftdTHVJpynkbtad0u6Op1MqmOnaVET9jU
	ipjouRE+qfawvqcd96et1lGG0J2blxk1tdT0tIyX5gxVJdPkiq4KkxnG7WOviPjRa9TbsTc+
	fDqXTxHbxprKoefS+2v39O3b0wuVTSns1sxqloMyWyNqWimW5zIGH35TUelw8S0Jn1Q5vSOz
	LPIOp4vvaOxqrowNU9hZK3ozv2aPzXpqmK+NzY6pPC7lHyqRfq3BJ7sw3sIUzZtE6AKExBXU
	OoeYTFyBtQW+YEWhgsJNrOUhrsDKVjXn6GXIf9psmzvD8NN9D5szxWGFB1xcy6ccaUTX1261
	TOUnhledzx034k2HmFyjbVQQo7s019eaKRRMXB3kSEVi83uqm6R2e+4SEBEUEwrJ5AcqGPT0
	2YNa35OyxdcM+gHK9kqSqmpaJyKqsPltV4RVWmqlj3CSON14sM+2gtYb1RFJO9Vx8N0gKLeQ
	j43pT59GBr/0qm3wKVPQGRo/+4NEAgSHw0PyxwOAmCBQhAwZGbcBSJYmAyLVG/5ngAQMQSDK
	NQS2pztrYwEu8wFcfeyBYD2uRC8cu9AcDJpOjLQh7rL0Fa7gA0e/PKc048NKtpjWvTy15IMc
	q4uFsqler/RyxCH4EQ5D3JoKmIAzHQMGrkiUOpngtr7yKtD1Ck60jerH1Pl5YDli1yPO8eqT
	dYGslS4vjnB2tgEI3t9gKaN5ajSqBQofOAWAYQioyBfyMNvbjJC3koCWTuO1A+XEl66LWhlg
	zo5pwC8w9OjdaAMFpEBr8cSA+xrfFV0kAXQEhFBoqWCE5A+s4GostEFs069Tkyc460L7alvL
	t0B7CQA+l6gZpkZywzEQATxYpIrZvtZvFY+NmLQ76NZvhd72aVyhHWrGgMXCoonW7dgxy4Bi
	wCsuGJB+NTPEBrEagkv08IyA+ScYD9t1ilA7hp3bMj0LvwaAVXZjIVR3U0thpwhTAXBxv2tg
	gAplMV0DrnilFovCKIxyldJcA2k=
	' | unpack
    }
    cpu18() {
	echo '1-4-8-4 Lenovo E540 i7-4712MQ'
	echo '
	KLUv/QRoRSMA+kY8DCrgjmpz6GpWtLK0DL5oW2iXhXfvoPKn9A8udDwya4/7NeYGAKcJM8QO
	GxzLAKcAsQDs+6hPMmJJHYLGCeAgIBLgYYmgVKIUJxHYGA4MhkNSoaDySp9Dgk3KbUvjWJpH
	L4UVuWnE9bmS6U7MpWFAMq49jSoUJGA4HBon8AeVhvPwWDy0M1QuCztjgTNILOxTeLcsVhq3
	DSkL2wQ3gQHKZ2RwJ5qHBaO5uX9hcwvooIlAbQwe+LruxuCSuWw6+HZm0jidejYq8niD09U4
	g5HnbtAFOHgrGp95J2MQzQPyhm7QouFg4IVl8S1kPISIAs0D8kAi1SU7p17bDbMmREyXPQ2X
	jPILUfG94TwP1pb8W0x+yq4Ocap1fdEliPF5Xz3qTq6H2Wfs9geEt9krsApuem7JNyivZ22S
	S0b4jBRdlLGrOxnhWYzSI3eeGzpDKw/ji+bKB7OmPg21Gcb15y4XN5uHJGclk6/gndPFGf5C
	8q/fmDO/scyfXEWv3nuTS8/NjuHJRW4d4miVp+JbV0l+zn6Xy19N6iPV+q73VfnJ74v7y/Ib
	kGsK214bRfqODZx8ytdWdk3gGqRzoZvOcH54iAqEBg2DA3FU3mgMvKv9sfBJW/BIYzFL15nD
	oKkWlwkYW2tFm2iY455PXbce9t4epM4tD51869Qra39zMc3eMvKb+4bc57QHvXmaoBBLHJ3p
	w5qk3nKf6TZjm7JaF50iMsXwM2W/mSfUziDmt5ZfJ8HGDwXbIblvN2n0PEj/3BNh1J1BnWx+
	QZzoFaVfSrk6r37ua/0Ekp4R0i+YYX3Fl2VxxblaBZq7mES8wbXoE4vExfKGCAgei8QkYkKB
	zUXZ6AaVP7dhi/LPcwb1PLfNqdBZkkrBADIyrrk8SRzqO9v1mvLaqDNu7BPLl2qtbpIwq8xA
	3xmbJRTRRXOpeApLm+fXSgvbdVCvxHtsAClACOu0+bE9CkVk7XYAz42iCXqBS5hV1lG/VCxv
	4HXamITKBM+lIOUHLhEfELXDgFdS+ZUmzKVFat0ql1QmFnTDtHbTe4CLIECEkEFl9ehJVn93
	hwA/7BCLC/NZLAEyUgY2GYCFqwTgijC5QVMmWPH62AyCDXK1+OpiWpsP6U0siLvMvrIVqI78
	1COnggEzDpYxCkOKML7klSCO9u6RE66GTcJKlT6dDwjE4PrWMDouM98MDrDE4PDA5DeG6CaB
	DYzokYTORwA8+4yYLj4VnVRJe84uTm/rnEsY+C+A04PHnWF8hWEQnbvJESu4m6sn6wT5BC+v
	sDBKElGGn0xRhN3SZVgAU5GCwRcAhoObABCPBoUzeBrAgoEQA+ZNUNzFFM2M9wkFpc2oy8C/
	A9QawIpBoEEQHPbjTLfxvVtKondjLtGyfTorlITmE2YMTTBvR4pZCOjkMroX+5BpthahE0bS
	1xmBywKcDyryGSexILNwA7tRbNm7IJSiGy6wym6ow2+fOh7De2BiA65hfTBgShgjwlKbRSEq
	jAKUQ0da4Q==
	' | unpack
    }
    
    export -f $(compgen -A function | grep ^cpu)
    
    test_one() {
	eval $1 | head -n1
	export PARALLEL_LSCPU="$(eval $1 | tail -n +2)"
	echo $(parallel --number-of-sockets) \
	     $(parallel --number-of-cores) \
	     $(parallel --number-of-threads) \
	     $(parallel --number-of-cpus)
    }
    export -f test_one
    compgen -A function | grep ^cpu | sort | parallel -j0 -k test_one
    rm ~/.parallel/tmp/sshlogin/*/cpuspec 2>/dev/null
}

par_combineexec() {
    combineexec() {
	stderr=$(mktemp)
	parallel --combineexec "$combo" "$@" 2>"$stderr"
	# Redirected stderr should give no output
	cat "$stderr"
	rm "$stderr"
    }
    combo=$(mktemp)

    echo '### Check that "--pipe -k" works'
    combineexec -j 2 -k --pipe wc
    seq 920000 | "$combo"

    echo '### Check that "-k" is kept'
    combineexec -k bash -c :::
    "$combo" 'sleep 0.$RANDOM; echo 1' 'sleep 0.$RANDOM; echo 2' 'sleep 0.$RANDOM; echo 3'

    echo '### Check that "--tagstring {1}" is kept'
    combineexec --tagstring {1} -k perl -e :::
    "$combo" 'print("1\n")' 'print("2\n")' 'print("3\n")'
}

par__argfile_plus() {
    tmp=$(mktemp -d)
    (
	p() {
	    echo -- -a $1 $2 $3
	    stdout parallel -k -a $1 -a $2 -a $3 echo;
	}
	q() {
	    echo :::: $1 $2 $3
	    stdout parallel -k echo :::: $1 $2 $3;
	}
	cd "$tmp"
	seq 3 > file
	seq 4 6 > +file
	seq 7 9 > ++file

	p file +file ++file
	p file +./file ++file
	p file ./+file ++file

	p file +file +./+file
	p file +./file +./+file
	p file ./+file +./+file

	p file +file ./++file
	p file +./file ./++file
	p file ./+file ./++file

	q file +file ++file
	q file +./file ++file
	q file ./+file ++file

	q file +file +./+file
	q file +./file +./+file
	q file ./+file +./+file

	q file +file ./++file
	q file +./file ./++file
	q file ./+file ./++file
	
	seq 10 12 | p ./file ./++file -
	seq 10 12 | p ./file +./+file +-
	seq 10 12 | p ./file +- ./+file
    )
    rm -r "$tmp"
}

par__plus() {
    echo '### --plus'
    echo '(It is OK to start with extra / or end with extra .)'
    parallel -k --plus echo {} = {+/}/{/} = {.}.{+.} = {+/}/{/.}.{+.} = \
             {..}.{+..} = {+/}/{/..}.{+..} = {...}.{+...} = \
             {+/}/{/...}.{+...} \
	     ::: a a.b a.b.c a.b.c.d a/1 a.b/1.2 a.b.c/1.2.3 a.b.c.d/1.2.3.4 \
	     a. a.b. a.b.c. a.b.c.d. a/1. a.b/1.2. a.b.c/1.2.3. a.b.c.d/1.2.3.4. \
	     a.. a.b.. a.b.c.. a.b.c.d.. a./1. a.b./1.2.. \
	     a.b.c./1.2.3.. a.b.c.d./1.2.3.4.. \
    
    echo '### Test {%...} {%%...} {#...} {##...}'
    a=z.z.z.foo
    echo ${a#z*z.}
    parallel --plus echo {#z.*z.} ::: z.z.z.foo
    echo ${a##z*z.}
    parallel --plus echo {##z.*z.} ::: z.z.z.foo

    a=foo.z.z.z
    echo ${a%.z.z}
    parallel --plus echo {%.z.z} ::: foo.z.z.z
    echo ${a%%.z*z}
    parallel --plus echo {%%.z.*z} ::: foo.z.z.z

    parallel -k --plus echo {uniq} ::: A B C  ::: A B C  ::: A B C
    parallel -k --plus echo {1uniq}+{2uniq}+{3uniq} ::: A B C  ::: A B C  ::: A B C
    parallel -k --plus echo {choose_k} ::: A B C D ::: A B C D ::: A B C D
}

par__sql_colsep() {
    echo '### SQL should add Vn columns for --colsep'
    dburl=sqlite3:///%2ftmp%2fparallel-sql-colsep-$$/bar
    parallel -k -C' ' --sqlandworker $dburl echo /{1}/{2}/{3}/{4}/ \
	     ::: 'a A' 'b B' 'c C' ::: '1 11' '2 22' '3 33'
    parallel -k -C' ' echo /{1}/{2}/{3}/{4}/ \
	     ::: 'a A' 'b B' 'c C' ::: '1 11' '2 22' '3 33'
    parallel -k -C' ' -N3 --sqlandworker $dburl echo \
	     ::: 'a A' 'b B' 'c C' ::: '1 11' '2 22' '3 33' '4 44' '5 55' '6 66'
    parallel -k -C' ' -N3 echo \
	     ::: 'a A' 'b B' 'c C' ::: '1 11' '2 22' '3 33' '4 44' '5 55' '6 66'
    rm /tmp/parallel-sql-colsep-$$
}

par__I_X_m() {
    echo '### Test -I with -X and -m'

    seq 10 | parallel -k 'seq 1 {.} | parallel -k -I :: echo {.} ::'
    seq 10 | parallel -k 'seq 1 {.} | parallel -j1 -X -k -I :: echo a{.} b::'
    seq 10 | parallel -k 'seq 1 {.} | parallel -j1 -m -k -I :: echo a{.} b::'
}

par__test_XI_mI() {
    echo "### Test -I"
    seq 1 10 | parallel -k 'seq 1 {} | parallel -k -I :: echo {} ::'

    echo "### Test -X -I"
    seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -X -k -I :: echo a{} b::'

    echo "### Test -m -I"
    seq 1 10 | parallel -k 'seq 1 {} | parallel -j1 -m -k -I :: echo a{} b::'
}

par_process_slot_var() {
    echo '### bug #62310: xargs compatibility: --process-slot-var=name'
    seq 0.1 0.4 1.8 |
	parallel -n1 -kP4 --process-slot-var=name -q bash -c 'sleep $1; echo "$name"' _
    seq 0.1 0.4 1.8 |
	xargs -n1 -P4 --process-slot-var=name bash -c 'sleep $1; echo "$name"' _
    seq 0.1 0.4 1.8 |
	parallel -kP4 --process-slot-var=name sleep {}\; echo '$name'
}

par__prefix_for_L_n_N_s() {
    echo Must give xxx000 args
    seq 10000 | parallel -N 1k 'echo {} | wc -w' | sort
    seq 10000 | parallel -n 1k 'echo {} | wc -w' | sort
    echo Must give xxx000 lines
    seq 1000000 | parallel -L 1k --pipe wc -l | sort
    echo Must give max 1000 chars per line
    seq 10000 | parallel -mj1 -s 1k 'echo {} | wc -w' | sort
}

par_parset() {
    echo '### test parset'
    (
	. `which env_parallel.bash`

	echo 'Put output into $myarray'
	parset myarray -k seq 10 ::: 14 15 16
	echo "${myarray[1]}"

	echo 'Put output into vars "$seq, $pwd, $ls"'
	parset "seq pwd ls" -k ::: "seq 10" pwd ls
	echo "$seq"

	echo 'Put output into vars ($seq, $pwd, $ls)':
	into_vars=(seq pwd ls)
	parset "${into_vars[*]}" -k ::: "seq 5" pwd ls
	echo "$seq"

	echo 'The commands to run can be an array'
	cmd=("echo '<<joe  \"double  space\"  cartoon>>'" "pwd")
	parset data -k ::: "${cmd[@]}"
	echo "${data[0]}"
	echo "${data[1]}"

	echo 'You cannot pipe into parset, but must use a tempfile'
	seq 10 > /tmp/parset_input_$$
	parset res -k echo :::: /tmp/parset_input_$$
	echo "${res[0]}"
	echo "${res[9]}"
	rm /tmp/parset_input_$$

	echo 'or process substitution'
	parset res -k echo :::: <(seq 0 10)
	echo "${res[0]}"
	echo "${res[9]}"

	echo 'Commands with newline require -0'
	parset var -k -0 ::: 'echo "line1
line2"' 'echo "command2"'
	echo "${var[0]}"
    ) | replace_tmpdir
}

par_parset2() {
    echo '### parset into array'
    (
	. `which env_parallel.bash`
	env_parallel --session

	parset arr1 echo ::: foo bar baz
	echo foo bar baz
	echo ${arr1[0]} ${arr1[1]} ${arr1[2]}

	echo '### parset into vars with comma'
	parset comma3,comma2,comma1 echo ::: baz bar foo
	echo foo bar baz
	echo $comma1 $comma2 $comma3

	echo '### parset into vars with space'
	parset 'space3 space2 space1' echo ::: baz bar foo
	echo foo bar baz
	echo $space1 $space2 $space3

	echo '### parset with newlines'
	parset 'newline3 newline2 newline1' seq ::: 3 2 1
	echo 1 1 2 1 2 3
	echo "$newline1"
	echo "$newline2"
	echo "$newline3"

	echo '### parset into indexed array vars'
	parset 'myarray[6],myarray[5],myarray[4]' echo ::: baz bar foo
	echo foo bar baz
	echo ${myarray[*]}
	echo foo bar bar
	echo ${myarray[4]} ${myarray[5]} ${myarray[5]}

	echo '### env_parset'
	alias myecho='echo myecho "$myvar" "${myarr[1]}"'
	myvar="myvar"
	myarr=("myarr  0" "myarr  1" "myarr  2")
	mynewline="`echo newline1;echo newline2;`"
	env_parset arr1 myecho ::: foo bar baz
	echo "myecho myvar myarr  1 foo myecho myvar myarr  1 bar myecho myvar myarr  1 baz"
	echo "${arr1[0]} ${arr1[1]} ${arr1[2]}"
	env_parset comma3,comma2,comma1 myecho ::: baz bar foo
	echo "myecho myvar myarr  1 foo myecho myvar myarr  1 bar myecho myvar myarr  1 baz"
	echo "$comma1 $comma2 $comma3"
	env_parset 'space3 space2 space1' myecho ::: baz bar foo
	echo "myecho myvar myarr  1 foo myecho myvar myarr  1 bar myecho myvar myarr  1 baz"
	echo "$space1 $space2 $space3"
	env_parset 'newline3 newline2 newline1' 'echo "$mynewline";seq' ::: 3 2 1
	echo newline1 newline2 1 newline1 newline2 1 2 newline1 newline2 1 2 3
	echo "$newline1"
	echo "$newline2"
	echo "$newline3"
	env_parset 'myarray[6],myarray[5],myarray[4]' myecho ::: baz bar foo
	echo "myecho myvar myarr  1 foo myecho myvar myarr  1 bar myecho myvar myarr  1 baz"
	echo "${myarray[*]}"
	echo "myecho myvar myarr  1 foo myecho myvar myarr  1 bar myecho myvar myarr  1 bar"
	echo "${myarray[4]} ${myarray[5]} ${myarray[5]}"

	echo 'bug #52507: parset arr1 -v echo ::: fails'
	parset arr1 -v seq ::: 1 2 3
	echo "${arr1[2]}"
    ) | replace_tmpdir
}

par__parset_assoc_arr() {
    mytest=$(cat <<'EOF'
    mytest() {
	shell=`basename $SHELL`
	echo 'parset into an assoc array'
	. `which env_parallel.$shell`
	parset "var1,var2 var3" echo ::: 'val  1' 'val  2' 'val  3'
	echo "$var1 $var2 $var3"
	parset array echo ::: 'val  1' 'val  2' 'val  3'
	echo "${array[0]} ${array[1]} ${array[2]}"
	typeset -A assoc
	parset assoc echo ::: 'val  1' 'val  2' 'val  3'
	echo "${assoc[val  1]} ${assoc[val  2]} ${assoc[val  3]}"
	echo Bad var name
	parset -badname echo ::: 'val  1' 'val  2' 'val  3'
	echo Too few var names
	parset v1,v2 echo ::: 'val  1' 'val  2' 'val  3'
	echo "$v2"
	echo Exit value
	parset assoc exit ::: 1 0 0 1; echo $?
	parset array exit ::: 1 0 0 1; echo $?
	parset v1,v2,v3,v4 exit ::: 1 0 0 1; echo $?
	echo Stderr to stderr
	parset assoc ls ::: no-such-file
	parset array ls ::: no-such-file
	parset v1,v2 ls ::: no-such-file1 no-such-file2
    }
EOF
	  )
    parallel -k --tag --nonall -Sksh@lo,bash@lo,zsh@lo "$mytest;mytest 2>&1"
}

par_shebang() {
    echo '### Test different shebangs'
    gp() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k A={} /usr/bin/gnuplot
name=system("echo $A")
print name
EOF
	true
    }
    oct() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/octave -qf
arg_list = argv ();
filename = arg_list{1};
printf(filename);
printf("\n");
EOF
	true
    }
    pl() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/perl
print @ARGV,"\n";
EOF
	true
    }
    py() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/python3
import sys
print(str(sys.argv[1]))
EOF
	true
    }
    r() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/Rscript --vanilla --slave
options <- commandArgs(trailingOnly = TRUE)
options
EOF
	true
    }
    rb() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /usr/bin/ruby
p ARGV
EOF
	true
    }
    sh() {
	cat <<'EOF'
#!/usr/local/bin/parallel --shebang-wrap -k /bin/sh
echo "$@"
EOF
	true
    }
    run() {
	tmp=`mktemp`
	"$@" > "$tmp"
	chmod +x "$tmp"
	"$tmp" A B C
	rm "$tmp"
    }
    export -f run gp oct pl py r rb sh
    
    parallel --tag -k run  ::: gp oct pl py rb sh
    # R fails if TMPDIR contains space
    TMPDIR=/tmp
    parallel --tag -k run  ::: r
}

par_pipe_regexp() {
    echo '### --pipe --regexp'
    gen() {
	cat <<EOF
A2, Start, 5
A2, 00100, 5
A2, 00200, 6
A2, 00300, 6
A2, Start, 7
A2, 00100, 7
A2, Start, 7
A2, 00200, 8
EOF
	true
    }
    p="parallel --pipe --regexp -k"
    gen | $p --recstart 'A\d+, Start' -N1 'echo Record;cat'
    gen | $p --recstart '[A-Z]\d+, Start' -N1 'echo Record;cat'
    gen | $p --recstart '.*, Start' -N1 'echo Record;cat'
    echo '### Prepend first record with garbage'
    (echo Garbage; gen) |
	$p --recstart 'A\d+, Start' -N1 'echo Record;cat'
    (echo Garbage; gen) |
	$p --recstart '[A-Z]\d+, Start' -N1 'echo Record;cat'
    (echo Garbage; gen) |
	$p --recstart '.*, Start' -N1 'echo Record;cat'
}

par_pipe_regexp_non_quoted() {
    echo '### --pipe --regexp non_quoted \n'
    gen() {
	cat <<EOF
Start
foo
End
Start
Start this line is a false Start line
End this line is a false End line
End
EOF
	true
    }
    p="ppar --pipe --regexp -k"
    p="parallel --pipe --regexp -k"
    gen | $p --recend '' --recstart '^Start$' -N1 'echo :::Single record;cat'
    gen | $p --recend '' --recstart 'Start\n' -N1 'echo :::Single record;cat'
    gen | $p --recend '' --recstart 'Start
'  -N1 'echo :::Single record;cat'
    
    gen | $p --recend 'End$' --recstart '' -N1 'echo :::Single record;cat'
    gen | $p --recend 'End\n' --recstart '' -N1 'echo :::Single record;cat'
    gen | $p --recend 'End
' --recstart '' -N1 'echo :::Single record;cat'
}

par_delay_halt_soon() {
    echo "bug #59893: --halt soon doesn't work with --delay"
    seq 0 10 |
	stdout parallel --delay 1 -uj2 --halt soon,fail=1 'sleep 0.{};echo {};exit {}'
}

par_show_limits() {
    echo '### Test --show-limits'
    (
	(echo b; echo c; echo f) | parallel -k --show-limits echo {}ar
	(echo b; echo c; echo f) | parallel -j1 -kX --show-limits -s 100 echo {}ar
	echo "### BUG: empty lines with --show-limit"
	echo | stdout parallel --show-limits
    ) | perl -pe 's/(\d+)\d\d\d/${1}xxx/'
}

par_test_delimiter() {
    echo "### Test : as delimiter. This can be confusing for uptime ie. --load";
    export PARALLEL="--load 300%"
    parallel -k --load 300% -d : echo ::: a:b:c
}

par_10000_m_X() {
    echo '### Test -m with 10000 args'
    seq 10000 | perl -pe 's/$/.gif/' |
        parallel -j1 -km echo a{}b{.}c{.} |
        parallel -k --pipe --tee ::: wc md5sum
}

par__10000_5_rpl_X() {
    echo '### Test -X with 10000 args and 5 replacement strings'
    gen() {
	seq 10000 | perl -pe 's/$/.gif/'
    }
    gen | parallel -j1 -kX echo a{}b{.}c{.}{.}{} | wc -l
    gen | parallel -j1 -kX echo a{}b{.}c{.}{.} | wc -l
    gen | parallel -j1 -kX echo a{}b{.}c{.} | wc -l
    gen | parallel -j1 -kX echo a{}b{.}c | wc -l
    gen | parallel -j1 -kX echo a{}b | wc -l
}

par_X_I_meta() {
    echo '### Test -X -I with shell meta chars'
    seq 10000 | parallel -j1 -I :: -X echo a::b::c:: | wc -l
    seq 10000 | parallel -j1 -I '<>' -X echo 'a<>b<>c<>' | wc -l
    seq 10000 | parallel -j1 -I '<' -X echo 'a<b<c<' | wc -l
    seq 10000 | parallel -j1 -I '>' -X echo 'a>b>c>' | wc -l
}

par_delay() {
    echo "### Test --delay"
    seq 9 | /usr/bin/time -f %e  parallel -j3 --delay 0.57 true {} 2>&1 |
	perl -ne '$_ > 3.3 and print "More than 3.3 secs: OK\n"'
}

par_sshdelay() {
    echo '### test --sshdelay'
    stdout /usr/bin/time -f %e parallel -j0 --sshdelay 0.5 -S localhost true ::: 1 2 3 |
	perl -ne 'print($_ > 1.30 ? "OK\n" : "Not OK\n")'
}

par_plus_slot_replacement() {
    echo '### show {slot} {0%} {0#}'
    parallel -k --plus 'sleep 0.{%};echo {slot}=$PARALLEL_JOBSLOT={%}' ::: A B C
    doit() {
	parallel -j15 -k --plus "$@" ::: {1..100} | sort -u
    }
    export -f doit
    parallel doit ::: 'echo Seq: {0#} {#} {seq-1}*2={seq*2-2}' \
	     'sleep 0.{}; echo Slot: {0%} {%}={slot-1}+1'
}

par_replacement_slashslash() {
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
}

par_eta() {
    echo '### Test of --eta'
    seq 1 10 | stdout parallel --eta "sleep 1; echo {}" | wc -l

    echo '### Test of --eta with no jobs'
    stdout parallel --eta "sleep 1; echo {}" < /dev/null |
	perl -pe 's,1:local / \d / \d,1:local / 9 / 9,'
}

par_progress() {
    echo '### Test of --progress'
    seq 1 10 | stdout parallel --progress "sleep 1; echo {}" | wc -l

    echo '### Test of --progress with no jobs'
    stdout parallel --progress "sleep 1; echo {}" < /dev/null |
	perl -pe 's,1:local / \d / \d,1:local / 9 / 9,'
}

par_tee_with_premature_close() {
    echo '--tee --pipe should send all data to all commands'
    echo 'even if a command closes stdin before reading everything'
    echo 'tee with --output-error=warn-nopipe support'
    correct="$(seq 1000000 | parallel -k --tee --pipe ::: wc head tail 'sleep 1')"
    echo "$correct"
    echo 'tee without --output-error=warn-nopipe support'
    tmpdir=$(mktemp -d)
    cat > "$tmpdir"/tee <<-EOF
	#!/usr/bin/perl

	if(grep /output-error=warn-nopipe/, @ARGV) {
	    exit(1);
	}
	exec "/usr/bin/tee", @ARGV;
	EOF
    chmod +x "$tmpdir"/tee
    PATH="$tmpdir":$PATH
    # This gives incomplete output due to:
    # * tee not supporting --output-error=warn-nopipe
    # * sleep closes stdin before EOF
    # Depending on tee it may provide partial output or no output
    wrong="$(seq 1000000 | parallel -k --tee --pipe ::: wc head tail 'sleep 1')"
    if diff <(echo "$correct") <(echo "$wrong") >/dev/null; then
	echo Wrong: They should not give the same output
    else
	echo OK
    fi
    rm "$tmpdir"/tee
    rmdir "$tmpdir"
}

par_maxargs() {
    echo '### Test -n and --max-args: Max number of args per line (only with -X and -m)'

    (echo line 1;echo line 2;echo line 3) | parallel -k -n1 -m echo
    (echo line 1;echo line 1;echo line 2) | parallel -k -n2 -m echo
    (echo line 1;echo line 2;echo line 3) | parallel -k -n1 -X echo
    (echo line 1;echo line 1;echo line 2) | parallel -k -n2 -X echo
    (echo line 1;echo line 2;echo line 3) | parallel -k -n1 echo
    (echo line 1;echo line 1;echo line 2) | parallel -k -n2 echo
    (echo line 1;echo line 2;echo line 3) | parallel -k --max-args=1 -X echo
    (echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 -X echo
    (echo line 1;echo line 1;echo line 2) | parallel -k --max-args=2 -X echo
    (echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 -X echo
    (echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 echo
    (echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 echo
}

par_jobslot_repl() {
    echo 'bug #46232: {%} with --bar/--eta/--shuf or --halt xx% broken'

    parallel -kj2 --delay 0.1 --bar  'sleep 0.2;echo {%}' ::: a b  ::: c d e 2>/dev/null
    parallel -kj2 --delay 0.1 --eta  'sleep 0.2;echo {%}' ::: a b  ::: c d e 2>/dev/null
    parallel -kj2 --delay 0.1 --shuf 'sleep 0.2;echo {%}' ::: a b  ::: c d e 2>/dev/null
    parallel -kj2 --delay 0.1 --halt now,fail=10% 'sleep 0.2;echo {%}' ::: a b  ::: c d e

    echo 'bug #46231: {%} with --pipepart broken. Should give 1+2'

    seq 10000 > /tmp/num10000
    parallel -k --pipepart -ka /tmp/num10000 --block 10k -j2 --delay 0.1 'sleep 0.2; echo {%}'
    rm /tmp/num10000
}

par_distribute_args_at_EOF() {
    echo '### Test distribute arguments at EOF to 2 jobslots'
    seq 1 92 | parallel -j2 -kX -s 100 echo

    echo '### Test distribute arguments at EOF to 5 jobslots'
    seq 1 92 | parallel -j5 -kX -s 100 echo

    echo '### Test distribute arguments at EOF to infinity jobslots'
    seq 1 92 | parallel -j0 -kX -s 100 echo 2>/dev/null

    echo '### Test -N is not broken by distribution - single line'
    seq 9 | parallel  -N 10  echo

    echo '### Test -N is not broken by distribution - two lines'
    seq 19 | parallel -k -N 10  echo
}

par_test_X_with_multiple_source() {
    echo '### Test {} multiple times in different commands'

    seq 10 | parallel -v -Xj1 echo {} \; echo {}

    echo '### Test of -X {1}-{2} with multiple input sources'

    parallel -j1 -kX  echo {1}-{2} ::: a ::: b
    parallel -j2 -kX  echo {1}-{2} ::: a b ::: c d
    parallel -j2 -kX  echo {1}-{2} ::: a b c ::: d e f
    parallel -j0 -kX  echo {1}-{2} ::: a b c ::: d e f

    echo '### Test of -X {}-{.} with multiple input sources'

    parallel -j1 -kX  echo {}-{.} ::: a ::: b
    parallel -j2 -kX  echo {}-{.} ::: a b ::: c d
    parallel -j2 -kX  echo {}-{.} ::: a b c ::: d e f
    parallel -j0 -kX  echo {}-{.} ::: a b c ::: d e f
}

par_slow_args_generation() {
    echo '### Test slow arguments generation - https://savannah.gnu.org/bugs/?32834'
    seq 1 3 | parallel -j1 "sleep 2; echo {}" | parallel -kj2 echo
}

par_kill_term() {
    echo '### Are children killed if GNU Parallel receives TERM? There should be no sleep at the end'

    parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 &
    T=$!
    sleep 5
    pstree $$
    kill -TERM $T
    sleep 1
    pstree $$
}

par_kill_int_twice() {
    echo '### Are children killed if GNU Parallel receives INT twice? There should be no sleep at the end'

    parallel -q bash -c 'sleep 120 & pid=$!; wait $pid' ::: 1 &
    T=$!
    sleep 5
    pstree $$
    kill -INT $T
    sleep 1
    pstree $$
}

par_children_receive_sig() {
    echo '### Do children receive --termseq signals'

    show_signals() {
	perl -e 'for(keys %SIG) { $SIG{$_} = eval "sub { print STDERR \"Got $_\\n\"; }";} while(1){sleep 1}';
    }
    export -f show_signals
    echo | stdout parallel --termseq TERM,200,TERM,100,TERM,50,KILL,25 -u \
	--timeout 1s show_signals

    echo | stdout parallel --termseq INT,200,TERM,100,KILL,25 -u \
	--timeout 1s show_signals
    sleep 3
}

par_wrong_slot_rpl_resume() {
    echo '### bug #47644: Wrong slot number replacement when resuming'
    seq 0 20 |
	parallel -kj 4 --delay 0.2 --joblog /tmp/parallel-bug-47558 \
		 'sleep 1; echo {%} {=$_==10 and exit =}'
    seq 0 20 |
	parallel -kj 4 --resume --delay 0.2 --joblog /tmp/parallel-bug-47558 \
		 'sleep 1; echo {%} {=$_==110 and exit =}'
}

par_multiline_commands() {
    echo 'bug #50781: joblog format with multiline commands'
    rm -f /tmp/jl.$$
    parallel --jl /tmp/jl.$$ --timeout 2s 'sleep {}; echo {};
echo finish {}' ::: 1 2 4
    parallel --jl /tmp/jl.$$ --timeout 5s --retry-failed 'sleep {}; echo {};
echo finish {}' ::: 1 2 4
    rm -f /tmp/jl.$$
}

par_sqlworker_hostname() {
    echo 'bug #50901: --sqlworker should use hostname in the joblog instead of :'
    # Something like:
    #   :mysqlunittest mysql://tange:tange@localhost/tange
    MY=:mysqlunittest
    parallel --sqlmaster $MY/hostname echo ::: 1 2 3
    parallel -k --sqlworker $MY/hostname
    hostname=`hostname`
    sql $MY 'select host from hostname;' |
	perl -pe "s/$hostname/<hostname>/g"
}

par_delay_human_readable() {
    # Test that you can use d h m s in --delay
    parallel --delay 0.1s echo ::: a b c
    parallel --delay 0.01m echo ::: a b c
}

par_exitval_signal() {
    echo '### Test --joblog with exitval and Test --joblog with signal -- timing dependent'
    rm -f /tmp/parallel_sleep
    rm -f mysleep
    cp /bin/sleep mysleep
    chmod +x mysleep
    parallel --joblog /tmp/parallel_joblog_signal \
	     './mysleep {}' ::: 30 2>/dev/null &
    parallel --joblog /tmp/parallel_joblog_exitval \
	     'echo foo >/tmp/parallel_sleep; ./mysleep {} && echo sleep was not killed=BAD' ::: 30 2>/dev/null &
    while [ ! -e /tmp/parallel_sleep ] ; do
	sleep 1
    done
    sleep 1
    killall -6 mysleep
    wait
    grep -q 134 /tmp/parallel_joblog_exitval && echo exitval=128+6 OK
    grep -q '[^0-9]6[^0-9]' /tmp/parallel_joblog_signal && echo signal OK

    rm -f /tmp/parallel_joblog_exitval /tmp/parallel_joblog_signal
}

par_lb_mem_usage() {
    long_line() {
	perl -e 'print "x"x100_000_000'
    }
    export -f long_line
    memusage() {
	round=$1
	shift
	/usr/bin/time -v "$@" 2>&1 >/dev/null |
	    perl -ne '/Maximum resident set size .kbytes.: (\d+)/ and print $1,"\n"' |
	    perl -pe '$_ = int($_/'$round')."\n"'
    }
    # 1 line - RAM usage 1 x 100 MB
    memusage 100000 parallel --lb ::: long_line
    # 2 lines - RAM usage 1 x 100 MB
    memusage 100000 parallel --lb ::: 'long_line; echo; long_line'
    # 1 double length line - RAM usage 2 x 100 MB
    memusage 100000 parallel --lb ::: 'long_line; long_line'
}

export -f $(compgen -A function | grep par_)
compgen -A function | G par_ "$@" | LC_ALL=C sort |
    parallel --timeout 1000% -j6 --tag -k --joblog /tmp/jl-`basename $0` '{} 2>&1'
