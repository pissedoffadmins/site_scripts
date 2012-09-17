#!/bin/bash

#######
# this script uses bwm-ng to gather the bandwidth rx/tx and packet rx/tx on specified interfaces
# it only sends numeric values
# 
# to run this script :
# nohup sh ~/scripts/bandwidth_graphite.sh & >/dev/null 2>&1
#
# to run this script in cron :
# * 3 * * * kill -9 `ps -ef | egrep graphite | grep -v grep | awk '{print $2}'` | sleep 5 && nohup sh ~/scripts/bandwidth_graphite.sh & >/dev/null 2>&1
#
# legend of bwm-ng output formatted for csv :
# unix_timestamp;iface_name;bytes_out;bytes_in;bytes_total;packets_out;packets_in;packets_total;errors_out;errors_in
#######

HOSTNAME=`echo $HOSTNAME | cut -d. -f1`
GRAPH_SERVER="<GRAPHITE SERVER>"
GRAPH_PORT="<GRAPHITE PORT>"
INTERFACES='eth0
eth1
eth2
eth3'

#### check to see if bwm-ng is installed ####
if [  ! -f /usr/bin/bwm-ng ]; then
	echo "INSTALL BWM"
	exit 1
fi

#### check to see if netcat is installed ####
if [ ! -f /usr/bin/nc ]; then
	echo "INSTALL NETCAT"
	exit 1
fi

#### you should not have to change anything below this line ####

while (true)
do
	for I in ${INTERFACES}
	do
		#### set BWM_OUT to filtered output of bwm-ng ####
		BWM_OUT=`/usr/bin/bwm-ng --interface ${I} -o plain -t 1000 -o csv -c 1 | grep -v total`
		#### use date in epoch from BWM_OUT ####
		DATE=`echo ${BWM_OUT} | cut -d";" -f1`
		#### use interface name from BWM_OUT ####
		IFACE=`echo ${BWM_OUT} | cut -d";" -f2`
		#### packets in ####
		RXPCK=`echo ${BWM_OUT} | cut -d";" -f7`	
		#### packets out ####
		TXPCK=`echo ${BWM_OUT} | cut -d";" -f6`
		#### bytes in ####
		RXBYT=`echo ${BWM_OUT} | cut -d";" -f4`
		#### bytes out ####
		TXBYT=`echo ${BWM_OUT} | cut -d";" -f3`

		#### begin nc to graph services ####
		echo "${HOSTNAME}.${IFACE}.RxPACKETS ${RXPCK} ${DATE}"  | nc ${GRAPH_SERVER} ${GRAPH_PORT}
		echo "${HOSTNAME}.${IFACE}.TxPACKETS ${TXPCK} ${DATE}"  | nc ${GRAPH_SERVER} ${GRAPH_PORT}
		echo "${HOSTNAME}.${IFACE}.RxBYTES ${RXBYT} ${DATE}"  | nc ${GRAPH_SERVER} ${GRAPH_PORT}
		echo "${HOSTNAME}.${IFACE}.TxBYTES ${TXBYT} ${DATE}"  | nc ${GRAPH_SERVER} ${GRAPH_PORT}
	done
done
