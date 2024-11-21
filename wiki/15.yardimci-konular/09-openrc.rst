OpenRC
++++++

Openrc sistem açılışında çalışacak uygulamaları çalıştıran servis yöneticisidir.

**Çalıştırılması**
------------------

Openrc servis yönetiminin çalışması için boot parametrelerine yazılması gerekmektedir. 
**/boot/grub.cfg** içindeki **linux /vmlinuz init=/usr/sbin/openrc-init root=/dev/sdax** olan satırda **init=/usr/sbin/openrc-init** yazılması gerekmektedir. Artık sistem openrc servis yöneticisi tarafından uygulamalar çalıştırılacak ve sistem hazır hale getirilecek.

**openrc Kullanımı**
--------------------

Servis etkinleştirip devre dışı hale getirmek için **rc-update** komutu kullanılır. Aşağıda **udhcpc** internet servisi örnek olarak gösterilmiştir. **/etc/init.d/** konumunda **udhcpc** dosyamızın olması gerekmektedir.

.. code-block:: shell

	# servis etkinleştirmek için
	rc-update add udhcpc boot
	# servisi devre dışı yapmak için
	rc-update del udhcpc boot
	# Burada udhcpc servis adı boot ise runlevel adıdır.

Elle **/etc/runlevels/** altında bulunan **boot**, **default**,  **nonetwork**, **shutdown**, **sysinit** dizinlerine **/etc/init.d/** dizininin altındaki dosyaları **ln** komutuyla kısayol yaparsak **rc-update add** komutunun yaptığı görevi yapmış oluruz. Kısayolu silersek **rc-update del** komutunun görevini yapmış oluruz.

**/etc/runlevels/** altında bulunan **boot**, **default**,  **nonetwork**, **shutdown**, **sysinit** dizinler servis dosyalarımızın hangi sırayla çalışacağını belirleyen dizinlerdir. Mesela **boot** dizini ilk açılış sırasında çalışcak olan servis dosyalarının konulacağı dizindir.

Servisleri başlatıp durdurmak için ise **rc-service** komutu kullanılır.

.. code-block:: shell

	rc-service udhcpc start
	# veya şu şekilde de çalıştırılabilir.
	/etc/init.d/udhcpc start

Servislerin durmunu öğrenmek için **rc-status** komutu kullanılır. Ayrıca
sistemdeki servislerin sonraki açılışta hangisinin başlatılacağını öğrenmek için
ise parametresiz olarak **rc-update** kullanabilirsiniz.

.. code-block:: shell

	# şu an hangi servislerin çalıştığını gösterir
	rc-status
	# sonraki açılışta hangi servislerin çalışacağını gösterir
	rc-update

Sistemi kapatmak veya yeniden başlatmak için **openrc-shutdown** komutunu kullanabilirsiniz.

.. code-block:: shell

	# kapatmak için
	openrc-shutdown -p 0
	# yeniden başlatmak için
	openrc-shutdown -r 0

.. raw:: pdf

   PageBreak

**Servis Dosyası**
------------------

Openrc servis dosyaları basit birer **bash** betiğidir. Bu betikler **openrc-run** komutu ile çalıştırılır ve çeşitli fonksiyonlardan oluşabilir. Servis dosyaları **/etc/init.d** içerisinde bulunur. Servisleri ayarlamak için ise **/etc/conf.d** içerisine aynı isimle ayar dosyası oluşturabiliriz.

Çalıştırılacak komut komut parametreleri ve **pidfile** dosyamızı aşağıdaki gibi belirtebiliriz.

.. code-block:: shell

	description="Ornek servis"
	command=/usr/bin/ornek-servis
	command_args=--parametre
	pidfile=/run/ornek-servis.pid

Bununla birlikte **start**, **stop**, **status**, **reload**, **start_pre**, **stop_pre** gibi fonksiyonlar da yazabiliriz.

.. code-block:: shell

	...
	start(){
	    ebegin "Starting ${RC_SVCNAME}"
	    start-stop-daemon --start --pidfile "/run/servis.pid" --exec /usr/bin/ornek-servis --parametre
	}
	...

Servis bağımlılıklarını belirtmek için ise **depend** fonksiyonu kullanılır.

.. code-block:: shell

	...
	depend() {
	  need localmount
	  after dbus
	}
	...

OpenRc Disk İşlemi
------------------

Kullandığımız servis yöneticisi openrc ise **/etc/fstab** komunundaki dosyaya bakarak diske erişim sağlamaktadır. Bundan dolayı **fstab** dosyamızı aşağıdaki gibi yapılandırmalıyız.

Fstab dosyası
-------------

Bu dosyayı doldurarak açılışta hangi disklerin bağlanacağını ayarlamalıyız. /etc/fstab dosyasını aşağıdakine uygun olarak doldurun.


.. code-block:: shell

	# <fs>                  <mountpoint>    <type>          <opts>          <dump/pass>
	/dev/sda1       /boot   vfat    defaults,rw     0       1
	/dev/sda2       /       ext4    defaults,rw     0       1



.. raw:: pdf

   PageBreak


