#!/usr/bin/env bash

umask 022
unalias -a

#global utils

echolog() {
    kind=$1
    case $1 in
        log)
            color='none'
            ;;
        msg)
            color='\033[00;36m'
            ;;
        sucess)
            color='\033[00;32m'
            ;;
        warn)
            color='\033[00;33m'
            ;;
        error)
            color='\033[00;31m'
            ;;
    esac
    shift
    stage=${STAGE[${#STAGE[@]}-1]}

    if [ "$color" != "none" ] ; then
        echo -e "$stage: ${color}$@\033[0m"
    fi

    s=$(date "+%Y%m%d %T");
    echo "${s}: $kind: $CATEGORY/$PACKAGE: $stage: $@" >> $OPMLOG
}

log() { echolog log "${@}"; }
msg() { echolog msg "${@}"; }
success() { echolog success "${@}"; }
warn() { echolog warn "${@}"; }
error() { echolog error "${@}" >&2; }
die() { error "$@"; exit 1; }
try() { "$@" || die "Error running command: $@"; }

# opm util
opm.util.source_file() {
    local prefix="$1"
    shift
    for fn in "$@"
    do
        fn="$prefix/$fn"
        [ ! -r "${fn}" ] && die "File $fn not found. Exiting."
        log "Sourcing ${fn} ..."
        . "${fn}"
    done
}

opm.util.configure() {
    [ -e ${SOURCEDIR}/configure ] && try ${SOURCEDIR}/configure --prefix="${CONFIG_PREFIX:=/usr}" "$@" 2>&1 | tee ${SANDBOX}/configure.log
}

opm.util.source_opm() {
    if ! [ -z ${PACKAGE_REVISION} ] ; then
        revision="_${PACKAGE_REVISION}"
    fi

    if ! [ -z "$REPOS" ] ; then
        REPOS=( $(ls $OPMS) )
    fi

    for REPO in ${REPOS[@]} ; do
        if [ -e "$OPMS/$REPO/$CATEGORY/$PACKAGE_NAME/base.opm" ]; then
            opm.util.source_file "$OPMS/$REPO/$CATEGORY/$PACKAGE_NAME" "base.opm"
        fi

        opm.util.source_file "$OPMS/$REPO/$CATEGORY/$PACKAGE_NAME" "${PACKAGE_VERSION}${revision}.opm"
    done
}

opm.util.requires_dir() {
    for dir in "$@"
    do
        [ -d "${dir}" ] || install -d "${dir}"
    done
}

opm.util.func_exists() {
    type -t "$1" | grep -q "function"
}
