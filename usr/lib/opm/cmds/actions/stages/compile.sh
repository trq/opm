#!/usr/bin/env bash

opm.compile() {
    opm.stage.start "compile"
    opm.stage.requires "configure"

    msg "Compiling source ..."
    cd "$BUILDDIR";
    try make 2>&1 | tee ${SANDBOX}/compile.log

    opm.stage.complete "compile"
}
