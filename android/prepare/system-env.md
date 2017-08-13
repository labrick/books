# 系统开发环境搭建

2017-01-15

-----------------

## Java环境

Oracle Java 1.6

注意不要用OpenJDK. 这是个坑, 官方文档虽然有写, 但还是单独提一下(但是我们一直用的都是OpenJDK啊)。

安装:

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
    sudo apt-get install oracle-java6-installer
    sudo apt-get install oracle-java6-set-default
