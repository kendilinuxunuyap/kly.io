gcc
+++

gcc paketi, GNU Compiler Collection (GCC) ile birlikte gelen ve C, C++ gibi dillerde yazılmış programların çalışması için gerekli olan temel kütüphaneleri içeren bir bileşendir. Bu paket, derleyici tarafından üretilen kodun çalışabilmesi için gerekli olan düşük seviyeli işlevleri sağlar. Debian ortamında derlemek için **sudo apt install libmpc-dev libmpfr-dev libgmp-dev libisl-dev** komutuyla paketleri kurmalıyız.

Derleme
--------

.. code-block:: shell
	
	#!/usr/bin/env bash
	version="13.1.0"
	name="gcc"
	depends="glibc,gmp,mpfr,libmpc,zlib,libisl"
	builddepend="flex,elfutils,curl,linux-headers"
	description="DOS filesystem tools - provides mkdosfs, mkfs.msdos, mkfs.vfat"
	source="https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz"
	groups="sys.devel"
		
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
	# derleme dizini yoksa oluşturuluyor
	mkdir -p  $ROOTBUILDDIR
	# içeriği temizleniyor
	rm -rf $ROOTBUILDDIR/* 
	cd $ROOTBUILDDIR #dizinine geçiyoruz
	wget ${source}
	# isimde boşluk varsa silme işlemi yapılıyor
	for f in *\ *; do mv "$f" "${f// /}"; done 
	dowloadfile=$(ls|head -1)
	filetype=$(file -b --extension $dowloadfile|cut -d'/' -f1)
	if [ "${filetype}" == "???" ]; then unzip  ${dowloadfile}; else tar -xvf ${dowloadfile};fi
	director=$(find ./* -maxdepth 0 -type d)
	directorname=$(basename ${director})
	if [ "${directorname}" != "${name}-${version}" ]; then mv $directorname ${name}-${version};fi
	mkdir -p $BUILDDIR&&mkdir -p $DESTDIR&&cd $BUILDDIR
	
	# setup
	export CFLAGS="-O2 -s"
	export CXXFLAGS="-O2 -s"
	unset LDFLAGS
	case $(uname -m) in
	  x86_64)
	    sed -i.orig '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64
	  ;;
	esac

	cd $SOURCEDIR
	mkdir build
	cd build
	../configure --prefix=/usr --libexecdir=/usr/libexec --mandir=/usr/share/man --infodir=/usr/share/info \
	--enable-languages=c,c++ --with-linker-hash-style=gnu --with-system-zlib --enable-__cxa_atexit \
	--enable-cet=auto --enable-checking=release --enable-clocale=gnu --enable-default-pie \
	--enable-default-ssp --enable-gnu-indirect-function--enable-gnu-unique-object --enable-libstdcxx-backtrace \
	--enable-link-serialization=1 --enable-linker-build-id --enable-lto --disable-multilib --enable-plugin \
	--enable-shared --enable-threads=posix --disable-libssp --disable-libstdcxx-pch --disable-werror --without-zstd \
	--disable-nls	--libdir=/usr/lib64 --target=x86_64-pc-linux-gnu 	
	
	# build 
	cd $SOURCEDIR/build
	make
	
	# package
	cd $SOURCEDIR/build
	make install DESTDIR=${DESTDIR}
	    	
	mkdir -p ${DESTDIR}/usr/lib64/
	ln -s gcc ${DESTDIR}/usr/bin/cc
	ln -s g++ ${DESTDIR}/usr/bin/cxx
	cd $DESTDIR
	while read -rd '' file; do
	case "$(file -Sib "$file")" in
	application/x-executable\;*)     # Binaries
		strip "$file" ;;
	application/x-pie-executable\;*) # Relocatable binaries
	strip "$file" ;;
	esac
	done< <(find "./" -type f -iname "*" -print0)	 

Paket adında(gcc) istediğiniz bir konumda bir dizin oluşturun ve dizin içine giriniz. Yukarı verilen script kodlarını build adında bir dosya oluşturup içine kopyalayın ve kaydedin. Daha sonra build scriptini çalıştırın. Nasıl çalıştırılacağı aşağıdaki komutlarla gösterilmiştir. Aşağıda gösterilen komutları paket için oluşturulan dizinin içinde terminal açarak çalıştırınız.


.. code-block:: shell
	
	chmod 755 build
	fakeroot ./build
  
.. raw:: pdf

   PageBreak



