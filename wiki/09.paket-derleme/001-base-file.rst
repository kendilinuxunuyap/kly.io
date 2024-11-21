base-file
+++++++++

Linux sistemimiz için temel ayarlamalar, dosya ve dizin yapıları olması gerekmektedir. Bu yapıyı oluşturduktan sonra sistemi bu yapının üzerine inşaa edeceğiz. Aslında linux sisteminde temel paket **glibc** paketidir. **glibc** paketinin derlenip yüklenmesinden önce temel yapının oluşturulması gerektiği için **base-file** paketi oluşturduk. 

**base-file Komutları**
-----------------------

.. code-block:: shell
	
	# Sistemin oluşturulacağı dizin yoksa oluşturuluyor
	mkdir -p   $HOME/distro/rootfs
	# Derleme dizini yoksa oluşturuluyor
	mkdir -p  /tmp/build
	# içeriği temizleniyor 	
	rm -rf  /tmp/build/* 
	# Ek dosyalar kopyalanıyor. Ek dosyalar aşağıda verilmiştir.
	cp -prfv files/*  /tmp/build/
	# derleme konumuna geçiyoruz
	cd  /tmp/build
	
	# sistemin genel dizin yapısı oluşturuluyor
	mkdir  -p bin dev etc home lib64 proc root run sbin sys usr var etc/kly tmp tmp/kly/kur \
	var/log  var/tmp usr/lib64/x86_64-linux-gnu usr/lib64/pkgconfig \
	usr/local/{bin,etc,games,include,lib,sbin,share,src}
	ln -s lib64 lib
	cd var&&ln -s ../run run&&cd -
	cd usr&&ln -s lib64 lib&&cd -
	cd usr/lib64/x86_64-linux-gnu&&ln -s ../pkgconfig  pkgconfig&&cd -

	bash -c "echo -e \"/bin/sh \n/bin/bash \n/bin/rbash \n/bin/dash\" >>  /tmp/build/etc/shell"
	bash -c "echo 'tmpfs /tmp tmpfs rw,nodev,nosuid 0 0' >>  /tmp/build/etc/fstab"
	bash -c "echo '127.0.0.1 kly' >>  /tmp/build/etc/hosts"
	bash -c "echo 'kly' >  /tmp/build/etc/hostname"
	bash -c "echo 'nameserver 8.8.8.8' >  /tmp/build/etc/resolv.conf"
	echo root:x:0:0:root:/root:/bin/sh >  /tmp/build/etc/passwd
	chmod 755  /tmp/build/etc/passwd
	
	# tasarladığımız sistemin konumuna kopyalıyoruz.
	cp -prfv  /tmp/build/*   $HOME/distro/rootfs/
	
Yukarıdaki kodları standart bir yapıya dönüştürüp aşağıdaki şablon scriptini kullanacağız.

Şablon Script Yapısı
--------------------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version=""
	name=""
	depends=""
	source=""

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
	
	# derleme dizini yoksa oluşturuluyor
	mkdir -p  $ROOTBUILDDIR
	# içeriği temizleniyor 
	rm -rf $ROOTBUILDDIR/*
	# dizinine geçiyoruz 
	cd $ROOTBUILDDIR
	# Kaynak Dosya indiriliyor ve paket ismiyle açılıyor
	wget ${source}
	dowloadfile=$(ls|head -1)
	filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
	if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
	director=$(find ./* -maxdepth 0 -type d)
	directorname=$(basename ${director})
	if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
	# derleme dizini, yüklenecek konum dizini açılıyor ve derleme dizinine geçiliyor
	mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	# Paket derleme öncesi hazırlık
	# ...
	# Paket derlenmesi
	# ...
	# paket derleme sonrası yükleme ve ayarlar
	# ...



Şablon içinde kullanılan bazı sabit bilgiler var. Bular;

- ROOTBUILDDIR="/tmp/kly/build": Derleme konumu.
- BUILDDIR="/tmp/kly/build/build-${name}-${version}": Derlenen paketin derleme konumu.
- DESTDIR="$HOME/distro/rootfs": Derlennen paketin yükleneceği(tsarladığımız sistem) konum.
- PACKAGEDIR=$(pwd) : Derleme talimatının bulunduğu(build dosyası) konum.
- SOURCEDIR="/tmp/kly/build/${name}-${version}": Derlenen paketin kaynak kodlarının konumu.

Derleme konumunu uzun uzun yazmak yerine sadece $ROOTBUILDDIR ifadesi kullanılıyor. Aslında bu işleme takma ad(alias) denir. Mesela kaynak kodların olduğu konumda bir şeyler yapmak istersek $SOURCEDIR ifadesinin kullanmamız yeterli olacaktır. Bu takma adlar tüm paketlerde geçerli olacak ifadelerdir.

.. raw:: pdf

   PageBreak
   
Şablon Script(base-file)
------------------------

.. code-block:: shell

	#!/usr/bin/env bash
	version="1.0"
	name="base-file"
	depends=""
	description="sistemin temel yapısı"
	source=""
	groups="sys.base"

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
	mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	
	# setup
	cp -prfv $PACKAGEDIR/files/* $BUILDDIR/	
	# build
	
	# package
	mkdir  -p bin dev etc home lib64 proc root run sbin sys usr var etc/kly tmp tmp/kly/kur \
	var/log  var/tmp usr/lib64/x86_64-linux-gnu usr/lib64/pkgconfig \
	usr/local/{bin,etc,games,include,lib,sbin,share,src}
	ln -s lib64 lib
	cd var&&ln -s ../run run&&cd -
	cd usr&&ln -s lib64 lib&&cd -
	cd usr/lib64/x86_64-linux-gnu&&ln -s ../pkgconfig  pkgconfig&&cd -
	bash -c "echo -e \"/bin/sh \n/bin/bash \n/bin/rbash \n/bin/dash\" >> $BUILDDIR/etc/shell"
	bash -c "echo 'tmpfs /tmp tmpfs rw,nodev,nosuid 0 0' >> $BUILDDIR/etc/fstab"
	bash -c "echo '127.0.0.1 kly' >> $BUILDDIR/etc/hosts"
	bash -c "echo 'kly' > $BUILDDIR/etc/hostname"
	bash -c "echo 'nameserver 8.8.8.8' > $BUILDDIR/etc/resolv.conf"
	echo root:x:0:0:root:/root:/bin/sh > $BUILDDIR/etc/passwd
	chmod 755 $BUILDDIR/etc/passwd
	cp -prfv $BUILDDIR/*  $DESTDIR/

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/base-file/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **base-file** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. 

Yukarı verilen script kodlarını **build** adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra **build** scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları **base-file** dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build


.. raw:: pdf

   PageBreak
   	
   	
Paket Derleme Yöntemi
---------------------

**base-file** paketleri ilk paketler olmasından dolayı detaylıca anlatıldı. Bu paketten sonraki paketlerde **şablon script** dosyası yapısında verilecektir. Script dosya altında ise ek dosyalar varsa **files.tar** şeklinde link olacaktır. Her paket için istediğiniz bir konumda bir dizin oluşturunuz. **files.tar** dosyasını oluşturulan dizin içinde açınız. Test amaçlı derleme yaptığım paketler ve **base-file** için yaptığımız dizin yapısı aşağıda gösterilmiştir.

.. image:: /_static/images/base-file-0.png
  	:width: 600


Derleme scripti için **build** dosyası oluşturup içine yapıştırın ve kaydedin. 
**build**  dosyasının bulunduğu dizininde terminali açarak aşağıdaki gibi çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build

.. raw:: pdf

   PageBreak

