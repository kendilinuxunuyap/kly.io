strip
++++++

strip, derlenmiş dosyaların sembolik ve degub  bilgilerini kaldırır. Bu, sayade ikili dosyaların daha az yer kaplaması sağlanır.

Özellikle kernel ve modül derlerken kullanılır. Bazı paketlerde özellikle kullanılırken, bazı paketlerde de özellikle kullanılmaması gerekir. Mesela gcc derlerken boyutu büyük diye **strip** kullanılmaması gerekir. Ayrıca gömülü kütüphaneler(static kütüphaneler) kullanılan dosyalarda dikkatli kullanmalıyız.  
 
Aşağıdaki komut, "ikilidosya" adlı dosyanın sembolik ve degub  bilgilerini temizler;

.. code-block:: shell

	strip ikilidosya

Bu komutla, "ikilidosya" dosyasının boyutunu küçültülür.

Kaynak:
- https://zzzcode.ai/answer-question?id=e115feb7-7dc3-4305-8609-cdd5ae53af90

.. raw:: pdf

   PageBreak
