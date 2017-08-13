# 3.12.03 创建文件系统镜像

2017-02-16

--------

linux中允许我们在一个普通文件中创建一个文件系统镜像，然后使用Linux的回环设备来挂载这个文件，就像是挂载一个块设备。

## 创建文件系统

    # dd if=/dev/zero of=./new-fs-image bs=1K count=512
    512+0 records in
    512+0 records out
    524288 bytes (524 kB, 512 KiB) copied, 0.000660534 s, 794 MB/s

这里相当于创建了一个没有文件系统的存储介质（比如：U盘），只是它是以文件代替的存储介质，有自己的块的大小，有总的容量值。

## 创建文件系统镜像

    # mkfs.ext2 ./new-fs-image 
    mke2fs 1.42.13 (17-May-2015)
    Discarding device blocks: done                            
    Creating filesystem with 512 1k blocks and 64 inodes

    Allocating group tables: done                            
    Writing inode tables: done                            
    Writing superblocks and filesystem accounting information: done

## 挂载文件系统镜像

    $ mkdir tmp
    # mount -o loop ./new-fs-image ./tmp

**注意：使用dd命令和mkfs.ext2命令时要万分小心，因为这两个命令很容易搞崩溃文件系统。**

**另外一个需要注意的地方是：使用这种方法时，文件系统的大小在创建时就确定了而且不能改变。**

    $ du -sh ./somefile
    1.6M    .   
    # cp -r ./somefile ./tmp
    cp: error writing './somefile': No space left on device

    $ du -sh ./new-fs-image 
    512K    ../new-fs-image 
