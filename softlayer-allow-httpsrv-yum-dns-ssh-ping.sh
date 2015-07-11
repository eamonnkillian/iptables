#!/bin/sh
#
# A quick script to implement an iptables firewall on your Linux server (virrtual
# machine) or bare metal server. This script provides for a locked down secured 
# server on the Cloud. Specifically this script provides for:
#
# Public interface:
#
# - Ping possible from one named host only;
# - SSH possbile from one host only;
# - HTTP outbound to any host;
# - HTTP web serving from this machine;
# 
# Private Interface:
# 
# - Ping possible from any host on private network 10.0.0.0
# - SSH possible from any host on private network 10.0.0.0
# - DNS resolution 
# - Yum updating
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
# INCLUDING BUT NOT LIMITED TO: THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
# IP address on the public interface only and from just
# one IP address. You can open this up to all or a group
# of IP addresses being able to ping if you need to.
#
# All IPs make ALLOWED = 0.0.0.0/0
# Range then define --src-range 192.168.0.0-192.169.0.0
#

ALLOWED="<Enter yours>"

iptables -A INPUT --in-interface eth1 -p icmp --icmp-type echo-request -s $ALLOWED -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p icmp --icmp-type echo-reply -j ACCEPT
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

iptables -A INPUT --in-interface eth0 -p icmp --icmp-type echo-request -s 10.0.0.0/0 -j ACCEPT
iptables -A OUTPUT --out-interface eth0 -p icmp --icmp-type echo-reply -j ACCEPT
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
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PUBLIC INTERFACE
#
# Now this portion of our script adds ssh on our Public interface 
# for one specified host.
# 

iptables -A INPUT --in-interface eth1 -p tcp --dport 22 -s $ALLOWED -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p tcp --sport 22 -d $ALLOWED -j ACCEPT
echo "STEP 6: Public SSH access for $ALLOWED enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PRIVATE INTERFACE
#
# And finally we will add ssh access for a range of specified 
# hosts on our Private interface.
#

iptables -A INPUT --in-interface eth0 -p tcp --dport 22 -s 10.0.0.0/0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 10.0.0.0/0 -j ACCEPT
echo "STEP 7: Private SSH access for 10.0.0.0/0 enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PRIVATE INTERFACE
#
# Now we will add the outbound DNS traffic to be able to name resolve
# with the outside world.
#

iptables -A OUTPUT --out-interface eth0 -p udp --dport 53 -j ACCEPT
iptables -A INPUT --in-interface eth0 -p udp --sport 53 -j ACCEPT

echo "STEP 8: Private DNS resolution access enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PRIVATE INTERFACE
#
# Now we will enable YUM to work by enabling inbound http requests
# to facilitate Yum downloading.
#

iptables -A INPUT --in-interface eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT --in-interface eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT --out-interface eth0 -p tcp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

echo "STEP 9: Private INBOUND HTTP access enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PRIVATE INTERFACE
#
# Now we need to be able to web browse from this server!
#

iptables -A OUTPUT --out-interface eth1 -p tcp --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT --in-interface eth1 -p tcp --sport 443 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT --in-interface eth1 -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "STEP 10: Private OUTBOUND HTTPS access enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#
# PUBLIC INTERFACE
#
# And finally we need to be able to be a web server from this server!
#

iptables -A INPUT --in-interface eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT --in-interface eth1 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT --out-interface eth1 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

echo "STEP 11: Public HTTP/HTTPS server enabled"
echo " "
echo "------------------------------------------------------------------------------"
echo " "

#iptables -A INPUT --in-interface eth0 -p tcp -j ACCEPT
#iptables -A OUTPUT --out-interface eth0 -p tcp -j ACCEPT


#
#  SAVE & RESTART IPTABLES SERVICE
#

service iptables save
service iptables restart
