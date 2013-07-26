help="clean     : Clean the build directory"

opm.clean() {
    if [ -d "${BUILDDIR}" ]; then
        msg "Cleaning build directory ..."
        rm -rf "${BUILDDIR}"
    fi
}
