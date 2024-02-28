#!/usr/bin/expect -f
set timeout 120
set host [lindex $argv 0]
send_user "host: $host\n"
spawn ssh -o StrictHostKeyChecking=no ubuntu@$host "git clone https://github.com/devops630-broadway/mern-ecommerce.git || true;cd mern-ecommerce;ls;cd ~/mern-ecommerce;git checkout production;bash .github/scripts/install_gitlab.sh"
expect "ubuntu*\ password:"
send -- "changeme\r"
# sleep 5
# send -- "ls /\r"
# sleep 10
# send -- "exit\r"
expect eof

