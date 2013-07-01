#!/usr/bin/env bash

umask 022
unalias -a

die() { echo -e "\033[1;31m$@ \033[0m" 1>&2; exit 1; }
msg() { echo -e "\033[1;32m$@ \033[0m"; }

try() { msg "$@"; "$@" || die "Error running command: $@"; }
