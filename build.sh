#!/bin/sh
# temizlik


make html pdf
find build/html -type f -iname *.html -exec sed -i "s/.*src=\".*\.js\".*//g" {} \;
find build/html -type f -iname *.js -exec rm -rf {} \;
rm -rf build/html/_static/css build/html/{search,genindex}.html

rm build/html/index.html
ln -s main.html build/html/index.html
exit

pip3 install -r requirements.txt
