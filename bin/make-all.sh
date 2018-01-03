#!/bin/bash

#
# This script will run make from the configs/nrf52832_dk directory against every
# example directory contiaining the file defconfig.
#

#
# Standard routine is to peform a distclean, <example app>, > out.<example>, and to cycle
# through each of the possible examples.
#

BOARD=nrf52832_dk
ARG_LIST="BOARD TARGET_DIRS NO_ERRORS Q V VERBOSE RELOCATE"

#
# Filter out everything but the while loop and the two boundary markers.
# Then filter out anything that does not have a ')' in it.  Voila, instant
# help message!
#
help_msg()
{
        sed -n -e '/^### HELP.*start/,/^### HELP.*end/p' "$0" | sed -n -e '/)/p'
#       grep "\-" |  grep -v 'while'
}

print_vars()
{
        for var in $ARG_LIST ; do
                echo -e "$var\t(${!var})"
        done
}

### HELP message start
while [ $# -ne 0 ] ; do
        case "$1" in
        -b) BOARD="$2"; shift              # Specify the directory to build from
                ;;
        -e) NO_ERRORS="NO_ERRORS=1"        # Disable -Werror (warnings are errors)
                ;;
        -h) help_msg && exit 0
                ;;
        -p) print_vars && exit 0
                ;;
        -Q) Q="";                          # Expose the raw commands make issues.
                ;;
        -t) TARGET_DIRS="$TARGET_DIRS ${2%/}"; shift   # Specify build target. May specify multiple times.
                ;;
        -v) VERBOSE="${VERBOSE}V"          # Print info beyond success/failure. May specify multiple times.
                ;;
        -V) V=2                            # Essentially a dup of -Q 
                ;;
        *) [ ! -d "$1" ] && echo "Unexpected argument. ($1)" >&2 && exit 1 #
           TARGET_DIRS="$TARGET_DIRS ${1%/}";  # Specify build target. May specify multiple times.
                ;;
        esac
        shift
done
### HELP message end

find_make_dir()
{
        local HERE=
        local Target=

        [ -z "$1" ] && echo "No target provided." >&2 && return 1

        Target="$1"
        HERE=$(pwd)
        if [ "$(basename $HERE)" == "$BOARD" ] ; then
                echo "./"
        else
                find . -type d -name $BOARD
        fi
}

set_app_list()
{
        local Dir=

        [ ! -d "$1" ] && echo "No directory specified: ($1)" >&2 && return 1
        Dir="$1"
        echo $(ls */defconfig | sed -e 's/\/.*//')
}

V=${V:-0}
Q=${Q:-@}
# DEFAULT_APPS="nsh hello ble_hello ble_app_uart"
RELOCATE=$(find_make_dir $BOARD)
DEFAULT_APPS=$(set_app_list $RELOCATE)
TARGET_DIRS=${TARGET_DIRS:-$DEFAULT_APPS}
[ "${VERBOSE:0:1}" == "V" ] && print_vars

if [ ! -d "$RELOCATE" ] ; then
        echo "No such dir: ($RELOCATE)" >&2
        exit 2
fi
pushd $RELOCATE >/dev/null
for build in $TARGET_DIRS ; do
        CMD="make distclean"
        $CMD >/dev/null 2>&1

        CMD="make V=\"$V\"  $NO_ERRORS $build"
        [ "${VERBOSE:0:2}" = "VV" ] && echo "==: $CMD > out.$build 2>&1"
        echo -n "Building for $build: ... "
        $CMD > out.$build 2>&1
        if [ $? -ne 0 ] ; then
                echo -e "Failed."
                continue
        fi
        echo "Succeeded."
done
popd >/dev/null

