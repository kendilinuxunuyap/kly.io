Paket Kurma
+++++++++++

Hazırlanan dağıtımda paketlerin kurulması için  sırasıyla aşağıdaki işlem adımları yapılmalıdır.

1. Paketin indirilmesi
2. İndirilen paketin /tmp/kly/kur/ konumunda açılması
3. Açılan paket dosyalarının / konumuna yüklenmesi(kopyalanması)

	- Paketin bağımlı olduğu paketler varmı kontrol edilir
	- Yüklü olmayan bağımlılıklar yüklenir
	
4. Yüklenen paket bilgileri(name, version ve bağımlılık) yüklü paketlerin index bilgilerini tutan paket sistemi dizininindeki index dosyasına eklenir.	
5. Açılan paket içindeki yüklenen dosyaların nereye yüklendiğini tutan file.index dosyası paket sistemi dizinine yüklenir


Bu işlemler daha detaylandırılabilir. Bu işlemlerin detaylı olması paket sisteminin kullanılabilirliğini ve yetenekleri olarak ifade edebiliriz. İşlem adımlarını kolaylıkla sıralarken bunları yapacak script yazmak ciddi planlamalar yapılarak tasarlanması gerekmektedir.


Örneğin bir paketimiz zip dosyası olsun ve içinde dosya listesini tutan **file.index** adında bir dosyamız olsun. Paketi aşağıdaki gibi kurabiliriz.

.. code-block:: shell

	cd /tmp/kur/
	unzip /dosya/yolu/paket.zip
	cp -rfp ./* /
	cp file.index /paket/veri/yolu/paket.index

- Bu örnekte ilk satırda geçici dizine gittik 
- Paketi oraya açtık.
- Paket içeriğini kök dizine kopyaladık.
- Paket dosya listesini verilerin tutulduğu yere kopyaladık.

Bu işlemden sonra paket kurulmuş oldu.


.. raw:: pdf

   PageBreak

**kly Paket Kurma Scripti Tasarlama**
-------------------------------------
Burada basit seviyede kurulum yapan script kullanılmıştır. Detaylandırıldıkça doküman güncellenecektir. Kurulum scripti aşağıda görülmektedir.

Paket kurulurken paket içerisinde bulunan dosyalar sisteme kopyalanır.
Daha sonra istenirse silinebilmesi için paket içeriğinde dosyaların listesi tutulur.
Bu dosya ayrıca paketin bütünlüğünü kontrol etmek için de kullanılır.


**klykur** Scripti
------------------

.. code-block:: shell
	
	#!/bin/sh
	name="name=\"${1}\""
	target=$2
	mkdir -p $target
	paket=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f2)
	version=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f4)
	depends=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f6)
	# index dosyamızda paket aranıyor
	if [ ! -n "${paket}" ]; then
	echo "***********Paket Bulunamadı**********"; exit
	fi

	# 1. adım paketi indirme
	mkdir -p $target/tmp/kly $target/tmp/kly/kur
	rm -rf $target/tmp/kly/kur/*
	curl -Lo $target/tmp/kly/kur/${paket}-${version}.tar.gz \
	https://github.com/kendilinuxunuyap/kly-binary-packages/raw/master/${paket}/${paket}-${version}.kly
	mkdir -p $target/var/lib/kly
	cd $target/tmp/kly/kur/

	# 2. adım paketi açma
	tar -xf ${paket}-${version}.tar.gz
	mkdir -p rootfs
	tar -xf rootfs.tar.xz -C rootfs

	# 3. adım paketi kurma
	cp -prfv rootfs/* $target/

	# 4. adım name version depends /var/lib/kly/index.lst eklenmesi
	echo "name=\"${paket}\":"version=\"${version}\":"depends=\"${depends}\"">>$target/var/lib/kly/index.lst
	# 5. adım paket içinde gelen paket dosyalarının dosya ve dizin yapısını tutan
	# file index dosyanının /var/lib/kly/ konumuna kopyalanması
	cp file.index $target/var/lib/kly/${paket}-${version}.lst
	
**klykur** Scriptini Kullanma
-----------------------------

Script iki parametre almaktadır. İlk parametre paket adı. İkinci parametremiz ise nereye kuracağını belirten hedef olmalıdır. Bu scripti kullanarak readline paketi aşağıdaki gibi kurulabilir. 

.. code-block:: shell
	
	./klykur readline /home/user1/testiso
	# /home/user1/testiso konumu hazırladığımız dağıtım konumudur.
	# kendi siteminize uygun konum belirleyiniz. 

.. raw:: pdf

   PageBreak

