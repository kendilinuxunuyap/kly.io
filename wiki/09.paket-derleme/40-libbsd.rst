libbsd
++++++

libbsd, geliştiricilere daha güvenli ve taşınabilir kod yazma imkanı tanırken, aynı zamanda BSD sistemlerinde yaygın olarak kullanılan işlevlerin Linux üzerinde de kullanılmasını sağlar. Bu kütüphane, sistem programlama ve ağ programlama gibi alanlarda sıkça tercih edilmektedir.

Derleme
--------

Derlemek için **sudo apt-get install libbsd-dev** paketi kurulmalı.

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="libbsd"
	version="0.11.7"
	description="Library to provide useful functions commonly found on BSD systems"
	source="https://libbsd.freedesktop.org/releases/libbsd-$version.tar.xz"
	depends=""
	group="dev.libs"
		
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
	autoreconf -fvi
	./configure --prefix=/usr --libdir=/usr/lib64
	
	# build
	make
		
	# package
	make install DESTDIR=$DESTDIR

Paket adında(libbsd) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build

.. raw:: pdf

   PageBreak



