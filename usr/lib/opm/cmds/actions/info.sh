help="info      : Display information about an installed package"

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
