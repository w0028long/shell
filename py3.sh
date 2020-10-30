#!/bin/bash
mkdir /data/
yum repolist
cd /data/
yum install -y  zlib zlib-devel bzip2 bzip2-devel ncurses ncurses-devel readline readline-devel openssl openssl-devel openssl-static xz lzma xz-devel sqlite sqlite-devel gdbm gdbm-devel tk tk-devel gcc
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
mkdir -p /usr/local/python3
tar -xf /data/Python-3.6.2.tar.xz
cd /data/Python-3.6.2
./configure --prefix=/usr/local/python3  --enable-optimizations
make && make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
pip3 install --upgrade pip
if [ $? -eq 0 ];
then
    echo "python3 install done."
else
    echo " please check screen print."
fi
