opm.list() {
    echo
    echo  Installed Packages:
    echo
    for installed in $(ls --color=never ${METADIR}) ; do
        success ${installed%*.installed} ;
    done
    echo
}

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

    opm.util.complete_stage "fetch"
}

opm.unpack() {
    opm.util.requires_stage "fetch"
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
    opm.util.complete_stage "unpack"
}

opm.prepare() {
    opm.util.requires_stage "unpack"
    opm.util.complete_stage "prepare"
}

opm.configure() {
    opm.util.requires_stage "prepare"
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    opm.util.configure \
        --prefix=${CONFIG_PREFIX:=/usr} \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --disable-dependency-tracking

    opm.util.complete_stage "configure"
}

opm.compile() {
    opm.util.requires_stage "configure"

    msg "Compiling source ..."
    cd "$BUILDDIR";
    try make 2>&1 | tee ${SANDBOX}/compile.log

    opm.util.complete_stage "configure"
}

opm.preinstall() {
    opm.util.requires_stage "compile"
    opm.util.complete_stage "preinstall"
}

opm.install() {
    opm.util.requires_stage "preinstall"
    opm.util.requires_dir ${INSTDIR}

    msg "Installing into '$INSTDIR' ..."
    cd "$BUILDDIR";
    try make DESTDIR="$INSTDIR" install

    opm.util.complete_stage "install"
}

opm.postinstall() {
    opm.util.requires_stage "install"
    opm.util.complete_stage "postinstall"
}

opm.package() {
    opm.util.requires_stage "postinstall"
    opm.util.requires_dir ${INSTDIR} ${PKGDIR}

    cd ${INSTDIR}
    msg "Packaging '$INSTDIR' ..."
    tar cvzf ${PKGDIR}/${PACKAGE}.tar.gz .

    opm.util.complete_stage "package"
}

opm.merge() {
    opm.util.requires_stage "package"
    opm.util.requires_dir ${METADIR}

    if [ -f ${PKGDIR}/${PACKAGE}.tar.gz ]; then
        msg "Merging '${PACKAGE}' into ${TARGETFS} ..."
        sudo tar xvf ${PKGDIR}/${PACKAGE}.tar.gz -C ${TARGETFS} > ${METADIR}/${PACKAGE}.installed
    fi

    opm.util.complete_stage "merge"
}

opm.unmerge() {
    opm.util.requires_dir ${METADIR}

    cd ${TARGETFS:=/}

    if [ -f ${METADIR}/${PACKAGE}.installed ]; then
        for file in $(cat ${METADIR}/${PACKAGE}.installed) ; do
            msg "Removing '${file}' ..."
            rm ${file}
        done
    fi
}
