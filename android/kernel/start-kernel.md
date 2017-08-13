# Linux启动

2017-01-12

--------------

head.S包含的head-common.S中`b start_kernel`调用了.../init/main.c中的start_kernel，也就是将控制权交给了C语言。


