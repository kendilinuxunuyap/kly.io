rsync
+++++

rsync, dosya transferi ve senkronizasyonu için geliştirilmiş bir yazılımdır. Temel işlevi, yerel veya uzak sistemler arasında dosyaların ve dizinlerin hızlı ve verimli bir şekilde kopyalanmasını sağlamaktır. rsync, yalnızca değişen verileri transfer ederek bant genişliği kullanımını optimize eder. Bu özellik, büyük dosyaların veya dizinlerin güncellenmesi gerektiğinde önemli bir avantaj sunar.

Derleme
--------

Debian ortamında bu paketin derlenmesi için;

- **sudo apt install libzstd-dev libacl1-dev libacl1** 

komutuyla paketin kurulması gerekmektedir.


.. code-block:: shell
	
	#!/usr/bin/env bash
	version="3.2.7"
	name="rsync"
	depends="glibc,acl,openssl"
	description="shell ve network copy"
	source="https://download.samba.org/pub/rsync/src/${name}-${version}.tar.gz"
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
	./configure --prefix=/usr --libdir=/lib64/ --with-included-popt --with-included-zlib --disable-xxhash --disable-lz4
	
	# build
	make 
	    
	# package
	make install DESTDIR=$DESTDIR

Paket adında(rsync) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



