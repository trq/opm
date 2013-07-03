#!/usr/bin/env bash

umask 022
unalias -a

#global util
die() { echo -e "\033[1;31m$@ \033[0m" 1>&2; exit 1; }
msg() { echo -e "\033[1;32m$@ \033[0m"; }
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

opm.util.source_opm() {
    if [ -e "$OPMS/$CATEGORY/$PACKAGE_NAME/defaults" ]; then
        opm.util.source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "defaults"
    fi

    opm.util.source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "$PACKAGE_VERSION"
}

opm.util.requires_dir() {
    for dir in "$@"
    do
        [ -d "${dir}" ] || install -d "${dir}"
    done
}
