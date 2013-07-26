#!/usr/bin/env bash

opm.configure() {
    opm.stage.start "configure"
    opm.stage.requires "prepare"
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    opm.util.configure \
        --prefix=${CONFIG_PREFIX:=/usr} \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --disable-dependency-tracking

    opm.stage.complete "configure"
}
