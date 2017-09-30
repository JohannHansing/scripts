#!/bin/bash
# spawn ssh johannh@sheldon-ng
# expect "assword:"
# send "xlyfr729\r"
# interact


a1='eval spawn sshfs johannh@sheldon-ng:/home/johannh /Users/jh/Documents/Remote_PC/sheldon-ng; set prompt ":|#|\\\$"; interact -o -nobuffer -re $prompt return; send "'
a2='spawn ssh johannh@sheldon-ng; set prompt ":|#|\\\$"; interact -o -nobuffer -re $prompt return; send "'
pw=$1
b='\r"; interact'
string=$a1$pw$b

echo $string

/usr/bin/expect -c "$string"
#
# string=$a2$pw$b
# /usr/bin/expect -c "$string"

# spawn sshfs johannh@sheldon-ng:/home/johannh /Users/jh/Documents/Remote_PC/sheldon-ng
# expect "assword:"
# send "$1\r"
# interact
#
#
# spawn ssh johannh@sheldon-ng
# expect "assword:"
# send "$1\r"
# interact