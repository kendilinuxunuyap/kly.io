
Paket Kaldırma
++++++++++++++

Sistemde kurulu paketleri kaldırmak için işlem adımları şunlardır.

1. Paketin kullandığı bağımlılıkları başka paketler kullanıyor mu kontrol edilir. Eğer kullanılmıyorsa kaldırılır.
2. Paketin paket.LIST dosyası içerisindeki dosyalar, dizinler kaldırılır.
3. Kaldırılan dosyalardan sonra /paket/veri/yolu/paket.LIST dosyasından paket bilgisi kaldırılır.
4. Sistemde kurulu paketler index dosyasından ilgili paket satırı kaldırılmalıdır.
5. Pakete ait boş hale gelmiş dizinler kaldırılmalıdır.

Paketi kaldırmak için ise aşağıdaki örnek kullanılabilir.

.. code-block:: shell

	cat /paket/veri/yolu/paket.LIST | while read dosya ; do
	    if [[ -f "$dosya" ]] ; then
	        rm -f "$dosya"
	    fi
	done
	cat /paket/veri/yolu/paket.LIST | while read dizin ; do
	    if [[ -d "$dizin" ]] ; then
	        rmdir "$dizin" || true
	    fi
	done
	rm -f /paket/veri/yolu/paket.LIST

Bu örnekte paket listesini satır satır okuduk. Önce dosya olanları sildik.
Daha sonra tekrar okuyup boş kalan dizinleri sildik.
Paket listesi dosyamızı sildik.
Boş hale gelen dizinleri kaldırdık.
Bu işlem sonunda paket silinmiş oldu.


.. raw:: pdf

   PageBreak


**kly Paket Kaldırma Scripti Tasarlama**
----------------------------------------

Dokumanda örnek olarak verilen kly paket sistemi için yukarıdaki paket kaldırma bilgilerini kullanarak tasarlanmıştır.

**klykaldir** scripti
---------------------

.. code-block:: shell

	#!/bin/sh
	name="name=\"${1}\""
	target="$2"
	mkdir -p $target
	paket=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f2)
	version=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f4)
	depends=$(echo $(cat $target/etc/kly/index.lst|grep $name)|cut -d"\"" -f6)
	# index dosyamızda paket aranıyor
	if [ ! -n "${paket}" ]; then
	    echo "***********Paket Bulunamadı**********"; exit
	fi
	# Bağımlılıkları başka paketler kullanıyor mu kontrol edilir
	# Başka paketler kullanılıyorsa silinmemeli. Bu işlemin kodları yazılmadı.
	echo "${paket}-${version} bağımlılık kontrolü yapılacak"

	# Paketin file.lst dosyası içerisindeki dosyalar kaldırılır.
	if [ -f "$target/var/lib/kly/${paket}-${version}.lst" ]; then
	    cat $target/var/lib/kly/${paket}-${version}.lst | while read dosya ; do
			    if [[ -f "$target/$dosya" ]] ; then
			        rm -f "$target/$dosya"
			    fi
		  done
	fi
	# /var/lib/kly/paket-version.lst dosyasından paket bilgisi kaldırılır.
	rm -f $target/var/lib/kly/${paket}-${version}.lst

	# /var/lib/kly/index.lst dosyasından ilgili paket satırı kaldırılır.
	sed -i "/name=\"${paket}\"/d" $target/var/lib/kly/index.lst

	echo "********** ${paket}-${version}  Paketi Kaldırıldı **********"

Bu örnekte paket listesini satır satır okuduk. Önce dosya olanları sildik. Daha sonra tekrar okuyup boş kalan dizinleri sildik.
Son olarak paket listesi dosyamızı sildik. Bu işlem sonunda paket silinmiş oldu.

**klykaldir** Kullanma
----------------------

.. code-block:: shell

	./klykaldir readline /home/user1/testiso
	# /home/user1/testiso konumu hazırladığımız dağıtım konumudur.
	# kendi siteminize uygun konum belirleyiniz.

.. raw:: pdf

   PageBreak

