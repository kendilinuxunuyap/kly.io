kly ile İso Yapma
+++++++++++++++++

Dağıtımlarda, dağıtıma ait paket sistemini kullanarak iso hazırlanabilir. Bu dokümanda paket sistemi(kly) önceki bölümde anlatılmıştı. **kly** paket sistemini kullanarak bir iso nasıl oluşturulur aşağıda verilmiştir. Burada anlatılan iso yapma scripti **Debian** vb. dağıtımlarda da benzer bir yapıdadır. Başka dağıtımlarda iso hazırlayan(deneyimi olan) geliştiriciler iso yapma aşamalırını benzer yapıda olduğunu göreceklerdir.

iso Scripti
-----------

.. code-block:: shell
	
	#!/bin/bash
	#set -x
	rootfs="/tmp/distro/rootfs"
	distro="/tmp/distro"
	#rm -rf distro/iso
	rm -rf $rootfs
	mkdir -p $rootfs
	mkdir -p $rootfs/bin $rootfs/etc


	##Kurulum scripti
	cp -prf files/bin/* $rootfs/bin/
	cp -prf files/etc/* $rootfs/etc/

	# temel dizinler ve dosyalar oluşturuluyor
	cd $rootfs/
	mkdir  -p bin dev etc home lib64 proc root run sbin sys usr var etc/kly tmp tmp/kly/kur \
	var/log  var/tmp usr/lib64/x86_64-linux-gnu usr/lib64/pkgconfig \
	usr/local/{bin,etc,games,include,lib,sbin,share,src}
	ln -s lib64 lib
	cd var&&ln -s ../run run&&cd -
	cd usr&&ln -s lib64 lib&&cd -
	cd usr/lib64/x86_64-linux-gnu&&ln -s ../pkgconfig  pkgconfig&&cd -

	bash -c "echo -e \"/bin/sh \n/bin/bash \n/bin/rbash \n/bin/dash\" >> $rootfs/etc/shell"
	bash -c "echo 'tmpfs /tmp tmpfs rw,nodev,nosuid 0 0' >> $rootfs/etc/fstab"
	bash -c "echo '127.0.0.1 kly' >> $rootfs/etc/hosts"
	bash -c "echo 'kly' > $rootfs/etc/hostname"
	bash -c "echo 'nameserver 8.8.8.8' > $rootfs/etc/resolv.conf"

	# paket adresi ekleniyor
	echo "kendilinuxunuyap/kly-binary-packages">$rootfs/etc/kly/sources.list

	### installing kly package in rootfs

	echo root:x:0:0:root:/root:/bin/sh > $rootfs/etc/passwd 
	chmod 755 $rootfs/etc/passwd

	### system chroot  bind/mount
	for dir in dev dev/pts proc sys; do mount -o bind /$dir $rootfs/$dir; done
	## paket listesi güncelleniyor
	$rootfs/bin/kly -u $rootfs

	## paketler kuruluyor
	for paket in glibc readline ncurses \bash openssl acl attr libcap libpcre2 gmp coreutils util-linux \grep \sed mpfr \gawk findutils libgcc libcap-ng \
	sqlite \gzip xz-utils zstd \bzip2 \elfutils libselinux \tar \zlib brotli curl shadow \file eudev cpio libsepol \
	kmod audit libxcrypt libnsl pam libtirpc e2fsprogs dosfstools  initramfs-tools libxml2 expat libmd libaio lvm2 popt icu iproute2 net-tools  dhcp \
	openrc  rsync kbd busybox kernel kernel-headers live-boot live-config parted  nano grub dialog efibootmgr efivar libssh openssh
	do
	chroot $rootfs /bin/kly -ri $paket; 
	#$rootfs/bin/kly -ri  $paket $rootfs
	done

	#### system chroot umount
	for dir in dev dev/pts proc sys ; do    while umount -lf -R $rootfs/$dir 2>/dev/null ; do true; done done
	exit

	chroot $rootfs useradd live -m -s /bin/sh  -d /home/live
	chroot $rootfs echo -e "live\nlive\n"|chroot $rootfs passwd live

	for grp in users tty wheel cdrom audio dip video plugdev netdev; do
		chroot $rootfs usermod -aG $grp live || true
	done

	sed -i "/agetty_options/d" $rootfs/etc/conf.d/agetty
	echo -e "\nagetty_options=\"-l /usr/bin/login\"" >> $rootfs/etc/conf.d/agetty


	### update-initrd
	fname=$(basename $rootfs/boot/config*)
	kversion=${fname:7}
	mv $rootfs/boot/config* $rootfs/boot/config-$kversion
	cp $rootfs/boot/config-$kversion $rootfs/etc/kernel-config

	chroot $rootfs update-initramfs -u -k $kversion

	#### system chroot umount
	for dir in dev dev/pts proc sys ; do    while umount -lf -R $rootfs/$dir 2>/dev/null ; do true; done done

	#************************									iso 										*********************************
	mkdir -p $distro/iso
	mkdir -p $distro/iso/boot
	mkdir -p $distro/iso/boot/grub
	mkdir -p $distro/iso/live || true

	#### Copy kernel and initramfs
	cp -pf $rootfs/boot/initrd.img-* $distro/iso/boot/initrd.img
	cp -pf $rootfs/boot/vmlinuz-* $distro/iso/boot/vmlinuz
	rm -rf $rootfs/boot

	#### Create squashfs
	mksquashfs $rootfs $distro/filesystem.squashfs -comp xz -wildcards
	mv $distro/filesystem.squashfs $distro/iso/live/filesystem.squashfs

	#### Write grub.cfg
	# Timeout for menu
	echo -e "set timeout=3\n"> $distro/iso/boot/grub/grub.cfg

	# Default boot entry
	echo -e "set default=1\n">> $distro/iso/boot/grub/grub.cfg

	# Menu Colours
	echo -e "set menu_color_normal=white/black\n">> $distro/iso/boot/grub/grub.cfg
	echo -e "set menu_color_highlight=white\/blue\n">> $distro/iso/boot/grub/grub.cfg
	echo -e "insmod all_video">> $distro/iso/boot/grub/grub.cfg
	echo -e "terminal_output console">> $distro/iso/boot/grub/grub.cfg
	echo -e "terminal_input console">> $distro/iso/boot/grub/grub.cfg

	echo 'menuentry "Canli(live) GNU/Linux 64-bit" --class liveiso  {' >> $distro/iso/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz boot=live init=/sbin/openrc-init net.ifnames=0 biosdevname=0' >> $distro/iso/boot/grub/grub.cfg
	echo '    initrd /boot/initrd.img' >> $distro/iso/boot/grub/grub.cfg
	echo '}' >> $distro/iso/boot/grub/grub.cfg

	echo 'menuentry "Kur GNU/Linux 64-bit" --class liveiso  {' >> $distro/iso/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz boot=live init=/bin/kur quiet' >> $distro/iso/boot/grub/grub.cfg
	echo '    initrd /boot/initrd.img' >> $distro/iso/boot/grub/grub.cfg
	echo '}' >> $distro/iso/boot/grub/grub.cfg

	grub-mkrescue $distro/iso/ -o $distro/distro.iso

.. raw:: pdf

   PageBreak

