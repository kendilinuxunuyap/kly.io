Kullanıcı Ekleme
++++++++++++++++

linux sistemlerine kullanıcı eklemek için iki farklı komut bulunur. Bu komutlar adduser ve useradd komutlarıdır.


**adduser:**
------------

Kullanıcı dostu bir arayüz sunar. Birçok aşamayı bizim adımıza yapar. Temelde useradd komutunu kullanarak yazılan bir script olarak düşünebiliriz.

.. code-block:: shell

	# adduser komutuyla kullanıcı oluşturma
	sudo adduser yeni_kullanici

**useradd:** 
------------

Kullanıcıdan tüm parametreleri girmesini ister.  Bu sebepten çok tercih edilmemektedir. Fakat özel bir şekilde kullanıcı oluşturulmak istenildiğinde tercih edilir. Bu dokümanda kurulum aşamalarında useradd komutu kullanıldı.


.. code-block:: shell

	# useradd komutuyla kullanıcı oluşturma
	sudo useradd -m -s /bin/bash yeni_kullanici -d /home/yeni_kullanici
	# -s/bin/bash : kullanıcının kullanacağı shell belirtiliyor.
	# -d /home/yeni_kullanici : home dizinine oluşturulacak kullanıcı dizini belirtiyoruz


.. raw:: pdf

   PageBreak
