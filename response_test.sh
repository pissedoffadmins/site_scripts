#!/bin/bash

# vim:set ts=2 sw=4 noexpandtab:
# <cesar@pissedoffadmins.com> 2014

set -e
set -o pipefail
clear
SDIR="$(cd $(dirname $0) ; pwd)"
NAME=$(basename $0)

GRN=$(tput setaf 2); YLW=$(tput setaf 3); RED=$(tput setaf 1)
BLU=$(tput setaf 4); CLR=$(tput sgr0)

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
  [ ! -z $(which gnuplot 2>/dev/null) ] && gnuplot_exe="$(which gnuplot)" ||
    { printf "${RED}Missing gnuplot${CLR}\n"; exit 1; }
  [ ! -z $(which ab 2>/dev/null) ] ||
    { printf "${RED}Missing ab${CLR}\n"; exit 1; }
}

function create_tempfile() {
  GDATA="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  GSCRIPT="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  GPNG="$(mktemp --tmpdir loadtest.XXXXXX)" || return 0
  trap "rm -rf ${GDATA} ${GSCRIPT} ${GPNG}" 0 1 2 3 9 15
}

function create_GSCRIPT() {
  cat > "${GSCRIPT}" << __GNUPLOT__
  set datafile separator '\t'     # Use tabs as delimiter
  set format x "%S"               # *output* format for the x-axis tick labels
  set grid y                      # Draw gridlines oriented on the y axis
  set key left top                # Where to place the legend/key
  set output "${GPNG}"            # save file to "${GPNG}"
  set size 1,1                    # aspect ratio for image size
  set terminal png size 1280,720  # output to a 1280x720 png file
  set timefmt "%s"                # *input* format of the time data
  set title "response testing"    # graph title
  set xdata time                  # x-series data is time data
  set xlabel 'seconds'            # Label the x-axis
  set ylabel "response time (ms)" # Label the y-axis
  plot "${GDATA}" every ::2 using 2:5 title 'response time' with points
__GNUPLOT__
}

function gather_info() {
  printf "${BLU}[*]${CLR} How many requests (Default 400)             : ${GRN}"
  read REQS
  [ -z ${REQS} ] && REQS=400

  printf "${BLU}[*]${CLR} How many concurrent connections (Default 10): ${GRN}"
  read CONC
  [ -z ${CONC} ] && CONC=10

  printf "${BLU}[*]${CLR} For how long (Default 10 seconds)           : ${GRN}"
  read ABTIME
  [ -z ${ABTIME} ] && ABTIME=10

  printf "${BLU}[*]${CLR} URL to test (Default http://localhost)      : ${GRN}"
  read TURL
  [ -z ${TURL} ] && TURL="http://localhost"
  TURL="`echo ${TURL} | sed -e "s/http:\/\///g" -e "s/\///g"`"

  printf "${BLU}[*]${CLR} Port to test against (Default 80)           : ${GRN}"
  read PORT
  [ -z ${PORT} ] && PORT=80
  printf "${CLR}\n"
  return 0
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
  create_GSCRIPT || return $?
  gather_info || return $?
  run_ab || return $?
  create_plot
}

main "$@"
exit $?
