# 基础镜像为ubuntu:14.04
FROM ubuntu:14.04

# 作者为liusec
MAINTAINER liusec <75065472@qq.com>

# 替换apt源: 将/etc/apt/sources.list文件中的archive.ubuntu.com替换为mirrors.aliyun.com
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 设置环境变量: 将env环境变量中的TZ设置为Asia/Shanghai
ENV TZ=Asia/Shanghai

# (1)设置本地时间：强制为/usr/share/zoneinfo/Asia/Shanghai文件创建符号链接（软链接）为/etc/localtime，-f为force
# (2)设置时区：向文件/etc/timezone中写入字符串‘Asia/Shanghai’,更改时区为上海
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新源
RUN apt-get update -y

# 安装apache、vim、bash-completion、unzip
RUN apt-get install -y apache2 vim bash-completion unzip
# 创建文件夹/var/lock/apache2 、/var/run/apache2
RUN mkdir -p /var/lock/apache2 /var/run/apache2

# 安装mysql-client、 mysql-server; 启动mysql服务; 设置mysql密码
RUN apt-get install -y mysql-client mysql-server \
    && /etc/init.d/mysql start \
    && mysqladmin -u root password "root"

# 安装php
RUN apt-get install -y php5 php5-mysql php5-dev php5-gd php5-memcache php5-pspell php5-snmp snmp php5-xmlrpc libapache2-mod-php5 php5-cli
# RUN yum install -y php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml


# 拷贝phpinfo.php 到docker镜像的/var/www/html/下
COPY src/phpinfo.php /var/www/html/
# 拷贝启动脚本start.sh 到docker镜像的根目录下
COPY src/start.sh /start.sh
# 增加启动脚本start.sh 所有用户和组的执行权限
RUN chmod a+x /start.sh

# 只开放了80 443端口的映射访问权限
EXPOSE 80 443
# 运行后默认执行start.sh启动脚本
CMD ["/start.sh"]