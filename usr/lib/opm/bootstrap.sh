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
export EXTRAS=${OPMS}/${CATEGORY}/${PACKAGE_NAME}/extras

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
