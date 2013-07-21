opm.usage() {
    echo "Usage:"
    echo "  ${0} list"
    echo "      list installed builds"
    echo
    echo "  ${0} info <category>/<package>"
    echo "      list information about an installed package"
    echo
    echo "  ${0} sync"
    echo "      sync the package repository with upstream"
    echo
    echo "  ${0} help"
    echo "      show this help screen"
    echo
    echo "  ${0} category/package-version <action>"
    echo
    echo "  Available actions:"
    echo
    echo "      Utils:"
    echo "          unmerge     : remove the package from the root filesystem"
    echo "          clean       : clean the build directory"
    echo "          purge       : remove the sandbox"
    echo
    echo "      Stages:"
    echo "          fetch       : download source archive(s) and patches"
    echo "          unpack      : unpack sources"
    echo "          prepare     : prepare source"
    echo "          configure   : configure sources"
    echo "          compile     : compile sources"
    echo "          preinstall  : pre install utility"
    echo "          install     : install the package to the temporary install directory"
    echo "          postinstall : post install utility"
    echo "          package     : package the package into a tarball"
    echo "          merge       : merge the packaged tarball into the root filesystem"
    echo
}
