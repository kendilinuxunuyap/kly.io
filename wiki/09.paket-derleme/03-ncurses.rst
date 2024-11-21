ncurses
+++++++

ncurses, Linux işletim sistemi için bir programlama kütüphanesidir. Bu kütüphane, terminal tabanlı kullanıcı arayüzleri oluşturmak için kullanılır. ncurses, terminal ekranını kontrol etmek, metin tabanlı menüler oluşturmak, renkleri ve stil özelliklerini ayarlamak gibi işlevlere sahiptir.

ncurses, kullanıcıya metin tabanlı bir arayüz sağlar ve terminal penceresinde çeşitli işlemler gerçekleştirmek için kullanılabilir. Örneğin, bir metin düzenleyici, dosya tarayıcısı veya metin tabanlı bir oyun gibi uygulamalar ncurses kullanarak geliştirilebilir.

Derleme
-------

Debian ortamında bu paketin derlenmesi için;
**sudo apt install libncurses-dev** komutuyla paketin kurulması gerekmektedir.


.. code-block:: shell
	
	#!/usr/bin/env bash
	version="6.4"
	so_ver="6"
	name="ncurses"
	depends="glibc"
	description="ncurses kütüphanesi"
	source="https://ftp.gnu.org/pub/gnu/ncurses/${name}-${version}.tar.gz"
	groups="sys.libs"
	
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

	# initsetup
	mkdir -p  $ROOTBUILDDIR #derleme dizini yoksa oluşturuluyor
	rm -rf $ROOTBUILDDIR/* #içeriği temizleniyor
	cd $ROOTBUILDDIR #dizinine geçiyoruz
	wget ${source}
	for f in *\ *; do mv "$f" "${f// /}"; done #isimde boşluk varsa silme işlemi yapılıyor
	dowloadfile=$(ls|head -1)
	filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
	if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
	director=$(find ./* -maxdepth 0 -type d)
	directorname=$(basename ${director})
	if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
	mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	
	# setup
	./configure --prefix=/usr --libdir=/lib64 --with-shared --disable-tic-depends --with-versioned-syms  --enable-widec --with-cxx-binding \
	--with-cxx-shared --enable-pc-files --mandir=/usr/share/man --with-manpage-format=normal --with-xterm-kbs=del --with-pkg-config-libdir=/usr/lib64/pkgconfig
	
	# build
	 make -j5 #-C $DESTDIR all 
	
	# package
	make install DESTDIR=$DESTDIR
	cd $DESTDIR/lib64
	ln -s libncursesw.so.6 libtinfow.so.6
	ln -s libncursesw.so.6 libtinfo.so.6
	ln -s libncursesw.so.6 libncurses.so.6
	 	
	# make sure that anything linking against it links against libncurses.so instead
	for lib in ncurses ncurses++ form panel menu; do
		if [ ! -f "$DESTDIR/usr/lib64/pkgconfig/${lib}.pc" ]; then
			ln -sv ${lib}w.pc "$DESTDIR/usr/lib64/pkgconfig/${lib}.pc"
		fi
	done    	
	# make sure that anything linking against it links against libncursesw.so instead
	for lib in tic tinfo tinfow ticw; do 
		if [ ! -f "$DESTDIR/usr/lib64/pkgconfig/${lib}.pc" ]; then
			ln -sv ncursesw.pc "$DESTDIR/usr/lib64/pkgconfig/${lib}.pc"
		fi
	done
	# legacy binary support
	for lib in libncursesw libncurses libtinfo libpanelw libformw libmenuw ; do
		ln -sv ${lib}.so.${so_ver} ${lib}.so.5
	done

Paket adında(ncurses) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak


