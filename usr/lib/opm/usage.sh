opm.usage() {
    echo "Usage:"
    echo "  ${0} category/package-version <action>"
    echo
    echo "Available actions:"
    echo "  help        : show this help screen"
    echo "  unmerge     : remove the package from the root filesystem"
    echo "  sync        : "
    echo "  clean       : clean the build directory"
    echo "  purge       : remove the sandbox"
    echo "  fetch       : download source archive(s) and patches"
    echo "  unpack      : unpack sources"
    echo "  prepare     : prepare source"
    echo "  configure   : configure sources"
    echo "  compile     : compile sources"
    echo "  install     : install the package to the temporary install directory"
    echo "  package     : package the package into a tarball"
    echo "  merge       : merge the packaged tarball into the root filesystem"
    echo
}
