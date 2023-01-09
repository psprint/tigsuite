#!/usr/bin/env zsh
#
# Copyright (c) 2022 Sebastian Gniazdowski

# A shared stub loaded as the first command in Tig/tigrc binding.
# It sets up environment for all Tig defined commands/bindings

# Handle $0 according to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html

0="${(%):-%x}"

# Mark start of new output
builtin print --

# Set the base and typically useful options
builtin emulate -L zsh
builtin setopt extendedglob warncreateglobal typesetsilent noshortloops \
    noautopushd promptsubst

local -x TINICK=TigSuite TINICK_=TigSu
typeset -gA Plugins

# FUNCTION: tigmsg [[[
# An wrapping function that looks for backend outputting function
# and uses a verbatim `print` builtin otherwise.
\tigmsg_()
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
alias tigmsg='noglob tigmsg_ $0:t\:$LINENO'
# ]]]

# Run as script? ZSH_SCRIPT is a Zsh 5.3 addition
if [[ $0 != */ti::global.zsh || ! -f $0 ]]; then
     if [[ -f $0:h/ti::global.zsh ]]; then
        Plugins[TIG_DIR]=$0:h:h
        TIG_SUITE_DIR=$Plugins[TIG_DIR]
    elif [[ -f $TIG_SUITE_DIR/libexec/ti::global.zsh ]]; then
        0=$TIG_SUITE_DIR/libexec/ti::global.zsh
        Plugins[TIG_DIR]=$TIG_SUITE_DIR
    elif [[ -f $Plugins[TIG_DIR]/libexec/ti::global.zsh ]]; then
        0=$Plugins[TIG_DIR]/libexec/ti::global.zsh
        TIG_SUITE_DIR=$Plugins[TIG_DIR]
    else
        local -a q=($Plugins[TIG_DIR] $TIG_SUITE_DIR $0:h:h)
        tigmsg {204}Error:%f couldn\'t locate {39}$TINICK\'s%f source \
            directory (tryied in dirs: {27}${(j:%f,{27}:)q}%f), cannot \
            continue.
        return 1
    fi
else
    Plugins[TIG_DIR]=$0:h:h
    TIG_SUITE_DIR=$Plugins[TIG_DIR]
fi

# Shorthand vars
local TIG=$0:h:h

Plugins[TIG_DIR]=$TIG
local -a reply match mbegin mend
local REPLY MATCH TMP; integer MBEGIN MEND
local -aU path=($path) fpath=($fpath)
local -U PATH FPATH

# In case of the script using other scripts from the plugin, either set up
# $fpath and autoload, or add the directory to $PATH.
fpath+=( $TIG/{libexec,functions}(N/) )

# OR
path+=( $TIG/{bin,libexec,functions}(N/) )

# Modules
zmodload zsh/parameter zsh/datetime

export TIREGI_FILE TILOG TICACHE TICHOOSE_APP TINL

 # Right customizable ~/.config/… and ~/.cache/… file paths
: ${TIREGI_FILE:=${${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/${(L)TINICK}}:-$HOME/.config/${(L)TINICK}}/features.reg}
: ${TICACHE:=${${XDG_CACHE_HOME:+$XDG_CACHE_HOME/${(L)TINICK}}:-$HOME/.cache/${(L)TINICK}}}
: ${TILOG:=$TICACHE/${(L)TINICK}.log}
: ${TINL:=$TILOG}
export TIREGI_FILE=${~TIREGI_FILE} TILOG=${~TILOG} TICACHE=${~TICACHE} \
        TINL=${~TINL}
command mkdir -p $TIREGI_FILE:h $TILOG:h $TICACHE $TINL:h
local QREGI_FILE=${TIREGI_FILE//(#s)$HOME/\~}
# useful global alias
alias -g TIO="&>>!$TILOG"

# No config dir found ?
if [[ ! -d $TIREGI_FILE:h ]]; then
    tigmsg -h {204}Error:%f Couldn\'t setup config directory \
                    at %B%F{39}$QREGI_FILE:h%b%f, exiting…
    return 1
fi

# No config ?
if [[ ! -f $TIREGI_FILE ]]; then
    command touch $TIREGI_FILE
    [[ ! -f $TIREGI_FILE ]]&&{tigmsg -h %U{204}Error:%f couldn\'t create \
                the registry-file %B{39}$QREGI_FILE%f%b, please addapt \
                file permissions or check if disk is full.
                return 4}
fi

# Config empty?
[[ ! -s $TIREGI_FILE ]]&&tigmsg -h %U{204}Warning:%f features registry-file \
                    \({41}$QREGI_FILE%F\) currently empty, need to \
                    add some entries

# Autoload functions
autoload -z regexp-replace $TIG/functions/(xzmsg|ti::)*~*'~'(#qN.non:t) \
                $TIG/functions/*/(ti::)*~*'~'(#qN.non:t2)

# Export a few local var
util/ti::verify-tigsuite-dir||return 1
util/ti::verify-chooser-app||return 1
util/ti::get-prj-dir||return 1
local -x PDIR=$REPLY PID=$REPLY:t:r
local -x TIPID_QUEUE=$TICACHE/PID::${(U)PID}.queue
local -x TIZERO_PAT='(#s)0#(#e)'

# Snippets with code
for q in $TIG/libexec/ti::*.zsh~*/ti::global.zsh(N.); do
    builtin source $q
    integer ret=$?
    if ((ret));then
        tigmsg -h %U{204}Error:%f error %B{174}$ret%f%b when sourcing \
            sub-file: {39}$q:t%f…
        return 1
    fi
done

# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker
