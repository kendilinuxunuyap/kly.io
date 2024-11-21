squashfs-tools
++++++++++++++

squashfs-tools, Linux tabanlı sistemlerde sıkıştırılmış dosya sistemleri oluşturmak ve yönetmek için kullanılan bir araç setidir. SquashFS, özellikle depolama alanını verimli bir şekilde kullanmak amacıyla dosyaları sıkıştırarak depolayan bir dosya sistemidir. Bu paket, mksquashfs ve unsquashfs gibi komutları içerir. 

Derleme
--------

Debian ortamında bu paketin derlenmesi için;

- **sudo apt install liblz4-dev** 

komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
		
	#!/usr/bin/env bash
	version="4.6.1"
	name="squashfs-tools"
	depends="squashfs"
	description="squashfs"
	source="https://github.com/plougher/squashfs-tools/archive/refs/tags/4.6.1.tar.gz"
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

	setup(){
		cd $SOURCEDIR/squashfs-tools
	}

	build(){
		make GZIP_SUPPORT=1 LZ4_SUPPORT=1 LZMA_XZ_SUPPORT=1 LZO_SUPPORT=1 XATTR_SUPPORT=1 XZ_SUPPORT=1 ZSTD_SUPPORT=1
	}
	package(){
	  	make INSTALL_PREFIX="$DESTDIR/usr" INSTALL_MANPAGES_DIR='$(INSTALL_PREFIX)/share/man/man1' install
	  	install -vDm 644 $SOURCEDIR/{ACTIONS-README,CHANGES,"README-$version",USAGE*} -t "$DESTDIR/usr/share/doc/$name/"
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.
	
Paket adında(squashfs-tools) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build

.. raw:: pdf

   PageBreak



