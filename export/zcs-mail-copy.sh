#!/usr/bin/expect -f

# connect via scp

set from [lindex $argv 0]
set to [lindex $argv 1]
set pass [lindex $argv 2]

spawn scp -r $from $to
#######################
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send $pass\n
  }
}
interact