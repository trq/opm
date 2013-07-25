#!/usr/bin/env bash

source src/opm/usr/lib/opm/usage.sh

opm.dispatch() {
    local opm=
    while [ "${1}" != "" ]; do
        [ -f actions/${1}.sh ] && source actions/${1}.sh
        [ -f actions/stages/${1}.sh ] && source action/stages/${1}.sh


        if type -t "opm.${1}" | grep -q "function" ; then
            opm.${1} $opm
        else
            case "${1}" in
                *.opm)  opm="${1}"  ;;
                *)      opm.usage   ;;
            esac
        fi
        shift
    done
}

opm.dispatch "$@"
