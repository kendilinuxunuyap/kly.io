Temel Paketler
++++++++++++++

Bir önceki bölümde minimal bir sistemi **busybox** yardımıyla tasarladık. Minimal sistem tasarımımızda temel bir sistemin nasıl hazırlandığını anlatmaya çalıştık. Eğer aşamaları takip ederek yaptığımızda kendisini açabilen bir sistem olduğunu görmekteyiz. Minimal sistemde kullanılan **busybox** aslında bizim işlerimiz çok kolaylaştırdı. Şimdi ise **busybox** ile yapabileceğimiz işlemleri kısaca şöyle sıralayabiliriz.

- Temel linux komutlarının(ls, cp, mkdir vs.) yerine busybox kullanabilir.
- Çeşitli sıkıştırma formatları(zip, tar, cpio vb.) yerine busybox kullanabilir.
- İnternete bağlanabililir(udhcpc).
- Dosya indirebilir(wget, curl vb.)
- Log(raporlama) tutabilir.
- Modülleri yönetebilir(kmod, modprobe,insmod vb.)

Bu bölümde **busybox** ile yaptımız işleri yapan paketleri derleyeceğiz. **busybox** yapamadığımız bazı işlemleri(ssh vb.) yapan paketlerde olacak. Tasarlayacağımız sistemde genel olarak şunlar yapılabilecek.

- Temel linux komutları kullanılacak
- Bash kabuğu ile tty ortamı olacak
- Sıkıştırma formatları kullanılabilecek
- Modüller yönetilebilecek
- initrd oluşturabilecek
- grub kurabilecek
- Sistemi kurabilecek
- Sistemi live olarak açabilecek
- İnternete bağlanılabilecek
- ssh bağlantısı ile uzaktan yönetilebilecek
- Metin düzenleyici editör olacak

Bu yapıda bir dağıtım için aşağıdaki paketlere ihtiyacımız olacak.

.. list-table::
   :widths: 25 25 50

   * - 0- `base-file <./001-base-file.html>`_
     - 25- `elfutils <./25-elfutils.html>`_
     - 50- `popt <./50-popt.html>`_
   * - 1- `glibc <./01-glibc.html>`_
     - 26- `libselinux <./26-libselinux.html>`_
     - 51- `icu <./51-icu.html>`_
   * - 2- `readline <./02-readline.html>`_
     - 27- `tar <./27-tar.html>`_
     - 52- `iproute2 <./52-iproute2.html>`_
   * - 3- `ncurses <./03-ncurses.html>`_
     - 28- `zlib <./28-zlib.html>`_
     - 53- `net-tools <./53-net-tools.html>`_
   * - 4- `bash <./04-bash.html>`_
     - 29- `brotli <./29-brotli.html>`_
     - 54- `dhcp <./54-dhcp.html>`_
   * - 5- `openssl <./05-openssl.html>`_
     - 30- `curl <./30-curl.html>`_
     - 55- `openrc <./55-openrc.html>`_
   * - 6- `acl <./06-acl.html>`_
     - 31- `shadow <./31-shadow.html>`_
     - 56- `rsync <./56-rsync.html>`_
   * - 7- `attr <./07-attr.html>`_
     - 32- `file <./32-file.html>`_
     - 57- `kbd <./57-kbd.html>`_
   * - 8- `libcap <./08-libcap.html>`_
     - 33- `eudev <./33-eudev.html>`_
     - 58- `kernel <./58-kernel.html>`_
   * - 9-  `libpcre2 <./09-libpcre2.html>`_
     - 34- `cpio <./34-cpio.html>`_
     - 59- `dialog <./59-dialog.html>`_
   * - 10- `gmp <./10-gmp.html>`_
     - 35- `libsepol <./35-libsepol.html>`_
     - 60- `live-boot <./60-live-boot.html>`_
   * - 11- `coreutils <./11-coreutils.html>`_
     - 36- `kmod <./36-kmod.html>`_
     - 61- `live-config <./61-live-config.html>`_
   * - 12- `util-linux <./12-util-linux.html>`_
     - 37- `audit <./37-audit.html>`_
     - 62- `parted <./62-parted.html>`_
   * - 13- `grep <./13-grep.html>`_
     - 38- `libxcrypt <./38-libxcrypt.html>`_
     - 63- `busybox <./63-busybox.html>`_
   * - 14- `sed <./14-sed.html>`_
     - 39- `libnsl <./39-libnsl.html>`_
     - 64- `nano <./64-nano.html>`_
   * - 15- `mpfr <./15-mpfr.html>`_
     - 40- `libbsd <./40-libbsd.html>`_
     - 65- `grub <./65-grub.html>`_
   * - 16- `gawk <./16-gawk.html>`_
     - 41- `libtirpc <./41-libtirpc.html>`_
     - 66- `efibootmgr <./66-efibootmgr.html>`_
   * - 17- `findutils <./17-findutils.html>`_
     - 42- `e2fsprogs <./42-e2fsprogs.html>`_
     - 67- `efivar <./67-efivar.html>`_
   * - 18- `gcc <./18-gcc.html>`_
     - 43- `dostools <./43-dostools.html>`_
     - 68- `libssh <./68-libssh.html>`_
   * - 19- `libcap-ng <./19-libcap-ng.html>`_
     - 44- `initramfs-tools <./44-initramfs-tools.html>`_
     - 69- `openssh <./69-openssh.html>`_
   * - 20- `sqlite <./20-sqlite.html>`_
     - 45- `libxml2 <./45-libxml2.html>`_
     - 70- `pam <./70-pam.html>`_
   * - 21- `gzip <./21-gzip.html>`_
     - 46- `expat <./46-expat.html>`_
     - 71- 
   * - 22- `xz-utils <./22-xz-utils.html>`_
     - 47- `libmd <./47-libmd.html>`_
     - 72- 
   * - 23- `zstd <./23-zstd.html>`_
     - 48- `libaio <./48-libaio.html>`_
     - 73-    
   * - 24- `bzip2 <./24-bzip2.html>`_
     - 49- `lvm2 <./49-lvm2.html>`_
     - 74-
      
Bir linux paketinin sorunsuz çalışabilmesi için bağımlı olduğu paketlerin önceden derlenmiş olması gerekir. Örneğin  **bash** paketinin sorunsuz çalışabilmesi için **readline** ve **ncurses** kütüphaneleri gerekli. **readline** ve **ncurses** kütüphanelerinin çalışabilmesi içinde **glibc** kütüphanesi gerekli.
Listede bulunan paketler sırasıyla nasıl derleneceği ayrı başlıklar altında anlatılacaktır.

Paketlere başlamadan önce şu paketleri kurmanızı tavsiye ederim.

.. code-block:: shell

	sudo apt-get install autoconf \
	    automake \
	    autotools-dev \
	    make \
	    meson \
	    cmake \
	    ninja-build \
	    pkgconf \
	    patch \
	    libtool \
	    grub-pc grub-pc-bin \
	    fakeroot

Paketlerin derlenmesini **fakeroot** ile yapınız.

.. raw:: pdf

   PageBreak

