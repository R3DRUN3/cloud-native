# GETTING STARTED WITH FIRECRACKER



## Abstract  
[*Firecracker*]() is an open-source virtualization technology designed to create and manage microVMs, which are lightweight, minimalist virtual machines optimized for performance and security.  
Developed by Amazon Web Services, Firecracker is tailored for workloads like serverless applications and containerized environments, where rapid startup times and efficient resource usage are critical.  
MicroVMs are a specialized form of virtual machines that strip away unnecessary components, focusing solely on essentials to provide a secure and isolated environment while maintaining high performance.  
Firecracker achieves this through a minimal device model, a streamlined architecture, and integration with KVM, making it ideal for modern cloud-native workloads.  
This repository contains scripts and walktrough to spin up your first MicroVM (with a python webserver) with Firecracker!  

## Prerequisites
- [*Docker*](https://docs.docker.com/engine/install/ubuntu/)  
- [*Firectl*](https://github.com/firecracker-microvm/firectl)   
- [*KVM enabled*](https://ubuntu.com/blog/kvm-hyphervisor)  

This folder has been tested on Ubuntu 24.04 LTS.


## Instructions

### Download Firecracker Binary

Download a recent version of Firecracker:  
```console
sudo sh download_firecracker_bin.sh
```  

### Download a version of the Linux kernel
You need to have a version of the linux kernel, for example you can download this:  
```console
curl -fsSL -o hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
```  


### Configure Networking

Configure tap and iptables for the MicroVM:  
```console
sudo sh configure_tap.sh
```  






### Create Root FS

For this demo we are going to create our own rootfs, starting from the official Alpine docker image.  

Step 1: Prepare the Root Filesystem File

Create a 1 GB ext4 filesystem image:

```console
dd if=/dev/zero of=rootfs.ext4 bs=1M count=1024
mkfs.ext4 rootfs.ext4
```  


Mount the image:

```console
mkdir /tmp/my-rootfs
sudo mount rootfs.ext4 /tmp/my-rootfs
```  

Step 2: Populate the Root Filesystem

Start an Alpine Docker container and bind the mounted directory:

```console
sudo docker run -it --rm -v /tmp/my-rootfs:/my-rootfs alpine
```  


Inside the container, install necessary tools and set up OpenRC:

```console
apk update && apk add openrc util-linux curl haveged python3 py3-pip wget git && rc-update add haveged default
```

Change the root password (remember it if you want to login inside the MicroVM):  

```console
passwd
```  


Set up the init system:

```console
ln -s agetty /etc/init.d/agetty.ttyS0
echo ttyS0 > /etc/securetty
rc-update add agetty.ttyS0 default

rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
```  


Step 3: Configure Networking

Create the network configuration file:

```console
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 172.16.0.2
    netmask 255.255.255.252
    gateway 172.16.0.1
    dns-nameservers 8.8.8.8 8.8.4.4
EOF
```  


Link the networking service to boot:

```console
ln -s /etc/init.d/networking /etc/init.d/ifupdown
rc-update add networking boot
```  



Configure DNS:

```console
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
```  


python webserver:  
```console
cat <<EOF > /root/hello_server.py
import http.server
import socketserver

PORT = 8080

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write("Hello from your Firecracker VM! 🔥\n".encode("utf-8"))

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("Serving on port", PORT)
    httpd.serve_forever()
EOF
```  


start the python webserver on boot:  
```console
mkdir -p /var/runcat && cat <<EOF > /etc/init.d/webserver
#!/sbin/openrc-run
command="/usr/bin/python3 /root/hello_server.py"
command_background="yes"
pidfile="/var/run/webserver.pid"
EOF

chmod +x /etc/init.d/webserver
rc-update add webserver default
```  




Step 4: Copy Filesystem Contents

Copy essential directories to the rootfs:

```console
for d in bin etc lib root sbin usr var; do tar c "/$d" | tar x -C /my-rootfs; done
``` 


Create required empty directories:

```console
for dir in dev proc run sys; do mkdir /my-rootfs/${dir}; done
```

Step 5: Finalize the Root Filesystem

Exit the Docker container:

```console
exit
``` 


Unmount the root filesystem:

```console
sudo umount /tmp/my-rootfs
``` 


### Start your MicroVM

Now we have everything we need to start our MicroVM.  
For this we will use `firectl` (you need to download the release binary from github).  
Spin up the MicroVM:  
```console
  sudo ./firectl \
  --kernel=hello-vmlinux.bin \
  --root-drive=./rootfs.ext4 \
  --tap-device=tap0/02:FC:00:00:00:01
```  

Open a new terminal and run: 
```console
curl http://172.16.0.2:8080
```  

If everything went well you should see:  
```console
Hello from your Firecracker VM! 🔥
```  


The following video showcase the MicroVM spin up!  

https://github.com/user-attachments/assets/2fdc9016-bc2e-4408-aad9-9842af6e8635


