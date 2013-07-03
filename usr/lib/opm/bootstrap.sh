# Store the current location
ORIGDIR="$(pwd)"

# Create directory locations
OPMS="${OPMDIR}/var/opm/opms"
DISTDIR="${OPMDIR}/var/opm/distfiles"
WORKDIR="${OPMDIR}/tmp/opm"

# Resolve package specific information
CATEGORY="${1%%/*}"                     ; export CATEGORY
PACKAGE_NAME="${1##*/}"                 ; export PACKAGE_NAME
OPM_FILE=$(ls ${OPMS}/${CATEGORY}/${PACKAGE_NAME}/ | grep ^[0-9].*\.opm$ | tail -n1)
PACKAGE_VERSION=${OPM_FILE%*.*}         ; export PACKAGE_VERSION
PACKAGE=$PACKAGE_NAME-$PACKAGE_VERSION  ; export PACKAGE

# Dynamically configure some defaults.
NUMCPU="$(grep -c '^processor' /proc/cpuinfo)" ; export NUMCPU
if [ -z "${MAKEOPTS}" ]; then
    export MAKEOPTS="--jobs=$NUMCPU"
fi

## Laoad external config file.
if [ -f $OPMDIR/etc/opm.conf ] ; then
    . $OPMDIR/etc/opm.conf
fi

# Working area.
SANDBOX="${WORKDIR}/${PACKAGE}" ; export SANDBOX    # Root of the sandbox stuff
INSTDIR="${SANDBOX}/inst"       ; export INSTDIR    # Location package will be installed into
WORKDIR="${SANDBOX}/work"       ; export WORKDIR    # Location source will be unpacked to.
SOURCEDIR="$WORKDIR/$PACKAGE"   ; export SOURCEDIR  # THe directory the actual source is in
