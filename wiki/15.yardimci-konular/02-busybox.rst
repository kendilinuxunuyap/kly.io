busybox Nedir?
++++++++++++++

Busybox tek bir dosya halinde bulunan birçok araç seçine sahip olan bir programdır. Bu araçlar initramfs sisteminde ve sistem genelinde sıkça kullanılabilir. Busybox aşağıdaki gibi kullanılır.

.. code-block:: shell

	busybox [komut] (seçenekler)

Eğer busyboxu komut adı ile linklersek o komutu doğrudan çalıştırabiliriz. Aşağıda tar uygulamasını busybox dan türettik.

.. code-block:: shell

	ln -s /bin/busybox ./tar
	./tar

Busyboxtaki tüm araçları sisteme sembolik bağ atmak için aşağıdaki gibi bir yol izlenebilir. Bu işlem var olan dosyaları sildiği için tehlikeli olabilir. Sistemin tasarımına uygun olarak yapılmalıdır.

.. code-block:: shell

	# -s parametresi sembolik bağ olarak kurmaya yarar.
	busybox --install -s /bin 
	
Busybox Derleme
---------------

Busybox **static** olarak derlenmediği sürece bir libc kütüphanesine ihtiyaç duyar. initramfs içerisinde kullanılacaksa içerisine libc dahil edilmelidir. Bir dosyanın static olarak derlenip derlenmediğini öğrenmek için aşağıdaki komut kullanılır. Derleme türleri ve detayları için bu dokümandaki derleme konusuna bakınız.

.. code-block:: shell

	# static derlenmişse hata mesajı verir. Derlenmemişse bağımlılıklarını listeler.
	ldd /bin/busybox 

Busybox derlemek için öncelikle **make defconfig** kullanılarak veya önceden oluşturduğumuz yapılandırma dosyasını atarak yapılandırma işlemi yapılır. Ardından eğer static derleme yapacaksak yapılandırma dosyasına müdahale edilir. Son olarak **make** komutu kullanarak derleme işlemi yapılır.

.. code-block:: shell

	make defconfig
	sed -i "s|.*CONFIG_STATIC_LIBGCC .*|CONFIG_STATIC_LIBGCC=y|" .config
	sed -i "s|.*CONFIG_STATIC .*|CONFIG_STATIC=y|" .config
	make

Derleme bittiğinde kaynak kodun bulunduğu dizinde busybox dosyamız oluşmuş olur.

Static olarak derlemiş olduğumuz busyboxu kullanarak minimal bir dağıtım hazırlayabiliriz.

.. raw:: pdf

   PageBreak
