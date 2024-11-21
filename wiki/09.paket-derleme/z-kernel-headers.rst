kernel-headers
++++++++++++++

Kernel-headers paketi, Linux çekirdeği başlık dosyalarını barındırır. Kernel-headers paketi derleme yaparsanız lazım olacaktır.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="kernel-headers"
	version="6.9.9"
	description="Linux kernel"
	source="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$version.tar.xz"
	depends="kernel"
	builddepend="rsync,bc,cpio,gettext,elfutils,pahole,perl,python,tar,xz-utils"
	group="sys.kernel"
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
		cp -prvf $PACKAGEDIR/files/ $SOURCEDIR/
		patch -Np1 -i $PACKAGEDIR/files/patch-$version
		cp $PACKAGEDIR/files/config $SOURCEDIR/.config
		make olddefconfig
	}
	build(){
		make bzImage -j$(nproc)
		make modules -j$(nproc)
	}
	package(){
		arch="x86"
		kernelbuilddir="${DESTDIR}/lib/modules/${version}/build"
		# install bzImage
		mkdir -p "$DESTDIR/boot"
		install -Dm644 "$(make -s image_name)" "$DESTDIR/boot/vmlinuz-${version}"
		#make INSTALL_PATH=$DESTDIR install ARCH=amd64
		# install modules
		mkdir -p ${DESTDIR}/lib/modules/${version}
		mkdir -p $DESTDIR/usr/src
		mkdir -p ${DESTDIR}/lib/modules/${version}/build
		make INSTALL_MOD_PATH=$DESTDIR modules_install INSTALL_MOD_STRIP=1 -j$(nproc)
		rm "${DESTDIR}/lib/modules/${version}"/{source,build} || true
		depmod --all --verbose --basedir="$DESTDIR" "${version}" || true
		# install build directories
		install .config "$DESTDIR/boot/config-${version}"
		install -Dt "$kernelbuilddir/kernel" -m644 kernel/Makefile
		install -Dt "$kernelbuilddir/arch/$arch" -m644 arch/$arch/Makefile
		cp -t "$kernelbuilddir" -a scripts
		install -Dt "$kernelbuilddir/tools/objtool" tools/objtool/objtool
		mkdir -p "$kernelbuilddir"/{fs/xfs,mm}
		ln -s "../../lib/modules/${version}/build" "$DESTDIR/usr/src/linux-headers-${version}"
		install -Dt "$kernelbuilddir" -m644 Makefile Module.symvers System.map vmlinux
		# install libc headers
		mkdir -p "$DESTDIR/usr/include/linux"
		cp -v -t "$DESTDIR/usr/include/" -a include/linux/
		cp -v -t "$DESTDIR/usr/" -a tools/include	
		make headers_install INSTALL_HDR_PATH=$DESTDIR/usr
		mkdir -p "$kernelbuilddir" "$kernelbuilddir/arch/$arch"
		cp -v -t "$kernelbuilddir" -a include
	   	cp -v -t "$kernelbuilddir/arch/$arch" -a arch/$arch/include
		install -Dt "$kernelbuilddir/arch/$arch/kernel" -m644 arch/$arch/kernel/asm-offsets.*
		install -Dt "$kernelbuilddir/drivers/md" -m644 drivers/md/*.h
		install -Dt "$kernelbuilddir/net/mac80211" -m644 net/mac80211/*.h
		install -Dt "$kernelbuilddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h
		install -Dt "$kernelbuilddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
		install -Dt "$kernelbuilddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
		install -Dt "$kernelbuilddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h
		install -Dt "$kernelbuilddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h 		# https://bugs.archlinux.org/task/71392
		find . -name 'Kconfig*' -exec install -Dm644 {} "$kernelbuilddir/{}" \;
		find -L "$kernelbuilddir" -type l -printf 'Removing %P\n' -delete					# clearing
		find "$kernelbuilddir" -type f -name '*.o' -printf 'Removing %P\n' -delete
		#-------------------------------------- 					install 										------------------------------------
		if [[ -d "$kernelbuilddir" ]] ; then
	    while read -rd '' file; do
		case "$(file -Sib "$file")" in
		    application/x-sharedlib\;*)      # Libraries (.so)
		        strip "$file" ;;
		    application/x-executable\;*)     # Binaries
		        strip "$file" ;;
		    application/x-pie-executable\;*) # Relocatable binaries
		        strip "$file" ;;
		esac
	    done < <(find "$kernelbuilddir" -type f -perm -u+x ! -name vmlinux -print0)
		fi
		if [[ -f "$kernelbuilddir/vmlinux" ]] ; then
	    strip "$kernelbuilddir/vmlinux"
		fi
		mkdir -p "$DESTDIR/usr/src"
		ln -sr "$kernelbuilddir" "$DESTDIR/usr/src/linux"
	    mv -vf System.map $DESTDIR/boot/System.map-$version
	    find ${DESTDIR}/ -iname "*" -exec unxz {} \;
	    depmod -b "$DESTDIR" -F $DESTDIR/boot/System.map-$version $version
	}
	initsetup       # initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir
	setup           # setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların ayalanması sağlanır.
	build           # build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	package         # package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır ve yüklenir.

Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/kernel-headers/files.tar>`_ tar dosyasını indirdikten sonra istediğiniz bir konumda **kernel-headers** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build&&sudo ./build
  
.. raw:: pdf

   PageBreak



