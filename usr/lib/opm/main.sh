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
            purge)
                opm.purge
                ;;
            fetch)
                opm.fetch
                opm.util.complete_stage fetch
                ;;
            unpack)
                opm.util.requires_stage fetch
                opm.unpack
                opm.util.complete_stage unpack
                ;;
            prepare)
                opm.util.requires_stage unpack
                opm.prepare
                opm.util.complete_stage prepare
                ;;
            configure)
                opm.util.requires_stage prepare
                opm.configure
                opm.util.complete_stage configure
                ;;
            compile)
                opm.util.requires_stage configure
                opm.compile
                opm.util.complete_stage compile
                ;;
            install)
                opm.util.requires_stage compile
                opm.install
                opm.util.complete_stage 'install'
                ;;
            package)
                opm.util.requires_stage 'install'
                opm.package
                opm.util.complete_stage package
                ;;
            merge)
                opm.util.requires_stage package
                opm.merge
                opm.util.complete_stage merge
                ;;
            *)
                opm.usage
                exit 1
                ;;
        esac
        shift
    done
}
