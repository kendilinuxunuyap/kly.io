openssl
+++++++

OpenSSL, açık kaynaklı bir kriptografik kütüphanedir. coreutils için gerekli olan paket.

Derleme
--------

Debian ortamında bu paketin derlenmesi için; **sudo apt install perl** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="3.2.0"
	name="openssl"
	depends="glibc,zlib"
	source="https://www.openssl.org/source/${name}-${version}.tar.gz"
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
	mkdir -p  $ROOTBUILDDIR #derleme dizini yoksa oluşturuluyor
	rm -rf $ROOTBUILDDIR/* #içeriği temizleniyor
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
	cp -prfv $PACKAGEDIR/files/ $SOURCEDIR
	wget -O $SOURCEDIR/files/cacert.pem https://curl.haxx.se/ca/cacert.pem
	patch -Np1 -i $SOURCEDIR/files/ca-dir.patch
	./config --prefix=/usr  --openssldir=/etc/ssl --libdir=/usr/lib64 shared linux-x86_64
		    
	# build
	make depend
	make -j5 #-C $DESTDIR all
		    
	# package
	mkdir -p "${DESTDIR}/etc/ssl/" "${DESTDIR}/sbin/"
	install $SOURCEDIR/files/update-certdata "${DESTDIR}/sbin/update-certdata"
	install $SOURCEDIR/files/cacert.pem "${DESTDIR}/etc/ssl/cert.pem"
	make DESTDIR="${DESTDIR}" install_sw install_ssldirs install_man_docs  $jobs     

Bu paketin ek dosyalarını indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/openssl/files.tar>`_. tar dosyasını indirdikten sonra **openssl** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. Yukarı verilen script kodlarını **openssl** dizini altında **build** adında bir dosya oluşturup içine kopyalayın ve kaydedin. Oluşturulan  **build** dosyasını **openssl** dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



