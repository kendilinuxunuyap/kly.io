curl
++++

Curl, "Client URL" ifadesinin kısaltmasıdır ve internet protokolleri üzerinden veri transferi yapabilen bir komut satırı aracıdır. Özellikle HTTP, HTTPS, FTP gibi protokollerle çalışarak, web sunucularına istek göndermek ve yanıt almak için kullanılır. Linux sistemlerinde yaygın olarak kullanılan bu araç, geliştiricilere ve sistem yöneticilerine API'lerle etkileşim kurma, dosya indirme veya yükleme gibi işlemleri kolaylaştırır.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="8.4.0"
	name="curl"
	depends="glibc,acl,openssl"
	description="shell ve network copy"
	source="https://curl.se/download/${name}-${version}.tar.xz"
	groups="net.misc"
		
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
	opts=(
	--prefix=/usr --libdir=/usr/lib64 --disable-ldap --disable-ldaps --disable-versioned-symbols
	--enable-doh --enable-ftp --enable-ipv6 --with-ca-path=/etc/ssl/certs --with-ca-bundle=/etc/ssl/cert.pem
	--enable-threaded-resolverl --enable-websockets --without-libidn2 --without-libpsl --without-nghttp2)
	./configure ${opts[@]} --with-openssl
	
	# build 
	make
	
	# package
	make install DESTDIR=$DESTDIR
	cd $DESTDIR
	for ver in 3 4.0.0 4.1.0 4.2.0 4.3.0 4.4.0 4.5.0 4.6.0 4.7.0; do
	ln -s $DESTDIR/lib/libcurl.so.4.8.0 $DESTDIR/lib/libcurl.so.${ver}
	done

Paket adında(curl) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak




