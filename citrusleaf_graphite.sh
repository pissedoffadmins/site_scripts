#!/bin/bash

#######
# this script runs through clinfo and grabs all the values for citrusleaf, then parses them out to graphite every 10 seconds.
# it only sends numeric values.
#
# to run this script :
# nohup sh citrusleaf_graphite.sh &
#
#######

NAMESPACE="<NAMESPACE>"
HOSTNAME=`echo $HOSTNAME | cut -d. -f1`
DATE=`date +%s`
NETCAT=`which nc`
CL_SERVER="127.0.0.1"
CL_PORT="3000"
GRAPHITE_SERVER="<GRAPHITE SERVER ADDRESS>"
GRAPHITE_PORT="2003"
NUMBER="0"

#### this is to check whether or not netcat is installed ####

if [[ -z ${NETCAT} ]]; then
    printf "\nnc not found.\n"
    exit 1
fi

#### you should not have to change anything below this line ####

while (true)
do
    NUMBER="0"
    for I in $(clinfo -h ${CL_SERVER} -p ${CL_PORT} -v ${NAMESPACE} | grep type | cut -d" " -f4 | tr ";" "\n")
    do
        # NUMBER=`expr ${NUMBER} + 2`
        NAME=`echo ${I} | cut -d"=" -f1`
        VALUE=`echo ${I} | cut -d"=" -f2 | cut -d";" -f1`
        VALUE_CHK=${VALUE//[^0-9]/}
            if [[ ${VALUE} == ${VALUE_CHK} ]]; then
                # echo ${NUMBER} ${I}
                # echo "value to nc:"
                # echo ${HOSTNAME}.${NAME} ${VALUE} ${DATE}
                echo "${HOSTNAME}.${NAME} ${VALUE} ${DATE}" | nc ${GRAPHITE_SERVER} ${GRAPHITE_PORT}
            fi
    done
    sleep 10
done
