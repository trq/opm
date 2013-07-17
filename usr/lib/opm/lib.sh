opm.sync() {
    cd ${OPMDIR}
    git submodule foreach git pull origin develop
}

opm.clean() {
    if [ -d "${BUILDDIR}" ]; then
        msg "Cleaning build directory ..."
        rm -rf "${BUILDDIR}"
    fi
}

opm.purge() {
    if [ -d "${SANDBOX}" ]; then
        msg "Purging sandbox ..."
        rm -rf "${SANDBOX}"
    fi
}

opm.fetch() {
    opm.util.requires_dir ${DISTDIR}

    for source in "${sources[@]}"; do
        if [ -z "$archive" ]; then archive=${sources##*/}; fi

        if ! [ -f "${DISTDIR}/${archive}" ]; then
            case "${source}" in
                http://*|https://*)
                    msg "Fetching ${archive} ..."
                    wget "${source}" -O "${DISTDIR}/${archive}"
                    if ! [ -s "${DISTDIR}/${archive}" ]; then
                        rm -f "${DISTDIR}/${archive}"
                        die "Unable to fetch ${archive}."
                    else
                        if ! [ -z $checksum ] ; then
                            md5=$(md5sum ${DISTDIR}/${archive} | awk '{print $1}')
                            if ! [ "${md5}" = "${checksum}" ] ; then
                                rm -f "${DISTDIR}/${archive}"
                                die "Checksum mismatch, try fetching again."
                            fi
                        fi
                    fi
                ;;
                *)
                    die "You have to provide '${archive}'."
                ;;
            esac
        fi
    done;
    unset source
}

opm.unpack() {
    opm.util.requires_dir ${DISTDIR} ${WORKDIR}

    for source in "${sources[@]}"; do
        if [ -z "$archive" ]; then archive=${sources##*/}; fi

        if ! [ -f "${DISTDIR}/${archive}" ]; then die "Missing source '${archive}'."; fi

        case "${source##*/}" in
            *.tar|*.tar.bz2|*.tar.xz|*.tar.gz|l*.tar.lzma)
                msg "Extracting ${DISTDIR}/"${archive}" ..."
                try tar xvf "${DISTDIR}/${archive}" -C "${WORKDIR}"
            ;;
            *)
                die "Unsupported format."
            ;;
        esac
    done;

    unset source

    [ ! -d "$SOURCEDIR" ] && die "Source directory $SOURCEDIR specified in \$SOURCEDIR does not exist. Exiting."

    cd "$SOURCEDIR"
}

opm.prepare() {
    return
}

opm.configure() {
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    [ -e ${SOURCEDIR}/configure ] && try ${SOURCEDIR}/configure \
        --prefix=${CONFIG_PREFIX:=/usr} \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --disable-dependency-tracking \
        "$@"
}

opm.compile() {
    msg "Compiling source ..."
    # Shoudn't we drop MAKEOPTS in favor of MAKEFLAGS variable which make use by default?
    cd "$BUILDDIR";
    try make "$MAKEOPTS"
}

opm.preinstall() {
    return
}

opm.install() {
    opm.util.requires_dir ${INSTDIR}

    msg "Installing into '$INSTDIR' ..."
    cd "$BUILDDIR";
    try make DESTDIR="$INSTDIR" install
}

opm.postinstall() {
    return
}

opm.package() {
    opm.util.requires_dir ${INSTDIR} ${PKGDIR}

    cd ${INSTDIR}
    msg "Packaging '$INSTDIR' ..."
    tar cvzf ${PKGDIR}/${PACKAGE}.tar.gz .
}

opm.merge() {
    opm.util.requires_dir ${METADIR}

    if [ -f ${PKGDIR}/${PACKAGE}.tar.gz ]; then
        msg "Merging '${PACKAGE}' into ${TARGETFS} ..."
        sudo tar xvf ${PKGDIR}/${PACKAGE}.tar.gz -C ${TARGETFS} > ${METADIR}/${PACKAGE}.installed
    fi
}

opm.unmerge() {
    opm.util.requires_dir ${METADIR}

    cd /

    if [ -f ${METADIR}/${PACKAGE}.installed ]; then
        for file in $(cat ${METADIR}/${PACKAGE}.installed) ; do
            msg "Removing '${file}' ..."
            rm ${file}
        done
    fi
}
