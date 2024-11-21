#!/bin/sh
set -ex
# install dependencies

     apt-get update
     echo "işlem başladı....."
     apt install mtools make python3 make python3-pip python3-sphinx python3-sphinx-sitemap rst2pdf python3-svglib -y
     #rm /usr/lib/python3.11/EXTERNALLY-MANAGED
     #pip install --upgrade pip
     #pip install --no-cache-dir --upgrade pip
  #pip3 install --break-system-packages --upgrade package    
   #  pip3 install sphinx-build
   #  pip3 install rst2pdf
   #  pip3 install sphinx-sitemap
#pip install --user sphinx-build
#pip install --user rst2pdf
#pip install --user sphinx-sitemap
#apt install python3 python make

# install font
#wget https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_2_37/dejavu-fonts-ttf-2.37.zip -O font.zip
#unzip font.zip
#mv dejavu-*/ttf /usr/share/fonts/
#fc-cache -fv
# build
#rm -rf /build/*
sh build.sh
mkdir /output -p
cp -rf kitap /output

cp -r build/pdf/rst2pdf.pdf /output/distro.pdf
cp -r build/html/* /output
cp robots.txt /output
