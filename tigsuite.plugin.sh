# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# Copyright (c) 2023 Sebastian Gniazdowski

#
# Bash full initiate script
#

TMP="$_"
TINAME=tigsuite.plugin.sh
[[ ! -f $TMP ]]&&TMP="${BASH_SOURCE[0]}"
[[ $TMP != ./* && $TMP != /* ]]&&TMP=./"$TMP"
ZERO="$(cd -- "${TMP%/*}" 2>/dev/null && pwd )"/$TINAME
unset TMP

err_trap() {
    local cmd=$1 l=$2 rc=$3 msg=$4

    printf "[%s:%s] %s\\n" "${ZERO##*/}" "$l" \
        "Error occured, cmd=·$cmd·, code=$rc $msg"
    return ${rc:-9}
}

_() {

    #
    # Environment preparation for this file (options, word splitting)
    #

    local -a opts=(extglob failglob globstar)
    trap " $(shopt -p ${opts[@]}); $(shopt -po noglob); trap - RETURN ERR" RETURN
    trap 'err_trap "$BASH_COMMAND" "$LINENO" "$?" "$1"; trap - ERR' ERR
    shopt -s ${opts[@]}
    set -f
    local IFS=

    #
    # Environment preparation for the plugin (exported vars, PATH, etc.)
    #
    if [[ ! -s $ZERO ]]; then
        printf "Couldn't get the correct tigsuite.plugin.sh path.\\n\
Provide it by setting ZERO to it.\\n"
        return 1
    fi

    # Standard hash for plugins, to not pollute the namespace
    : ${TICONFIG:=${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/tigsuite}}
    : ${TICONFIG:=$HOME/.config/tigsuite}
    : ${TINFO:=$TICONFIG/features.reg}
    : ${TICACHE:=${XDG_CACHE_HOME:+$XDG_CACHE_HOME/tigsuite}}
    : ${TICACHE:=$HOME/.cache/tigsuite}
    : ${TILOG:=$TICACHE/tig.log}
    : ${TICHOOSE_APP:=tig-pick}
    : ${TIG_SUITE_DIR:=${ZERO%/*}}
    [[ $TIG_SUITE_DIR != /* || ! -f $TIG_SUITE_DIR/tigsuite.plugin.sh ]]&&\
        TIG_SUITE_DIR=${ZERO%/*}
    [[ $TIG_SUITE_GL != */ti::global.zsh ]]&&\
        TIG_SUITE_GL=$TIG_SUITE_DIR/libexec/ti::global.zsh
    export TIG_SUITE_DIR TIG_SUITE_GL TICACHE TILOG TICHOOSE_APP

    # Use config
    local qc qct=${XDG_CONFIG_HOME:-$HOME/.config}/tig/config
    if [[ -n ${TIGRC_USER##$TIG_SUITE_DIR*} ]]; then
        qc=$TIGRC_USER
    elif [[ -f $qct  ]]; then
        qc=$qct
    elif [[ -f ~/.tigrc ]]; then
        qc=$HOME/.tigrc
    fi

    # Save original config
    [[ -f $qc ]]&&TIORIG_RC=$qc||printf "Warning: ·TigSuite· found\
 no user tigrc. (Run \`touch ~/.tigrc\` to mute this warning.)\\n"
    export TIORIG_RC TIGRC_USER=$TIG_SUITE_DIR/xtigrc

    # Create new config which includes old
    printf "source $TIG_SUITE_DIR/tigrc\\n">"$TIGRC_USER"
    [[ -f $TIORIG_RC ]]&&printf "source $TIORIG_RC\\n">>"$TIGRC_USER"
    [[ $PATH == *$TIG_SUITE_DIR*]]||PATH=$TIG_SUITE_DIR/bin:$PATH
} && _ "$@"

unset -f _ err_trap

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
