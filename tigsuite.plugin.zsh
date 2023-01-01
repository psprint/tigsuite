# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2022 Sebastian Gniazdowski

# According to the Zsh Plugin Standard:
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0=${(%):-%x}

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
    export TIG_SUITE_DIR=$Plugins[TIG_DIR] \
        TIG_SUITE_GL=$Plugins[TIG_DIR]/libexec/ti::global.zsh
    autoload -z $TIG_SUITE_DIR/functions/(ti::|xzmsg)*~*~(:tN.)
}

# vim:ft=zsh:tw=80:sw=4:sts=4:et:foldmarker=[[[,]]]
