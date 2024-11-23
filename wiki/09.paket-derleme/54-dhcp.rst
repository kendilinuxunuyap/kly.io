dhcp
++++

Bu protokol, bir istemci cihazın ağa bağlandığında, DHCP sunucusuna bir istek göndererek IP adresi talep etmesiyle başlar. Sunucu, istemciye uygun bir IP adresi, alt ağ maskesi, varsayılan ağ geçidi ve DNS sunucusu gibi bilgileri iletir.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="dhcp"
	version="4.4.3"
	description="GNU regular expression matcher"
	source="https://downloads.isc.org/isc/dhcp/4.4.3/dhcp-4.4.3.tar.gz"
	depends=""
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
	cp -prvf ${PACKAGEDIR}/files $SOURCEDIR/
	./configure --prefix=/usr --libdir=/usr/lib64/
	
	# build
	make
	    
	# package
	mkdir -p $DESTDIR/sbin/
	make install DESTDIR=$DESTDIR
	install  $SOURCEDIR/client/scripts/linux $DESTDIR/sbin/dhclient-script
	mkdir -p $DESTDIR/etc/init.d    
	for level in boot default nonetwork shutdown sysinit ; do
	mkdir -p ${DESTDIR}/etc/runlevels/$level
	done
	install -Dm755  $SOURCEDIR/files/dhclient.init.d $DESTDIR/etc/init.d/dhclient
	install -Dm755  $SOURCEDIR/files/dhclient.init.d ${DESTDIR}/etc/runlevels/default/dhclient

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/dhcp/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **dhcp** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.

Paket adında(dhcp) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



