opm.init() {
    # Resolve package specific information
    CATEGORY="${1%%/*}" ; export CATEGORY
    PACKAGE_NAME="${1##*/}"

    PACKAGE_VERSION="${PACKAGE_NAME##*-}"

    if ! [[ "$PACKAGE_VERSION" =~ ^[0-9] ]] ; then
        opm_file=$(ls ${OPMS}/${CATEGORY}/${PACKAGE_NAME}/ | grep ^[0-9].*\.opm$ | tail -n1)
        PACKAGE_VERSION=${opm_file%*.*}
    else
        tmp="${PACKAGE_NAME%-*}"
        PACKAGE_NAME="${tmp##*/}"
    fi

    PACKAGE_REVISION="${PACKAGE_VERSION#*_}"
    PACKAGE_VERSION=${PACKAGE_VERSION%_*}

    if [[ "$PACKAGE_REVISION" = "$PACKAGE_VERSION" ]] ;then
        PACKAGE_REVISION=
    fi

    export PACKAGE_NAME
    export PACKAGE_VERSION

    if ! [ -z $PACKAGE_REVISION ] ; then
        PACKAGE=$PACKAGE_NAME-${PACKAGE_VERSION}_${PACKAGE_REVISION} ; export PACKAGE
        pkg=$PACKAGE_NAME-${PACKAGE_VERSION} ;
    else
        PACKAGE=$PACKAGE_NAME-${PACKAGE_VERSION} ; export PACKAGE
        pkg=$PACKAGE_NAME-${PACKAGE_VERSION} ;
    fi

    TARGETFS=/ ; export TARGETFS

    # Laoad external config files in order of precedence.
    if [ -f $OPMDIR/etc/opm.conf ] ; then
        . $OPMDIR/etc/opm.conf
    fi

    if [ -f /etc/opm.conf ] ; then
        . /etc/opm.conf
    fi

    if [ -f ~/.opm.conf ] ; then
        . ~/.opm.conf
    fi


    # Working area.
    SANDBOX="${WORKDIR}/${PACKAGE}" ; export SANDBOX    # Root of the sandbox stuff
    STAGEDIR="${SANDBOX}/stages"    ; export INSTDIR    # Used to track what *stage* the build is currently in
    INSTDIR="${SANDBOX}/inst"       ; export INSTDIR    # Location package will be installed into
    WORKDIR="${SANDBOX}/work"       ; export WORKDIR    # Location source will be unpacked into
    BUILDDIR="${SANDBOX}/build"     ; export BUILDDIR   # Location source will be built within.
    SOURCEDIR="$WORKDIR/$pkg"       ; export SOURCEDIR  # The directory the actual unpacked source is in

    opm.util.source_opm
}

opm.dispatch() {
    while [ "${1}" != "" ]; do
        if [ -f ${OPMCMDDIR}/${1}.sh ] ; then
            source ${OPMCMDDIR}/${1}.sh
        fi

        if [ -f ${OPMCMDDIR}/actions/${1}.sh ] ; then
            source ${OPMCMDDIR}/actions/${1}.sh
        fi

        if [ -f ${OPMCMDDIR}/actions/stages/${1}.sh ] ; then
            source ${OPMCMDDIR}/actions/stages/${1}.sh
        fi

        if type -t "opm.${1}" | grep -q "function" ; then
            opm.${1}
        else
            opm.init "${1}"
        fi
        shift
    done
}
