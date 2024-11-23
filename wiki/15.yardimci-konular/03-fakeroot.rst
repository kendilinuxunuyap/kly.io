Fakeroot
++++++++

Fakeroot, root yetkisi olmadan root yetkisi varmış gibi işlemler yapılmasını sağlayan bir uygulamadır. fakeroot sayesinde paket oluşturma aşamasında, root yetkisi olmadan paketin izin ve sahipliklerini ayarlamak kullanılır.

fakeroot'u debianda kullanmak için kurulu olması gerekir. Aşağıdaki komutla sisteme kurulur.

.. code-block:: shell

	sudo apt-get install fakeroot

Kullanma
--------

.. code-block:: shell

	fakeroot chown root:root abc

root yetkisi olmadan, abc dosyasının sahipliğini root olarak ayarlamamızı sağlar. 



.. raw:: pdf

   PageBreak
