# iptables
This is a repository for iptables scripts to help with building up</br>
progressively more "allowed" interaction with a Linux server in the</br>
Cloud. The idea is that we have two base scripts:</br>
</br>
-> BASE 1: Total Lockdown - this sets the policies for your machine to drop all inbound traffic to your server</br>
-> BASE 2: Wide Open - this sets the policies to allow all traffic inbound to your server</br>
</br>
Building from the BASE of Total Lockdown the scripts show how to add:</br>
</br>
1) Pinging;</br>
2) SSH/SFTP;</br>
3) FTP;</br>
4) DNS;</br>
5) YUM (as its CentOS baseds);</br>
6) HTTP;</br>
7) HTTPS</br>
</br>
The scripts also show you how you can differentiate between two NIC interfaces and set </br>
different rules depeding on your interface. This gives the idea of a Public and Private</br>
set of interfaces.</br>

