Depo indexleme
++++++++++++++

Depo paketlerimizin olduğu alandır. Paketler genel olarak;

1. Sıkıştırılmış bir dosyadır
2. İçerisinde sisteme yüklenecek derlenmiş paket dizini(sıkıştırılmış olur genelde)
3. Sisteme yüklenecek derlenmiş paket dizini içindeki dosyaların ve dizinleri konumu ve listesi(file.lst)
4. Paket derleme talimatı.

Depoada ne kadar paket varsa bunların isimleri sürüm numaraları gibi bilgiler ile adreslerini liste halinde oluşturma işlemine **depo indexleme** denir.
Depo indexlenirken genellikle bilgiler **paket derleme talimatı** dosyasından alınır.
Paketlerin listesi oluşturlduktan sonra paketler kurulurken, silinirken ve güncellenirken bu listeden yararlanılır.

.. code-block:: c

	paket_adi: bash
	paket_versiyonu: 1.0
	paket_bagimliliklari: glibc, ncurses, readline
	paket_konumu: b/bash/bash_1.0.zip
	
	paket_adi: test
	paket_versiyonu: 1.1
	paket_bagimliliklari:
	paket_konumu: t/test/test_2.0.zip

Yukarıdaki örnekte paket adı bilgisi sürüm bilgisi ve bağımılılıklar gibi bilgiler ile paketin sunucu içerisindeki konumu yer almaktadır.
Depo indexi paketlerin içinde yer alan paket bilgileri okunarak otomatik olarak oluşturulur.

Örneğin paketlerimiz zip dosyası olsun ve paket bilgisini **build** dosyası taşısın. Aşağıdaki gibi depo indexi alabiliriz.

.. code-block:: shell

	index() {
	    > index.txt
	    for i in $@ ; do
	        unzip -p $i build >> index.txt
	        echo "Paket_Konumu: $i" >> index.txt
	    done
	}

	index t/test/test_2.0.zip b/bash/bash_1.0.zip ...

Bu örnekte paketlerin içindeki paket bilgisi içeren dosyaları uç uca ekledik.
Buna ek olarak paketin nerede olduğunu anlamak için paket konumunu da ekledik. Çıktısı aşağıdaki gibidir.

.. code-block:: shell

	Paket_Konumu: t/test/test_2.0.zip
	Paket_Konumu: b/bash/bash_1.0.zip

.. raw:: pdf

   PageBreak


kly github Depo Yapma
---------------------

Bu doküman kullanılarak hazırlanan paketleri bilgisayarınızda bir dizinde tutabiliriz. Fakat bu çok kısıtlı bir sistem olmasına sebep olacaktır. Paketleri bir internet ortamında bir yerde saklayarak, kurmak istediğimizde internet(uzak) üzerinden kurulması daha doğru bir yöntemdir. Bu dağıtımda paketlerimizi github.com üzerinde oluşturulan bir repository üzerinden çekilmektedir. İnternetteki paketlerimizin listesi her yeni paketi yükleme sırasında güncellenmektedir. Bu işlem github hesabı üzerinden yapılmaktadır. github hakkında temel işlemler için :ref:`githubbilgi` konusunu okuyunuz.

**github üzerinde depolamak için;**

- github hesabı açılır(kendilinuxunuyap)
- github repository oluşturulur(kly-binary-packages)
- kly-binary-packages deposuna aşağıda verilen index dosyasını oluşturunuz.
- kly-binary-packages deposuna .github/workflows dizinini ouşturarak aşağıda verilen main.yml dosyasını oluşturunuz.
- internet üzerinden kly-binary-packages reposunda settings->action->general->Workflow permissions->Read and write permissions  işaretlenmelidir.
- Yapılan paketler github üzerinde gönderilmelidir.

index Dosyası
-------------

Bu script kly paket dosyalarımızın olduğu dizinde tüm paketleri açarak içerisinden **klybuild** dosyalarını çıkartarak paketle ilgili bilgileri alıp **index.lst** dosyası oluşturmaktadır. istersek paketler local ortamdada index oluşturabiliriz. Bu dokümanda github üzerinde oluşturacak şekilde anlatılmıştır.Paket indeksi oluşturan **index.lst** dosyası aşağıdaki gibi olacaktır. Listede name, version ve depends(bağımlı olduğu paketler) bilgileri bulunmaktadır. Bilgilerin arasında **|** karekteri kullanılmıştır.

.. code-block:: shell

	#!/bin/sh
	#set -ex
	mkdir /output -p
	mkdir -p /klysource
	>index.lst
	find * -type f -name *.kly |
			while IFS= read file_name; do
				dosya="$(dirname $file_name)/klybuild"
				version=$(cat $dosya|grep version=)
				name=$(cat $dosya|grep name=)
				depends=$(cat $dosya|grep depends=)
				echo "$name|$version|$depends|$(dirname $file_name)">>index.lst
			done
	cp -rf index.lst /output

	# *****************************source files******************************
	cp -prfv ./* /klysource/

	find /klysource/* -type f -name *.kly |
			while IFS= read file_name; do
			rm -rf "$file_name"
			done
	tar -cf /output/klysourcepackage.tar /klysource/
	rm -rf /klysource


index.lst İçeriği
-----------------

https://github.com/kendilinuxunuyap/kly-binary-packages/releases/download/current/index.lst adresinde bulunan dosya aşağıdaki gibi liste oluşturacaktır.

.. code-block:: shell

	name="acl"|version="2.3.1"|depends="attr"|acl
	name="attr"|version="2.5.1"|depends=""|attr
	name="audit"|version='3.1.1'|depends=""|audit
	name="bash"|version="5.2.21"|depends="glibc,readline,ncurses"|bash

main.yml
--------
Örnek bir github CI/CD yapılandırması aşağıda verilmiştir. İnceleyebilirsiniz :D

.. code-block:: shell

	name: CI

	on:
	  push:
		branches: [ master ]

	jobs:
		compile:
		    name: depoindex
		    runs-on: ubuntu-latest
		    steps:
		      - name: Check out the repo
		        uses: actions/checkout@v2
		      - name: Run the build process with Docker
		        uses: addnab/docker-run-action@v3
		        with:
		            image: debian:testing
		            options: -v ${{ github.workspace }}:/root -v /output:/output
		            run: |
		                cd /root
		                sh index
		      - uses: "marvinpinto/action-automatic-releases@latest"
		        with:
		            repo_token: "${{ secrets.GITHUB_TOKEN }}"
		            automatic_release_tag: "current"
		            prerelease: false
		            title: "Latest release"
		            files: |
		              /output/*


.. raw:: pdf

   PageBreak

