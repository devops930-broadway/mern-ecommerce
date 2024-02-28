#!/usr/bin/expect -f
set timeout 120
set host [lindex $argv 0]
send_user "host: $host\n"
spawn ssh -o StrictHostKeyChecking=no ubuntu@$host "git clone https://github.com/devops930-broadway/mern-ecommerce.git;cd mern-ecommerce;git checkout hol/luminous; bash .github/scripts/install_gitlab.sh"
expect "ubuntu*\ password:"
send -- "changeme\r"
# sleep 5
# send -- "ls /\r"
# sleep 10
# send -- "exit\r"
expect eof
