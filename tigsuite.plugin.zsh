# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2023 Sebastian Gniazdowski
0="${(%):-%x}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Then ${0:h} to get plugin's directory
if [[ ${zsh_loaded_plugins[-1]} != */tigsuite && -z ${fpath[(r)${0:h}]} ]] {
    fpath+=( "${0:h}" )
}

# Add bin/ to path if requested
[[ -v tig_set_path ]]&&{typeset -gU path; path+=("${0:h}"/bin);}

# (){…} is to use extglob locally
typeset -gA Plugins
Plugins[TIG_DIR]="$0:h"
() {
    emulate -L zsh -o extendedglob
    : ${TINICK:=TigSuite}
    : ${TICONFIG:=${XDG_CONFIG_HOME:-$HOME/.config}/${(L)TINICK}}
    : ${TINFO:=$TICONFIG/features.reg}
    : ${TICACHE:=${XDG_CACHE_HOME:-$HOME/.cache}/${(L)TINICK}}
    : ${TILOG:=$TICACHE/tio.log}
    : ${TICHOOSE_APP:=tig-pick}

    export TICONFIG TINFO TIG_SUITE_DIR=$Plugins[TIG_DIR] \
        TIG_SUITE_GL=$Plugins[TIG_DIR]/libexec/ti::global.zsh \
        TIAES=$Plugins[TIG_DIR]/aliases \
        TICACHE TILOG

    autoload -z $TIG_SUITE_DIR/functions/(ti::|z*)*~*~(#qN.non:t) \
            $TIG_SUITE_DIR/functions/*/(ti::|z*)*~*~(#qN.non:t2)

    (($?||!$+functions[zmsg]))&&print "Warning: ·TigSuite·-plugin occurred" \
                                "problems when loading functions"

    # Use config
    local qc qct=${XDG_CONFIG_HOME:-$HOME/.config}/tig/config
    if [[ -n ${TIGRC_USER##$TIG_SUITE_DIR*} ]];then
        qc=$TIGRC_USER
    elif [[ -f $qct  ]];then
        qc=$qct
    elif [[ -f ~/.tigrc ]];then
        qc=$HOME/.tigrc
    fi

    # Set up aliases (global, suffix and the proper ones)
    [[ -f $TIAES/*[^~](#qNY1.) ]]&&for REPLY in $TIAES/*[^~];do
        REPLY="$REPLY:t=$(<$REPLY)"
        alias "${${REPLY#*=}%%:*}" "${(M)REPLY##[^=]##}=${REPLY#*:}"
    done

    # Save original config
    [[ -f $qc ]]&&TIORIG_RC=$qc||print "Warning: ·TigSuite· found no user" \
        "tigrc. (Run \`touch ~/.tigrc\` to mute this warning.)"
    export TIORIG_RC TIGRC_USER=$TIG_SUITE_DIR/xtigrc

    # Create new config which includes old
    print -r -- source $TIG_SUITE_DIR/tigrc>!$TIGRC_USER
    [[ -f $TIORIG_RC ]]&&print -r -- source $TIORIG_RC>>!$TIGRC_USER
}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
