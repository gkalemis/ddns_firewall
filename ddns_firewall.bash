#!/bin/bash
#allow a dyndns name
#include <stdlib.h>
HOSTNAME1=host1.xxxx.xxx
HOSTNAME2=host2.xxxx.xxx
LOGFILE1=/root/host1.ddns_firewall.log
LOGFILE2=/root/host2.ddns_firewall.log
RULES=/root/rules.ddns
CHNGLOG=/root/ddns.log
changed=0
COUNT1=$(/sbin/iptables-save | grep `cat /root/host1.ddns_firewall.log` | wc -l)
COUNT2=$(/sbin/iptables-save | grep `cat /root/host2.ddns_firewall.log` | wc -l)
COUNT3=$(/sbin/iptables -L INPUT | wc -l)


if [ ! -e $CHNGLOG ] ; then
  touch $CHNGLOG
fi

echo ====================================================================  >>$CHNGLOG


Current_IP1=$(host $HOSTNAME1 | cut -f4 -d' ')
Current_IP2=$(host $HOSTNAME2 | cut -f4 -d' ')

echo "#!/bin/bash" > $RULES
echo "/sbin/iptables -F INPUT" >> $RULES
# echo "/sbin/iptables -A INPUT -m conntrack ! --ctstate RELATED,ESTABLISHED -m mark ! --mark 0x14 -j pgl_in" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s $Current_IP1 -p tcp --dport 22 -j ACCEPT" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s $Current_IP2 -p tcp --dport 22 -j ACCEPT" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s $Current_IP1 -p tcp --dport 9443 -j ACCEPT" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s $Current_IP2 -p tcp --dport 9443 -j ACCEPT" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s 0.0.0.0/0 -p tcp --dport 22 -j DROP" >> $RULES
echo "/sbin/iptables -A INPUT -i eth1 -s 0.0.0.0/0 -p tcp --dport 9443 -j DROP" >> $RULES

if [ $LOGFILE1 = "" ] ; then
  echo $Current_IP1 > $LOGFILE1
  echo "$(date '+%Y-%m-%d %X'): New host1 IP : $Current_IP1" >>$CHNGLOG
  changed =1
else

  Old_IP1=$(cat $LOGFILE1)

  if [ "$Current_IP1" = "$Old_IP1" ] ; then
   echo "$(date '+%Y-%m-%d %X'): host1 IP not changed : $Current_IP1" >>$CHNGLOG
   #echo host1 IP address has not changed
  else
    echo $Current_IP1 > $LOGFILE1
    echo "$(date '+%Y-%m-%d %X'): host1 IP changed : $Current_IP1" >>$CHNGLOG
    # echo iptables for host1 have been updated
    changed=1
  fi
fi
if [ $LOGFILE2 = "" ] ; then
  echo $Current_IP2 > $LOGFILE2
  echo "$(date '+%Y-%m-%d %X'): New host2 IP : $Current_IP2" >>$CHNGLOG
  changed=1
else

  Old_IP2=$(cat $LOGFILE2)

  if [ "$Current_IP2" = "$Old_IP2" ] ; then
    echo "$(date '+%Y-%m-%d %X'): host2 IP not changed : $Current_IP2" >>$CHNGLOG
    #echo host2 IP address has not changed
  else
    echo $Current_IP2 > $LOGFILE2
    echo "$(date '+%Y-%m-%d %X'): host2 IP changed : $Current_IP2" >>$CHNGLOG
    #echo iptables for host2 have been updated
    changed=1
  fi
fi
chmod +x $RULES
if [ $changed = 1 ] ; then
    echo "$(date '+%Y-%m-%d %X'): Ips have changed : Updating rules" >>$CHNGLOG
    $RULES
    /usr/bin/pglcmd stop
    sleep 1
    /usr/bin/pglcmd start
fi

COUNT1= expr $COUNT1 >> /dev/null
COUNT2= expr $COUNT2 >> /dev/null

#COUNT1=$(( $COUNT1 + 0 ))
#COUNT2=$(( $COUNT2 + 0 ))

if [ $COUNT3 -lt  9 ] || [ $COUNT1 -lt 2 ] || [ $COUNT2 -lt 2 ]; then
    echo "$(date '+%Y-%m-%d %X') : Firewall has been altered : Updating rules" >>$CHNGLOG
    $RULES
    /usr/bin/pglcmd stop
    sleep 1
    /usr/bin/pglcmd start
fi
rm /root/rules.ddns
exit 0
