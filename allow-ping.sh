#!/bin/sh
#
# A quick script to implement an iptables firewall on your Linux
# server or desktop machine. This script provides for a locked 
# down secured server with the ability to ping only from one host 
# 
# What we want to achieve on a two NIC (Ethernet interface) machine
# is to allow pinging by a host range on the private network and only 
# from one host on the public
# 
# PUBLIC -> IP 192.168.x.x = only one host can ping
# PRIVATE -> IP 10.0.2.x = all hosts or a range of hosts can ping
# 
# Author: EJK
# Website: www.eamonnkillian.com
# License: MIT
# 
# Copyright (c) 2015 Eamonn Killian, www.eamonnkillian.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to use, 
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
# Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#
# Flush the tables from their starting position and 
# set out policies to explicitly deny anything. Your
# server is now in total lockdown mode.
#

echo "------------------------------------------------------------------------------"
echo " "

iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
echo "STEP 1: Total Lockdown Achieved"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

# 
# Now we'll add the loopback interface
#

iptables -A INPUT --in-interface lo -j ACCEPT
iptables -A OUTPUT --out-interface lo -j ACCEPT
echo "STEP 2: Loopback interface access enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PUBLIC INTERFACE
#
# Now we'll add a ping allowed from a specific hosts
# IP address on the eth1 interface only and from just
# one IP address. You can open this up to all or a group 
# of IP addresses being able to ping if you need to.
#
# All IPs make ALLOWED = 0.0.0.0/0
# Range then define --src-range 192.168.0.0-192.169.0.0
#

ALLOWED="ipt-clt1-pub"

iptables -A INPUT --in-interface eth0 -p icmp --icmp-type echo-request -s $ALLOWED -j ACCEPT
iptables -A OUTPUT --out-interface eth0 -p icmp --icmp-type echo-reply -j ACCEPT
echo "STEP 3: Public interface INBOUND PING enabled for one host."
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PRIVATE INTERFACE
#
#
# Now we'll add a ping allowed from a range of hosts
# on our private interface to emulate the back office 
# or internal datacenter traffic.
#
# All IPs make ALLOWED = 0.0.0.0/0
# Range then define --src-range 192.168.0.0-192.169.0.0
#

iptables -A INPUT --in-interface eth1 -p icmp --icmp-type echo-request -m iprange --src-range 10.0.2.15-10.0.2.17 -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p icmp --icmp-type echo-reply -j ACCEPT
echo "STEP 4: Private interface INBOUND PING enabled."
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PUBLIC & PRIVATE INTERFACE
#
# Now this piece enables the use of ping by our server
# so OUTBOUND pinging of hosts from our server.
#

iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
echo "STEP 5: Public & Private interfaces OUTBOUND PING enabled."

#
#  SAVE & RESTART IPTABLES SERVICE
#

service iptables save
service iptables restart
