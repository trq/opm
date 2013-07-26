#!/usr/bin/env bash

opm.postinstall() {
    opm.stage.start "postinstall"
    opm.stage.requires "install"
    opm.stage.complete "postinstall"
}
