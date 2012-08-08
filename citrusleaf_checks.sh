#!/bin/bash 

#####
# this script is used in nagios to check citrusleaf's "available_percent", "bytes-disk-used", and "evicted-objects"
# it also outputs the performance data of those numbers for usage in pnp4nagios or whatever else.
# usage:
# citrusleaf_checks.sh <evict|bytes|pct> <WARNING> <CRITICAL>
#####

NAMESPACE="namespace/devices"
# rm -f /tmp/cl*
TEMP=/tmp/cltmp.$$
INFO=/tmp/clinfotmp.$$
touch $TEMP $INFO
SERVER="127.0.0.1"
PORT="3000"
CLINFO=`which clinfo`


#### you should not have to change anything below this line ####

if [[ -z ${CLINFO} ]]; then
    printf "\nclinfo not installed\n"
    exit 1
done


for x in $SERVER; do
    clinfo -h $x -p $PORT -v "$NAMESPACE" > $INFO
done

grep "type" $INFO > $TEMP

case $1 in
'evictions'|'evicted'|'evict')
    EVICTIONS=`cat $TEMP | awk -F "[;=]" '{print $8}'` 
    if [[ -z "${2}" || -z "${3}" ]]; then
        printf "must set warning and critical values" 
    else
        if [[ ${EVICTIONS} -ge ${2} ]]; then 
            if [[ ${EVICTIONS} -ge ${3} ]]; then 
                echo "CRITICAL: evicted-objects=${EVICTIONS} | evicted-objects=${EVICTIONS};${2};${3};0;0"
                rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
                exit 2
            fi
            echo "WARNING: evicted-objects=${EVICTIONS} | evicted-objects=${EVICTIONS};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 1
        else
            echo "OK: evicted-objects=${EVICTIONS} | evicted-objects=${EVICTIONS};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 0
        fi
    fi
;;

'bytes'|'disk')
    BYTES_USED_DISK=`cat $TEMP | awk -F "[;=]" '{print $40}'`
    BYTES_USED_DISK_GB=`echo ${BYTES_USED_DISK} | awk '{ split( "KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) v[s] }'`
    if [[ ${BYTES_USED_DISK} -lt "1024000" ]]; then 
        BUD_SIZE="KB"
    else
        if [[ ${BYTES_USED_DISK} -ge 1024000000 ]]; then 
            BUD_SIZE="GB"
        else
            BUD_SIZE="MB"
        fi
    fi

    TOTAL_BYTES_DISK=`cat $TEMP | awk -F "[;=]" '{print $42}'`
    TOTAL_BYTES_DISK_GB=`echo ${TOTAL_BYTES_DISK} | awk '{ split( "KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) v[s] }'`
    if [[ ${TOTAL_BYTES_DISK} -lt "1024000" ]]; then 
        TBD_SIZE="KB"
    else
        if [[ ${TOTAL_BYTES_DISK} -ge 1024000000 ]]; then 
            TBD_SIZE="GB"
        else
            TBD_SIZE="MB"
        fi
    fi

    if [[ -z "${2}" || -z "${3}" ]]; then
        printf "must set warning and critical values"
    else
        if [[ ${BYTES_USED_DISK} -ge ${2} ]]; then
            if [[ ${BYTES_USED_DISK} -ge ${3} ]]; then
                echo "CRITICAL: used-bytes-disk=${BYTES_USED_DISK_GB}${BUD_SIZE} | used_bytes_disk=${BYTES_USED_DISK};${2};${3};0;0"
                rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
                exit 2
            fi
            echo "WARNING: used-bytes-disk=${BYTES_USED_DISK_GB}${BUD_SIZE} | used_bytes_disk=${BYTES_USED_DISK};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 1
        else
            echo "OK: used-bytes-disk=${BYTES_USED_DISK_GB}${BUD_SIZE} | used_bytes_disk=${BYTES_USED_DISK};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 0
        fi
    fi
;;

'percent'|'pct')
    AVAILABLE_PCT=`cat $TEMP | awk -F "[;=]" '{print $68}'`
    if [[ -z "${2}" || -z "${3}" ]]; then
        printf "must set warning and critical values"
    else
        if [[ ${AVAILABLE_PCT} -ge ${2} ]]; then
            if [[ ${AVAILABLE_PCT} -ge ${3} ]]; then
                echo "CRITICAL: available_pct=${AVAILABLE_PCT} | available_pct=${AVAILABLE_PCT};${2};${3};0;0"
                rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
                exit 2
            fi
            echo "WARNING: available_pct=${AVAILABLE_PCT} | available_pct=${AVAILABLE_PCT};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 1
        else
            echo "OK: available_pct=${AVAILABLE_PCT} | available_pct=${AVAILABLE_PCT};${2};${3};0;0"
            rm -f /tmp/cltmp.$$ ; rm -f /tmp/clinfotmp.$$
            exit 0
        fi
    fi
;;

'help'|*) echo "usage: $0 <evictions|bytes|percent>"
esac
