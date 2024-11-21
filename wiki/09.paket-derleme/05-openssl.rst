openssl
+++++++

OpenSSL, açık kaynaklı bir kriptografik kütüphanedir ve SSL/TLS protokollerini uygulamak, şifreleme, dijital sertifikalar oluşturma ve doğrulama gibi işlemleri gerçekleştirmek için yaygın olarak tercih edilir. coreutils için gerekli olan paket.

Derleme
--------

Debian ortamında bu paketin derlenmesi için; **sudo apt install perl** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="3.2.0"
	name="openssl"
	depends="glibc,zlib"
	description="openssl"
	source="https://www.openssl.org/source/${name}-${version}.tar.gz"
	groups="dev.libs"
	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"	#Detect the name of the display in use
	user=$(who | grep '('$display')' | awk '{print $1}')	#Detect the user using such display
	ROOTBUILDDIR="/home/$user/distro/build" # Derleme konumu
	BUILDDIR="/home/$user/distro/build/build-${name}-${version}" #Derleme yapılan paketin derleme konumun
	DESTDIR="/home/$user/distro/rootfs" #Paketin yükleneceği sistem konumu
	PACKAGEDIR=$(pwd) #paketin derleme talimatının verildiği konum
	SOURCEDIR="/home/$user/distro/build/${name}-${version}" #Paketin kaynak kodlarının olduğu konum
	initsetup(){
			mkdir -p  $ROOTBUILDDIR #derleme dizini yoksa oluşturuluyor
			rm -rf $ROOTBUILDDIR/* #içeriği temizleniyor
			cd $ROOTBUILDDIR #dizinine geçiyoruz
			wget ${source}
			dowloadfile=$(ls|head -1)
			filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
			if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
			director=$(find ./* -maxdepth 0 -type d)
			directorname=$(basename ${director})
			if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
			mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $SOURCEDIR
	}
	setup(){
		    cp -prfv $PACKAGEDIR/files/ $SOURCEDIR
		    wget -O $SOURCEDIR/files/cacert.pem https://curl.haxx.se/ca/cacert.pem
		    patch -Np1 -i $SOURCEDIR/files/ca-dir.patch
		    ./config --prefix=/usr  --openssldir=/etc/ssl --libdir=/usr/lib64 shared linux-x86_64
	}
	build(){
		    make depend
		    make -j5 #-C $DESTDIR all
	}
	package(){
		    mkdir -p "${DESTDIR}/etc/ssl/" "${DESTDIR}/sbin/"
		    install $SOURCEDIR/files/update-certdata "${DESTDIR}/sbin/update-certdata"
		    install $SOURCEDIR/files/cacert.pem "${DESTDIR}/etc/ssl/cert.pem"
		    make DESTDIR="${DESTDIR}" install_sw install_ssldirs install_man_docs  $jobs
		    ${DESTDIR}/sbin/ldconfig -r ${DESTDIR}           # sistem guncelleniyor
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/openssl/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **openssl** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. Oluşturuluna dizinde yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build
  
.. raw:: pdf

   PageBreak



