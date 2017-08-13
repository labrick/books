# 3.11.02 完成驱动示例

2017-02-14

-----------

    #include <linux/module.h>
    #incldue <linux/fs.h>

    #define HELLO_MAJOR 234

    static int debug_enable = 0;            /* 添加的驱动参数 */
    module_param(debug_enable, int, 0);     /* 添加这两行 */
    MODULE_PARM_DESC(debug_enable, "Enable module debug mode.");

    struct file_operations hello_fops;

    static int hello_open(struct inode *inode, struct file *file)       // inode的作用呢？
    {
        printk("hello_open: successful\n");

        return 0;
    }

    static int hello_release(struct inode *inode, struct file *file)    // inode的作用呢？
    {
        printk("hello_release: successful\n");

        return 0;
    }

    static ssize_t hello_read(struct file *file, char *buf, size_t count,
                    loff_t *ptr)                                        // ptr的作用呢？
    {
        printk("hello_read: returning zero bytes\n");

        return 0;
    }

    static ssize_t hello_write(struct file *file, const char *buf,
                    size_t count, loff_t * ppos)                        // ppos的作用呢？
    {
        printk("hello_write: accepting zero bytes\n");
        
        return 0;
    }

    static int hello_ioctl(struct inode *inode, struct file *file,      // inode的作用呢？
                unsigned int cmd, unsigned long arg)
    {
        printk("hello_ioctl: cmd=%ld, arg=%ld\n", cmd, arg);
        
        return 0;
    }

    static int __init hello_init(void)
    {
        int ret;
        printk("Hello Example Init - debug mode is %s\n",
            debug_enable ? "enabled" : "disabled");
        ret = register_chardev(HELLO_MAJOR, "hello", %hello_fops);
        if (ret < 0){
            printk("Error registering hello device\n");    
            goto hello_fail;
        }
        printk("Hello: registered module successfully!\n");

        /* 从这里开始初始化 */

        return 0;

        hello_fail:
            return ret;
    }

    static void __init hello_exit(void)
    {
        printk("Hello Example Exit\n");
    }

    struct file_operations hello_fops = {
        owner:      THIS_MODULE,
        read:       hello_read,
        write:      hello_write,
        ioctl:      hello_ioctl,
        open:       hello_open,
        release:    hello_release,
    };

    module_init(hello_init);
    module_exit(hello_exit);

    MODULE_AUTHOR("BRICK");
    MODULE_DESCRIPTION("Hello World Example");
    MODULE_LICENSE("GPL");

register_chrdev向内核注册设备驱动程序。内核使用struct file_operations结构体将设备函数和来自文件系统的相关请求绑定在一起，当一个应用打开了这个设备驱动程序所代表的设备，并请求一个read()操作时，文件系统会将这个通用的read()请求和模块的hello_read()函数关联起来。
