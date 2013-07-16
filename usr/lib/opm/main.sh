opm.main() {
    case "${ACTION}" in
        sync)
            opm.sync
            ;;
        clean)
            opm.clean
            ;;
        fetch)
            opm.util.source_opm
            opm.fetch
            ;;
        unpack)
            opm.util.source_opm
            opm.unpack
            ;;
        configure)
            opm.util.source_opm
            opm.configure
            ;;
        compile)
            opm.util.source_opm
            opm.compile
            ;;
        install)
            opm.util.source_opm
            opm.install
            ;;
        package)
            opm.util.source_opm
            opm.package
            ;;
        merge)
            opm.util.source_opm
            opm.merge
            ;;
        unmerge)
            opm.util.source_opm
            opm.unmerge
            ;;
        *)
            die "Please specify unpack, configure, compile or all as the second arg"
            ;;
    esac
}
