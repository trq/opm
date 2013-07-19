#!/usr/bin/env bash

umask 022
unalias -a

RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
CYAN='\033[00;36m'

#global util
msg() { echo -e "${CYAN}${@}${RESTORE}"; }
success() { echo -e "${GREEN}${@}${RESTORE}"; }
warn() { echo -e "${YELLOW}${@}${RESTORE}"; }
error() { echo -e "${RED}${@}${RESTORE}" >&2; }
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
        msg "Sourcing ${fn} ..."
        . "${fn}"
    done
}

opm.util.configure() {
    [ -e ${SOURCEDIR}/configure ] && try ${SOURCEDIR}/configure "$@" 2>&1 | tee ${SANDBOX}/configure.log
}

opm.util.source_opm() {
    if [ -e "$OPMS/$CATEGORY/$PACKAGE_NAME/base.opm" ]; then
        opm.util.source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "base.opm"
    fi

    opm.util.source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "$PACKAGE_VERSION.opm"
}

opm.util.requires_dir() {
    for dir in "$@"
    do
        [ -d "${dir}" ] || install -d "${dir}"
    done
}

opm.util.func_exists() {
    type "$1" | grep -q "function"
}

opm.util.complete_stage() {
    opm.util.requires_dir ${STAGEDIR}
    touch "$STAGEDIR/$1"
}

opm.util.is_stage_complete() {
    [ -f "$STAGEDIR/$1" ]
}

opm.util.requires_stage() {
    if [ -z $virtual ] ; then
        if ! opm.util.is_stage_complete $1; then
            if opm.util.func_exists "opm.$1"; then
                opm.${1}
            fi
        fi
    fi
}
