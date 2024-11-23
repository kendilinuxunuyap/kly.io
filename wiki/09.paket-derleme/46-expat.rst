expat
+++++

Expat, özellikle C dilinde geliştirilmiş bir XML ayrıştırma kütüphanesidir. Bu kütüphane, XML belgelerini okuma ve işleme süreçlerini kolaylaştırmak amacıyla tasarlanmıştır. Expat, olay tabanlı bir ayrıştırma modeli kullanarak, XML belgelerinin içeriğini parçalara ayırır ve bu parçaları işlemek için geliştiricilere bir dizi geri çağırma (callback) fonksiyonu sunar. Bu sayede, büyük XML dosyaları ile çalışırken bellek verimliliği sağlanır.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="expat"
	version="2.6.2"
	vrsn="2_6_2"
	description="An XML parser library"
	#source="https://github.com/libexpat/libexpat/archive/refs/tags/R_${version}.tar.gz"
	source="https://github.com/libexpat/libexpat/releases/download/R_${vrsn}/expat-${version}.tar.bz2"
	depends=""
	builddepend=""
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
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64 -DCMAKE_BUILD_TYPE=None \
		-DEXPAT_BUILD_DOCS=false -W no-dev -B $BUILDDIR
	
	# build
	make -C $BUILDDIR
	    
	# package
	make DESTDIR="$DESTDIR" install -C $BUILDDIR

Paket adında(expat) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



