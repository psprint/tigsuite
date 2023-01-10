#!/usr/bin/env zsh

emulate zsh -o extended_glob
typeset -g LOG_DIR=~/.config/tig

function log()
{
        local open=$1 l=${(M)2##<->##} time=`date +%y%m%d-%T`
        mkdir -p $LOG_DIR
        print
        if [[ -z $l ]]; then
            print -Pr -- %B%F{174}'\\'%F{69}°%F{174}'\\' %F{40}Opening%F{69}: %F{27}$open%f%b on $time | tee -a $LOG_DIR/open.log
        else
            print -Pr -- %B%F{174}'\\'%F{69}$l%F{174}'\\' %F{40}Opening%F{69}: %F{27}$open%F{14}:%F{174}$l%f%b on $time | tee -a $LOG_DIR/open.log
        fi
        sleep 1
}

function find-matches()
{
     local f=$1
     { reply=( **/$f:t(.NDY1) ) } 2>/dev/null
     return $(( !$#reply ))
}

msg()
{
    print -rP -- "%F{208}%BFailed to find the matched filename part (last used was: %F{40}$1%F{208})%f%b" \
        | tee -a $LOG_DIR/open.log
    (( $2 )) && exit $2
}

edit()
{
    local que=$EDITOR
    (($+commands[$que]))||que=mcedit
    (($+commands[$que]))||que=emacs
    (($+commands[$que]))||que=micro
    (($+commands[$que]))||que=vim
    (($+commands[$que]))||{print -P -- %B%F{135}Couldn\'t find editor, please \
        set {208}\$EDITOR{135}, exiting…;return 1;}
 
    $que ${2:++${(M)2##<->##}} $1
}

if [[ $1 == (#b)*(([[:space:]]##)|(#s))([^[:space:]]##):(#B)(:(#b)([^[:space:]]##)|)([[:space:]]##|(#e)) || $1 == (#b)[[:space:]]#((([^:]##))):([0-9]##|):* ]]; then
    find-matches $match[3]:t || { msg $match[3]:t 1;}
    log "$reply[1]" $match[4]
    edit "$reply[1]" $match[4]
else
    # Multiple tries – one for each token
    { local -a arr=( ${(Z+Cn+@)1} ) } 2>/dev/null
    local f
    for f in $arr; do
        if [[ -f $f ]]; then
            reply=( $f )
            log "$f"
            edit "$f"
        elif [[ $f == (#b)*(([[:space:]]##)|(#s))([^:[:space:]]##)(#B)(:(#b)([^[:space:]]##)|)([[:space:]]##|(#e))* ]]; then
            if [[ -f $match[3] ]]; then
                reply=( $match[3] )
                log "$match[3]" $match[4]
                edit "$match[3]" $match[4];
            else
                find-matches $match[3]:t || { continue}
                log "$reply[1]" $match[4]
                edit "$reply[1]" $match[4];
            fi
        fi
    done
fi

(( $#reply )) || msg "$match[3]:t" 1
