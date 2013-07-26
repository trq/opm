#!/usr/bin/env bash

help="
    ${0} sync
        Sync the package repository with upstream
"

opm.sync() {
    cd ${OPMDIR}
    git submodule foreach git pull origin develop
}
