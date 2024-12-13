wget https://github.com/firecracker-microvm/firecracker/releases/download/v1.10.1/firecracker-v1.10.1-x86_64.tgz
tar -xzf firecracker-v1.10.1-x86_64.tgz
sudo mv release-v1.10.1-x86_64/firecracker-v1.10.1-x86_64 /usr/local/bin/firecracker
sudo chmod +x /usr/local/bin/firecracker
