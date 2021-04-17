*! version 1.0.0
* 设置 Dropbox 和 Nutstore 的位置
program sys,
    version 14.0
    global S_USER: env USERNAME
    if "$S_USER" == ""  global S_USER: env USER
    if "$S_USER" == "liubianshi" {
        global Dropbox "C:/AirCloud/Dropbox"
        global NutStore "C:/Users/wei-l_000/Documents/NutStore"
    }
    else if "$S_USER"  == "Wei-l_000" {
        global Dropbox "C:/AirCloud/Dropbox"
        global NutStore "G:/NutStore"
    }
    else if "$S_USER" == "luowei" {
        global Dropbox "/Users/luowei/Dropbox"
        global NutStore "/Users/luowei/Nustore Files/NutStore"
    }
    adopath + "$Dropbox/Backup/ado/personal"
end
