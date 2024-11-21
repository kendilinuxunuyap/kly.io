Tek Bölüm Kurulum
++++++++++++++++++

Diskler üzerinde işlem yapabilmek için evdev veya udevd servisi çalışıyor olmalı.
Ayrıca aşağıdaki modüllerin yüklü olduğundan emin olun.
Anlatım boyunca **/dev/sda** diski üzerinden örnekleme yapılmıştır. Siz kendi diskinize göre düzenleyebilirsiniz.
Disk ve isoya erişim için aşağıdaki modüllerin yüklü olduğundan emin olun.

- loop
- squashfs
- ext4 modulleri **modprobe** komutuyla yüklenmeli.

Disk Hazırlanmalı(legacy)
-------------------------
Öncelikle **cfdisk** veya **fdisk** komutları ile diski bölümlendirelim. Ben bu anlatımda **cfdisk** kullanacağım.


0. cfdisk komutuyla disk bölümlendirilmeli.

.. code-block:: shell
		
	$ cfdisk /dev/sda
	
1. dos seçilmeli
2. type linux system
3. write
4. quit
5. Bu işlem sonucunda sadece sda1 olur
6. mkfs.ext2 ile disk biçimlendirilir.

.. code-block:: shell

	$ mkfs.ext2 /dev/sda1


Dosya sistemini kopyalama
-------------------------

Kurulum medyası **/cdrom** dizinine bağlanır.
Kurulacak sistemin imajını bir dizine bağlayalım.

.. code-block:: shell
		
	$ mkdir -p cdrom
	$ mkdir -p kaynak
	$ mount -t iso9660 -o loop /dev/sr0 /cdrom/
	$ mount -t squashfs -o loop /cdrom/live/filesystem.squashfs /kaynak

Şimdi de disk bölümümüzü bağlayalım.

.. code-block:: shell

	$ mkdir -p hedef
	$ mount /dev/sda1 /hedef
	$ mkdir -p /hedef/boot

Ardından dosyaları kopyalayalım.

.. code-block:: shell

	# -prfv alt zinlerle beraber dosyanın özniteliklerini koruyarak kopyalar
	cp -prfv /kaynak/* /hedef
	# diske yazılan bilgiler senkronize edildi.
	sync 

Bootloader kurulumu
--------------------

grub kurulumu yapmak için grub paketinini kurulu olduğundan emin olun.

.. code-block:: shell

	$ mkdir -p /hedef/dev
	$ mkdir -p /hedef/sys
	$ mkdir -p /hedef/proc 
	$ mkdir -p /hedef/run
	$ mkdir -p /hedef/tmp
	$ mount --bind /dev /hedef/dev
	$ mount --bind /sys /hedef/sys
	$ mount --bind /proc /hedef/proc
	$ mount --bind /run /hedef/run
	$ mount --bind /tmp /hedef/tmp
	
	# Bunun yerine aşağıdaki gibi de girilebilir.
	for dir in /dev /sys /proc /run /tmp ; do
		mount --bind /$dir /hedef/$dir
	done
	$ chroot /hedef


Grub Kurulumu
--------------

.. code-block:: shell

	$ grub-install --boot-directory=/boot  /dev/sda


grub.cfg Yapılandırılması
-------------------------

1. /boot bölümünde initrd.img-**kernel-version** dosyamızın olduğundan emin olalım.
2. /boot bölümünde vmlinuz-**kernel-version** kernel dosyamızın olduğundan emin olalım.
3. /boot/grub/grub.cfg konumunda dostamızı oluşturalım(vi, touch veya nano ile).
4. dev/sda1 diskimizim uuid değerimizi bulalım.


.. code-block:: shell

	blkid | grep /dev/sda2
	/dev/sda2: UUID="?????" BLOCK_SIZE="xxxxx" TYPE="xxxxx" PARTUUID="xxxxx"
	# kernel versiyonu
	uname -r
	6.1.0-25-amd64

Diskimizimin uuid değerine göre /boot/grub/grub.cfg dosyasını aşağıdaki gibi düzenleyip kaydedelim.
Burada uuid değerini ve kernel versiyonunu düzenleyelim.

.. code-block:: shell

	linux /boot/vmlinuz-kernel-version	root=UUID= ????? rw quiet
	initrd /boot/initrd.img-kernel-version
	boot

grub.cfg dosyasını elle düzenlemek yerine aşğıdaki komutla otomatik yapılandırılabilir.

.. code-block:: shell
	
	$ grub-mkconfig -o /boot/grub/grub.cfg



.. raw:: pdf

   PageBreak
