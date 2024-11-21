.. _chrootnedir:

Chroot Nedir?
+++++++++++++

chroot komutu çalışan sistem üzerinde belirli bir klasöre root yetkisi verip sadece o klasörü sanki linux sistemi gibi çalıştıran bir komuttur. Sağladığı avantajlar çok fazladır. Bunlar;

    - Sistem tasarlama
    - Sitem üzerinde yeni dağıtımlara müdahale etme ve sorun çözme
    - Kullanıcı kendine özel geliştirme ortamı oluşturabilir.
    - Yazılım bağımlıkları sorunlarına çözüm olabilir.
    - Kullanıcıya sadece kendisine verilen alanda sınırsız yetki verme vb.

.. image:: /_static/images/chroot-1.png
  :width: 600
  :height: 400


Yukarıdaki resimde user1 altında wrk dizini altına yeni bir sistem kurulmuş gibi yapılandırmayı gerçekleştirmiş.

**/home/etapadmin/test** dizinindeki sistem üzerinde sisteme erişmek için;

.. code-block:: shell

	# sisteme erişim yapıldı.
	sudo chroot /home/etapadmin/test 
	
**/home/etapadmin/test** dizinindeki sistem üzerinde sistemi silmek için;

.. code-block:: shell

	# sistem silindi
	sudo rm -rf /home/etapadmin/test

.. raw:: pdf

   PageBreak
   
Yeni sistem tasarlamak ve erişmek için temel komutları ve komut yorumlayıcının olması gerekmektedir. Bunun için bize gerekli olan komutları bu yapının içine koymamız gerekmektedir. Örneğin ls komutu için doğrudan çalışıp çalışmadığını ldd komutu ile kontrol edelim.

.. image:: /_static/images/chroot-2.png
  :width: 600

Görüldüğü gibi ls komutunun çalışması için bağımlı olduğu kütüphane dosyaları bulunmaktadır. Bağımlı olduğu dosyaları yeni oluşturduğumuz sistem dizinine aynı dizin yapısında kopyalamamız gerekmektedir. Bu dosyalar eksiksiz olursa ls komutu çalışacaktır. Fakat bu işlemi tek tek yapmamız çok zahmetli bir işlemdir. Bu işi yapacak script dosyası aşağıda verilmiştir.

Bağımlılık Scripti
------------------

lddscript.sh

.. code-block:: shell

	#!/bin/bash

	if [ ${#} != 2 ]
	then
	    echo "usage $0 PATH_TO_BINARY target_folder"
	    exit 1
	fi
	path_to_binary="$1"
	target_folder="$2"

	# if we cannot find the the binary we have to abort
	if [ ! -f "${path_to_binary}" ]
	then
	    echo "The file '${path_to_binary}' was not found. Aborting!"
	    exit 1
	fi

	echo "---> copy binary itself" # copy the binary itself
	cp --parents -v "${path_to_binary}" "${target_folder}"

	echo "---> copy libraries" # copy the library dependencies
	ldd "${path_to_binary}" | awk -F'[> ]' '{print $(NF-1)}' | while read -r lib
	do
	    [ -f "$lib" ] && cp -v --parents "$lib" "${target_folder}"
	done

Basit Sistem Oluşturma
----------------------

Bu örnekte kullanıcının(etapadmin) ev dizinine(/home/etapadmin) test dizini oluşturuldu ve işlemler yapıldı. 
ls, rmdir, mkdir ve bash komutlarından oluşan sistem hazırlama.

Sistem Dizinin Oluşturulması
----------------------------

.. code-block:: shell

	# ev dizinine test dizini oluşturuldu.
	mkdir /home/etapadmin/test/
	
/home/etapadmin/ dizinine **Bağımlılık Scripti** kodunu **lddscripts.sh** oluşturalım.

ls Komutu
----------

.. code-block:: shell

	# ls komutu ve bağımlılığı kopyalandı.
	bash lddscripts.sh /bin/ls /home/etapadmin/test/

.. image:: /_static/images/chroot-3.png
  :width: 600

Bu işlemi diğer komutlar içinde sırasıyla yapmamız gerekmektedir.

rmdir Komutu
------------

.. code-block:: shell

	# rmdir komutu ve bağımlılığı kopyalandı.
	bash lddscripts.sh /bin/rmdir /home/etapadmin/test/

.. image:: /_static/images/chroot-4.png
  :width: 600


.. raw:: pdf

   PageBreak
   
mkdir Komutu
------------

.. code-block:: shell

	# mkdir komutu ve bağımlılığı kopyalandı.
	bash lddscripts.sh /bin/mkdir /home/etapadmin/test/

.. image:: /_static/images/chroot-5.png
  :width: 600

bash Komutu
------------

.. code-block:: shell

	# bash komutu ve bağımlılığı kopyalandı.
	bash lddscripts.sh /bin/bash /home/etapadmin/test/

.. image:: /_static/images/chroot-6.png
  :width: 600


chroot Sistemde Çalışma
------------------------

.. code-block:: shell

	sudo chroot /home/etapadmin/test komutunu kullanmalıyız.

.. image:: /_static/images/chroot-7.png
  :width: 600

- **abc** dizini oluşturuldu, **abc** dizini silindi, **pwd** komutuyla konum öğrenildi, **ldd** komutu sistemimizde olmadığından hata verdi.
- Çıkış için ise **exit** komutu kullanılarak sistemden çıkıldı.

Kaynak:
https://stackoverflow.com/questions/64838052/how-to-delete-n-characters-appended-to-ldd-list
https://app.diagrams.net/

.. raw:: pdf

   PageBreak

