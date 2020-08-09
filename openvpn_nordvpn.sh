#!/bin/sh

# 参考文件：https://nordvpn.com/zh/tutorials/linux/openvpn/

sudo pacman -S openvpn networkmanager-openvpn
cd /etc/open/vpn
sudo wget https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip
sudo unzip ovpn.zip
sudo rm open.zip

cd /etc/openvpn/ovpn_tcp/
sudo openvpn jp124.nordvpn.com.tcp.ovpn


