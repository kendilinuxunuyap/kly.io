audit
+++++

Audit paketi, Linux sistemlerinde güvenlik denetimlerini gerçekleştirmek için tasarlanmış bir yazılımdır. Bu paket, sistemdeki önemli olayları, kullanıcı aktivitelerini ve dosya erişimlerini kaydederek, sistem yöneticilerine kapsamlı bir denetim ve izleme imkanı sunar. 

Derleme
--------

Debian ortamında bu paketin derlenmesi için; **sudo apt install libaudit-dev** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="audit"
	version='3.1.1'
	depends=""
	description="servis yöneticisi"
	source="https://github.com/linux-audit/audit-userspace/archive/refs/tags/v$version.tar.gz"
	groups="sys.process"
		
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
	cp -prvf $PACKAGEDIR/files/ $SOURCEDIR
	./autogen.sh
	./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib64 --disable-zos-remote --disable-listener \
	--disable-systemd --disable-gssapi-krb5 --enable-shared=audit --with-arm --with-aarch64 --without-python \
	--without-python3 --with-libcap-ng=no

	# build
	make

	# package
	make install DESTDIR=$DESTDIR
	install -Dm755 files/auditd.initd "$DESTDIR"/etc/init.d/auditd
	install -Dm755 files/auditd.confd "$DESTDIR"/etc/conf.d/auditd

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/audit/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **audit** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.


Paket adında(audit) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak




