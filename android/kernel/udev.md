# 3.14 udev系统

2017-02-28

------------

Linux系统中的设备管理一度很混乱，/dev目录中的很多文件都是无效的，它们对应的设备实际上并不存在，未解决这一问题，内核开发人员开发了devfs，它能够根据系统中实际存在的硬件动态创建/dev目录中的条目。不过，devfs也存在很多的缺陷，被udev所取代。

udev是最新和最优秀的设备管理子系统，它使用内核在发现设备时提供的信息动态创建/dev目录中的内容。它已经发展成为一个非常灵活和强大的方式，能够在系统检测到硬件设备时运用策略（加载设备驱动/创建设备节点/软连接设备节点名称/自定义其他行为等）。udev的默认行为是使用内核提供的设备名称创建一个同名的设备节点。

## 发现设备

当内核发现一个新的设备时，它会创建一个uevent事件，并通过**netlink套接字**将它发送到一个用户空间的侦听者udev。通过使用程序udevadm可以捕捉到uevent事件。

    # udevadm monitor --environment
    monitor will print the received events for:
    UDEV - the event which udev sends out after rule processing
    KERNEL - the kernel uevent

    UDEV  [547482.722156] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0006/hidraw/hidraw0 (hidraw)
    ACTION=add
    DEVNAME=/dev/hidraw0
    DEVPATH=/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0006/hidraw/hidraw0
    ID_BUS=usb
    ID_MODEL=USB_Optical_Mouse
    ID_MODEL_ENC=USB\x20Optical\x20Mouse
    ID_MODEL_ID=0061
    ID_REVISION=0100
    ID_SERIAL=PixArt_USB_Optical_Mouse
    ID_TYPE=hid
    ID_USB_DRIVER=usbhid
    ID_USB_INTERFACES=:030102:
    ID_USB_INTERFACE_NUM=00
    ID_VENDOR=PixArt
    ID_VENDOR_ENC=PixArt
    ID_VENDOR_ID=04ca
    MAJOR=251
    MINOR=0
    SEQNUM=2489
    SUBSYSTEM=hidraw
    USEC_INITIALIZED=81267772

    ...........

uevent第一行的add表示这是个”添加操作“，意味着内核检测到一个新的USB设备，它的内核名称是`/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0006/hidraw/hidraw0`。

当内核检测到一个新设备时，它采取的默认操作之一是在sysfs文件系统（通常挂载于/sys目录）中创建一个条目。DEVPATH属性代表它在/sys目录中的位置，udev规则和工具的很多地方都引用了这个属性。

其他属性描述了设备类型、设备、产品（厂商ID和/或设备ID）和设备在USB总线物理拓扑结构中的位置。DEVICE属性描述了内核中的设备节点信息。

每个uevent都有一个序列号，内核每发送一个uevent，序列号就递1。MAJOR/MINOR则是设备驱动程序的主次设备号(251/0)。

当udev接收到uevent时，它会扫描其规则数据库。udev将使用设备的属性在数据库中查找匹配的条目，这些条目规定了他要执行的动作。如果找不到任何匹配的规则，**udev的默认动作只是创建一个设备节点，其名称由内核提供，主次设备号由uevent指定。**udev创建的设备节点：

    crw------- 1 root root 251, 0  2月 27 21:52 hidraw0

系统设计人员或发行版维护人员可以定制udev的规则，从而让它执行适合具体应用的操作。在大多数情况下，默认规则是在/dev目录中创建合适的设备节点。除此之外，它们一般还会生成符号链接指向这些新创建的设备节点。符号链接的名称可能是一个大家熟知的简短名称，应用程序使用它来访问设备。

## udev的默认行为

简单插入一个设备时，内核会会发送很多个uevent，简化uevent事件列表：

    # udevadm monitor --kernel
    monitor will print the received events for:
    KERNEL - the kernel uevent

    KERNEL[547584.214196] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4 (usb)
    KERNEL[547584.214587] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0 (usb)
    KERNEL[547584.217625] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007 (hid)
    KERNEL[547584.217721] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/input/input18 (input)
    KERNEL[547584.217763] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/input/input18/event2 (input)
    KERNEL[547584.217789] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/hidraw/hidraw0 (hidraw)
    KERNEL[547584.504348] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4 (usb)
    KERNEL[547584.504682] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0 (usb)
    KERNEL[547584.506210] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008 (hid)
    KERNEL[547584.506253] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19 (input)
    KERNEL[547584.506311] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19/mouse0 (input)
    KERNEL[547584.506335] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19/event3 (input)
    KERNEL[547584.506395] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/hidraw/hidraw1 (hidraw)

## udev规则

udev真正的的强大功能来自于它的规则引擎。系统设计人员和发行版维护人员可以使用udev的规则来组织/dev目录中的层次结构、创建设备节点、以及为这些设备节点分配易于使用的名称。通常情况下，udev会用内核提供的名称创建设备节点，并用一个易于使用的名称创建相应的符号链接，从而将这两个名称关联起来。

udev的规则引擎还可用于加载设备驱动程序（模块）。实际上，通过使用udev规则，在系统检测到设备插入或拔出时执行几乎任何你能想出的操作。然而，udev规则最常用于设备的重命名（创建具有易读名称的符号链接）和设备驱动程序的加载。

在最新的udev版本中，udev规则（文件）的默认存放位置是目录/lib/udev/rules.d，而很多发行版都将udev规则存放在目录/etc/udev/rules.d中，但如果这两个目录中有同名的规则文件，**以后一个目录中的规则文件为准。**这样可以采用/etc/udev/rules.d来覆盖/lib/udev/rules.d。

当udev第一次启动时，它会读取/lib/udev/rules.d中的所有规则，并创建一个内部的规则表，**当内核发现一个设备，udev使用内核uevent中的动作和属性在规则表中查找匹配项，当找到匹配项时，udev就会执行那条规则（或一组规则）规定的动作。**

规则举例（鼠标设备）：

    DRIVER!="?*", ENV{MODALIAS}=="?*", RUN{ignore_error}+="/sbin/modprobe -b $env{MODALIAS}"
    KERNEL=="mouse*|mice|event*", NAME="input/%k", MODE="0640"

上面规则放入随机命名的规则文件（以.rules为后缀名）中，并将其放到目录/etc/udev/rules.d中。

第一条规则用于加载设备驱动程序。这条规则的匹配条件是没有设置内核uevent中的DRIVE属性（表示内核不知道或没有提供驱动的名称）。这条规则指示udev运行modprobe程序，并将环境变量MODALIAS（uevent中的一个变量，modprobe利用它来加载合适的设备驱动程序）的值传递给它。

加载了设备驱动程序之后，鼠标设备就可以被识别出来，而不仅仅是被当作一个普通的USB设备。驱动能够识别鼠标的功能并将其自身注册为鼠标设备。当这个驱动被加载时，**内核会产生另外一系列uevent，从而使udev开始处理其他规则。**

第二条规则的匹配条件是内核uevent中的设备名称是mouse*、mice或event*。当找到匹配项时，这条规则指示udev在一个名为input的子目录中创建设备节点。除非指定，udev假设/dev是设备节点的根目录。设备节点的名称就是内核设备的名称，这是由替换操作符%k（怎么对应的？？）指定的。设备节点的模式是0640，这意味这文件的拥有者可以读写该设备，同一组中的用户只能读，而其他用户则不能访问。

    # ls /dev/input/mouse0
    # cat /dev/input/mouse0

上述命令，移动鼠标应该就可以看到设备接收的控制字符。

    # ls /dev/input
    by-id  by-path  event0  event1  event10  event2  event3  event4  event5  event6  event7  event8  event9  mice  mouse0

event0设备代表第一个事件流，它是输入事件的高层描述。mice设备代表所有鼠标设备（mice是mouse的复述形式）的混合输入！mouse0设备则是底层鼠标设备本身。

## Modalias

当检测到一个设备，比如USB鼠标，内核会发出一系列uevent，宣告添加了这个设备。

    # udevadm monitor --kernel
    monitor will print the received events for:
    KERNEL - the kernel uevent

    KERNEL[547584.214196] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4 (usb)
    KERNEL[547584.214587] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0 (usb)
    KERNEL[547584.217625] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007 (hid)
    KERNEL[547584.217721] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/input/input18 (input)
    KERNEL[547584.217763] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/input/input18/event2 (input)
    KERNEL[547584.217789] add      /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/0003:413C:2107.0007/hidraw/hidraw0 (hidraw)
    KERNEL[547584.504348] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4 (usb)
    KERNEL[547584.504682] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0 (usb)
    KERNEL[547584.506210] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008 (hid)
    KERNEL[547584.506253] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19 (input)
    KERNEL[547584.506311] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19/mouse0 (input)
    KERNEL[547584.506335] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/input/input19/event3 (input)
    KERNEL[547584.506395] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0008/hidraw/hidraw1 (hidraw)

简单插入一个USB鼠标内核会发出一系列事件，它们是USB设备、接口和端点（我还没看懂|—_—|）
    # udevadm monitor --environment
    monitor will print the received events for:
    UDEV - the event which udev sends out after rule processing
    KERNEL - the kernel uevent

    UDEV  [547482.722256] add      /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0006/input/input17 (input)
    ACTION=add
    DEVPATH=/devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.4/1-1.4:1.0/0003:04CA:0061.0006/input/input17
    EV=17
    ID_BUS=usb
    ID_FOR_SEAT=input-pci-0000_00_1a_0-usb-0_1_4_1_0
    ID_INPUT=1
    ID_INPUT_MOUSE=1
    ID_MODEL=USB_Optical_Mouse
    ID_MODEL_ENC=USB\x20Optical\x20Mouse
    ID_MODEL_ID=0061
    ID_PATH=pci-0000:00:1a.0-usb-0:1.4:1.0
    ID_PATH_TAG=pci-0000_00_1a_0-usb-0_1_4_1_0
    ID_REVISION=0100
    ID_SERIAL=PixArt_USB_Optical_Mouse
    ID_TYPE=hid
    ID_USB_DRIVER=usbhid
    ID_USB_INTERFACES=:030102:
    ID_USB_INTERFACE_NUM=00
    ID_VENDOR=PixArt
    ID_VENDOR_ENC=PixArt
    ID_VENDOR_ID=04ca
    KEY=ff0000 0 0 0 0
    MODALIAS=input:b0003v04CAp0061e0111-e0,1,2,4,k110,111,112,113,114,115,116,117,r0,1,8,am4,lsfw
    MSC=10
    NAME="PixArt USB Optical Mouse"
    PHYS="usb-0000:00:1a.0-1.4/input0"
    PRODUCT=3/4ca/61/111
    PROP=0
    REL=103
    SEQNUM=2486
    SUBSYSTEM=input
    TAGS=:seat:
    UNIQ=""
    USEC_INITIALIZED=81267382

注意其中的MODALIAS字段，乍看起来像是乱码，实际上，这个字符串可以分解为多个单独的字段，它们是USB设备暴露给设备驱动程序的属性。

    b0004厂商ID
    v04CA产品ID

其他字段是与设备、设备类和子系统具体相关的，这些属性为驱动提供了设备的底层硬件细节。

    # modprobe input:b0003v04CAp0061e0111-e0,1,2,4,k110,111,112,113,114,115,116,117,r0,1,8,am4,lsfw

上面指令同样可以加载鼠标的驱动（包括依赖），和规则中一样。

执行modprobe时，它会查看位于目录/lib/modules/'uname -r'中的文件modula.alias。这个文件是由depmod生成的，depmod的作用是创建模块依赖关系的数据库。modprobe使用命令行中的参数在文件modules.alias中寻找匹配的行。如果找到匹配行，其中指定的模块就会被加载。

文件modules.alias中的modalias条目来自设备驱动程序本身，比如在modules.alias中有这句：

    alias input:b*v*p*e*-e*1,*k*r*a*m*l*s*f*w* mac_hid

同样在内核源码文件hid.mod.c中可以发现这行代码：

    MODULE_ALIAS("input:b*v*p*e*-e*1,*k*r*a*m*l*s*f*w*");

musb_hdrc.c中也有类似的：

    MODULE_ALIAS("platform:" MUSB_DRIVER_NAME);

当模块被编译和安装到系统中时，depmod工具会收集（**什么时候收集的呢？？？这些ko模块并没有安装到系统，指示放到了文件系统而已啊？？**）所有这些字符并将它们放到文件modules.alias中，以供modprobe引用。

## 典型的udev规则配置

先看下ubuntu的规则文件：

    $ ls -l /etc/udev/rules.d/
    total 768
    -rw-r--r-- 1 root root    552 Jan  5  2016 39-usbmuxd.rules
    -rw-r--r-- 1 root root     69 Nov 18  2014 40-crda.rules
    -rw-r--r-- 1 root root  96634 Sep 18  2015 40-libsane.rules
    -rw-r--r-- 1 root root    998 Oct  8  2014 40-usb-media-players.rules
    -rw-r--r-- 1 root root  35692 Nov  2  2015 40-usb_modeswitch.rules
    -rw-r--r-- 1 root root    613 Nov 25 20:57 40-vm-hotadd.rules
    -rw-r--r-- 1 root root    165 Mar 31  2016 50-apport.rules
    -rw-r--r-- 1 root root    113 Mar  1  2016 50-bluetooth-hci-auto-poweron.rules
    -rw-r--r-- 1 root root    210 Nov 24 19:41 50-firmware.rules
    -rw-r--r-- 1 root root   3310 Nov 25 20:57 50-udev-default.rules
    -rw-r--r-- 1 root root   6497 Apr 16  2016 55-dm.rules
    -rw-r--r-- 1 root root    606 Nov 25 20:57 60-block.rules
    -rw-r--r-- 1 root root    910 Nov 25 20:57 60-cdrom_id.rules
    -rw-r--r-- 1 root root    153 Nov 25 20:57 60-drm.rules
    -rw-r--r-- 1 root root    738 Nov 25 20:57 60-evdev.rules
    -rw-r--r-- 1 root root    583 May  5  2015 60-gnupg2.rules
    -rw-r--r-- 1 root root   3368 Dec 22  2015 60-gnupg.rules
    -rw-r--r-- 1 root root    329 Jan  9  2016 60-inputattach.rules
    -rw-r--r-- 1 root root   6107 Dec 11  2015 60-libgphoto2-6.rules
    -rw-r--r-- 1 root root    912 Jun 29  2012 60-pcmcia.rules
    -rw-r--r-- 1 root root    616 Nov 25 20:57 60-persistent-alsa.rules
    -rw-r--r-- 1 root root   2464 Nov 25 20:57 60-persistent-input.rules
    -rw-r--r-- 1 root root   1495 Apr 16  2016 60-persistent-storage-dm.rules
    -rw-r--r-- 1 root root   5766 Nov 25 20:57 60-persistent-storage.rules
    -rw-r--r-- 1 root root   1420 Nov 25 20:57 60-persistent-storage-tape.rules
    -rw-r--r-- 1 root root    769 Nov 25 20:57 60-persistent-v4l.rules
    -rw-r--r-- 1 root root   1190 Nov 25 20:57 60-serial.rules
    -rw-r--r-- 1 root root     75 Jun 29  2016 60-virtualbox-dkms.rules
    -rw-r--r-- 1 root root    454 Jun 29  2016 60-virtualbox.rules
    -rw-r--r-- 1 root root    472 Aug 20  2016 60-xdiagnose.rules
    -rw-r--r-- 1 root root    328 Jan 24  2016 61-gnome-bluetooth-rfkill.rules
    -rw-r--r-- 1 root root    456 Nov 25 20:57 61-persistent-storage-android.rules
    -rw-r--r-- 1 root root    418 Nov 25 20:57 64-btrfs.rules
    -rw-r--r-- 1 root root    257 Nov  3 06:12 64-xorg-xkb.rules
    -rw-r--r-- 1 root root    606 Mar  3  2016 66-xorg-synaptics-quirks.rules
    -rw-r--r-- 1 root root   5219 Nov  7  2015 69-cd-sensors.rules
    -rw-r--r-- 1 root root 165557 Jan 26  2016 69-libmtp.rules
    -rw-r--r-- 1 root root   1142 Mar  3  2016 69-wacom.rules
    -rw-r--r-- 1 root root    170 Mar  3  2016 69-xorg-vmmouse.rules
    -rw-r--r-- 1 root root   1430 Mar 31  2016 70-android-tools-adb.rules
    -rw-r--r-- 1 root root    235 Mar 31  2016 70-android-tools-fastboot.rules
    -rw-r--r-- 1 root root    231 Nov 24 19:41 70-debian-uaccess.rules
    -rw-r--r-- 1 root root    734 Nov 25 20:57 70-mouse.rules
    -rw-r--r-- 1 root root    942 Nov 25 20:57 70-power-switch.rules
    -rw-r--r-- 1 root root    462 Mar  8  2016 70-printers.rules
    -rw-r--r-- 1 root root   2591 Nov 25 20:57 70-uaccess.rules
    -rw-r--r-- 1 root root    461 Nov 25 20:57 71-power-switch-proliant.rules
    -rw-r--r-- 1 root root   2710 Nov 25 20:57 71-seat.rules
    -rw-r--r-- 1 root root    429 Aug 25  2016 71-u-d-c-gpu-detection.rules
    -rw-r--r-- 1 root root    596 Nov 25 20:57 73-seat-late.rules
    -rw-r--r-- 1 root root    746 Nov 24 19:41 73-special-net-names.rules
    -rw-r--r-- 1 root root    608 Nov 24 19:41 73-usb-net-by-mac.rules
    -rw-r--r-- 1 root root    452 Nov 25 20:57 75-net-description.rules
    -rw-r--r-- 1 root root    174 Nov 25 20:57 75-probe_mtd.rules
    -rw-r--r-- 1 root root    484 Nov  4  2015 77-mm-cinterion-port-types.rules
    -rw-r--r-- 1 root root   6910 Nov  4  2015 77-mm-ericsson-mbm.rules
    -rw-r--r-- 1 root root   1734 Nov  4  2015 77-mm-huawei-net-port-types.rules
    -rw-r--r-- 1 root root  13187 Nov  4  2015 77-mm-longcheer-port-types.rules
    -rw-r--r-- 1 root root   2479 Nov  4  2015 77-mm-mtk-port-types.rules
    -rw-r--r-- 1 root root   2024 Nov  4  2015 77-mm-nokia-port-types.rules
    -rw-r--r-- 1 root root    383 Nov  4  2015 77-mm-pcmcia-device-blacklist.rules
    -rw-r--r-- 1 root root    514 Nov  4  2015 77-mm-platform-serial-whitelist.rules
    -rw-r--r-- 1 root root   3155 Nov  4  2015 77-mm-qdl-device-blacklist.rules
    -rw-r--r-- 1 root root   1840 Nov  4  2015 77-mm-simtech-port-types.rules
    -rw-r--r-- 1 root root   2929 Nov  4  2015 77-mm-telit-port-types.rules
    -rw-r--r-- 1 root root   6705 Nov  4  2015 77-mm-usb-device-blacklist.rules
    -rw-r--r-- 1 root root   2452 Nov  4  2015 77-mm-usb-serial-adapters-greylist.rules
    -rw-r--r-- 1 root root   3666 Nov  4  2015 77-mm-x22x-port-types.rules
    -rw-r--r-- 1 root root  14421 Nov  4  2015 77-mm-zte-port-types.rules
    -rw-r--r-- 1 root root    965 Nov 25 20:57 78-graphics-card.rules
    -rw-r--r-- 1 root root   4505 Nov 25 20:57 78-sound-card.rules
    -rw-r--r-- 1 root root   1375 Nov 24 19:41 80-debian-compat.rules
    -rw-r--r-- 1 root root    618 Nov 25 20:57 80-drivers.rules
    -rw-r--r-- 1 root root    190 Dec  1 01:15 80-ifupdown.rules
    -rw-r--r-- 1 root root    796 Nov  4  2015 80-mm-candidate.rules
    -rw-r--r-- 1 root root    292 Nov 25 20:57 80-net-setup-link.rules
    -rw-r--r-- 1 root root   8179 Apr  2  2016 80-udisks2.rules
    -rw-r--r-- 1 root root  10155 Mar 11  2014 80-udisks.rules
    -rw-r--r-- 1 root root    523 Sep 27 23:09 84-nm-drivers.rules
    -rw-r--r-- 1 root root  10560 Apr 28  2016 85-brltty.rules
    -rw-r--r-- 1 root root     82 Mar 17  2016 85-hdparm.rules
    -rw-r--r-- 1 root root   1872 Apr  7  2016 85-hplj10xx.rules
    -rw-r--r-- 1 root root    396 Apr  5  2016 85-keyboard-configuration.rules
    -rw-r--r-- 1 root root   1682 Sep 27 23:09 85-nm-unmanaged.rules
    -rw-r--r-- 1 root root    221 Nov 18  2014 85-regulatory.rules
    -rw-r--r-- 1 root root    489 Apr 15  2016 90-alsa-restore.rules
    -rw-r--r-- 1 root root   1632 Aug 17  2016 90-fwupd-devices.rules
    -rw-r--r-- 1 root root   1850 Apr 13  2016 90-libgpod.rules
    -rw-r--r-- 1 root root   6640 Nov  4 02:24 90-pulseaudio.rules
    -rw-r--r-- 1 root root    703 Nov  6  2015 92-libccid.rules
    -rw-r--r-- 1 root root    847 Nov  7  2015 95-cd-devices.rules
    -rw-r--r-- 1 root root   1972 Nov 10 18:48 95-kpartx.rules
    -rw-r--r-- 1 root root   2496 Jun 15  2016 95-upower-csr.rules
    -rw-r--r-- 1 root root   8109 Jun 15  2016 95-upower-hid.rules
    -rw-r--r-- 1 root root    354 Jun 15  2016 95-upower-wup.rules
    -rw-r--r-- 1 root root   1518 Mar  1  2016 97-hid2hci.rules
    -rw-r--r-- 1 root root   3866 Nov 25 20:57 99-systemd.rules

注意这些规则文件的分组。它们的命名方式类似与system V风格的init脚本，文件名中的数字确定了文件的读取顺序。

具体可以参考Daniel Drake撰写的文档：[编写udev规则]()。

注意：**udev是事件驱动的，除非有事件发生，否则udev什么都不会做。而且虽然udev会使用inotify检测它的规则目录，并在修改规则文件后重新扫描规则，但是直到某个使用此规则文件的设备被移除或重新安装时，udev才会采取动作并允许对规则的修改生效（不过可以手动触发生效：`udevadm trigger`）。**

## udev的初始系统设置

udev是一个用户空间进程，因此，在内核启动完毕并挂载了根文件系统之前它不能运行，实际上是在init进程之后。如果udev负责创建系统中的设备节点，那么就必需确保init进程和它的子进程能够在udev运行之前访问一些必要的设备，这通常包括控制台设备、输入/输出设备(stdin/stdout/stderr)和其他一些设备。

对于小型嵌入式系统来说，最简单也是最常用的方法是在/dev目录中事先创建几个静态的设备节点，然后将tmpfs文件系统挂载到/dev目录，之后再启动udev。

最少功能udev启动脚本：

    #!/bin/sh
    # Simplified udev init script
    # Assumes we've already mounted our virtual file systems, i.e. /proc, /sys, etc.
    
    # mount /dev as a tmpfs
    mount -n -t tmpfs -o mode=0755 udev /dev
    
    # copy default static devices, which were duplicated here
    cp -a -f /lib/udev/devices/* /dev
    
    #udev does all the work of hotplug now
    if [ -e /proc/sys/kernel/hotplug ]; then
        echo "" > /proc/sys/kernel/hotplug
    fi
    
    # Now start the udev daemon
    /sbin/udevd --daemon
    
    # Process devices already created by the kernel during boot
    /sbin/udevadm trigger
    
    # Wait until initial udevd processing (from the trigger event)
    # has completed
    /sbin/udevadm settle

其中`echo "" > /proc /sys/kernel/hotplug`是确认没有指定任何hotplug代理程序，内核会将uevent发送给它指定的用户空间代理程序(对代理程序的理解还不清楚？？？)，udev通过netlink套接字接收这些消息，所以将文件`/proc/sys/kernel/hotplug`的内容清空。

`/sbin/udevadm trigger`是因为udev是在init运行一段时间之后才运行的，因此会有很多个设备没有得到udev的处理，所以这里要进行udev的触发操作。命令的意思是：回收内核的uevent事件，并按照正常方式处理/sys中的所有条目。

## 定制udev的行为

udev允许自己定义某些行为，比如当一个USB存储设备被插入嵌入式Linux设备时，可以启动软件的升级程序：

    ACTION="add", KERNEL=="sd[a-d][0-9]", RUN+="/bin/myloader"

bin/myloader是自己写的程序，udev会传递给它一份与此相关的环境参数。接着，myloader可以炎症刚刚安装的USB设备中的内容并开始执行必要的操作。这是嵌入式Linux设备中实现自动安装新软件镜像的方法。

如果采用这种方法，比较明智的做法是在程序中派生出一个新的进程，然后与udev父进程分离，从而让父进程完成工作并返回。如果udev现在或将来决定终止那些占用太多时间的子进程，这样做可以避免产生一些不愉快的意外结果。另外需要注意的是：**自己的程序只继承udev提供的必需的执行环境，可能无法满足需求，不过可以创建自己的环境，从而让处理函数程序能够顺利完成任务。**

## udev定制示例：USB自动挂载

USB自动挂载规则：

    # Handle all usb storage devices from sda<n> to sdd<n>
    ACTION="add", KERNEL=="sd[a-d][0-9]", SYMLINK+="usbdisk%n", NAME="%k"
    ACTION="add", KERNEL=="sd[a-d][0-9]", RUN+="/bin/mkdir -p /media/usbdisk%n"
    ACTION="add", KERNEL=="sd[a-d][0-9]", RUN+="/bin/mount /dev/%k /media/usbdisk%n"
    ACTION="remove", KERNEL=="sd[a-d][0-9]", RUN+="/bin/umount /dev/%k /media/usbdisk%n"
    ACTION="add", KERNEL=="sd[a-d][0-9]", RUN+="/bin/rmdir /media/usbdisk%n"

上述规则可以放在/lib/udev/rules/99-usb-automount.rules中。

## 持久的设备命名

udev默认实现了持久的设备名称，它使用了最初由Hannes Reinecke提出的方案。与持久命名相关的规则都位于文件名包含“persistent”的规则文件中。

    # ls /dev/input
    by-id  by-path  event0  event1  event10  event2  event3  event4  event5  event6  event7  event8  event9  mice  mouse0
    # ls -l /dev/input/by-id
    total 0
    drwxr-xr-x 2 root root 240  2月 21 21:46 ./
    drwxr-xr-x 5 root root 100  2月 21 21:46 ../
    lrwxrwxrwx 1 root root   9  2月 21 13:46 ata-ST1000DM003-1ER162_W4Y3YJAX -> ../../sdb
    lrwxrwxrwx 1 root root  10  2月 21 13:46 ata-ST1000DM003-1ER162_W4Y3YJAX-part1 -> ../../sdb1
    lrwxrwxrwx 1 root root  10  2月 21 13:46 ata-ST1000DM003-1ER162_W4Y3YJAX-part2 -> ../../sdb2
    lrwxrwxrwx 1 root root  10  2月 21 13:46 ata-ST1000DM003-1ER162_W4Y3YJAX-part5 -> ../../sdb5
    lrwxrwxrwx 1 root root   9  2月 21 13:46 ata-ST3000DM001-1ER166_W502S85F -> ../../sda
    lrwxrwxrwx 1 root root   9  2月 21 13:46 wwn-0x5000c5008a27a42e -> ../../sdb
    lrwxrwxrwx 1 root root  10  2月 21 13:46 wwn-0x5000c5008a27a42e-part1 -> ../../sdb1
    lrwxrwxrwx 1 root root  10  2月 21 13:46 wwn-0x5000c5008a27a42e-part2 -> ../../sdb2
    lrwxrwxrwx 1 root root  10  2月 21 13:46 wwn-0x5000c5008a27a42e-part5 -> ../../sdb5
    lrwxrwxrwx 1 root root   9  2月 21 13:46 wwn-0x5000c5009b0fe191 -> ../../sda

还不太懂............

## udev辅助工具

从`udevadm monitor --environment`的结果可以看到，内核发出的uevent事件中包含了大量的ID_*属性值，这些可以通过udev辅助工具直接读取或者查询/sys中的data属性得到。这组辅助工具（scsi_id/cdrom_id/path_id/volume_id等）位于udev源码树的extras目录中。

规则：

    KERNEL=="sd*[!0-9]|sr", ENV{ID_SERIAL}!="?*", SUBSYSTEMS=="usb", IMPORT{program}=="usb_id --export %p"

执行usb_id程序，并将它在stdout中的输出信息作为环境变量。%p是udev的一个字符串替换操作符，代表DEVPATH(/sys中的设备路径)。

ubuntu中没找到usb_id。。。。。。。。。。。。。。。

获得设备信息命令：

    # udevadm info --query=env --name=/dev/sdb1
    DEVLINKS=/dev/disk/by-id/ata-ST1000DM003-1ER162_W4Y3YJAX-part1 /dev/disk/by-id/wwn-0x5000c5008a27a42e-part1 /dev/disk/by-uuid/0f7cbbd6-d26d-469a-aa67-ff121333a160
    DEVNAME=/dev/sdb1
    DEVPATH=/devices/pci0000:00/0000:00:1f.5/ata4/host3/target3:0:0/3:0:0:0/block/sdb/sdb1
    DEVTYPE=partition
    ID_ATA=1
    ID_ATA_DOWNLOAD_MICROCODE=1
    ID_ATA_FEATURE_SET_APM=1
    ID_ATA_FEATURE_SET_APM_CURRENT_VALUE=254
    ID_ATA_FEATURE_SET_APM_ENABLED=1
    ID_ATA_FEATURE_SET_HPA=1
    ID_ATA_FEATURE_SET_HPA_ENABLED=1
    ID_ATA_FEATURE_SET_PM=1
    ID_ATA_FEATURE_SET_PM_ENABLED=1
    ID_ATA_FEATURE_SET_PUIS=1
    ID_ATA_FEATURE_SET_PUIS_ENABLED=0
    ID_ATA_FEATURE_SET_SECURITY=1
    ID_ATA_FEATURE_SET_SECURITY_ENABLED=0
    ID_ATA_FEATURE_SET_SECURITY_ENHANCED_ERASE_UNIT_MIN=98
    ID_ATA_FEATURE_SET_SECURITY_ERASE_UNIT_MIN=98
    ID_ATA_FEATURE_SET_SECURITY_FROZEN=1
    ID_ATA_FEATURE_SET_SMART=1
    ID_ATA_FEATURE_SET_SMART_ENABLED=1
    ID_ATA_ROTATION_RATE_RPM=7200
    ID_ATA_SATA=1
    ID_ATA_SATA_SIGNAL_RATE_GEN1=1
    ID_ATA_SATA_SIGNAL_RATE_GEN2=1
    ID_ATA_WRITE_CACHE=1
    ID_ATA_WRITE_CACHE_ENABLED=1
    ID_BUS=ata
    ID_FS_TYPE=ext4
    ID_FS_USAGE=filesystem
    ID_FS_UUID=0f7cbbd6-d26d-469a-aa67-ff121333a160
    ID_FS_UUID_ENC=0f7cbbd6-d26d-469a-aa67-ff121333a160
    ID_FS_VERSION=1.0
    ID_MODEL=ST1000DM003-1ER162
    ID_MODEL_ENC=ST1000DM003-1ER162\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
    ID_PART_ENTRY_DISK=8:16
    ID_PART_ENTRY_FLAGS=0x80
    ID_PART_ENTRY_NUMBER=1
    ID_PART_ENTRY_OFFSET=2048
    ID_PART_ENTRY_SCHEME=dos
    ID_PART_ENTRY_SIZE=1937006592
    ID_PART_ENTRY_TYPE=0x83
    ID_PART_TABLE_TYPE=dos
    ID_REVISION=CC46
    ID_SERIAL=ST1000DM003-1ER162_W4Y3YJAX
    ID_SERIAL_SHORT=W4Y3YJAX
    ID_TYPE=disk
    ID_WWN=0x5000c5008a27a42e
    ID_WWN_WITH_EXTENSION=0x5000c5008a27a42e
    MAJOR=8
    MINOR=17
    SUBSYSTEM=block
    UDISKS_PARTITION=1
    UDISKS_PARTITION_ALIGNMENT_OFFSET=0
    UDISKS_PARTITION_FLAGS=boot
    UDISKS_PARTITION_NUMBER=1
    UDISKS_PARTITION_OFFSET=1048576
    UDISKS_PARTITION_SCHEME=mbr
    UDISKS_PARTITION_SIZE=991747375104
    UDISKS_PARTITION_SLAVE=/sys/devices/pci0000:00/0000:00:1f.5/ata4/host3/target3:0:0/3:0:0:0/block/sdb
    UDISKS_PARTITION_TYPE=0x83
    UDISKS_PRESENTATION_NOPOLICY=0
    USEC_INITIALIZED=43170

## udev和busybox配合使用的注意点

注意执行modprobe命令时使用-b标志，这个标志用于检测模块黑名单（？？）。目前，这和busybox中的modprobe不兼容。如果不对modprobe做修改，任何驱动都不会被加载，但这个错误不容易被发现，因为udev守护进程在执行时会接收它打印到stdout和stderr中的消息，因此错误消息不会显示在控制台上。

解决这个问题的方法就是使modprobe的真实版本(module-init-tools软件包)。

另外busybox实现了自己的udev，叫mdev，同样需要内核支持sysfs和热插拔。不过mdev使用早期的热插拔机制来接收内核uevent，需要开启/proc文件系统中热插拔代理的名称为其自身`/bin/mdev`。
