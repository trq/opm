#!/usr/bin/env bash

opm.fetch() {
    opm.stage.start "fetch"
    opm.util.requires_dir ${DISTDIR}

    for source in "${sources[@]}"; do
        if [ -z "$archive" ]; then archive=${sources##*/}; fi

        if ! [ -f "${DISTDIR}/${archive}" ]; then
            case "${source}" in
                http://*|https://*)
                    msg "Fetching ${archive} ..."
                    wget "${source}" -O "${DISTDIR}/${archive}"
                    if ! [ -s "${DISTDIR}/${archive}" ]; then
                        rm -f "${DISTDIR}/${archive}"
                        die "Unable to fetch ${archive}."
                    else
                        if ! [ -z $checksum ] ; then
                            md5=$(md5sum ${DISTDIR}/${archive} | awk '{print $1}')
                            if ! [ "${md5}" = "${checksum}" ] ; then
                                rm -f "${DISTDIR}/${archive}"
                                die "Checksum mismatch, try fetching again."
                            fi
                        fi
                    fi
                ;;
                *)
                    die "You have to provide '${archive}'."
                ;;
            esac
        fi
    done;
    unset source

    opm.stage.complete "fetch"
}
