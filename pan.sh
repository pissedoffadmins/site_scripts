#!/bin/bash

#### pianobar fifo control script

# lets check if fifo file exists, if not create it
PIPE=`cat ${HOME}/.config/pianobar/config | grep -v "#" | grep fifo | tr -d "\ " | cut -d"=" -f2`
if [[ ! -p ${PIPE} ]]; then
    if [[ -z ${PIPE} ]]; then
        printf "\npianobar fifo not specified in config\nexiting\n"
        exit 1
    fi
    printf "\npianobar fifo does not exist\n"
    read -p "should i create it ? (y/n): " YN
    case $YN in
        [Yy]* ) mkfifo ${PIPE} ; printf -- "\npianobar fifo created\n" ;;
        [Nn]* ) exit 1 ;;
    esac
fi

# lets make sure pianobar is running, if not ask to run
if [[ ! `pgrep -u $(id -u) pianobar$` ]]; then
    printf "\npianobar is not running\n"
    read -p "should i start pianobar ? (y/n): " YN
    case $YN in
        [Yy]* ) pianobar && exit ;;
        [Nn]* ) exit 1 ;;
    esac
fi

# help stuffs
help_section() {
    printf "\n$(basename $0)\n"
    printf -- "Usage: $(basename $0) [OPTION]\n\n"
    printf -- "Usage Example : \"$(basename $0) n\" <or> \"$(basename $0) --next\" <or> \"$(basename $0) next\"\n"
    printf -- "This will jump to the next track\n\n"
    printf -- "Options:\n"
    printf -- "+,  --love,     love        --  Love this song\n"
    printf -- "-,  --ban,      ban         --  Ban this song\n"
    printf -- "b,  --bookmark, bookmark    --  Bookmark song \ artist\n"
    printf -- "e,  --explain,  explain     --  Explain why this song is playing\n"
    printf -- "h,  --history,  history     --  History of whats played\n"
    printf -- "i,  --info,     info        --  Info for whats playing\n"
    printf -- "n,  --next,     next        --  Next song\n"
    printf -- "p,  --pause,    pause       --  Pause \ Play song\n"
    printf -- "q,  --quit,     quit        --  Quit Pianobar\n"
    printf -- "t,  --tired,    tired       --  Tired (ban song for 1 month)\n"
    printf -- "u,  --upcoming, upcoming    --  Upcoming songs\n"
    printf -- "vd, --voldown,  voldown     --  Volume Down\n"
    printf -- "vu, --volup,    volup       --  Volume Up\n"
    printf -- "\nvolume up and down can also have a value added:\n"
    printf -- "\n$(basename $0) [volume option] [1-25]\n\n\n"
    printf "pianobar pid (euid=$(id -u)): "
    pgrep -u $(id -u) pianobar$
    printf -- "\n"
}

# menu stuffs
case $1 in
    +|--love|love           ) printf "+" > ${PIPE} ;;
    -|--ban|ban             ) printf "-" > ${PIPE} ;;
    b|--bookmark|bookmark   ) printf "b" > ${PIPE} ;;
    e|--explain|explain     ) printf "e" > ${PIPE} ;;
    h|--history|history     ) printf "h" > ${PIPE} ;;
    i|--info|info           ) printf "i" > ${PIPE} ;;
    n|--next|next           ) printf "n" > ${PIPE} ;;
    p|--pause|pause         ) printf "p" > ${PIPE} ;;
    q|--quit|quit           ) printf "q" > ${PIPE} ;;
    t|--tired|tired         ) printf "t" > ${PIPE} ;;
    u|--upcoming|upcoming   ) printf "u" > ${PIPE} ;;
    vd|--voldown|voldown    ) printf "(" > ${PIPE}
        count=1
        while [[ $count -lt $2 ]]; do
            printf "(" > ${PIPE}
            count=`expr $count + 1`
        done
        ;;
    vu|--volup|volup        ) printf ")" > ${PIPE}
        count=1
        while [[ $count -lt $2 ]]; do
            printf ")" > ${PIPE}
            count=`expr $count + 1`
        done
        ;;
    *                       ) help_section ;;
esac
