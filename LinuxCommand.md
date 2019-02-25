# Linux Commad

## 系统命令

```bash
shutdown -r now # 立即重启
sudo pacman-mirrors -f 5 && sudo pacman -Syyuu # 系统更新
systemctl disable <name> # 更改 systemd 相关内容
systemctl enable <name>
systemctl start <name>
systemctl status <name>
startx # 在 tty 窗口启动图形界面
export LANG=en_US.UTF-8 # 将终端语言临时设置为英语
more /var/log/pacman.log # 查看 pacman 的使用日志
sudo mhwd-kernel -i <kernel> (rmc) # 安装内核，如果增加 rmc 将替换当前内核
journalctl -b # 查看登录日志
inxi -Fx # 查看系统信息
```

## Frpc 或内网穿透

```bash
nohup frpc -c ./frpc.ini &
```

## SSH 相关

```bash
scp <filename> liubianshi@192.168.199.167 # 通过 ssh 在不同的电脑之间传递文件
ssh liubianshi@192.168.199.167 # 远程登录
ssh -oPort=6000 liubianshi@45.77.191.222 # 登录内网电脑
```
