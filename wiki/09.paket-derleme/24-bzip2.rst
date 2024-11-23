bzip2
+++++

bzip2, dosyaları sıkıştırmak için kullanılan bir yazılımdır ve genellikle Unix tabanlı sistemlerde tercih edilmektedir.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="1.0.8"
	name="bzip2"
	depends="glibc,readline,ncurses"
	description="şıkıştırma kütüphanesi"
	source="https://sourceware.org/pub/bzip2/${name}-${version}.tar.gz"
	groups="app.arch"
		
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
	sed -i -e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
	sed -i -e "s:1\.0\.4:$version:" bzip2.1 bzip2.txt Makefile-libbz2_so manual.*
	
	# build 
	make -f Makefile-libbz2_so all
	make all
	
	# package
	cd $SOURCEDIR
	make DESTDIR=$DESTDIR/usr install
	install -D libbz2.so.$version "$DESTDIR"/usr/lib64/libbz2.so.$version
	ln -s libbz2.so.$version "$DESTDIR"/usr/lib64/libbz2.so
	ln -s libbz2.so.$version "$DESTDIR"/usr/lib64/libbz2.so.${version%%.*}
	mkdir -p "$DESTDIR"/usr/lib64/pkgconfig/
	install -Dm644 files/bzip2.pc -t "$DESTDIR"/usr/lib64/pkgconfig

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/bzip2/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **bzip2** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.

Paket adında(bzip2) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak




