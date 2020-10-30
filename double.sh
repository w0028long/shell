#!/bin/bash
#准备工作，准备通用目录和数据目录以及相关系统用户,清理历史环境
tem=$(rpm -qa | grep mariadb)
for item in $tem
do
    rpm -e $item --nodeps
done
yum  -y   install   gcc-c++   ncurses-devel   cmake openssl openssl-devel bison* perl*
useradd mysql -s /sbin/nologin
mkdir -p /usr/local/mysql56 && mkdir -p /usr/local/mysql57
mkdir -p /data/mysql56/data && mkdir -p /data/mysql57/data
mkdir -p /var/log/mysql56 && mkdir -p /var/log/mysql57
chown mysql:mysql -R /usr/local/mysql56 && chown mysql:mysql -R /usr/local/mysql57
chown mysql:mysql -R /data/*
chown mysql:mysql -R /var/log/mysql56 && chown mysql:mysql -R /var/log/mysql57
#######################以上准备工作完成#######################################

#准备5.6的安装############################
cd /data/ && tar -xf mysql-5.6.48.tar.gz && cd /data/mysql-5.6.48
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql56 \
    -DMYSQL_UNIX_ADDR=/data/mysql56/mysql.sock \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DMYSQL_DATADIR=/data/mysql56/data \
    -DMYSQL_TCP_PORT=3307
make && make install
cat > /data/mysql56/my.cnf <<EOF
[mysqld]
basedir=/usr/local/mysql56
datadir=/data/mysql56/data
socket=/data/mysql56/mysql.sock
log_error=/var/log/mysql56/mysql.log
port=3307
user=mysql
EOF
cd /usr/local/mysql56
./scripts/mysql_install_db --user=mysql --datadir=/data/mysql56/data --basedir=/usr/local/mysql56
#准备5.7的安装##############################
cd /data/ && tar -xf mysql-boost-5.7.30.tar.gz && cd /data/mysql-5.7.30 && mv boost /usr/local/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql57 \
      -DMYSQL_DATADIR=/data/mysql57/data \
      -DDEFAULT_CHARSET=utf8 \
      -DDEFAULT_COLLATION=utf8_general_ci \
      -DMYSQL_TCP_PORT=3308 \
      -DMYSQL_UNIX_ADDR=/data/mysql57/mysql.sock \
      -DWITH_MYISAM_STORAGE_ENGINE=1 \
      -DWITH_INNOBASE_STORAGE_ENGINE=1 \
      -DDOWNLOAD_BOOST=1 \
      -DWITH_BOOST=/usr/local/boost \
      -DWITH_INNODB_MEMCACHED=ON
make && make install
cat > /data/mysql57/my.cnf <<EOF
[mysqld]
basedir=/usr/local/mysql57
datadir=/data/mysql57/data
server_id=8
socket=/data/mysql57/mysql.sock
log_error=/var/log/mysql57/mysql.log
port=3308
user=mysql
EOF
/usr/local/mysql57/bin/mysqld --initialize-insecure  --user=mysql --datadir=/data/mysql57/data --basedir=/usr/local/mysql57
#############################生成启动脚本#####################
cat > /etc/systemd/system/mysqld56.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql56/bin/mysqld --defaults-file=/data/mysql56/my.cnf
LimitNOFILE = 5000
EOF
cat > /etc/systemd/system/mysqld57.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql57/bin/mysqld --defaults-file=/data/mysql57/my.cnf
LimitNOFILE = 5000
EOF
systemctl daemon-reload && systemctl start mysqld56.service && systemctl start mysqld57.service
######################验证返回################
netstat -lpn | grep 330
