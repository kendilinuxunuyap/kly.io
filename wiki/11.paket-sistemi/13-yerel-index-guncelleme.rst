
index Güncelleme
++++++++++++++++

İndex güncelleme uzak(internet) depodaki paketlerin index listesinin yerelde tutulan index dosyasıyla eşitlemek işlemidir.
Depoda olan paketlerin listesi yerelde tutulan index.lst dosyasındada olması gerekmetedir. Bu işlemi yapan klyupdate dosya içeriği aşağıdadır.

**klyupdate** 
-------------

Debian sisteminde /etc/apt/source.list gibi bir yapı bulunmaktadır. Bu dosya içindeki depo adreslerine göre index oluşturmaktadır. Hazırladığımız paket sitemindede /etc/kly/source.list dosyası kullanılmaktadır. Birden fazla index dosyasını birleştiren ve güncelleyen scriptimiz aşağıdadır.
 
.. code-block:: shell
	
	#!/bin/sh
	target="$1"
	mkdir -p $target/etc/kly -p $target/tmp
	rm -rf $target/etc/kly/index.lst
	rm -rf $target/tmp/temp.lst
	curl -Lo $target/etc/kly/index.lst \
	https://github.com/kendilinuxunuyap/kly-binary-packages/releases/download/current/index.lst
		 
**klyupdate** Kullanma
----------------------

Script bir parametre almaktadır. Parametremiz --update veya -u olmalıdır. Bu scripti kullanarak /etc/kly/index.lst dosyasını github depomuzdaki paket listesiyle güncelleyecektir. 

.. code-block:: shell
	
	./klyupdate /home/user1/testiso
	# /home/user1/testiso konumu hazırladığımız dağıtım konumudur.
	# kendi siteminize uygun konum belirleyiniz. 


.. raw:: pdf

   PageBreak


