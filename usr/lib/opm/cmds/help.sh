help="
    ${0} help
        Show this help screen
"

opm.help() {
    echo "Usage:"
    for cmd in $OPMCMDDIR/*.sh ; do
        source $cmd
        if ! [ -z "$help" ] ; then
            echo -e "   $help"
            help=
        fi
    done
    echo "    ${0} category/package-version <action>"
    echo
    echo "    Available actions:"
    echo
    echo "      Utils:"
    for cmd in $OPMCMDDIR/actions/*.sh ; do
        source $cmd
        if ! [ -z "$help" ] ; then
            echo -e "           $help"
            help=
        fi
    done
    echo
    echo "      Stages:"
    for cmd in $OPMCMDDIR/actions/stages/*.sh ; do
        source $cmd
        if ! [ -z "$help" ] ; then
            echo -e "           $help"
            help=
        fi
    done
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
