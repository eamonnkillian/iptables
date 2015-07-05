#!/bin/sh
#
# A quick script to implement an iptables firewall on your Linux
# server or desktop machine. This script provides for a totally
# locked down secured server from a network traffic point of view. 
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
# Flush the current tables from their starting position 
#

iptables -F

#
# Set out our policies to explicitly deny anything inbound
# outbound or forwarded - basically a total lockdown!
#

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#
# Restart the iptables services
#

service iptables save
service iptables restart
