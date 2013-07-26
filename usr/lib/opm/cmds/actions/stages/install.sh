#!/usr/bin/env bash

opm.install() {
    opm.stage.start "install"
    opm.stage.requires "preinstall"
    opm.util.requires_dir ${INSTDIR}

    msg "Installing into '$INSTDIR' ..."
    cd "$BUILDDIR";
    try make DESTDIR="$INSTDIR" install 2>&1 | tee ${SANDBOX}/install.log

    opm.stage.complete "install"
}
