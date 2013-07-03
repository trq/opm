main() {

    case "${ACTION}" in
        sync)
            opm_sync
            ;;
        clean)
            src_clean
            ;;
        fetch)
            source_opm
            src_fetch
            ;;
        unpack)
            src_clean
            source_opm
            src_fetch
            src_unpack
            ;;
        configure)
            src_clean
            source_opm
            src_fetch
            src_unpack
            src_configure
            ;;
        compile)
            src_clean
            source_opm
            src_fetch
            src_unpack
            src_configure
            src_compile
            ;;
        install|all)
            src_clean
            source_opm
            src_fetch
            src_unpack
            src_configure
            src_compile
            src_install
            ;;
        *)
            die "Please specify unpack, configure, compile or all as the second arg"
            ;;
    esac

}
