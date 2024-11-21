base-file
+++++++++

Linux sistemimiz için temel ayarlamalar, dosya ve dizin yapıları olması gerekmektedir. Bu yapıyı oluşturduktan sonra sistemi bu yapının üzerine inşaa edeceğiz. Aslında linux sisteminde temel paket **glibc** paketidir. **glibc** paketinin derlenip yüklenmesinden önce temel yapının oluşturulması gerektiği için **base-file** paketi oluşturduk. 

**base-file Komutları**
-----------------------

.. code-block:: shell

	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"	# açık ekran tespit ediliyor
	user=$(who | grep '('$display')' | awk '{print $1}')	#ekranı açan kullanıcı tespit ediliyor
	mkdir -p  /home/$user/distro/build 	#Derleme dizini yoksa oluşturuluyor
	mkdir -p   /home/$user/distro/rootfs  	#Sistemin oluşturlacağı dizin yoksa oluşturuluyor
	rm -rf  /home/$user/distro/build/* #içeriği temizleniyor
	cp -prfv files/*  /home/$user/distro/build/ # Ek dosyalar kopyalanıyor. Ek dosyalar aşağıda verilmiştir.
	cd  /home/$user/distro/build  #build geçiyoruz

	mkdir  -p bin dev etc home lib64 proc root run sbin sys usr var etc/kly tmp tmp/kly/kur \
	var/log  var/tmp usr/lib64/x86_64-linux-gnu usr/lib64/pkgconfig \
	usr/local/{bin,etc,games,include,lib,sbin,share,src}
	ln -s lib64 lib
	cd var&&ln -s ../run run&&cd -
	cd usr&&ln -s lib64 lib&&cd -
	cd usr/lib64/x86_64-linux-gnu&&ln -s ../pkgconfig  pkgconfig&&cd -

	bash -c "echo -e \"/bin/sh \n/bin/bash \n/bin/rbash \n/bin/dash\" >>  /home/$user/distro/build/etc/shell"
	bash -c "echo 'tmpfs /tmp tmpfs rw,nodev,nosuid 0 0' >>  /home/$user/distro/build/etc/fstab"
	bash -c "echo '127.0.0.1 kly' >>  /home/$user/distro/build/etc/hosts"
	bash -c "echo 'kly' >  /home/$user/distro/build/etc/hostname"
	bash -c "echo 'nameserver 8.8.8.8' >  /home/$user/distro/build/etc/resolv.conf"
	echo root:x:0:0:root:/root:/bin/sh >  /home/$user/distro/build/etc/passwd
	chmod 755  /home/$user/distro/build/etc/passwd
	cp -prfv  /home/$user/distro/build/*   /home/$user/distro/rootfs/
	
Yukarıdaki kodları fonksiyonel hale getirmek için aşağıdaki şablon scripti kullanacağız.

Şablon Script Yapısı
--------------------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version=""
	name=""
	depends=""
	source=""
	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"	# açık ekran tespit ediliyor
	user=$(who | grep '('$display')' | awk '{print $1}')	#ekranı açan kullanıcı tespit ediliyor
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
		    dowloadfile=$(ls|head -1)
		    filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
		    if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
		    director=$(find ./* -maxdepth 0 -type d)
		    directorname=$(basename ${director})
		    if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
		    mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	}
	setup(){		#Derleme öncesi kaynak dosyaların sisteme göre ayarlanması	}
	build(){		#Paketin derlenmesi	}
	package(){		# Derlenen dosyaları yükleme öncesi ayar ve yükleme işleminin yapılması	}
	initsetup 	# initsetup fonksiyonunu çalıştırır ve kaynak dosyayı inidirir
	setup		# setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build		# build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package		# package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

.. raw:: pdf

   PageBreak

Şablon içinde kullanılan bazı sabit bilgiler var. Bular;

- ROOTBUILDDIR=" /home/$user/distro/build": Derleme konumu.
- BUILDDIR=" /home/$user/distro/build/build-${name}-${version}": Derlenen paketin derleme konumu.
- DESTDIR=" /home/$user/distro/rootfs": Derlennen paketin yükleme konumu.
- PACKAGEDIR=$(pwd) : Derleme talimatının bulunduğu(build dosyası) konum.
- SOURCEDIR=" /home/$user/distro/build/${name}-${version}": Derlenen paketin kaynak kodlarının konumu.

Derleme konumunu uzun uzun yazmak yerine sadece $ROOTBUILDDIR ifadesi kullanılıyor. Aslında bu işleme takma ad(alias) denir. Mesela kaynak kodların olduğu konumda bir şeyler yapmak istersek $SOURCEDIR ifadesinin kullanmamız yeterli olacaktır. Bu takma adlar tüm paketlerde geçerli olacak ifadelerdir.

**base-file** script dosyasına benzer yapıda diğer paketler içinde script dosyası oluşturulacaktır. Bu sayede her aşamayı tek tek yazma gibi iş yükü olmayacak ve paket derlenirken hangi fonksiyonda(initsetup, setup vb.) sorun yaşanırsa o fonksiyon üzerinden hata ayıklama yapılacaktır.

Yapıyı Oluşturan Script
-----------------------

.. code-block:: shell

	#!/usr/bin/env bash
	version="1.0"
	name="base-file"
	depends=""
	description="sistemin temel yapısı"
	source=""
	groups="sys.base"
	
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
			mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	}
	setup(){	cp -prfv $PACKAGEDIR/files/* $BUILDDIR/	
			}
	build(){			echo ""	
			}
	package(){
			mkdir  -p bin dev etc home lib64 proc root run sbin sys usr var etc/kly tmp tmp/kly/kur \
			var/log  var/tmp usr/lib64/x86_64-linux-gnu usr/lib64/pkgconfig \
			usr/local/{bin,etc,games,include,lib,sbin,share,src}
			ln -s lib64 lib
			cd var&&ln -s ../run run&&cd -
			cd usr&&ln -s lib64 lib&&cd -
			cd usr/lib64/x86_64-linux-gnu&&ln -s ../pkgconfig  pkgconfig&&cd -
			bash -c "echo -e \"/bin/sh \n/bin/bash \n/bin/rbash \n/bin/dash\" >> $BUILDDIR/etc/shell"
			bash -c "echo 'tmpfs /tmp tmpfs rw,nodev,nosuid 0 0' >> $BUILDDIR/etc/fstab"
			bash -c "echo '127.0.0.1 kly' >> $BUILDDIR/etc/hosts"
			bash -c "echo 'kly' > $BUILDDIR/etc/hostname"
			bash -c "echo 'nameserver 8.8.8.8' > $BUILDDIR/etc/resolv.conf"
			echo root:x:0:0:root:/root:/bin/sh > $BUILDDIR/etc/passwd
			chmod 755 $BUILDDIR/etc/passwd
			cp -prfv $BUILDDIR/*  $DESTDIR/
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

.. raw:: pdf

   PageBreak
   	
Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/base-file/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **base-file** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. 

Yukarı verilen script kodlarını **build** adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra **build** scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları **base-file** dizinin içinde terminal açarak çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build


Paket Derleme Yöntemi
---------------------

**base-file** paketleri ilk paketler olmasından dolayı detaylıca anlatıldı. Bu paketten sonraki paketlerde **şablon script** dosyası yapında verilecektir. Script dosya altında ise ek dosyalar varsa **files.tar** şeklinde link olacaktır. Her paket için istediğiniz bir konumda bir dizin oluşturunuz. **files.tar** dosyasını oluşturulan dizin içinde açınız. Test amaçlı derleme yaptığım paketler ve **base-file** için yaptığımız dizin yapısı aşağıda gösterilmiştir.

.. image:: /_static/images/base-file-0.png
  	:width: 600


Derleme scripti için **build** dosyası oluşturup içine yapıştırın ve kaydedin. 
**build**  dosyasının bulunduğu dizininde terminali açarak aşağıdaki gibi çalıştırınız.

.. code-block:: shell
	
	chmod 755 build
	sudo ./build

.. raw:: pdf

   PageBreak

