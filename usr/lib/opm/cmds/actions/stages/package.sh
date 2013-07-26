#!/usr/bin/env bash

opm.package() {
    opm.stage.start "package"
    opm.stage.requires "postinstall"
    opm.util.requires_dir ${INSTDIR} ${PKGDIR}

    cd ${INSTDIR}

    if [ "$(ls -A $INSTDIR)" ] ; then
        msg "Packaging '$INSTDIR' ..."
        tar cpvzfh ${PKGDIR}/${PACKAGE}.tar.gz .
    else
        error "'$INSTDIR' is empty"
        opm.stage.fail "package"
    fi

    opm.stage.complete "package"
}
