main() {

    if [ -e "$OPMS/$CATEGORY/$PACKAGE_NAME/defaults" ]; then
        source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "defaults"
    fi

    source_file "$OPMS/$CATEGORY/$PACKAGE_NAME" "$PACKAGE_VERSION"

    case "${ACTION}" in
        clean)
            src_clean
            ;;
        fetch)
            src_fetch
            ;;
        unpack)
            src_clean
            src_fetch
            src_unpack
            ;;
        configure)
            src_clean
            src_fetch
            src_unpack
            src_configure
            ;;
        compile)
            src_clean
            src_fetch
            src_unpack
            src_configure
            src_compile
            ;;
        install|all)
            src_clean
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
