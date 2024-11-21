lz4
+++

LZ4, yüksek hızda veri sıkıştırma ve açma işlemleri gerçekleştiren bir algoritmadır. Genellikle, büyük veri setlerini hızlı bir şekilde sıkıştırmak ve açmak için kullanılır. LZ4, özellikle performansın kritik olduğu durumlarda tercih edilir. Örneğin, oyun verileri, veri tabanları ve ağ iletişimi gibi alanlarda sıkça kullanılır.

Derleme
--------

Debian ortamında bu paketin derlenmesi için;

- **sudo apt install liblz4-dev** 

komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
		
	#!/usr/bin/env bash
	name="lz4"
	version="1.9.4"
	description="Extremely fast compression algorithm"
	source="https://github.com/lz4/lz4/archive/refs/tags/v1.9.4.tar.gz"
	depends=""
	builddepend=""
	group="app.arch"


	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"      #Detect the name of the display in use
	user=$(who | grep '('$display')' | awk '{print $1}')    #Detect the user using such display
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
		for f in *\ *; do mv "$f" "${f// /}"; done #isimde boşluk varsa silme işlemi yapılıyor
		        dowloadfile=$(ls|head -1)
		        filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
		        if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
		        director=$(find ./* -maxdepth 0 -type d)
		        directorname=$(basename ${director})
		        if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
		        mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $SOURCEDIR
	}

	setup(){
		echo ""
	}

	build(){
		cd $SOURCEDIR
		make PREFIX=/usr
	}

	package(){
		make install DESTDIR=$DESTDIR PREFIX=/usr
		mv ${DESTDIR}/usr/{lib,lib64}
	}

	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.
	
Paket adında(lz4) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build

.. raw:: pdf

   PageBreak



