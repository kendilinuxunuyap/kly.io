Paket Oluşturma
+++++++++++++++

Paket sisteminde en önemli kısımlardan birisi paket oluşturmadır. Bu işlem paketin derlenmesi ve derlenmiş paketin belirli bir yapıyla saklanması olayıdır. Bu saklanan paket daha sonra ihtiyaç halinde uzaktan(internet üzerinden) ve yerelden istediğimiz sisteme kurma işlemidir. Bu başlıkta paketin derlenmesi ve saklanması(paket oluşturma) anlatılacaktır.

Paket oluşturma işlemi sırayla şu aşamalardan oluşmaktadır.

1. Paketin indirilmesi
2. Paketin derleme öncesi hazırlanması(configure)
3. Paketin derlenmesi
4. Derlenmiş paketin bir dizine yüklenmesi
5. Yüklenen dizindeki dosya ve dizin yapısının konum listesini tutan file.index oluşturulması
6. Derlenmiş paketin bir dizinin sıkıştırılması
7. Sıkıştırılmış derlenmiş dizin, file.index ve derleme talimatının paket isim ve versiyonuyla tekrardan sıkıştırılması

Burada maddeler halinde anlatılan işlem adımlarını bir paket oluşturma amacıyla sırasıyla yapmamız gerekmektedir. 7. maddede anlatılan son sıkıştırılma öncesi yapı aşağıda gösterilmiştir.

.. image:: /_static/images/klypaketle-0.png
  	:width: 600


.. raw:: pdf

   PageBreak
   

**kly Paket Oluşturma**
-----------------------

kly paket sisteminin temel parçalarından en önemlisi paket oluşturma uygulamasıdır. Dokümanda temel paketlerin nasıl derlendiği **Paket Derleme** başlığı altında anlatılmıştı. Bir paket üzerinden(readline) örneklendirerek paketimizi oluşturacak scriptimizi yazalım.

Daha önceden derlediğimiz readline paketinin scriptini,  aşağıdaki gibi düzenlendi.

.. code-block:: shell

	#!/usr/bin/env bash
	version="8.2"
	name="readline"
	depends="glibc"
	description="readline kütüphanesi"
	source="https://ftp.gnu.org/pub/gnu/readline/${name}-${version}.tar.gz"
	groups="sys.apps"
	
	# Paketin yükleneceği tasarlanan sistem konumu
	DESTDIR="$HOME/distro/rootfs"
	# Derleme konumu
	ROOTBUILDDIR="/tmp/kly/build"
	# Derleme yapılan paketin derleme konumun
	BUILDDIR="/tmp/kly/build/build-${name}-${version}" 
	# paketin derleme talimatının verildiği konum
	PACKAGEDIR=$(pwd) 
	# Paketin kaynak kodlarının olduğu konum
	SOURCEDIR="/tmp/kly/build/${name}-${version}" 
		
	initsetup(){
		# derleme dizini yoksa oluşturuluyor
		mkdir -p  $ROOTBUILDDIR
		# içeriği temizleniyor
		rm -rf $ROOTBUILDDIR/*
		# dizinine geçiyoruz
		cd $ROOTBUILDDIR
		wget ${source}
		# isimde boşluk varsa silme işlemi yapılıyor
		for f in *\ *; do
		    mv "$f" "${f// /}";
		done
		dowloadfile=$(ls|head -1)
		filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
		if [ "${filetype}" == "???" ]; then
		    unzip  ${dowloadfile};
		else
		    tar -xvf ${dowloadfile}
		fi
		director=$(find ./* -maxdepth 0 -type d)
		directorname=$(basename ${director})
		if [ "${directorname}" != "${name}-${version}" ]; then
		    mv $directorname ${name}-${version}
		fi
		mkdir -p $BUILDDIR $DESTDIR
		cd $SOURCEDIR
	}

	setup(){
		cp -prvf $PACKAGEDIR/files $SOURCEDIR/
		./configure \
		    --prefix=/usr \
		    --libdir=/usr/lib
	}

	build(){
		make SHLIB_LIBS="-L/tools/lib -lncursesw"
	}

	package(){
		make install \
		    SHLIB_LIBS="-L/tools/lib -lncursesw" \
		    pkgconfigdir="/usr/lib64/pkgconfig" \
		    DESTDIR="$DESTDIR"
	}
	# initsetup fonksiyonunu çalıştırır ve kaynak dosyayı indirir.
	initsetup
	# setup fonksiyonu çalışır ve derleme öncesi kaynak dosyaların
	# ayalanması sağlanır.
	setup
	# build fonksiyonu çalışır ve kaynak dosyaları derlenir.
	build
	# package fonksiyonu çalışır, yükleme öncesi ayarlamalar yapılır
	# ve yüklenir.
	package


Bu script readline kodunu internetten indirip derliyor ve kurulumu yapıyor. Aslında bu scriptle **paketleme**, **paket kurma** işlemini bir arada yapıyor. Bu işlem mantıklı gibi olsada paket sayısı arttıkça ve rutin yapılan işlemleri tekrar tekrar yapmak gibi işlem fazlalığına sebep olmaktadır.

Bu sebeplerden dolayı **readline** paketleme scriptini yeniden düzenleyelim. Yeni düzenlenen halini  **klypaketle** ve **klybuild** adlı script dosyaları olarak düzenleyeceğiz. Genel yapısı aşağıdaki gibi olacaktır. Devamında ise **packageindex** ve **packagecompress** fonksiyonları klypaketle dosyasına eklenecektir.

**klybuild** Dosyası
--------------------

.. code-block:: shell

	setup()	{
	   ...
	}
	build()	{
	   ...
	}
	package() {
	   ...
	}

**klypaketle** Dosyası
----------------------

.. code-block:: shell

	# genel değişkenler tanımlanır
	initsetup() {
	   ...
	}

	# klybuild dosya fonksiyonları birleştiriliyor
	# bu komutla setup build package fonsiyonları klybuild doyasından
	# alınıp birleştiriliyor
	source klybuild

	packageindex() {
	   ...
	}
	packagecompress() {
	   ...
	}

Aslında yukarıdaki **klypaketle** ve **klybuild** adlı script dosyaları tek bir script dosyası olarak **klypaketle** dosyası. İki dosyayı birleştiren **source klybuild** komutudur. **klypaketle** dosyası aşağıdaki gibi düşünebiliriz.

.. code-block:: shell

	# genel değişkenler klybuild içinde tanımlanır
	# klypaketle dosyasından gelir
	initsetup() {...}

	# klpbuild dosyasından gelen fonksiyonlar
	setup()	{...}
	build()	{...}
	package() {...}

	# klypakelte dosyasından gelen fonksiyonlar
	packageindex() {...}
	packagecompress() {...}

Bu şekilde ayrılmasının temel sebebi  **klypaketle** scriptinde hep aynı işlemler yapılırken **klybuild** scriptindekiler her pakete göre değişmektedir. Böylece paket yapmak için ilgili pakete özel **klybuild** dosyası düzenlememiz yeterli olacaktır. **klypaketle** dosyamızda **klybuild** scriptini kendisiyle birleştirip paketleme yapacaktır.

**klybuild** Dosyamızın Son Hali
----------------------------------

.. code-block:: shell

	#!/usr/bin/env bash
	version="8.2"
	name="readline"
	depends="glibc"
	description="readline kütüphanesi"
	source="https://ftp.gnu.org/pub/gnu/readline/${name}-${version}.tar.gz"
	groups="sys.apps"
	#2. madde, derleme öncesi hazırlık
	setup(){
		./configure \
		  --prefix=/usr \
			--libdir=/usr/lib
	}
	#3. madde, paketin derlenmesi
	build(){
		make SHLIB_LIBS="-L/tools/lib -lncursesw"
	}
	#4. madde, derlenen paketin bir dizine yüklenmesi
	package(){
		make install \
		    SHLIB_LIBS="-L/tools/lib -lncursesw" \
		    DESTDIR="$DESTDIR" \
		    pkgconfigdir="/usr/lib64/pkgconfig"
	}



**klypaketle** Dosyamızın Son Hali
----------------------------------

.. code-block:: shell
	
	#!/usr/bin/env bash
	set -e
	paket="$1"
	dizin="$PWD"
	echo "Paket : $paket"
	source ${paket}/klybuild
	# Paketin yükleneceği tasarlanan sistem konumu
	DESTDIR="$HOME/distro/rootfs"
	# Derleme konumu
	ROOTBUILDDIR="/tmp/kly/build"
	# Derleme yapılan paketin derleme konumun
	BUILDDIR="/tmp/kly/build/build-${name}-${version}" 
	# paketin derleme talimatının verildiği konum
	PACKAGEDIR=$(pwd) 
	# Paketin kaynak kodlarının olduğu konum
	SOURCEDIR="/tmp/kly/build/${name}-${version}" 

	# 1. madde, paketin indirilmesi
	initsetup(){
		# derleme dizini yoksa oluşturuluyor
		mkdir -p $ROOTBUILDDIR
		# içeriği temizleniyor
		rm -rf $ROOTBUILDDIR/*
		# dizinine geçiyoruz
		cd $ROOTBUILDDIR
		if [ -n "${source}" ] ; then
		    wget ${source}
		    dowloadfile=$(ls|head -1)
		    filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
		    if [ "${filetype}" == "???" ]; then
		        unzip ${dowloadfile}
		    else
		        tar -xvf ${dowloadfile}
		    fi
		    director=$(find ./* -maxdepth 0 -type d)
		    directorname=$(basename ${director})
		    if [ "${directorname}" != "${name}-${version}" ]; then
		        mv $directorname ${name}-${version}
		    fi
		fi
		mkdir -p $BUILDDIR $DESTDIR
		cd $BUILDDIR
		cp $PACKAGEDIR/klybuild $ROOTBUILDDIR/
	}
	# 6. madde, paketlenecek dosların listesini tutan file.index
	# dosyası oluşturulur.
	packageindex() {
		rm -rf file.index
		cd /tmp/kly/build/rootfs-${name}-${version}
		find . -type f | while IFS= read file_name; do
		    if [ -f ${file_name} ]; then
		        echo ${file_name:1} >>../file.index
		    fi
		done
		find . -type l | while IFS= read file_name; do
		    if [ -L ${file_name} ]; then
		        echo ${file_name:1} >> ../file.index
		    fi
		done
	}
	# paket dosyası oluşturulur;
	# rootfs.tar.xz, file.index ve klybuild dosyaları tar.gz dosyası
	# olarak hazırlanıyor.
	# 7. madde, tar.gz dosyası olarak hazırlanan dosya kly ismiyle
	# değiştirilip paketimiz hazırlanır.
	packagecompress() {
		cd /tmp/kly/build/rootfs-${name}-${version}
		tar -cf ../rootfs.tar ./*
		cd /tmp/kly/build/
		xz -9 rootfs.tar
		tar -cvzf paket-${name}-${version}.tar.gz \
		    rootfs.tar.xz file.index klybuild
		cp paket-${name}-${version}.tar.gz \
		    ${dizin}/${paket}/${name}-${version}.kly
	}
	# fonksiyonlar aşağıdaki sırayla çalışacaktır.
	# bu dosya içindeki fonksiyon (indirilmesi)
	initsetup
	# klybuild dosyasından gelen fonksiyon (derleme öncesi hazırlık)
	setup
	# klybuild dosyasından gelen fonksiyon (derleme)
	build
	# klybuild dosyasından gelen fonksiyon (derlenen paketin dizine
	# yüklenemesi)
	package
	# bu dosya içindeki fonksiyon (dizine yüklelen paketin indexlenmesi)
	packageindex
	# bu dosya içindeki fonksiyon (index.lst, derleme talimatı ve dizinin
	# sıkıştırılması)
	packagecompress

Burada **readline** paketini örnek alarak **klypaketle** dosyasının ve **klybuild** dosyasının nasıl hazırlandığı anlatıldı.
Diğer paketler için sadece hazırlanacak pakete uygun şekilde **klybuild** dosyası hazırlayacağız. **klypaketle**  dosyamızda değişiklik yapmayacağız. Artık  **klypaketle**  dosyası paketimizi oluşturan script **klybuild** ise hazırlanacak paketin bilgilerini bulunduran script doyasıdır.


.. raw:: pdf

   PageBreak
   
**Paket Yapma**
---------------

Bu bilgilere göre readline paketi nasıl oluşturulur onu görelim. Paketlerimizi oluşturacağımız bir dizin oluşturarak aşağıdaki işlemleri yapalım. Burada yine **readline** paketi anlatılacaktır.


.. code-block:: shell

	mkdir readline
	cd readline
	# readline için hazırlanan klybuild dosyası, readline dizininin içine
	# kopyalayın
	cd ..
	# klypaketle dosyamıza parametre olarak readline dizini verilmiştir.
	fakeroot ./klypaketle readline

Komut çalışınca readline/readline-8.1.kly dosyası oluşacaktır. Aşağıda resimde nasıl yapıldığı gösterilmiştir. Burada anlatılan **klypaketle** script dosyasını **/bin/** konumuna oluşturnuz ve **chmod 755 /bin/klypaketle** komutuyla çalıştırma izni vermeliyiz. **kly** paket sistemi için yapılacak olan **bsppaketle, klyupdate, klykur, klykaldir** scriptlerinide **/bin/** konumunda oluşturulmalı veya kopyalanmalı ve çalıştırma izni verilmeli.

.. image:: /_static/images/klypaketle-2.png
  	:width: 600

Artık sisteme kurulum için ikili dosya, kütüphaneleri ve dizinleri barındıran paketimiz oluşturuldu. Bu paketi sistemimize nasıl kurarız? konusu **Paket Kurma** başlığı altında anlatılacaktır.

.. raw:: pdf

   PageBreak

