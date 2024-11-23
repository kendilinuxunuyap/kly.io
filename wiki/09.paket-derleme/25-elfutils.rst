elfutils
++++++++

elfutils, ELF dosyalarının oluşturulması, düzenlenmesi ve incelenmesi için gerekli araçları sağlayan bir yazılım paketidir. Bu paket, özellikle derleyiciler ve bağlantı editörleri tarafından üretilen ikili dosyaların yapısını anlamak ve analiz etmek için kullanılır.

Paket, readelf, objdump, eu-strip gibi araçları içerir. Örneğin, readelf komutu, bir ELF dosyasının içeriğini detaylı bir şekilde görüntülemeye olanak tanırken, objdump ise ikili dosyaların iç yapısını analiz etmek için kullanılır. Bu araçlar, geliştiricilerin yazılımlarını optimize etmelerine ve hata ayıklama süreçlerini kolaylaştırmalarına yardımcı olur.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="elfutils"
	version="0.190"
	description="Libraries/utilities to handle ELF objects (drop in replacement for libelf)"
	source="https://sourceware.org/elfutils/ftp/${version}/elfutils-${version}.tar.bz2"
	depends="bzip2,xz-utils,zstd,zlib"
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
	./configure --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-debuginfod \
	--enable-libdebuginfod=dummy --disable-thread-safety --disable-valgrind --disable-nls \
	--program-prefix="eu-" --with-bzlib --with-lzma 
	
	# build 
	make
	
	# package
	make install DESTDIR=$DESTDIR

Paket adında(elfutils) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



