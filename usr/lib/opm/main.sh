opm.main() {
    opm.util.source_opm
    shift
    while [ "${1}" != "" ]; do
        case "${1}" in
            unmerge)
                opm.unmerge
                ;;
            sync)
                opm.sync
                ;;
            clean)
                opm.clean
                ;;
            info)
                opm.info
                ;;
            purge)
                opm.purge
                ;;
            fetch)
                opm.fetch
                ;;
            unpack)
                opm.unpack
                ;;
            prepare)
                opm.prepare
                ;;
            configure)
                opm.configure
                ;;
            compile)
                opm.compile
                ;;
            preinstall)
                opm.preinstall
                ;;
            install)
                opm.install
                ;;
            postinstall)
                opm.postinstall
                ;;
            package)
                opm.package
                ;;
            merge)
                opm.merge
                ;;
            *)
                opm.usage
                exit 1
                ;;
        esac
        shift
    done
}
