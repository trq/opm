#!/usr/bin/env bash

opm.preinstall() {
    opm.stage.start "preinstall"
    opm.stage.requires "compile"
    opm.stage.complete "preinstall"
}
