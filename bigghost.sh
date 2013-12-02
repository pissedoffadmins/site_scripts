#!/bin/bash
#
# this script generates names according to the names from :
# http://www.bigghostlimited.com/?b2w=http://bigghostnahmean.blogspot.com/
# made for fun

[ -z $(which tput 2>/dev/null) ] && { printf "%s\n" "tput not found"; exit 1; }

GRN=$(tput setaf 2); YLW=$(tput setaf 3); RED=$(tput setaf 1); CLR=$(tput sgr0)

PRE=("" "Muthafuckin wise n powerful" "The world famous" "The imperial"
  "That muthafucka wit two iron midgets for hands" "The almighty"
  "The grand emperor" "The grand royal" "The illustrious" "The magnificent"
  "The super supreme")
PRE_INDEX=$(( $RANDOM % ${#PRE[*]} ))
PRE_W_CNT=$(( ${#PRE[$PRE_INDEX]} ))
PRE_OUT=${GRN}${PRE[$PRE_INDEX]}

MID1=("Broccoli" "Caviar" "Cocaine" "Divine" "Galaxy" "Hands_of_Zeus" "Phantom"
  "Shampoo" "Spartacus" "Swole_Ya_Eye" "Thor" "Volcano" "Watch_Ya_Mouf")
MID1_INDEX=$(( $RANDOM % ${#MID1[*]} ))
MID1_W_CNT=$(( ${#MID1[$MID1_INDEX]} ))
if [ `echo ${MID1[$MID1_INDEX]} | cut -d_ -f1 -s | wc -l` -lt 1 ]; then
  MID2=("Bundles" "Tusks" "Biceps" "Snowcones" "Knuckles" "Raviolis"
    "Bracelets" "Deluxe" "Molecules" "Hands")
  MID2_INDEX=$(( $RANDOM % ${#MID2[*]} ))
  MID_W_CNT=$(( ${#MID1[$MID1_INDEX]} + ${#MID2[$MID2_INDEX]} ))
  MID_OUT="${RED}${MID1[$MID1_INDEX]} ${MID2[$MID2_INDEX]}"
else
  MID_W_CNT=$(( ${#MID1[$MID1_INDEX]} ))
  MID_OUT="${RED}`echo ${MID1[$MID1_INDEX]}|tr "_" " "`"
fi

POST=("" "in the flesh" "the magnificent" "the panty melter" "the great"
  "the wallabee champ" "via amazin wizardry n shit"
  "the Stapleton gladiator namsayin")
POST_INDEX=$(( $RANDOM % ${#POST[*]} ))
POST_W_CNT=$(( ${#POST[$POST_INDEX]} ))
POST_OUT=${YLW}${POST[$POST_INDEX]}${CLR}

printf $(tput clear)
CNT=$(( ${PRE_W_CNT} + ${MID_W_CNT} + ${POST_W_CNT} ))
tput cup $(( $(tput lines) / 2 )) $((( $(tput cols) / 2 ) - ( $CNT / 2 ) ))
printf "${PRE_OUT} ${MID_OUT} ${POST_OUT}"
tput cup $(tput lines) 0
