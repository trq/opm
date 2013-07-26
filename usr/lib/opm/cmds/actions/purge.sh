help="purge     : Remove the sandbox"

opm.purge() {
    if [ -d "${SANDBOX}" ]; then
        msg "Purging sandbox ..."
        rm -rf "${SANDBOX}"
    fi
}
