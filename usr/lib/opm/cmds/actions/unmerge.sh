help="unmerge   : Remove the package from the root filesystem"

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
