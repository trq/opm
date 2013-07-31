opm.stage.start() {
    if [ "$1" == 'fetch' ] ; then
        if opm.util.func_exists 'opm.pre'; then
            opm.pre
        fi
    fi
    STAGE+=($1)
    opm.util.requires_dir ${STAGEDIR}
    touch "$STAGEDIR/$1-pending"
    msg "starting"
}

opm.stage.complete() {
    opm.util.requires_dir ${STAGEDIR}
    if [ -f "$STAGEDIR/$1-pending" ] ; then
        mv "$STAGEDIR/$1-pending" "$STAGEDIR/$1"
    else
        touch "$STAGEDIR/$1"
    fi
    msg "completed"
    unset STAGE[${#STAGE[@]}-1]

    # Handle postmerge
    if [ "$1" == 'merge' ] ; then
        if opm.util.func_exists 'opm.post'; then
            opm.post
        fi
    fi
}

opm.stage.fail() {
    opm.util.requires_dir ${STAGEDIR}
    if [ -f "$STAGEDIR/$1-pending" ] ; then
        mv "$STAGEDIR/$1-pending" "$STAGEDIR/$1-failed"
    else
        touch "$STAGEDIR/$1-failed"
    fi

    die "failed"
    exit 1
}

opm.stage.is_complete() {
    [ -f "$STAGEDIR/$1" ]
}

opm.stage.requires() {
    if [ -z $virtual ] ; then
        if ! opm.stage.is_complete $1; then
            if opm.util.func_exists "opm.$1"; then
                msg "> ${1}"
                opm.${1}
                if [ $? -ne 0 ] ; then
                    opm.stage.fail ${STAGE[${#STAGE[@]}-1]}
                fi
            fi
        fi
    fi
}
