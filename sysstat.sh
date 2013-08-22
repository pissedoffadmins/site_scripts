#!/bin/bash

HOSTNAME=`echo $HOSTNAME | cut -d. -f1`
ENV=`echo $HOSTNAME | cut -d. -f1 | cut -d- -f1`
ENV_TOT="${ENV}_sysstats"
GSERVER="127.0.0.1"
GPORT="8080"
DATE=`date +%s`

[ ! -z $(which nc) ] && NETCAT=`which nc` ||
  { printf "\nnc not found.\n" ; exit 1 ; }

eval $(vmstat 1 2 | sed -n '/[0-9]/p' | sed -n '2p' | \
  awk '{printf "CPU_ID=%s; CPU_SY=%s; CPU_US=%s; CPU_WA=%s;", $15,$14,$13,$16};\
    {printf "SWAP_SI=%s; SWAP_SO=%s;", $7,$8}; \
    {printf "MEM_BUF=%s; MEM_CCH=%s; MEM_FRE=%s; MEM_SWP=%s;", $5,$6,$4,$3};' -)

eval $(df | awk 'NR==2 {printf "DISK_FREE=%s; DISK_TOTL=%s; DISK_USED=%s;", \
  $4*1000,$2*1000,$3*1000};' -)

eval $(cat /proc/loadavg | awk '{printf "LOAD1=%s; LOAD5=%s; LOAD15=%s;", \
  $1,$2,$3};' -)

eval $(free -b | \
  awk '/^Mem/ {printf "RAM_FREE=%s; RAM_TOTL=%s; RAM_USED=%s;", $4,$2,$3}; \
  /^Swap/ {printf "RAM_SWAP_FREE=%s; RAM_SWAP_TOTL=%s; RAM_SWAP_USED=%s;", \
    $4,$2,$3};' -)

USERS=`uptime | sed 's/users.*$//' | gawk '{print $NF}'`

STATN="cpu.idle_CPU_ID cpu.systime_CPU_SY cpu.usertime_CPU_US cpu.wait-IO_CPU_WA
swap.swapped-in_SWAP_SI swap.swapped-to_SWAP_SO
mem.buffers_MEM_BUF mem.cache_MEM_CCH mem.virtfree_MEM_FRE mem.virtswap_MEM_SWP
disk.free_DISK_FREE disk.total_DISK_TOTL disk.used_DISK_USED
load.1-minute_LOAD1 load.5-minutes_LOAD5 load.15-minutes_LOAD15
mem.free_RAM_FREE mem.total_RAM_TOTL mem.used_RAM_USED
swap.free_RAM_SWAP_FREE swap.total_RAM_SWAP_TOTL swap.used_RAM_SWAP_USED
users_USERS"

for statn in $STATN; do
  ID=`echo $statn | cut -d_ -f1` ; IDVAL=$(echo $statn | cut -d_ -f2-5)
  SNAME=${ENV_TOT}.${HOSTNAME}
  echo "${SNAME}.${ID} `eval echo '$'${IDVAL}` ${DATE}" | \
    ${NETCAT} ${GSERVER} ${GPORT}
done
