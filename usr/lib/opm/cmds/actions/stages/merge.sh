#!/usr/bin/env bash

opm.merge() {
    opm.stage.start "merge"
    opm.stage.requires "package"
    opm.util.requires_dir ${METADIR}/${CATEGORY}

    if [ -f ${PKGDIR}/${PACKAGE}.tar.gz ]; then
        msg "Merging '${PACKAGE}' into ${TARGETFS} ..."
        tar xpvfh ${PKGDIR}/${PACKAGE}.tar.gz -C ${TARGETFS} > ${METADIR}/${CATEGORY}/${PACKAGE}.installed
    fi

    opm.stage.complete "merge"

    if opm.util.func_exists 'opm.postmerge'; then
        opm.postmerge
    fi
}
