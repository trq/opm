opm.stage.start() {
    opm.util.requires_dir ${STAGEDIR}
    export STAGE=$1
    touch "$STAGEDIR/$1-pending"
    msg "Starting stage $1"
}

opm.stage.complete() {
    opm.util.requires_dir ${STAGEDIR}
    export STAGE=
    if [ -f "$STAGEDIR/$1-pending" ] ; then
        mv "$STAGEDIR/$1-pending" "$STAGEDIR/$1"
    else
        touch "$STAGEDIR/$1"
    fi
    msg "Completing stage $1"
}

opm.stage.fail() {
    opm.util.requires_dir ${STAGEDIR}
    if [ -f "$STAGEDIR/$1-pending" ] ; then
        mv "$STAGEDIR/$1-failed" "$STAGEDIR/$1"
    else
        touch "$STAGEDIR/$1-failed"
    fi

    die "Stage $STAGE failed"
    exit 1
}

opm.stage.is_complete() {
    [ -f "$STAGEDIR/$1" ]
}

opm.stage.requires() {
    if [ -z $virtual ] ; then
        if ! opm.util.is_stage_complete $1; then
            if opm.util.func_exists "opm.$1"; then
                opm.${1}
            fi
        fi
    fi
}
