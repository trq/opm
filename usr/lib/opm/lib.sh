opm.sync() {
    cd ${OPMDIR}
    git submodule foreach git pull origin develop
}

opm.clean() {
    if [ -d "${SANDBOX}" ]; then
        msg "Cleaning old sources ..."
        rm -rf "${SANDBOX}"
    fi
}

opm.fetch() {
    opm.util.requires_dir ${DISTDIR}

    for source in "${sources[@]}"; do
        if ! [ -f "${DISTDIR}/${source##*/}" ]; then
            case "${source}" in
                http://*|https://*)
                    msg "Fetching ${source##*/} ..."
                    wget "${source}" -O "${DISTDIR}/${source##*/}"
                    if ! [ -s "${DISTDIR}/${source##*/}" ]; then
                        rm -f "${DISTDIR}/${source##*/}"
                        die "Unable to fetch ${source##*/}."
                    fi
                ;;
                *)
                    die "You have to provide '${source##*/}'."
                ;;
            esac
        fi
    done; unset source
}

opm.unpack() {
    opm.util.requires_dir ${DISTDIR} ${WORKDIR}

    for source in "${sources[@]}"; do
        if ! [ -f "${DISTDIR}/${source##*/}" ]; then die "Missing source '${source##*/}'."; fi

        case "${source##*/}" in
            *.tar|*.tar.bz2|*.tar.xz|*.tar.gz|l*.tar.lzma)
                msg "Extracting ${DISTDIR}/"${source##*/}" ..."
                try tar xf "${DISTDIR}/${source##*/}" -C "${WORKDIR}"
            ;;
            *)
                die "Unsupported format."
            ;;
        esac
    done;

    unset source

    [ ! -d "$SOURCEDIR" ] && die "Source directory $SOURCEDIR specified in \$SOURCEDIR does not exist. Exiting."

    # We should cd into $SOURCEDIR before src_configure is done or ebuild will fail when we override src_configure with an ebuild.
    # like into e2fsprogs-1.18.ebuild.
    cd "$SOURCEDIR"
}

opm.compile() {
    msg "Compiling source ..."
    # Shoudn't we drop MAKEOPTS in favor of MAKEFLAGS variable which make use by default?
    cd "$SOURCEDIR"; try make "$MAKEOPTS"
}

opm.configure() {
    msg "Configuring source ..."
    cd "$SOURCEDIR"; [ -e ./configure ] && try ./configure \
        --prefix=/usr \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --disable-dependency-tracking \
        "$@"
}

opm.install() {
    opm.util.requires_dir ${INSTDIR}

    msg "Installing into '$INSTDIR' ..."
    cd "$SOURCEDIR"; try make DESTDIR="$INSTDIR" install
}
