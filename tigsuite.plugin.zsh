# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2022 Sebastian Gniazdowski

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${(%):-%x}"

# Then ${0:h} to get plugin's directory

if [[ ${zsh_loaded_plugins[-1]} != */tigsuite && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# (){…} is to use extglob locally

typeset -gA Plugins
Plugins[TIG_DIR]="$0:h"
() {
    emulate -L zsh -o extendedglob
    # Standard hash for plugins, to not pollute the namespace
    : ${TICACHE:=${${XDG_CACHE_HOME:+$XDG_CACHE_HOME/tigsuite}:-\
$HOME/.cache/tigsuite}}
    : ${TILOG:=$TICACHE/tio.log}
    : ${TICHOOSE_APP:=tig-pick}
    export TIG_SUITE_DIR=$Plugins[TIG_DIR] \
        TIG_SUITE_GL=$Plugins[TIG_DIR]/libexec/ti::global.zsh \
        TICACHE TILOG
    autoload -z $TIG_SUITE_DIR/functions/(ti::|xzmsg)*~*~(:tN.)

    # Use config
    local qc qct=${XDG_CONFIG_HOME:-$HOME/.config}/tig/tigrc
    if [[ -n ${TIGRC_USER##$TIG_SUITE_DIR*} ]];then
        qc=$TIGRC_USER
    elif [[ -f $qct  ]];then
        qc=$qct
    elif [[ -f ~/.tigrc ]];then
        qc=$HOME/.tigrc
    fi

    # Save original config
    : ${TIG_ORIG_RC:=$qc}
    export TIG_ORIG_RC TIGRC_USER=$TIG_SUITE_DIR/xtigrc

    # Create new config which includes old
    print -r -- source $TIG_SUITE_DIR/tigrc>!$TIGRC_USER
    [[ -n $TIG_ORIG_RC ]]&&print -r -- source $TIG_ORIG_RC>>!$TIGRC_USER
}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
