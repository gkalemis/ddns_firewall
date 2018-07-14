# ddns_firewall
Open specific ports to specific Dynamic DNS IPs 

The system runs peer guardian linux, so the commands to start and stop the firewall are issued with pglcmd

host1 is the first host addresss
host2 is the second host address. If you do not want second host remove the according lines

Log files are kept with the name ddns.log

It is better to test it before you run it. 
Make sure that you have physical access to the machine or create a failsafe script that resets 
the firewall after 5 minutes before you are absolutely sure that the scripts runs flawlessly. 

