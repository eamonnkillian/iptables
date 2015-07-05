# iptables
This is a repository for iptables scripts to help with building up
progressively more "allowed" interaction with a Linux server in the
Cloud. The idea is that we have two base scripts:

-> BASE 1: Total Lockdown - this sets the policies for your machine to drop all inbound traffic to your server
-> BASE 2: Wide Open - this sets the policies to allow all traffic inbound to your server

Building from the BASE of Total Lockdown the scripts show how to add:

1) Pinging;
2) SSH/SFTP;
3) FTP;
4) DNS;
5) YUM (as its CentOS baseds);
6) HTTP;
7) HTTPS

The scripts also show you how you can differentiate between two NIC interfaces and set 
different rules depeding on your interface. This gives the idea of a Public and Private
set of interfaces.

