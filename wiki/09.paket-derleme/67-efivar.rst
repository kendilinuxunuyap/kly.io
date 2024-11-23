efivar
++++++

efivar paketi, UEFI tabanlı sistemlerde, firmware ile işletim sistemi arasında veri alışverişini sağlamak için kritik bir rol oynamaktadır. UEFI, BIOS'un yerini alarak daha modern bir arayüz sunmakta ve sistem başlangıcında daha fazla esneklik sağlamaktadır. efivar, UEFI değişkenlerini okuma, yazma ve silme işlemlerini gerçekleştirmek için bir dizi komut sunar.

Derleme
--------

Debian ortamında bu paketin derlenmesi için; **sudo apt install libefivar-dev** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="efivar"
	version="39"
	description="Tools and libraries to work with EFI variables"
	source="https://github.com/rhboot/efivar/archive/refs/tags/$version.tar.gz"
	depends=""
	builddepend=""
	group="sys.libs"
		
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
	export ERRORS=''
	export PATH=$PATH:$HOME
	# fake mandoc for ignore extra dependency
	echo "exit 0" > $HOME/mandoc		
	chmod +x $HOME/mandoc
	
	# build
	make
	    
	# package
	local make_options=(V=1 libdir=/usr/lib64/ bindir=/usr/bin/ mandir=/usr/share/man/ includedir=/usr/include/)
	make DESTDIR=$DESTDIR "${make_options[@]}" install

Paket adında(efivar) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak




