#!/usr/bin/env bash

opm.unpack() {
    opm.stage.start "unpack"
    opm.stage.requires "fetch"
    opm.util.requires_dir ${DISTDIR} ${WORKDIR}

    for source in "${sources[@]}"; do
        if [ -z "$archive" ]; then archive=${sources##*/}; fi

        if ! [ -f "${DISTDIR}/${archive}" ]; then die "Missing source '${archive}'."; fi

        case "${source##*/}" in
            *.tar|*.tar.bz2|*.tar.xz|*.tar.gz|l*.tar.lzma)
                msg "Extracting ${DISTDIR}/"${archive}" ..."
                try tar xvf "${DISTDIR}/${archive}" -C "${WORKDIR}"
            ;;
            *)
                die "Unsupported format."
            ;;
        esac
    done;

    unset source

    [ ! -d "$SOURCEDIR" ] && die "Source directory $SOURCEDIR specified in \$SOURCEDIR does not exist. Exiting."

    cd "$SOURCEDIR"
    opm.stage.complete "unpack"
}
