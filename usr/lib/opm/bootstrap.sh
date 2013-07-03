# Store the current location
ORIGDIR="$(pwd)"

# Resolve package specific variables.
PACKAGE_VERSION="${1##*-}" ; export PACKAGE_VERSION
rest="${1%-*}"
PACKAGE_NAME="${rest##*/}" ; export PACKAGE_NAME
CATEGORY="${1%%/*}" ; export CATEGORY
PACKAGE=$PACKAGE_NAME-$PACKAGE_VERSION ; export PACKAGE

export NUMCPU="$(grep -c '^processor' /proc/cpuinfo)"
if [ -z "${MAKEOPTS}" ]; then
    export MAKEOPTS="--jobs=$NUMCPU"
fi

if [ -f $OPMDIR/etc/opm.conf ] ; then
    . $OPMDIR/etc/opm.conf
fi

OPMS="${OPMDIR}/var/opm/opms"
DISTDIR="${OPMDIR}/var/opm/distfiles"
WORKDIR="${OPMDIR}/tmp/opm"

# Working area.
SANDBOX="${WORKDIR}/${PACKAGE}" ; export SANDBOX  # Root of the sandbox stuff
INSTDIR="${SANDBOX}/inst"       ; export INSTDIR  # Location package will be installed into
WORKDIR="${SANDBOX}/work"       ; export WORKDIR  # Location source will be unpacked to.

export SOURCEDIR="$WORKDIR/$PACKAGE"
