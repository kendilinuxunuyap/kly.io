openrc
++++++

OpenRC, sistem başlangıcını ve hizmetlerin yönetimini sağlamak amacıyla geliştirilmiş bir init sistemidir. 

Derleme
-------

.. code-block:: shell
	
	#!/usr/bin/env bash
	name="openrc"
	version="0.53"
	description="The OpenRC init system"
	source="https://github.com/OpenRC/openrc/archive/refs/tags/$version.zip"
	depends=""
	group="sys.apps,pam"
		
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
	cp -prfv $PACKAGEDIR/files $SOURCEDIR/
	cp -prfv $PACKAGEDIR/extras $SOURCEDIR/
	meson setup $BUILDDIR --sysconfdir=/etc --prefix=/ --libdir=/lib64 --includedir=/usr/include \
	-Ddefault_library=both -Dzsh-completions=true -Dbash-completions=true -Dpam=true -Dselinux=disabled -Dpkgconfig=true
	
	# build
	meson compile -C $BUILDDIR
	    
	# package
	export DESTDIR=${DESTDIR}//
	DESTDIR="$DESTDIR" meson install --no-rebuild -C $BUILDDIR
	rm -f ${DESTDIR}/etc/runlevels/*/*	    # disable all services
	rm ${DESTDIR}//etc/init.d/functions.sh
	ln -s ../../lib/rc/sh/functions.sh ${DESTDIR}/etc/init.d/functions.sh
	mkdir -p ${DESTDIR}/etc/sysconf.d/	    # install sysconf script
	install $SOURCEDIR/files/openrc.sysconf ${DESTDIR}/etc/sysconf.d/openrc
	mkdir -p ${DESTDIR}/usr ${DESTDIR}/sbin
	mv ${DESTDIR}/{,usr}/share	    # move /share to /usr/share

	install $SOURCEDIR/files/reboot ${DESTDIR}/sbin/reboot	    # reboot and poweroff script
	install $SOURCEDIR/files/poweroff ${DESTDIR}/sbin/poweroff
	ln -s openrc-shutdown ${DESTDIR}/sbin/shutdown
	mkdir -p ${DESTDIR}/usr/libexec
	install $SOURCEDIR/extras/disable-secondary-gpu.sh ${DESTDIR}/usr/libexec/disable-secondary-gpu
	install $SOURCEDIR/extras/disable-secondary-gpu.initd ${DESTDIR}/etc/init.d
	install $SOURCEDIR/extras/backlight-restore.initd ${DESTDIR}/etc/init.d
	install $SOURCEDIR/files/0modules.init.d ${DESTDIR}/etc/init.d/0modules
			
	for level in boot default nonetwork shutdown sysinit ; do
	mkdir -p ${DESTDIR}/etc/runlevels/$level
	done
	touch ${DESTDIR}/etc/fstab
	install $SOURCEDIR/files/0modules.init.d ${DESTDIR}/etc/init.d/0modules
	install $SOURCEDIR/files/0modules.init.d ${DESTDIR}/etc/runlevels/default/0modules
	    
	install ${DESTDIR}/etc/init.d/hostname ${DESTDIR}/etc/runlevels/default/hostname
	cd ${DESTDIR}/etc/init.d/
	ln -s agetty agetty.tty1
	install ${DESTDIR}/etc/init.d/agetty.tty1 ${DESTDIR}/etc/runlevels/default/agetty.tty1

.. raw:: pdf

   PageBreak
   
Yukarıdaki kodların sorunsuz çalışabilmesi için ek dosyayalara ihtiyaç vardır. Bu ek dosyaları indirmek için `tıklayınız. <https://kendilinuxunuyap.github.io/_static/files/openrc/files.tar>`_

Bu extras dosyalarını indirmek için `tıklayınız.. <https://kendilinuxunuyap.github.io/_static/files/openrc/extras.tar>`_

tar dosyalarını indirdikten sonra istediğiniz bir konumda **openrc** adında bir dizin oluşturun ve tar dosyasını oluşturulan dizin içinde açınınız.

Paket adında(openrc) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build

Çalıştırılması
--------------

Openrc servis yönetiminin çalışması için boot parametrelerine yazılması gerekmektedir. 
**/boot/grub.cfg** içindeki **linux /vmlinuz init=/usr/sbin/openrc-init root=/dev/sdax** olan satırda **init=/usr/sbin/openrc-init** yazılması gerekmektedir. Artık sistem openrc servis yöneticisi tarafından uygulamalar çalıştırılacak ve sistem hazır hale getirilecek.

Basit kullanım
--------------

Servis etkinleştirip devre dışı hale getirmek için **rc-update** komutu kullanılır. Aşağıda **udhcpc** internet servisi örnek olarak gösterilmiştir. **/etc/init.d/** konumunda **udhcpc** dosyamızın olması gerekmektedir.

.. code-block:: shell

	# servis etkinleştirmek için
	$ rc-update add udhcpc boot
	# servisi devre dışı yapmak için
	$ rc-update del udhcpc boot
	# Burada udhcpc servis adı boot ise runlevel adıdır.
	
 
.. raw:: pdf

   PageBreak



