glibc
+++++

**glibc** linux dağıtımlarında bütün uygulamaların çalışmasını sağlayan en temel C kütüphanesidir. **glibc** dışında diğer C standart kütüphaneler şunlardır: Bionic libc, dietlibc, EGLIBC, klibc, musl, Newlib ve uClibc. **glibc** temel kütüphane olduğu için ilk bu paketi derleyeceğiz.

glibc Script Dosyası
--------------------

Debian ortamında bu paketin derlenmesi için;
**sudo apt install make bison gawk diffutils gcc gettext grep perl sed texinfo libtool** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="2.39"
	name="glibc"
	depends=""
	description="temel kütüphane"
	source="https://ftp.gnu.org/gnu/libc/${name}-${version}.tar.gz"
	groups="sys.base"
	export CC="gcc"
	export CXX="g++"
	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"	#Detect the name of the display in use
	user=$(who | grep '('$display')' | awk '{print $1}')	#Detect the user using such display
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
		    mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	}

	setup()	{
			cp -prvf $PACKAGEDIR/files $BUILDDIR/            
			echo "slibdir=/lib64" >> configparms
			echo "rtlddir=/lib64" >> configparms
			$SOURCEDIR/configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --enable-bind-now \
			--enable-multi-arch --enable-stack-protector=strong --enable-stackguard-randomization --disable-crypt --disable-profile --disable-werror --enable-static-pie \
			--enable-static-nss--disable-nscd --host=x86_64-pc-linux-gnu --libdir=/lib64 --libexecdir=/lib64/glibc
	}
	build(){
		  	make -j5 #-C $DESTDIR all
	}
	package(){
			mkdir -p ${DESTDIR}/lib64
			cd $DESTDIR
			ln -s lib64 lib
			cd $BUILDDIR
			make install DESTDIR=$DESTDIR

			mkdir -p ${DESTDIR}/etc/ld.so.conf.d/ ${DESTDIR}/etc/sysconf.d/ ${DESTDIR}/bin
			install $BUILDDIR/files/ld.so.conf ${DESTDIR}/etc/ld.so.conf
			install $BUILDDIR/files/usr-support.conf ${DESTDIR}/etc/ld.so.conf.d/
			install $BUILDDIR/files/x86_64-linux-gnu.conf ${DESTDIR}/etc/ld.so.conf.d/
			rm -f ${DESTDIR}/etc/ld.so.cache	# remove ld.so.cache file
			install $BUILDDIR/files/locale-gen ${DESTDIR}/bin/locale-gen 	# install extra tools
			install $BUILDDIR/files/revdep-rebuild ${DESTDIR}/bin/revdep-rebuild
			install $BUILDDIR/files/tr_TR ${DESTDIR}/usr/share/i18n/locales/tr_TR # replace buggy turkish format with better one
			sed -i "s|#!/bin/bash|#!/bin/sh|g" ${DESTDIR}/usr/bin/ldd	# fix ldd shebang
	   		cd ${DESTDIR}/lib64/ &&mkdir -p x86_64-linux-gnu&&cd x86_64-linux-gnu
	   		   
		         while read -rd '' file; do
		           ln -s $file $(basename "$file")
	   		done< <(find "../"  -maxdepth 1 -type f -iname "*" -print0)
			${DESTDIR}/sbin/ldconfig -r ${DESTDIR}           # sistem guncelleniyor
	}

	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/glibc/files.tar>`_ tar dosyasını indirdikten sonra **glibc** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. 

Yukarı verilen script kodlarını **build** adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra **build** scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları **glibc** dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build

.. raw:: pdf

   PageBreak

Test Etme
---------

glibc kütüphanemizi **$HOME/distro/rootfs** komununa yüklendi. Şimdi bu kütüphanenin çalışıp çalışmadığını test edelim. Aşağıdaki c kodumuzu derleyelim ve **$HOME/distro/rootfs** konumuna kopyalayalım. **$HOME/** (ev dizinimiz) konumuna dosyamızı oluşturup aşağıdaki kodu içine yazalım.

.. code-block:: shell

	#include<stdio.h>
	void main(){
	puts("Merhaba Dünya");
	}

Program Derleme
................

.. code-block:: shell
	
	cd $HOME
	gcc -o merhaba merhaba.c #merhaba.c dosyası derlenir.

Program Yükleme
...............

Derlenen çalışabilir merhaba dosyamızı **glibc** kütüphanemizin olduğu dizine yükleyelim. 

.. code-block:: shell
	
	cp merhaba $HOME/distro/rootfs/merhaba # derlenen merhaba ikili dosyası $HOME/distro/rootfs/ konumuna kopyalandı.

Programı Test Etme
..................

**glibc** kütüphanemizin olduğu dizin dağıtımızın ana dizini oluyor.  **$HOME/distro/rootfs/** konumuna **chroot** ile erişelim.

Aşağıdaki gibi çalıştırdığımızda bir hata alacağız.

.. code-block:: shell

	sudo chroot $HOME/distro/rootfs/ /merhaba
	chroot: failed to run command ‘/merhaba’: No such file or directory
	
Hata Çözümü
...........

.. code-block:: shell
	
	# üstteki hatanın çözümü sembolik bağ oluşturmak.
	cd $HOME/distro/rootfs/
	ln -s lib lib64

#merhaba dosyamızı tekrar chroot ile çalıştıralım. Aşağıda görüldüğü gibi hatasız çalışacaktır.

.. code-block:: shell
	
	sudo chroot $HOME/distro/rootfs/ /merhaba
	Merhaba Dünya

**Merhaba Dünya** mesajını gördüğümüzde glibc kütüphanemizin  ve merhaba çalışabilir dosyamızın çalıştığını anlıyoruz. 
Bu aşamadan sonra **Temel Paketler** listemizde bulunan paketleri kodlarından derleyerek **$HOME/distro/rootfs/** dağıtım dizinimize yüklemeliyiz.

Derlemede **glibc** kütüphanesinin derlemesine benzer bir yol izlenecektir. **glibc** temel kütüphane olması ve ilk derlediğimiz paket olduğu için detaylıca anlatılmıştır. Diğer paketlerimizde de **glibc** için paylaşılan script dosyası gibi dosyalar hazırlayıp derlenecektir.

.. raw:: pdf

   PageBreak


