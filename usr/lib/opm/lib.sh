# Auxiliary actions.

opm.list() {
    echo
    echo  Installed Packages:
    echo
    for installed in $(find ${METADIR} -type f -printf '%P\n' | sort) ; do
        echo ${installed%*.installed} ;
    done
    echo
}

opm.info() {
    echo "Package: $CATEGORY/$PACKAGE"
    if [ -n "$description" ] ; then
        local description=$(echo $description | fold -w80 -s -)
        echo "Description:"
        echo "  $description"
        echo
        echo "Sources:"
        for url in "${sources[@]}"
        do
            echo "  $url"
        done
        echo
    fi
    if [ -f ${METADIR}/${CATEGORY}/${PACKAGE}.installed ] ; then
        echo -e "\033[00;32mInstalled:\033[0m"
        echo "Install Date: $(date -r ${METADIR}/${CATEGORY}/${PACKAGE}.installed)"
        echo "Merged Files:"
        echo
        cat $METADIR/$CATEGORY/$PACKAGE.installed
    else
        echo -e "\033[00;31mNot Installed\033[0m"
    fi
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

opm.unmerge() {
    opm.util.requires_dir ${METADIR}

    cd ${TARGETFS:=/}

    set +e

    if [ -f ${METADIR}/${CATEGORY}/${PACKAGE}.installed ]; then
        for file in $(cat ${METADIR}/${CATEGORY}/${PACKAGE}.installed) ; do
            msg "Removing '${file}' ..."
            if [ "$file" != './' ] ; then
                rm -f ${file}
            fi
        done
        rm ${METADIR}/${CATEGORY}/${PACKAGE}.installed
    fi

    set -e
}

# Stages

opm.fetch() {
    opm.stage.start "fetch"
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

    opm.stage.complete "fetch"
}

opm.unpack() {
    opm.stage.start "unpack"
    opm.stage.requires "fetch"
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
    opm.stage.complete "unpack"
}

opm.prepare() {
    opm.stage.start "prepare"
    opm.stage.requires "unpack"
    opm.stage.complete "prepare"
}

opm.configure() {
    opm.stage.start "configure"
    opm.stage.requires "prepare"
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    opm.util.configure

    opm.stage.complete "configure"
}

opm.compile() {
    opm.stage.start "compile"
    opm.stage.requires "configure"

    msg "Compiling source ..."
    cd "$BUILDDIR";
    try make 2>&1 | tee ${SANDBOX}/compile.log

    opm.stage.complete "compile"
}

opm.preinstall() {
    opm.stage.start "preinstall"
    opm.stage.requires "compile"
    opm.stage.complete "preinstall"
}

opm.install() {
    opm.stage.start "install"
    opm.stage.requires "preinstall"
    opm.util.requires_dir ${INSTDIR}

    msg "Installing into '$INSTDIR' ..."
    cd "$BUILDDIR";
    try make DESTDIR="$INSTDIR" install 2>&1 | tee ${SANDBOX}/install.log

    opm.stage.complete "install"
}

opm.postinstall() {
    opm.stage.start "postinstall"
    opm.stage.requires "install"
    opm.stage.complete "postinstall"
}

opm.package() {
    opm.stage.start "package"
    opm.stage.requires "postinstall"
    opm.util.requires_dir ${INSTDIR} ${PKGDIR}

    cd ${INSTDIR}

    if [ "$(ls -A $INSTDIR)" ] ; then
        msg "Packaging '$INSTDIR' ..."
        tar cpvzf ${PKGDIR}/${PACKAGE}.tar.gz .
    else
        error "'$INSTDIR' is empty"
        opm.stage.fail "package"
    fi

    opm.stage.complete "package"
}

opm.merge() {
    opm.stage.start "merge"
    opm.stage.requires "package"
    opm.util.requires_dir ${METADIR}/${CATEGORY}

    if [ -f ${PKGDIR}/${PACKAGE}.tar.gz ]; then
        msg "Merging '${PACKAGE}' into ${TARGETFS} ..."
        tar xpvfh ${PKGDIR}/${PACKAGE}.tar.gz -C ${TARGETFS} > ${METADIR}/${CATEGORY}/${PACKAGE}.installed
    fi

    opm.stage.complete "merge"
}
