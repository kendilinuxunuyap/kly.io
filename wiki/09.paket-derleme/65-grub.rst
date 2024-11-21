grub
++++

GRUB (GRand Unified Bootloader), çoklu işletim sistemlerini destekleyen ve kullanıcıların sistemlerini başlatmalarını sağlayan bir önyükleyici yazılımıdır. GRUB yapılandırma dosyası genellikle /boot/grub/grub.cfg konumunda bulunur.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="grub"
	version="2.12"
	description="GNU GRand Unified Bootloader"
	source="https://ftp.gnu.org/gnu/grub/grub-$version.tar.xz"
	depends="glibc,readline,ncurses,xz-utils,efibootmgr"
	builddepend="rsync,freetype,ttf-dejavu"
	group="sys.boot"
	uses=(efi bios)
	uses_extra=(ia32)
	dontstrip=1
	efi_dp=(efibootmgr)
	ia32_dp=(efibootmgr)
	unset CFLAGS
	unset CXXFLAGS

	get_grub_opt(){ echo -n "--disable-efiemu "
		if [[ "$1" == "efi" ]] ; then echo -n "--with-platform=efi --target=x86_64"
		elif [[ "$1" == "ia32" ]] ; then echo -n "--with-platform=efi --target=i386"
		elif [[ "$1" == "bios" ]] ; then echo -n "--with-platform=pc"
		fi
		}
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
	setup(){	cd $ROOTBUILDDIR
	 echo depends bli part_gpt > $SOURCEDIR/grub-core/extra_deps.lst
		for tgt in ${uses[@]} ; do cp -prfv $name-$version $tgt; done
		for tgt in ${uses[@]} ; do
		    cd $tgt
		    autoreconf -fvi
		    ./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib64/ --disable-nls --disable-werror --disable-grub-themes $(get_grub_opt $tgt)
		    cd ..
		done
	}
	build(){ for tgt in ${uses[@]} ; do make $jobs -C $tgt; done	}
	package(){
		for tgt in ${uses[@]} ; do make $jobs -C $tgt install DESTDIR=$DESTDIR; done
		mkdir -p $DESTDIR/etc/default $DESTDIR/usr/bin/
		install $PACKAGEDIR/files/grub $DESTDIR/etc/default/grub
		install -vDm 755  $PACKAGEDIR/files/update-grub $DESTDIR/usr/bin/update-grub
		${DESTDIR}/sbin/ldconfig -r ${DESTDIR}           # sistem guncelleniyor
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/grub/files.tar>`_

tar dosyasını indirdikten sonra istediğiniz bir konumda **grub** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. Oluşturuluna dizinde yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	sudo ./build
  
.. raw:: pdf

   PageBreak



