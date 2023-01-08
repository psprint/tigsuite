# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# Copyright (c) 2022 Sebastian Gniazdowski

#
# Bash full initiate script
#

TINAME=tigsuite.plugin.sh
ZERO="$(cd -- "${BASH_SOURCE[0]%/*}" && pwd )"/$TINAME

_() {
    # Prepare environment (options, word splitting)
    local -a opts=(extglob failglob globstar)
    trap " $(shopt -p ${opts[@]}); $(shopt -po noglob); trap - RETURN" RETURN
    shopt -s ${opts[@]}
    set -f
    local IFS=

    if [[ ! -s $ZERO ]]; then
        printf "Couldn't get the correct tigsuite.plugin.sh path.\\n\
Provide it by setting ZERO to it.\\n"
        return 1
    fi

    # Standard hash for plugins, to not pollute the namespace
    : ${TICACHE:=${XDG_CACHE_HOME:+$XDG_CACHE_HOME/tigsuite}}
    : ${TICACHE:=$HOME/.cache/tigsuite}
    : ${TILOG:=$TICACHE/tig.log}
    : ${TICHOOSE_APP:=tig-pick}
    : ${TIG_SUITE_DIR:=${ZERO/*}}
    [[ $TIG_SUITE_DIR != /* || ! -f $TIG_SUITE_DIR/tigsuite.plugin.sh ]]&&\
        TIG_SUITE_DIR=${ZERO/*}
    [[ $TIG_SUITE_GL != */ti::global.zsh ]]&&\
        TIG_SUITE_GL=$TIG_SUITE_DIR/libexec/ti::global.zsh
    export TIG_SUITE_DIR TIG_SUITE_GL TICACHE TILOG TICHOOSE_APP

    # Use config
    local qc qct=${XDG_CONFIG_HOME:-$HOME/.config}/tig/tigrc
    if [[ -n ${TIGRC_USER##$TIG_SUITE_DIR*} ]]; then
        qc=$TIGRC_USER
    elif [[ -f $qct  ]]; then
        qc=$qct
    elif [[ -f ~/.tigrc ]]; then
        qc=$HOME/.tigrc
    fi

    # Save original config
    : ${TIG_ORIG_RC:=$qc}
    export TIG_ORIG_RC TIGRC_USER=$TIG_SUITE_DIR/xtigrc

    # Create new config which includes old
    printf "source $TIG_SUITE_DIR/tigrc\\n" >$TIGRC_USER
    [[ -n $TIG_ORIG_RC ]]&&printf "source $TIG_ORIG_RC\\n">>$TIGRC_USER
} && _ "$@"

unset -f _

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
