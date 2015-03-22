#!/usr/bin/env bash

# text format && color
ORN=$(tput setaf 3); RED=$(tput setaf 1); BLU=$(tput setaf 4)
GRN=$(tput setaf 40); MGN=$(tput setaf 5); CLR=$(tput sgr0)

function FIGLET() {
    if [[ -f $(which figlet 2>/dev/null) ]]; then
        printf "%s" "${GRN}"; figlet -c $(hostname)
    fi
}

function LAST() {
    if [[ $(lastlog -u $USER | awk 'END {print $2}') = tty* ]]; then
        LL=$(lastlog -u $USER | tail -n 1)
        FROM=$(echo ${LL} | awk '{ print $2 }')
        AT=$(echo ${LL} | awk '{ print $3,$4,$5,$6 }')
    else
        LL=$(lastlog -u $USER | tail -n 1)
        FROM=$(echo ${LL} | awk '{ print $3 }')
        AT=$(echo ${LL} | awk '{ print $4,$5,$6,$7 }')
    fi
    printf "\n%s%s%s%s\n" "${MGN}" "Last Login.: " "${BLU}" \
        "From ${FROM} on ${AT}"
}

function UPTIME() {
    UPTOT=$(cut -d. -f1 /proc/uptime)
    UPD=$(expr ${UPTOT} / 60 / 60 / 24)
    UPH=$(expr ${UPTOT} / 60 / 60 % 24)
    UPM=$(expr ${UPTOT} / 60 % 60)
    UPS=$(expr ${UPTOT} % 60)
    printf "%s%s%s%s\n" "${MGN}" "Uptime.....: " "${BLU}" \
        "${UPD} days ${UPH} hours ${UPM} minutes ${UPS} seconds"
}

function LOAD() {
    eval $(cat /proc/loadavg | awk '{printf "LOAD1=%s; LOAD5=%s; LOAD15=%s;", \
        $1,$2,$3};' -)
    printf "%s%s%s%s\n" "${MGN}" "Load.......: " "${BLU}" \
        "${LOAD1} (1 minute) ${LOAD5} (5 minutes) ${LOAD15} (15 minutes)"
}

function MEMORY() {
    eval $(free -m | awk '/^Mem:/ {printf "MEM=%s; USED=%s; FREE=%s; \
        FREE_CACHE=%s;", $2,$3,$4,$6};')
    eval $(free -m | awk '/^Swap:/ {printf "SWAP_USE=%s;", $3};')
    printf "%s%s%s%s%s\n" "${MGN}" "Memory MB..: " "${BLU}" \
        "${MEM}mb, Used: ${USED}mb, Free: ${FREE}mb, " \
        "Free Cached: ${FREE_CACHE}mb, Swap In Use: ${SWAP_USE}mb"
}

function DISKUSAGE() {
    DUH=$(du -ms $(echo $HOME) | awk '{ print $1 }')
    printf "%s%s%s%s\n" "${MGN}" "Disk Usage.: " "${BLU}" \
        "You are using ${DUH}mb in ${HOME}"
}

function SSH() {
    USERS=$(who | awk '{print $1}' | sort | uniq | wc -l)
    printf "%s%s%s%s\n" "${MGN}" "SSH Logins.: " "${BLU}" \
        "There are currently ${USERS} users logged in"
}

function PROC() {
    P_TOT=$(ps -A h | wc -l)
    P_USR=$(ps U ${USER} | wc -l)
    printf "%s%s%s%s\n" "${MGN}" "Processes..: " "${BLU}" \
        "${P_TOT} total running of which ${P_USR} are yours"
}

function RULES() {
    printf "%s\n\n" "${GRN}"
cat <<EOL
  ::::::::::::::::::::::::::::::::::-RULES-::::::::::::::::::::::::::::::::::
    This is a private system that you are not to give out access to anyone
    without permission from the admin. No illegal files or activity. Stay,
    in your home directory, keep the system clean, and make regular backUPS.
     -==  DISABLE YOUR PROGRAMS FROM KEEPING SENSITIVE LOGS OR HISTORY ==-
EOL
}

function FORTUNE() {
    if [[ -f $(which fortune 2>/dev/null) ]]; then
        if [[ -f $(which cowthink 2>/dev/null) ]]; then
            printf "%s\n" "${RED}"
            fortune | cowthink -f $(ls /usr/share/cowsay-3.03/cows | shuf -n1)
        fi
    fi
}

##functions below
FIGLET
LAST
UPTIME
LOAD
MEMORY
DISKUSAGE
SSH
PROC
RULES
FORTUNE
printf "\n\n"
