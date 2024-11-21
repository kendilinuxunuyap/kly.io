Uefi Sistem Kurulumu
++++++++++++++++++++

Bu bölümde **Ext4** dosya sistemine grub kullanarak kurulum anlatılacaktır.
Anlatım boyunca **/dev/sda** diski kullanılarak anlatılacaktır. Sisteminizdeki diskinize göre düzenleyiniz.
Diskler üzerinde işlem yapabilmek için evdev veya udevd servisi çalışıyor olmalı.
Disk ve isoya erişim için aşağıdaki modüllerin yüklü olduğundan emin olun.


- loop
- squashfs
- ext4 modulleri **modprobe** komutuyla yüklenmeli.

Uefi - Legacy Tespiti
---------------------

**/sys/firmware/efi** dizini varsa uefi, yoksa legacy sisteme sahipsinizdir.
Eğer uefi ise ia32 veya x86_64 olup olmadığını anlamak için **/sys/firmware/efi/fw_platform_size** içeriğine bakın.

.. code-block:: shell

	[[ -d /sys/firmware/efi/ ]] && echo UEFI || echo Legacy
	[[ "64" == $(cat/sys/firmware/efi/fw_platform_size) ]] && echo x86_64 || ia32

Disk Hazırlanmalı
------------------

Uefi kullananlar ayrı bir disk bölümüne ihtiyaç duyarlar.
Bu bölümü **fat32** olarak bölümlendirmeliler.

Bu anlatımda kurulum için **/boot** dizinini ayırmayı ve efi bölümü olarak aynı diski kullanmayı tercih edeceğiz.
Öncelikle **cfdisk** veya **fdisk** komutları ile diski bölümlendirelim. Ben bu anlatımda **cfdisk** kullanacağım.

0. cfdisk komutuyla disk bölümlendirilmeli.

.. code-block:: shell
		
	$ cfdisk /dev/sda

1. gpt seçilmeli
2. 512 MB type uefi alan(sda1)
3. geri kalanı type linux system(sda2)
4. write
5. quit
6. Bu işlem sonucunda sadece sda1 sda2 olur
7. mkfs.vfat ve mkfs.ext4 ile diskler biçimlendirilir.

.. code-block:: shell

	$ mkfs.vfat /dev/sda1
	$ mkfs.ext4 /dev/sda2
		
e2fsprogs Paketi
----------------

e2fsprogs paket sistemde mkfs.ext4, e2fsck, tune2fs vb sistem araçlarının yüklenmesini sağlar. Eğer sistemde bu sistem uygulamaları yoksa bu paketin yüklenmesi veya derlenmesi gerekmektedir.

Eğer /boot bölümünü ayırmayacaksanız grub yüklenirken **unknown filesystem** hatası almanız durumunda aşağıdaki yöntemi kullanabilirsiniz.

.. code-block:: shell

	$ e2fsck -f /dev/sda2
	$ tune2fs -O ^metadata_csum /dev/sda2

Dosya Sistemini Kopyalama
--------------------------

Kurulum medyası **/cdrom** dizinine bağlanır.
Kurulacak sistemin imajını bir dizine bağlayalım.

.. code-block:: shell
		
	$ mkdir -p cdrom
	$ mkdir -p kaynak
	$ mount -t iso9660 -o loop /dev/sr0 /cdrom/
	$ mount -t squashfs -o loop /cdrom/live/filesystem.squashfs /kaynak

Şimdi de disk bölümümüzü bağlayalım.

.. code-block:: shell

	mkdir -p hedef || true
	mkdir -p /hedef/boot || true
	mkdir -p /hedef/boot/efi || true
	mount /dev/sda2 /hedef || true
	mount /dev/sda1 /hedef/boot/efi

Ardından dosyaları kopyalayalım.

.. code-block:: shell

	# -prfv alt zinlerle beraber dosyanın özniteliklerini koruyarak kopyalar
	cp -prfv /kaynak/* /hedef
	# diske yazılan bilgiler senkronize edildi.
	sync

grub Yapılandırılması
---------------------

grub kurulumu yapmak için grub paketinini kurulu olduğundan emin olun.

.. code-block:: shell

	mkdir -p /hedef/dev
	mkdir -p /hedef/sys
	mkdir -p /hedef/proc 
	mkdir -p /hedef/run
	mkdir -p /hedef/tmp
	mount --bind /dev /hedef/dev
	mount --bind /sys /hedef/sys
	mount --bind /proc /hedef/proc
	mount --bind /run /hedef/run
	mount --bind /tmp /hedef/tmp
	
	# efi alan bağlanıyor. 
	# Eğer uefi ise kernel tarafından /sys/firmware/efi dizin ve dosyaları oluşuyor. 
	# sistem uefi değilse /sys/firmware/efi dosya ve dizini olmayacaktır.
	 if [[ -d /sys/firmware/efi ]] ; then
    		mount --bind /sys/firmware/efi/efivars /hedef/sys/firmware/efi/efivars
	  fi
		
	# Bunun yerine aşağıdaki gibi de girilebilir.
	for dir in /dev /sys /proc /run /tmp ; do
		mount --bind /$dir /hedef/$dir
	done
	
	# chroot /hedef komutuyla hazırladığımız sisteme bağlanıyoruz.

Şimdi de uefi kullandığımız için efivar bağlayalım.

.. code-block:: shell

	mount -t efivarfs efivarfs /sys/firmware/efi/efivarfs
	
Grub Kurulumu
-------------

.. code-block:: shell

	# biz /boot ayırdığımız ve efi bölümü olarak kullanacağız.
	# uefi kullanmayanlar --efi-directory belirtmemeliler.
	# kurulu sistemden bağımsız çalışması için --removable kullanılır.
	grub-install --removable --boot-directory=/boot --efi-directory=/boot --target=x86_64-efi /dev/sda

grub.cfg Yapılandırması
-----------------------

1. /boot bölümünde initrd.img-**kernel-version** dosyamızın olduğundan emin olalım.
2. /boot bölümünde vmlinuz-**kernel-version**  kernel dosyamızın olduğundan emin olalım.
3. /boot/grub/grub.cfg konumunda dostamızı oluşturalım(vi, touch veya nano ile).
4. dev/sda2 diskimizim uuid değerimizi bulalım.

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

	grub-mkconfig -o /boot/grub/grub.cfg

.. raw:: pdf

   PageBreak

