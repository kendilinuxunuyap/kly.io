readline 
+++++++++++

libreadline, Linux işletim sistemi için geliştirilmiş bir kütüphanedir. Bu kütüphane, kullanıcıların komut satırında girdi almasını ve düzenlemesini sağlar. Bir programcı olarak, libreadline'i kullanarak kullanıcı girdilerini okuyabilir, düzenleyebilir ve işleyebilirsiniz.

Derleme
-------

Debian ortamında bu paketin derlenmesi için;
**sudo apt install libreadline-dev** komutuyla paketin kurulması gerekmektedir.

.. code-block:: shell

	#!/usr/bin/env bash
	version="8.2"
	name="readline"
	depends="glibc"
	description="readline kütüphanesi"
	source="https://ftp.gnu.org/pub/gnu/readline/${name}-${version}.tar.gz"
	groups="sys.apps"
	
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
		    mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $SOURCEDIR
	}
	
	setup(){
		cp -prvf $PACKAGEDIR/files $SOURCEDIR/
		./configure --prefix=/usr \
			--libdir=/usr/lib64
	}

	build(){
		make SHLIB_LIBS="-L/tools/lib -lncursesw"
	}

	package(){
		make SHLIB_LIBS="-L/tools/lib -lncursesw" DESTDIR="$DESTDIR" install pkgconfigdir="/usr/lib64/pkgconfig"
		
		install -Dm644 $SOURCEDIR/files/inputrc "$DESTDIR"/etc/inputrc
		${DESTDIR}/sbin/ldconfig -r ${DESTDIR}           # sistem guncelleniyor
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/readline/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **readline** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.

Paket adında(readline) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	sudo ./build
  
Program Yazma
-------------

Altta görülen **readline**  kütüphanesini kullanarak terminalde kullanıcıdan mesaj alan ve mesajı ekrana yazan programı hazırladık.
$HOME(ev dizinimiz) dizinine merhaba.c dosyası oluşturup aşağıdaki kodları ekleyelim.

.. code-block:: shell

	# merhaba.c doayası
	#include<stdio.h>
	#include<readline/readline.h>
	void main()
	{
	char* msg=readline("Adını Yaz:");
	puts(msg);
	}

Program Derleme
---------------

.. code-block:: shell

	cd $HOME
	gcc -o merhaba merhaba.c -lreadline
	cp merhaba $HOME/distro/rootfs/merhaba

Program Test Etme
-----------------

.. code-block:: shell

	sudo chroot $HOME/distro/rootfs /merhaba

Program hatasız çalışıyorsa **readline** kütüphanemiz hatasız derlenmiş olacaktır.

.. raw:: pdf

   PageBreak

