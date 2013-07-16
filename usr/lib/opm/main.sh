opm.main() {
    opm.util.source_opm
    shift
    while [ "${1}" != "" ]; do
        case "${1}" in
            sync)
                opm.sync
                ;;
            clean)
                opm.clean
                ;;
            fetch)
                opm.fetch
                ;;
            unpack)
                opm.unpack
                ;;
            configure)
                opm.configure
                ;;
            compile)
                opm.compile
                ;;
            install)
                opm.install
                ;;
            package)
                opm.package
                ;;
            merge)
                opm.merge
                ;;
            unmerge)
                opm.unmerge
                ;;
            *)
                die "Please specify unpack, configure, compile or all as the second arg"
                ;;
        esac
        shift
    done
}
