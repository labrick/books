# 3.11.04.02 MTD分区

2017-02-21

---------------

有很多种方法可以将MTD分区信息传递给Linux内核：

1. 解析Redboot分区表；
2. 在内核命令行中定义分区表；
3. 使用与具体板卡相关的驱动；
4. 使用TI AR7的分区支持；


    -> Device Drivers
        -> Memory Technology Device (MTD) support (MTD [=y])
            -> RedBoot partition table parsing (NEW) (MTD_REDBOOT_PARTS [=y])
            -> Command line partition table parsing (MTD_CMDLINE_PARTS [=y])
            -> TI AR7 partitioning support (MTD_AR7_PARTS [=y])

## Redboot分区表

一种定义和检查MTD分区的常用方法，源于以前的一个分区实现方式：Redboot分区。

暂时好像不怎么样，先不管了.......

## 内核命令行传递分区信息

内核命令行传递分区信息最直接的方法（不是最简单）就是手动设置分区信息。

内核命令行中定义一个分区时所使用的参数格式（来自内核源码文件.../drivers/mtd/cmdlinepart.c）

    mtdparts=<mtddef>[;<mtddef]
        <mtddef>  := <mtd-id>:<partdef>[,<partdef>]
        <partdef> := <size>[@offset][<name>][ro]
        <mtd-id>  := unique id used in mapping driver/device
        <size>    := standard linux memsize OR "-" to denote all remaining space
        <name>    := (NAME)

    格式为：
        mtdparts=mtd-id:<size1>@<offset1>(<name1>),<size2>@<offset2>(<name2>)

    比如：
        mtdparts=MainFlash:384K(Redboot),4K(config),128K(FIS),-(unused)

## 源码映射

如果要定义与具体板卡相关的闪存布局，可以使用针对这个板卡的映射驱动（.../drivers/mtd/maps）。

映射驱动是一个完备的内核模块，其中包含了对module_init()和module_exit()的调用，一般映射驱动比较小，只有几十行C代码。比如：.../drivers/mtd/maps/pq2fads.c中定义了飞思卡尔PQ2FADS评估板上的闪存设备：

    ...
    static struct mtd_partition pq2fads_partitions[] = {
        {
    #ifdef CONFIG_ADS8272
            .name       = "HRCW",
            .size       = 0x40000,
            .offset     = 0,
            .mask_flags = MTD_WRITEABLE,    /* 强制设为只读 */
        }, {
            .name       = "User FS",
            .size       = 0x5c0000,
            .offset     = 0x40000,
    #else
            .name       = "User FS",
            .size       = 0x600000,
            .offset     = 0,
    #endif
        }, {
            .name       = "uImage",
            .size       = 0x100000,
            .offset     = 0x600000,
            .mask_flags = MTD_WRITEABLE,    /* 强制设为只读 */

        }, {
            .name       = "bootloader",
            .size       = 0x40000,
            .offset     = 0x700000,
            .mask_flags = MTD_WRITEABLE,    /* 强制设为只读 */
        }, {
                
            .name       = "bootloader env",
            .size       = 0x40000,
            .offset     = 0x740000,
            .mask_flags = MTD_WRITEABLE,    /* 强制设为只读 */
        }
    };

    /* 这是个指针，指向MPC885ADS板卡的相关数据 */
    extern unsigned char __res[];

    static int __init init_pq2fads_mtd(void)
    {
        bd_t *bd = (bd_t *)__res;
        physmap_configure(bd->bi_flashstart, bd->bi_flashsize,
                        PA2FADS_BANK_WIDTH, NULL);

        physmap_set_partitions(pq2fads_partitions,
                        sizeof(pq2fads_partitions) /
                        sizeof(pq2fads_partitions[0]);

        return 0;
    }

    static void __exit cleanup_pq2fads_mtd(void)
    {    
    }

    module_init(init_pq2fads_mtd);
    module_exit(cleanup_pq2fads_mtd);
    ...

* 函数physmap_configure()向MTD子系统传递了一些闪芯片的信息，包括它的物理地址、大小、bank宽度以及一个访问它所需的特殊设置函数；
* 函数physmap_set_partitions()向MTD子系统传递了这个板卡所特有的分区信息，也就是数组pq2fads_partitions[]中定义的分区表。

## 与具体板卡相关初始化

正确的对闪存进行分区，除了映射驱动之外，还需要在具体板卡（平台）的设置函数中提供一些有关闪存芯片的底层定义(.../arch/arm/mach-xxxx/xxx-setup.c)，以使MTD闪存系统能够正常工作。

具体的先省略.......................
