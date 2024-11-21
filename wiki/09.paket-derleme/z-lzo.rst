lzo
+++

LZO (Lempel-Ziv-Oberhumer), hızlı veri sıkıştırma ve açma işlemleri için tasarlanmış bir algoritmadır. Özellikle, yüksek hızda sıkıştırma ve açma işlemleri gerektiren uygulamalarda tercih edilir. LZO, kayıpsız bir sıkıştırma yöntemi sunar; yani, sıkıştırılmış veriyi açtığınızda orijinal veriyi tam olarak geri alırsınız.

Derleme
--------

Debian ortamında bu paketin derlenmesi için;

- **sudo apt install liblz4-dev** 

komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
		
	#!/usr/bin/env bash
	version="2.10"
	name="lzo"
	depends=""
	description="squashfs lzo"
	source="https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
	groups="app.shell"

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

	setup()
	{
		cd $SOURCEDIR
	  ./configure --prefix=/usr --enable-shared
	 
		
	}
	build()
	{
		make
	  # build minilzo
	  gcc $CPPFLAGS $CFLAGS -fpic -Iinclude/lzo -o minilzo/minilzo.o -c minilzo/minilzo.c
	  gcc $LDFLAGS -shared -o libminilzo.so.0 -Wl,-soname,libminilzo.so.0 minilzo/minilzo.o
	}
	package()
	{

	  make DESTDIR="${DESTDIR}" install

	  # install minilzo
	  install -m 755 libminilzo.so.0 "${DESTDIR}"/usr/lib
	  install -p -m 644 minilzo/minilzo.h ${DESTDIR}/usr/include/lzo
	  cd "${DESTDIR}"/usr/lib
	  ln -s libminilzo.so.0 libminilzo.so

	}


	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.
	
Paket adında(lzo) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build

.. raw:: pdf

   PageBreak



