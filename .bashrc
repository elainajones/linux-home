# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi
# Put your fun stuff here.
source ~/bin/git-prompt.sh
if [[ -f ~/.bash_aliases ]]; then
	source ~/.bash_aliases
fi

# gruvbox-dark theme
# url github.com/raindeer44/gruvbox-tty
# raindeer44 <github.com/raindeer44>
# based on gruvbox.vim by morhetz <github.com/morhetz>
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0282828" #bg0
    echo -en "\e]P8928374" #grey
    echo -en "\e]P1cc241d" #darkred
    echo -en "\e]P9fb4934" #red
    echo -en "\e]P298971a" #darkgreen
    echo -en "\e]PAb8bb26" #green
    echo -en "\e]P3d79921" #darkyellow
    echo -en "\e]PBfabd2f" #yellow
    echo -en "\e]P4458588" #darkblue
    echo -en "\e]PC83a598" #blue
    echo -en "\e]P5b16286" #darkmagenta
    echo -en "\e]PDd3869b" #magenta
    echo -en "\e]P6689d6a" #darkcyan
    echo -en "\e]PE8ec07c" #cyan
    echo -en "\e]P7a89984" #fg4
    echo -en "\e]PFebdbb2" #fg1
    clear #for background artifacting
fi

export VISUAL=vim
export EDITOR="$VISUAL"
export GIT_EDITOR=vim
export GPG_TTY=$(tty)
export PS1='\[\e[01;32m\]\u@\h\[\e[01;34m\] \w$(__git_ps1 " (%s)") \$\[\e[00m\] '
