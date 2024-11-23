pam
+++

PAM, "Pluggable Authentication Modules" ifadesinin kısaltmasıdır ve Linux işletim sistemlerinde kimlik doğrulama süreçlerini esnek bir şekilde yönetmek için tasarlanmıştır. PAM, sistem yöneticilerine, kimlik doğrulama yöntemlerini modüler bir yapıda değiştirme ve özelleştirme imkanı sunar. Örneğin, bir sistem yöneticisi, kullanıcıların şifre ile kimlik doğrulamasını sağlarken, aynı zamanda iki faktörlü kimlik doğrulama gibi ek güvenlik önlemleri de ekleyebilir.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="pam"
	version="1.6.0"
	depends="libtirpc,libxcrypt,libnsl,audit"
	description="PAM (Pluggable Authentication Modules) library'"
	source="https://github.com/linux-pam/linux-pam/releases/download/v$version/Linux-PAM-$version.tar.xz"
	groups="sys.libs"
		
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
	./configure --prefix=/usr --sbindir=/usr/sbin --libdir=/usr/lib64 \
	--enable-securedir=/usr/lib64/security --enable-static --enable-shared --disable-nls --disable-selinux
		
	# build
	make
	
	# package
	make install DESTDIR=$DESTDIR
	chmod +s "$DESTDIR"/usr/sbin/unix_chkpwd

Paket adında(pam) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



