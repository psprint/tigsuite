#!/usr/bin/env zsh
#
# Copyright (c) 2022 Sebastian Gniazdowski

# A shared stub loaded as the first command in Tig/tigrc binding.
# It sets up environment for all Tig defined commands/bindings

# Handle $0 according to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0=${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}
0=${${(M)0##/*}:-$PWD/$0}
export TINICK=TigSuite

# FUNCTION: timsg [[[
# An wrapping function that looks for backend outputting function
# and uses a verbatim `print` builtin otherwise.
\timsg_()
{
    if [[ -x $TIG_SUITE_DIR/functions/xzmsg ]]; then
        $TIG_SUITE_DIR/functions/xzmsg "$@"
    elif (($+commands[xzmsg])); then
        command xzmsg "$@"
    elif (($+functions[xzmsg])); then
        xzmsg "$@"
    else
        builtin print -- ${@${@//(%f|%B|%F|%f)/}//\{[^\}]##\}/}
    fi
}

alias timsg='noglob timsg_ $0:t\:$LINENO'

# ]]]

# Run as script? ZSH_SCRIPT is a Zsh 5.3 addition
if [[ $0 != */ti::global.zsh ]]; then
     if [[ -f $0:h/ti::global.zsh ]]; then
        $Plugins[TIG_DIR]=$0:h:h
        TIG_SUITE_DIR=$Plugins[TIG_DIR]
    elif [[ -f $TIG_SUITE_DIR/libexec/ti::global.zsh ]]; then
        0=$TIG_SUITE_DIR/libexec/ti::global.zsh
        Plugins[TIG_DIR]=$TIG_SUITE_DIR
    elif [[ -f $Plugins[TIG_DIR]/libexec/ti::global.zsh ]]; then
        0=$Plugins[TIG_DIR]/libexec/ti::global.zsh
        TIG_SUITE_DIR=$Plugins[TIG_DIR]
    else
        local -a q=( $Plugins[TIG_DIR] $TIG_SUITE_DIR $0:h:h )
        timsg {204}Error:%f couldn\'t locate {39}Tig Suite\'s%f source \
            directory (tryied in dirs: {27}${(j:%f,{27}:)q}%f), cannot \
            continue.
        return 1
    fi
fi

# Set the base and typically useful options
builtin emulate -L zsh
builtin setopt extendedglob warncreateglobal typesetsilent noshortloops \
    noautopushd promptsubst

# Shorthand vars
local TIG=$0:h:h

# Such global variable is expected to be typeset'd -g in the plugin.zsh
# file. Here it's restored in case of the the file being sourced as a script.
typeset -gA Plugins
Plugins[TIG_DIR]=$TIG

# In case of the script using other scripts from the plugin, either set up
# $fpath and autoload, or add the directory to $PATH.
fpath+=( $TIG/{libexec,functions} )

# OR
path+=( $TIG/{libexec,functions} )

# Modules
zmodload zsh/parameter zsh/datetime zsh/stat

export TICONFIG=${${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/${(L)TINICK}}:-$HOME/.config/${(L)TINICK}}/features.conf
export TILOG=${${XDG_CACHE_HOME:+$XDG_CACHE_HOME/${(L)TINICK}}:-$HOME/.cache/${(L)TINICK}}/${(L)TINICK}.log
command mkdir -p $TICONFIG:h $TILOG:h
 
if [[ ! -d $TICONFIG:h ]]; then
    timsg -h {204}Error:%f Couldn\'t setup config directory \
                    at %B%F{39}$TICONFIG:h%b%f, cannot continue…
    return 3
fi

if [[ ! -f $TICONFIG ]]; then
    command touch $TICONFIG
    [[ ! -f $TICONFIG ]]&&{timsg -h %U{204}Error:%f couldn\'t create \
                the record-file %B{39}$TICONFIG%f%b, please addapt \
                file permissions or check if disk is full.
                return 4}
fi
[[ ! -s $TICONFIG ]]&&timsg -h %U{204}Warning:%f features record-file \
                    \({41}$TICONFIG%F\) currently empty, need to \
                    add some entries

 # Snippets with code
for q in $TIG/libexec/ti::*.zsh~*/ti::global.zsh; do
    builtin source $q
    integer ret=$?
    if ((ret));then
        timsg -h %U{204}Error:%f error %B{174}$ret%f%b when sourcing \
            sub-file: {39}$q%f…
        return 1
    fi
done

# Autoload functions
autoload -z $TIG/functions/(xzmsg|ti::)*~*~(:tN.)

# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker
