İso Hazırlama
+++++++++++++

Önceki bölümlerde paketler derlendi. Bu paketler oturum açtığınız kullanıcı ev dizinde **$HOME/distro/rootfs** konumunda olacaktır. Burada **$HOME** açık olan kullanıcı neyse onun konumunu verecektir. Örneğin kullanıcı adımız **bd** olsun. Bu durumda **$HOME** değeri **/home/bd/** olacaktır. Bu örneğimize göre **$HOME/distro/rootfs** ifadesi aslında **/home/bd/distro/rootfs** dir.

İso hazırlama işlemini yazımızın başında minimal iso yapma anlatılmıştı. Burada da benzer yol izlenecek. Sistemimin yani oluşacak **iso** dosyasının yapısı aşağıdaki gibi olacaktır. Buradaki dört dosyanında nasıl hazırlanacağı ayrı ayrı anlatılacak ve en son hepsini kapsayan iso yapma scriptimizi vereceğiz.

.. code-block:: shell
	
	$HOME/distro/iso/boot/grub/grub.cfg
	$HOME/distro/iso/boot/initrd.img
	$HOME/distro/iso/boot/vmlinuz
	$HOME/distro/iso/live/filesystem.squashfs
	
**grub.cfg Hazırlama**
----------------------

Sistemin açılmasını sağlayan dosyalardan birisi **grub.cfg** dosyasıdır. Genel olarak grub.cfg dosyası aşağıdaki gibi olmalıdır.

.. code-block:: shell

	linux /boot/vmlinuz
	initrd /boot/initrd.img
	boot

Bu sistem için grub.cfg dosyası aşağıdaki gibi düzenlendi. Burada dikkat edilmesi gereken menü seçeneklerinde **live** ifadesi kulllanılması. Ayrıca sistemimizin servis yönetici ile başlatılmasını istediğimiz için **linux /boot/vmlinuz boot=live init=/sbin/openrc-init net.ifnames=0 biosdevname=0** sistemi canlı açılmasını sağlıyor.

Kurulum için ise canlı(**live**) açıp kurulum yapmasını sağlayan satırımız **linux /boot/vmlinuz boot=live init=/bin/kur quiet** dır.


.. code-block:: shell

	#### Write grub.cfg
	# Timeout for menu
	echo -e "set timeout=3\n"> $HOME/distro/iso/boot/grub/grub.cfg

	# Default boot entry
	echo -e "set default=1\n">> $HOME/distro/iso/boot/grub/grub.cfg

	# Menu Colours
	echo -e "set menu_color_normal=white/black\n">>$HOME/distro/iso/boot/grub/grub.cfg
	echo -e "set menu_color_highlight=white\/blue\n">> $HOME/distro/iso/boot/grub/grub.cfg
	echo -e "insmod all_video">> $HOME/distro/iso/boot/grub/grub.cfg
	echo -e "terminal_output console">> $HOME/distro/iso/boot/grub/grub.cfg
	echo -e "terminal_input console">> $HOME/distro/iso/boot/grub/grub.cfg

	echo 'menuentry "Canli(live) GNU/Linux 64-bit" --class liveiso  {' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz boot=live init=/sbin/openrc-init net.ifnames=0 biosdevname=0' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '    initrd /boot/initrd.img' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '}' >> $HOME/distro/iso/boot/grub/grub.cfg

	echo 'menuentry "Kur GNU/Linux 64-bit" --class liveiso  {' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '    linux /boot/vmlinuz boot=live init=/bin/kur quiet' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '    initrd /boot/initrd.img' >> $HOME/distro/iso/boot/grub/grub.cfg
	echo '}' >> $HOME/distro/iso/boot/grub/grub.cfg


**initrd.img Oluşturma/Güncelleme**
-----------------------------------

Sistemin initrd.img dosyasının güncellenmesi/oluşturulması için çalıştığınız sistemde  aşağıdaki komutlarla yapılabilir. 

.. code-block:: shell

	 # initrd günceller
	/usr/sbin/update-initramfs -u -k $(uname -r)

Eğer bir dizin içinde bir sisteme initrd oluşturlacaksa, yani chroot ile sisteme erişiliyorsa yukarıdaki komut yeterli olmayacaktır. chroot öncesinde sistemin **dev sys proc run** dizinlerinin  bağlanılması gerekmektedir. Dizindeki sistemimizin dizin konumu **/$HOME/distro/rootfs** olsun. Buna göre aşağıda sisteme yukarıdaki komutu çalıştırmadan önce çalıştırılması gereken komutlar aşağıda verilmiştir. Dikkat edilmesi gereken en önemli noktalardan biriside bu komutlar **root** yetkisiyle çalıştırılmalıdır.

.. code-block:: shell

	## ------ 		initrd.img oluşturma scripti		 --------
	rootfs="$HOME/distro/rootfs"
	distro="$HOME/distro"
	## Dizinler Oluşturuluyor
	mkdir -p $rootfs/dev
	mkdir -p $rootfs/sys
	mkdir -p $rootfs/proc 
	mkdir -p $rootfs/run
	mkdir -p $rootfs/tmp
	## Dizinler bağlanıyor
	mount --bind /dev $rootfs/dev
	mount --bind /sys $rootfs/sys
	mount --bind /proc $rootfs/proc
	mount --bind /run$rootfs/run
	mount --bind /tmp $rootfs/tmp
	
	### initrd.img oluşturuluyor/güncelleniyor
	fname=$(basename $rootfs/boot/config*)
	kversion=${fname:7}
	mv $rootfs/boot/config* $rootfs/boot/config-$kversion
	cp $rootfs/boot/config-$kversion $rootfs/etc/kernel-config
	chroot $rootfs update-initramfs -u -k $kversion
	
	## Dizin bağlantıları kaldırılıyor
	umount -lf -R $rootfs/dev 2>/dev/null
	umount -lf -R $rootfs/sys 2>/dev/null
	umount -lf -R $rootfs/proc 2>/dev/null
	umount -lf -R $rootfs/run 2>/dev/null
	umount -lf -R $rootfs/tmp 2>/dev/null
	#### initrd kopyalanıyor
	cp -pf $rootfs/boot/initrd.img-* $distro/iso/boot/initrd.img	

**vmlinuz Hazırlanması**
------------------------

Kernelimizi iso dizinimize taşıyoruz.

.. code-block:: shell

	rootfs="$HOME/distro/rootfs"
	distro="$HOME/distro"
	#### Copy kernel
	cp -pf $rootfs/boot/vmlinuz-* $distro/iso/boot/vmlinuz
	#rm -rf $rootfs/boot #istenir boyut küçültmek için bu komut aktifleştirilebilir.

**filesystem.squashfs Hazırlama**
---------------------------------

Sistemi **live** kullanma ve yükleme yapabilmek için yapılan sistemi **squashfs** dosya sıkıştırma yöntemiyle sıkılştırıyoruz. Bu dosyayı **$HOME/distro/iso/live/filesystem.squashfs** konumunda olmalı. Aşağıdaki komutlar dosyayı oluşturup **$HOME/distro//iso/live/filesystem.squashfs** konumuna taşımaktadır.

.. code-block:: shell

	cd $HOME/distro/
	mksquashfs $HOME/distro/rootfs $HOME/distro/filesystem.squashfs -comp xz -wildcards
	mv $HOME/distro/filesystem.squashfs $HOME/distro/iso/live/filesystem.squashfs



**İso Dosyasının Oluşturulması**
--------------------------------

.. code-block:: shell
	
	cd $HOME/distro
	# iso doyamız oluşturulur.
	grub-mkrescue iso/ -o distro.iso 

**İsonun Test Edilmesi**
------------------------ 

isolarımız qemu veya virtualbox ile test edilebilir. Linux ortamında terminalden qemu kullanarak aşıdaki gibi test edebilirsiniz. Sistemde qemu paketinin kurulu olması gerekir.

.. code-block:: shell
	
	# qemu ile isonun test edilmesi. 
	qemu-system-x86_64 -cdrom $HOME/distro/distro.iso -m 1G


.. raw:: pdf

   PageBreak
   
iso Oluşturma Scripti
---------------------

Sisteme giriş yaptığımız kullanıcının ev dizinindeki **distro/rootfs** disininden **distro/iso** dizinini kullanarak **distro** dizinine **distro.iso** dosyasını oluşturan scriptimiz aşağıdadır.

.. code-block:: shell
	
	#!/bin/bash
	distro="$HOME/distro"
	rootfs="$HOME/distro/rootfs"
	rm -rf "$distro/iso"
	### system chroot  bind/mount
	for dir in dev dev/pts proc sys; do mount -o bind /$dir $rootfs/$dir; done
	
	chroot $rootfs echo -e "1\n1\n"|chroot $rootfs passwd root
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
		
	#************************iso *********************************
	mkdir -p $distro/iso
	mkdir -p $distro/iso/boot
	mkdir -p $distro/iso/boot/grub
	mkdir -p $distro/iso/live || true

	#### Copy initramfs
	cp -pf $rootfs/boot/initrd.img-* $distro/iso/boot/initrd.img

	#### Copy kernel
	cp -pf $rootfs/boot/vmlinuz-* $distro/iso/boot/vmlinuz
	#rm -rf $rootfs/boot

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

