shadow
++++++

Shadow paketi, Linux işletim sistemlerinde kullanıcı hesaplarının şifrelerini güvenli bir şekilde saklamak için kullanılan bir mekanizmadır. Bu paket, kullanıcı bilgilerini ve şifrelerini içeren dosyaların yönetiminde önemli bir rol oynamaktadır.

Derleme
--------

Debian ortamında bu paketin derlenmesi için; **sudo apt install libreadline-dev libcap-dev libcap2-bin** komutları çalıştırıldıktan sonra derleme yapılmalıdır.

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="shadow"
	version="4.13"
	description="Password and account management tool suite with support for shadow files and PAM"
	source="https://github.com/shadow-maint/shadow/releases/download/$version/shadow-$version.tar.xz"
	depends="pam,libxcrypt,acl,attr"
	group="sys.apps"
		
	# Paketin yükleneceği tasarlanan sistem konumu
	DESTDIR="$HOME/distro/rootfs"
	# Derleme konumu
	ROOTBUILDDIR="/tmp/kly/build"
	# Derleme yapılan paketin derleme konumun
	BUILDDIR="/tmp/kly/build/build-${name}-${version}" 
	# paketin derleme talimatının verildiği konum
	PACKAGEDIR=$(pwd) 
	# Paketin kaynak kodlarının olduğu konum
	SOURCEDIR="/tmp/kly/build/${name}-${version}" 

	# initsetup
	# derleme dizini yoksa oluşturuluyor
	mkdir -p  $ROOTBUILDDIR
	# içeriği temizleniyor
	rm -rf $ROOTBUILDDIR/* 
	cd $ROOTBUILDDIR #dizinine geçiyoruz
	wget ${source}
	# isimde boşluk varsa silme işlemi yapılıyor
	for f in *\ *; do mv "$f" "${f// /}"; done 
	dowloadfile=$(ls|head -1)
	filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
	if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
	director=$(find ./* -maxdepth 0 -type d)
	directorname=$(basename ${director})
	if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
	mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $SOURCEDIR

	# setup
	cp -prvf $PACKAGEDIR/files/ $SOURCEDIR/
	autoreconf -fiv      
	./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --bindir=/usr/bin --sbindir=/usr/sbin \
	--disable-account-tools-setuid --without-sssd --with-fcaps --with-libpam --without-group-name-max-length \
	 --with-bcrypt --with-yescrypt --without-selinux
	
	# build 
	make
	
	# package
	make install DESTDIR=$DESTDIR
	mkdir -p "${DESTDIR}/etc" "${DESTDIR}/etc/default/"
	sed -i "/.*selinux.*/d" ${DESTDIR}/etc/pam.d/*
	install -vDm 600 $SOURCEDIR/files/useradd.defaults "${DESTDIR}/etc/default/useradd"
	install -vDm 600 $SOURCEDIR/files/system-auth "${DESTDIR}/etc/pam.d/system-auth"
	if [ ! -f ${DESTDIR}/etc/group ] ; then install -vDm 600 $SOURCEDIR/files/group "${DESTDIR}/etc/group"; fi
	if [ ! -f ${DESTDIR}/etc/shadow ] ; then echo "root:*::0:::::" > ${DESTDIR}/etc/shadow; fi
	chmod 600 ${DESTDIR}/etc/shadow
	chmod 644 ${DESTDIR}/etc/group
	chown root ${DESTDIR}/etc/group  ${DESTDIR}/etc/shadow
	chgrp root ${DESTDIR}/etc/group  ${DESTDIR}/etc/shadow

	if [ ! -f "${DESTDIR}/etc/passwd" ]; then echo -e "root:x:0:0:root:/root:/bin/sh">${DESTDIR}/etc/passwd; fi

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/shadow/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **shadow** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.

Paket adında(shadow) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



