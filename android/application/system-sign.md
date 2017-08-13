# 获得系统签名

2017-01-10

-------------------

获得系统签名有三种方法：

1. 放入Android源码编译，生成的系统镜像中集成的该应用即具有系统签名。
2. 采用signapk.jar对应用直接签名，这也是[1]的本质。
3. 采用[keytool-importkeypair工具](https://github.com/getfatday/keytool-importkeypair)产生jks签名文件，给Android Studio或者Eclipse直接使用，使得每次编译出的应用直接就具有系统签名。

