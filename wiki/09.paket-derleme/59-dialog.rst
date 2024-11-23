dialog
++++++

Dialog paketi, terminal tabanlı uygulamalar için kullanıcı ile etkileşim kurmayı kolaylaştıran bir araçtır. Bu paket, kullanıcıdan bilgi almak veya kullanıcıya bilgi sunmak amacıyla çeşitli diyalog kutuları oluşturmanıza olanak tanır. Örneğin, metin kutuları, onay kutuları, seçim kutuları gibi farklı türde diyaloglar oluşturabilirsiniz.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="1.3-20230209"
	name="dialog"
	depends="glibc,readline,ncurses"
	description="shell box kütüphanesi"
	source="https://invisible-island.net/archives/dialog/${name}-${version}.tgz"
	groups="sys.apps"
		
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
   	./configure --prefix=/usr --libdir=/lib64/ --with-ncursesw
	
	# build
	make 
	    
	# package
	make install DESTDIR=$DESTDIR

Paket adında(dialog) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak




