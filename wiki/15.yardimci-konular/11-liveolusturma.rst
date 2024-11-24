Live Sistem Oluşturma
+++++++++++++++++++++

Canlı sistem oluşturma veya ram üzerinden çalışan sistem hazırlamak için SquashFS dosya sisteminde dağıtım sıkıştırılmalıdır. 
SquashFS, Linux işletim sistemlerinde sıkıştırılmış bir dosya sistemidir. Sistemimizi sıkıştırır ve ardından salt okunur bir dosya sistemine dönüştürür.

SquashFS Oluşturma
------------------

.. code-block:: shell

	# mksquashfs input_source output/filesystem.squashfs -comp xz -wildcards 
	mksquashfs rootfs $HOME/distro/filesystem.squashfs -comp xz -wildcards


Cdrom Erişimi
-------------

Cd veya Dvd aygıtı linux sistemlerinde /dev/sr0 aygıt dosyası olarak erişilir. Cd içeriği üzerinde okuma yazmak için aşağıdaki komutu kullanabiliriz.

.. code-block:: shell

	cat /dev/sr0

Cdrom Bağlama
-------------

.. code-block:: shell

	mkdir cdrom
	mount /dev/sr0 /cdrom

Bu işlem sonucunda cdrom bağlanmış olacaktır. iso dosyamızın içerisine erişebiliriz.

squashfs Dosyasını Bulma
-------------------------

Genellikle isoların içine squashfs dosyası oluşturlur. Bu sayede live yükleme yapılabilir. 
Örneğin /live/filesystem.squashfs imaj dosyalarında konumudur.

squashfs Bağlama
----------------

squashfs dosyasını bağlamadan önce loop modülünün yüklü olması gerekmektedir. Eğer yüklemediyseniz;

.. code-block:: shell

	# loop modülü yüklenir.
	modprobe loop 
	mkdir canli
	mount -t squashfs -o loop cdrom/live/filesystem.squashfs /canli

squashfs Sistemine Geçiş
------------------------

Yukarıdaki adımlarda squashfs doayamızı /canli adında dizine bağlamış olduk. Bu aşamadan sonra sistemimizin bir kopyası olan squashfs canlıdan erişebilir veya sistemi buradan başlatabiliriz.

squashfs dosya sistemimize bağlanmak için;

.. code-block:: shell

	chroot canli /bin/bash

Bu işlemin yerine exec komutuyla bağlanırsak sistemimiz id "1" değeriyle çalıştıracaktır. 
Eğer sistemin bu dosya sistemiyle açılmasını istiyorsak exec ile çalıştırıp id=1 olmasına dikkat etmeliyiz.

.. raw:: pdf

   PageBreak
