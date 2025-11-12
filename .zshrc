# vim  settings
# vim: set expandtab:
# vim: tabstop=4
# Lines configured by zsh-newuser-install
#
HISTFILE=~/.histfile
HISTSIZE=65536
SAVEHIST=65536
APPEND_HISTORY=1
HIST_IGNORE_DUPS=1
HIST_IGNORE_ALL_DUPS=1
HIST_FIND_NO_DUPS=1
HIST_BEEP=1


setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/dad/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# # copied from ~/.bash_profile
#
# User dependent .zshrc


if [ -f ~/.alias ] ; then
    . ~/.alias
else
    alias a='alias '                                # minimal aliases
    alias h='history '
    alias j='jobs -l '
    alias l='ls -CF '
    alias la='ls -CFa '
    alias ll='ls -Fal '
    alias L='ls -CL '
    alias pd='pushd '
    alias Pd='popd '
fi
# if we're not interactive ; skip entire script/file
if [ -n "$PS1" ] ; then

# functions to initialize shell
function prependpath()
{
    if test $# -lt 1; then
        echo "usage: prependpath directory"
        echo "Prepend directory to PATH; if it exists and it is not already in PATH"
        # this has the side effect of NOT moving target to front if it is already included
        # this may not be quite what is expectd or desired
        # so in these cases, use delfrompath, followed by prependpath
        return
    else
        newdir="$1"
        ###echo "prependpath got $newdir" ###echo
        if test ! -d "$newdir"
        then
            ###echo "prependpath: $newdir not a directory - ignored."  ###echo
            return
        fi
        for pathdir in $(echo $PATH | $TR ":" " ")
        do
            if [ "$pathdir" = "$newdir" ] ; then
                ###echo "prependpath: $newdir already on path - ignored."  ###echo
                return
            fi
        done
        PATH=$newdir:$PATH
    fi
}

function appendpath()
{
    if test $# -ne 1
    then
        echo "usage: appendpath directory "
        echo "Append directory to PATH; if it exists and is not already in PATH."
        # this has the side effect of NOT moving target to end if it is already included
        # this may not be quite what is expected or desired
        # in this case use delfrompath, followed by appendpath
        return
    fi
    newdir="$1"
    ###echo "appendpath got $newdir" ###DBG
    if test ! -d "$newdir"
    then
        ###echo "appendpath: $newdir not a directory - ignored." ###DBG
      return
    fi
    for pathdir in $(echo $PATH | $TR ":" " ")
    do
        if [ "$pathdir" = "$newdir" ] ; then
            ###echo "appendpath: $newdir already on path - ignored." ###DBG
          return
        fi
    done
    export PATH="$PATH:$newdir"
}

function delfrompath()
{
    if test $# -lt 1
    then
        echo "usage: delfrompath directory"
        echo "Delete ALL instances of directory from PATH variable"
        return
    else
        olddir=$1
        for pathdir in $(echo $PATH | tr ":" " ")
        do
            if [ "$pathdir" = "." ] ; then
                continue
            fi
            if [ "$pathdir" = "$olddir" ] ; then
                NP1=$(echo $PATH | sed -e "s,${olddir},,")
                NP2=$(echo $NP1 | tr -s ':')
                export PATH="$NP2"
           fi
        done
    fi
}

# remove leading and trailing colons from PATH - because they are variously (mis)interpreted
cleanpath()
{
    CLEANPATH=$( echo $PATH | sed -e 's/:$//' | tr -s ':' | sed -e 's/^://' )
    PATH="$CLEANPATH"
}

# functions to interactively modify initialization files

function esp()
{
  ${EDITOR:-vi} ~/.zshrc && pause && renew
}

function esv()
{
  ${EDITOR:-vi} ~/.vimrc ~/.gvimrc
}

function renew()
{
  # get and restore current directory
  my_cur_dir=$(pwd) 
  . ~/.zshrc
  cd "$my_cur_dir"
}

# functions for use in interactive shell mode

function pause()
{
  # this forces us to wait in case some prior call returns immediately, e.g. gvim
  echo -n "Press Enter to continue"
  read junk
}

function cls() {
  TERM=${TERM:-dumb} tput clear
}

# MacOS specific
# report file system path (directory/folder) associated with top finder window
function ff()
{ 
    osascript -e 'tell application "Finder"'\
    -e "if (${1-1} <= (count Finder windows)) then"\
    -e "get POSIX path of (target of window ${1-1} as alias)"\
    -e 'else' -e 'get POSIX path of (desktop as alias)'\
    -e 'end if' -e 'end tell'; 
}

# change to directory associated with top finder window
# very convenient, no?
function cdff()
{ 
    cd "`ff $@`"
}


# edit/export environment variables
# Note: This version will set, but not properly modify variables 
# to/with multi-line values
function ev() 
{ 
    TMP=/tmp/edenv.$$;
    if test $# -lt 1 ; then
        echo "Set or edit and export named environment variable(s)";
    else
  > $TMP
  for ENV
  do
    echo TMP=$TMP
    VAL=$(set | egrep "^$ENV=" | sed -e "s@$ENV=@@" -e "s@\'@@g")
    echo "$ENV=\"$VAL\"
export $ENV" >> $TMP ;
  done
        ${EDITOR:-vi} $TMP
        . $TMP
        rm -f $TMP
    fi
}

# MAIN

# assume this here
TR=/usr/bin/tr

prependpath /usr/local/sbin                     # ?? HomeBrew
prependpath /usr/local/bin

prependpath /opt/homebrew/sbin                     # Apple Silicon HomeBrew
prependpath /opt/homebrew/bin

appendpath /bin
appendpath /usr/bin
appendpath /usr/sbin
appendpath /sbin
#
delfrompath ~/Desktop/cli ; prependpath ~/Desktop/cli # ensure in first place

delfrompath /System/Cryptexes/App/usr/bin
delfrompath "/Applications/Little Snitch.app/Contents/Components"
delfrompath /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin
delfrompath /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
delfrompath /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
#

cleanpath

# local customizations
set -o notify                                   # Don't wait for job termination notification
set -o ignoreeof                                # Don't use ^D to exit

#export HISTCONTROL=ignoredups                  # Don't store duplicates in history.
export EDITOR=vim                               # other settings for externals ; may no longer need; check
#
#
function psb() 
{ 
    export PS1="\u@\h \w \# \\$ "               # workable basic prompt
}

function psz() 
{ 
    export PS1="%n@%m %W %* %~ %! \$ "
}

function pzs() 
{ 
    export PS1="%n@%m %~ %! \$ "
}

pzs

# set group friendly user permissions mask
umask 002

# end interactive script path
else
    echo "Non Interactive Invocation"
fi

