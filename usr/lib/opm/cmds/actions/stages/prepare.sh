#!/usr/bin/env bash

opm.prepare() {
    opm.stage.start "prepare"
    opm.stage.requires "unpack"
    opm.stage.complete "prepare"
}
