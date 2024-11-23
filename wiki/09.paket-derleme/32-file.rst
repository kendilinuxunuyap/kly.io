file
++++

Linux'ta "file" komutu, dosyaların türlerini tanımlamak için kullanılan bir araçtır. Bu komut, dosyanın içeriğini analiz ederek, dosyanın ne tür bir veri içerdiğini belirler. Örneğin, bir dosyanın metin dosyası mı, ikili dosya mı yoksa bir resim dosyası mı olduğunu tespit edebilir.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="file"
	version="5.45"
	description="Identify a files format by scanning binary data for patterns"
	source=("http://ftp.astron.com/pub/file/file-${version}.tar.gz")
	group=(sys.apps)
	depends=""
		
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
	./configure --prefix=/usr --libdir=/usr/lib64 --enable-static --enable-elf --enable-elf-core \
	--enable-zlib --enable-xzlib --enable-bzlib --enable-libseccomp

	# build 
	make
	
	# package
	make install DESTDIR=$DESTDIR

Paket adında(file) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



