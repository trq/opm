#!/usr/bin/env bash

_opm() {
    case $COMP_CWORD in
    1)
        local cur opts
        cur="${COMP_WORDS[COMP_CWORD]}"
        opts=$(find . -type f -name *.opm -not -name base.opm | sed 's/\.\///g' | sed 's/\.opm//g' | sed 's/\(.*\)\//\1-/')
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
    2)
        local cur opts
        cur="${COMP_WORDS[COMP_CWORD]}"
        opts="fetch unpack prepare configure compile install package merge unmerge clean"
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        ;;
    *)
        COMPREPLY=("")
        ;;
    esac
}

complete -F _opm opm
