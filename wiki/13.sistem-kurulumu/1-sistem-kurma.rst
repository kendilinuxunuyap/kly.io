.. _sistemkurma:

**Sistem Kurma**
++++++++++++++++

Hazırlanmış bir iso ile çeşitli kurulum araçları gelebilir. Bu araçların farklı kurulum yapma yöntemleri olmaktadır.
Sık kullanılan yöntemler şunlardır;

1. Tek bölüme sistem kurma
2. iki bölüme sistem kurma(boot+sistem)
3. uefi sistem kurma(boot+sistem)

Burada üç farklı kurulum yöntemi sırayla anlatılacaktır. Bu anlatılan yöntemler birden fazla senaryo isteğine cevap vermektedir. Fakat bu yöntemler için ayrı ayrı seçenek sunarak son kullanıcının kurulum yapılmasını istemek kafa karışıklığına sebep olabilir.
Örneğin efi seçeneği olsa fakat sistem legacy olsa veya tam tersi bir durumda kullanıcı bu detayları bilmeyebilir. Ayrıca sda veya nvme disklerde farklı senaryolar gerekecektir. Bizim yapacağımız sistem aşağıdaki tüm senaryolara cevap vermelidir. Muhtemel senaryolar;

- legacy-->sd*
- legacy-->nvme*(desteklenmemektedir)
- uefi-->sd* 
- uefi-->nvme*  kurulum yapılmak istenebilir. 

Bu senaryolara göre sorunsuz çalışacak kurlum scriptimiz **dialog** kullanarak hazırlanmıştır. Bu kurulum scriplerinin **base-file** paketinin **files.rar** paketinde bulunmaktadır. Bu bölümde sadece legacy ve uefi kurulum hangi adımlarla yapıldığını anlatan genel bir yazıdır. Bu yöntemleri kendi ihtiyacınıza göre düzenleyip kullanabilirsiniz. 




.. raw:: pdf

   PageBreak

