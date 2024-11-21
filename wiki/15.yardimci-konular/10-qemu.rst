Qemu Kullanımı
++++++++++++++

qemu açık kaynaklı Virtual Box, Vmware benzeri sanallaştırma aracıdır. 

Sisteme Kurulum
---------------

.. code-block:: shell

	sudo apt update
	sudo apt install qemu-system-x86  qemu-utils

qemu Kullanımı
--------------
	
.. code-block:: shell

	# 30GB disk oluşturuldu.
	qemu-img create disk.img 30G
	qemu-system-x86_64 --enable-kvm -hda disk.img -m 2G -cdrom etahta.iso
	# qemu-system-x86_64 --enable-kvm -hda disk.img -m 2G #sadece disk ile çalıştırılıyor
	# qemu-system-x86_64 -m 2G -cdrom etahta.iso          #sadece iso doayası ile çalıştırma

Sistem Hızlandırılması
----------------------

**--enable-kvm** eğer sistem disk ile çalıştırıldığında bu parametre eklenmezse yavaş çalışacaktır.

Boot Menu Açma
--------------

Sistemin diskten mi imajdan mı başlayacağını başlangıçta belilemek için boot menu gelmesini istersek aşağıdaki gibi komut satırına seçenek eklemeliyiz.
	
.. code-block:: shell
	
	qemu-system-x86_64 --enable-kvm -cdrom distro.iso -hda disk.img -m 4G -boot menu=on  

Uefi kurulum için:
------------------

sudo apt-get install ovmf

qemu-system-x86_64 --enable-kvm -bios /usr/share/ovmf/OVMF.fd -cdrom distro.iso -hda disk.img -m 4G -boot menu=on   

qemu Host Erişimi:
------------------

istemci bilgisayar ip'si:10.0.2.15 ve ana bilgisayar 10.0.0.2 olarak ayarlıyor.

vmlinuz ve initrd
-----------------
qemu ile vmlinuz ve initrd.img dosyaları iso olmadan test edilebilir.

.. code-block:: shell

	qemu-system-x86_64 --enable-kvm -kernel /boot/vmlinuz-5.17 -initrd /home/deneme/initrd.img -append "quiet" -m 512m

qemu Terminal Yönlendirmesi
----------------------------

.. code-block:: shell
	
	qemu-system-x86_64 --enable-kvm -kernel vmlinuz -initrd initrd.img -m 3G -serial stdio -append "console=ttyS0"

Diskteki Sistemin Açılışını Terminale Yönlendirme
-------------------------------------------------

.. code-block:: shell
	
	qemu-system-x86_64 -nographic -kernel boot/vmlinuz -hda disk.img -append console=ttyS0

Kaynak:
| https://www.ubuntubuzz.com/2021/04/how-to-boot-uefi-on-qemu.html  

.. raw:: pdf

   PageBreak
