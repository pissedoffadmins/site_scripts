#!/bin/bash

# <cesar@pissedoffadmins.com> 2014

set -e
set -o pipefail
clear
SDIR="$(cd $(dirname $0) ; pwd)"
NAME=$(basename $0)

ORN=$(tput setaf 3); RED=$(tput setaf 1)
BLU=$(tput setaf 4); GRN=$(tput setaf 40); CLR=$(tput sgr0)

version() {
  local VER="0.01"
cat <<EOL
${NAME} version ${VER}
Copyright (C) 2014 cesar@pissedoffadmins.com
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it.

EOL
}

descrip() {
  cat <<EOL
This script uses apache bench to plot data to gnuplot to make it easier
than having to do this by hand.

EOL
}

function check_platform() {
  [ ! -z $(which gnuplot 2>/dev/null) ] ||
    { printf "${RED}[*]${CLR}Missing gnuplot\n"; exit 1; }
  [ ! -z $(which ab 2>/dev/null) ] ||
    { printf "${RED}[*]${CLR}Missing ab\n"; exit 1; }
}

function create_tempfile() {
  GDATA="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  GSCRIPT="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  GPNG="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  trap "rm -rf ${GDATA} ${GSCRIPT} ${GPNG}" 0 1 2 3 9 15
}

function gather_info() {
  FMT="%s%-44s%s"
  MNHDR="${BLU}[*]${CLR} "
  BDHDR="${RED}[*]${CLR}"
  COLHDR="${GRN}[*]${CLR} "
  printf "${FMT}" "${MNHDR}" "How many requests (Default 400)" ": "
  read REQS
  [ -z ${REQS} ] && REQS=400
  if [ ${REQS} -ge $(ulimit -n) ]; then
    printf "${BDHDR} ulimit is set to $(ulimit -n)\n"
  fi

  printf "${FMT}" "${MNHDR}" "How many concurrent connections (Default 10)" ": "
  read CONC
  [ -z ${CONC} ] && CONC=10
  if [ ${CONC} -ge $(cat /proc/sys/net/core/somaxconn) ]; then
    printf "${BDHDR} somaxconn is $(cat /proc/sys/net/core/somaxconn)\n"
  fi

  printf "${FMT}" "${MNHDR}" "For how long (Default 10 seconds)" ": "
  read ABTIME
  [ -z ${ABTIME} ] && ABTIME=10

  printf "${FMT}" "${MNHDR}" "URL to test (Default http://localhost)" ": "
  read TURL
  [ -z ${TURL} ] && TURL="http://localhost"
  TURL="`echo ${TURL} | sed -e "s/http:\/\///g" -e "s/\///g"`"

  printf "${FMT}" "${MNHDR}" "Port to test against (Default 80)" ": "
  read PORT
  [ -z ${PORT} ] && PORT=80

  printf "${FMT}" "${MNHDR}" "Change colors or size of png ? (Default no)" ": "
  read YN
    case "${YN}" in
      [Yy][Ee][Ss]|[Yy])
        printf "${FMT}" "${COLHDR}" "Background color (Default white)" ": "
        read _BGCLR
        printf "${FMT}" "${COLHDR}" "Border color (Default black)" ": "
        read _BDCLR
        printf "${FMT}" "${COLHDR}" "Key text color (Default black)" ": "
        read _KTXTCLR
        printf "${FMT}" "${COLHDR}" "Title color (Default black)" ": "
        read _TLCLR
        printf "${FMT}" "${COLHDR}" "Grid color (Default grey)" ": "
        read _GCLR
        printf "${FMT}" "${COLHDR}" "X & Y label color (Default black)" ": "
        read _XYCLR
        printf "${FMT}" "${COLHDR}" "Change title (Response Testing)" ": "
        read _TL
        printf "${FMT}" "${COLHDR}" "PNG size (Default 1280,720)" ": "
        read _PNGSZ
      ;;
      [Nn][Oo]|[Nn]|*) ;;
    esac

  [ -z ${_BDCLR} ] && _BDCLR="black"
  [ -z ${_KTXTCLR} ] && _KTXTCLR="black"
  [ -z ${_TLCLR} ] && _TLCLR="black"
  [ -z ${_GCLR} ] && _GCLR="#808080"
  [ -z ${_BGCLR} ] && _BGCLR="white"
  [ -z ${_XYCLR} ] && _XYCLR="black"
  [ -z ${_TL} ] && _TL="Response Testing"
  [ -z ${_PNGSZ} ] && _PNGSZ="1280,720"

  printf "${CLR}\n"
  return 0
}

function create_GSCRIPT() {
  cat > "${GSCRIPT}" << __GNUPLOT__
  set datafile separator '\t'     # Use tabs as delimiter
  set format x "%S"               # *output* format for the x-axis tick labels
  set key left top                # Where to place the legend/key
  set output "${GPNG}"            # save file to "${GPNG}"
  set size 1,1                    # aspect ratio for image size
  set terminal png size 1280,720  # output to a 1280x720 png file
  set timefmt "%s"                # *input* format of the time data
  set title "${_TL}" textcolor rgbcolor "${_TLCLR}" # graph title
  set xdata time                  # x-series data is time data
  set xlabel "seconds" textcolor rgb "${_XYCLR}"
  set ylabel "response time (ms)" textcolor rgb "${_XYCLR}"
  set border linecolor rgbcolor "${_BDCLR}"
  set key textcolor rgbcolor "${_KTXTCLR}"
  set obj 1 rectangle behind from screen 0,0 to screen 1,1
  set obj 1 fillstyle solid 1.0 fillcolor rgbcolor "${_BGCLR}"
  set style line 11 lc rgb 'black' lt 1
  set style line 12 lc rgb 'black' lt 1
  set border 3 back ls 11
  set grid back ls 12
  set grid ytics lt 0 lw 0 lc rgb "${_GCLR}"
  set grid xtics lt 0 lw 0 lc rgb "${_GCLR}"
  plot "${GDATA}" every ::2 using 2:5 title 'response time' with points
__GNUPLOT__
}

function run_ab() {
  ab -v 1 -n ${REQS} -c ${CONC} -g "${GDATA}" \
    -t ${ABTIME} "http://${TURL}:${PORT}/"
}

function create_plot() {
  gnuplot ${GSCRIPT} || return $?
  GPNG_MV="${NAME%.*}.$(echo `date "+%Y%m%d_%H%M%S"`).png"
  mv "${GPNG}" ${GPNG_MV}
  GPNG=${GPNG_MV}
  printf "\n${BLU}[*]${CLR} Created PNG file: ${RED}${GPNG_MV}${CLR}\n\n"
}

function main() {
  check_platform || return $?
  create_tempfile || return $?
  gather_info || return $?
  create_GSCRIPT || return $?
  run_ab || return $?
  create_plot
}

main "$@"
exit $?
