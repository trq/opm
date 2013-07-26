help="
    ${0} list
        List installed packages
"

opm.list() {
    echo
    echo  Installed Packages:
    echo
    for installed in $(ls --color=never ${METADIR}) ; do
        echo ${installed%*.installed} ;
    done
    echo
}
