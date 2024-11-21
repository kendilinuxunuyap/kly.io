X11 Kullanıcısının Tespiti
++++++++++++++++++++++++++

Linux ortamında masaütündeyken sudo ile script çalıştırıldığında masaütünü açtığımız kullanıcının tespiti aşağıdaki kodla yapılabilir.

.. code-block:: shell

	#!/bin/bash

	# Detect the name of the display in use
	display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

	# Detect the user using such display
	user=$(who | grep '('$display')' | awk '{print $1}')

	# Detect the id of the user
	uid=$(id -u $user)

	echo $user $uid
	
	
.. raw:: pdf

   PageBreak
