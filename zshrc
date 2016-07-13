# Path to your oh-my-zsh configuration.
ZSH=$HOME/.zsh/oh-my-zsh
ZSH_THEME=""
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
# export UPDATE_ZSH_DAYS=30

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(history history-substring-search extract compleat git docker zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Path settings
export PATH=$PATH:~/bin:~/go/bin
export GOPATH=~/go

# Stop auto corrections
# unsetopt correct_all

#Completition from zsh-lovers
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' \
        max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*:functions' ignored-patterns '_*'

# Prompt

# Colors:
# http://gabri.me/2013/01/custom-colors-in-your-zsh-prompt/
function get_actual_load() {
    echo $(cut -f 1 -d " " /proc/loadavg)
}
local user='%{$fg[green]%}%n%{$reset_color%}@%{$fg[green]%}%m%{$reset_color%}'
local pwd='%{$fg[yellow]%}%~%{$reset_color%}'
local load_average='%{$fg[magenta]%}‹load: $(get_actual_load)›%{$reset_color%}'
local return_code='%(?..%{$fg[red]%}%? ↵%{$reset_color%})'
local git_branch='$(git_prompt_status)%{$reset_color%}$(git_prompt_info)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

PROMPT="${user} ${pwd} %{$fg[blue]%}»%{$reset_color%} "
RPROMPT="${return_code} ${git_branch} ${load_average}"

#quick change directories. Add this to your ~/.zshrc, then just enter “cd …./dir”
rationalise-dot() {
    #MH: if you type ... just instantly cd up
    if [[ $LBUFFER = .. ]]; then
        zle accept-line
        return 0
    fi
    #Normal behaviour of the function
    if [[ $LBUFFER = *..  ]]; then
        LBUFFER+=/..
    else
        LBUFFER+=.
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

#This will make C-z on the command line resume vi again, 
#so you can toggle between them easily
foreground-vi() {
  fg %vi
}
zle -N foreground-vi
bindkey '^Z' foreground-vi

#Directory stack works across sessions.
DIRSTACKSIZE=9
DIRSTACKFILE=~/.zdirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1] && cd $OLDPWD
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

#-------------------------------------------------------------------------

# bindkey -s "ůě" "@"
# bindkey -s "ůš" "#"
# bindkey -s "ůč" "$"
# bindkey -s "ůř" "%"
# bindkey -s "ůž" "^"
# bindkey -s "ůý" "&"
# bindkey -s "ůá" "*"
# bindkey -s "ůí" "{"
# bindkey -s "ůé" "}"
# bindkey -s "ú" "("
# bindkey -s "ůs" "$"
# bindkey -s "ůi" "*"
# bindkey -s "ůr" "^"
# bindkey -s "ůa" "&"
# bindkey -s "ůh" "#"
# bindkey -s "ůp" "%"
# bindkey -s "ůq" "'"
# bindkey -s "ůe" "="
# bindkey -s "ůg" ">"
# bindkey -s "ůl" "<"
# bindkey -s "ůy" "("
# bindkey -s "ůx" ")"
# bindkey -s "ůc" "["
# bindkey -s "ův" "]"
# bindkey -s "ůb" "{"
# bindkey -s "ůn" "}"
# bindkey -s "ům" "~"
# bindkey -s "ůt" "<"
# bindkey -s "ůw" "\`"
# bindkey -s "ůj" "|"
# bindkey -s "ůk" "\\"

#-------------------------------------------------------------------------
# map some keys
bindkey "" backward-char
bindkey "" forward-char

# needs the history-substring-search plugin to be enabled
bindkey "^K" history-substring-search-up
bindkey "^J" history-substring-search-down

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------

#http://zshwiki.org/home/examples/functions
function name() {
  [[ $#@ -eq 1 ]] || { echo Give exactly one argument ; return 1 }
  test -e "$1" || { echo No such file or directory: "$1" ; return 1 }
  local newname=$1
  if vared -c -p 'rename to: ' newname &&
    [[ -n $newname && $newname != $1 ]]
  then
    command mv -i -- $1 $newname
  else
    echo Some error occured; return 1
  fi
}

# Send email with a file.
function mail-file() {
    [[ $1 == "" ]] && { echo "Recepient is missing" ; return 1 }
    [[ $2 == "" ]] && { echo "File path is missing" ; return 1 }
    
    echo "File $2" | mutt -a "$2" -s "File $2" -- $1
}

# Quick upstream git commit fix
function gaddcommitpush() {
    git add -A :/ && git commit -m "$1" && git push
}

# Commits submodule
function gcommitsubmodule() {
    CURRENT_DIR=$(pwd)
    MODULE_DIR=$(git rev-parse --show-toplevel)
    MODULE_NAME=${MODULE_DIR##*/}
    cd $MODULE_DIR/..
    git rev-parse --show-toplevel
    if [[ "$?" == "0" ]]; then
        git add $MODULE_DIR
        git commit -m "Submodule $MODULE_NAME updated"
    else
        echo "Error: Super project was not found."
    fi
    cd $CURRENT_DIR
}

# Opens command in new terminal.
function NT() {
    if [[ "$@" == "" ]]; then
        i3-sensible-terminal
    else
        i3-sensible-terminal -e "$@"
    fi
    #i3-sensible-terminal -e "$@" > /dev/null 2>&1 &
}

#Downloads and enables drupal module
function drdlen() {
    drush dl $1 && drush en $1 -y
}

#Creates new invoice in my invoice folder.
function invoice-new() {
    YEAR=2016
    [[ "$1" == "" ]] && { echo "Enter client name"; return 1 }
    # Invoice dir
    cd ~/Documents/business/faktury/$YEAR
    # Let's show the result
    echo "Year  : $YEAR"
    echo "Client:"
    SOURCE_FILE=$(grep -i -l "$1" ../201?/*.html | sort | tail -n 1)
    cat $SOURCE_FILE | grep -i -m 1 "$1"
    echo
    echo "Source file: $SOURCE_FILE"
    echo
    test ! -e "$SOURCE_FILE" && { echo "No such file or directory: $SOURCE_FILE" ; return 1 }
    SOURCE_NO=$(echo "$SOURCE_FILE" | sed -r 's#^\.\.\/[0-9]+\/([0-9]+).*$#\1#g')
    DEST_NO=$(( $(ls -1 *.html | tail -n 1 | sed -r 's#^([0-9]+).*$#\1#g') + 1 ))
    echo "Source number: $SOURCE_NO"
    echo "Dest number: $DEST_NO"
    [[ "$DEST_NO" -lt 10 ]] && { echo "Dest number is too low, exit"; return 1 }
    DEST_FILE="${DEST_NO}-.html"
    echo
    echo "Is it correct? Ctrl+C to exit"
    read
    cp "$SOURCE_FILE" "$DEST_FILE"
    echo "File coppied to $DEST_FILE"
    sed -i.bak "s/8$SOURCE_NO</8$DEST_NO</g" $DEST_FILE                                         
    sed -i.bak "s/<title>.*<\/title>/<title>invoice-8$DEST_NO<\/title>/g" $DEST_FILE                                         
    # sed -i.bak "s/[0-9]{2}\.[0-9]{2}\.[0-9]{4}/$(date +%Y-%m-%d)/1" $DEST_FILE                                         
    DATE_TODAY=$(date +%d.%m.%Y)
    DATE_DUE_DATE=$(date --date="-14 days ago" +%d.%m.%Y)
    sed -i.bak -r ":a;N;\$!ba;s/[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{4}/$DATE_TODAY/1" $DEST_FILE
    sed -i.bak -r ":a;N;\$!ba;s/[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{4}/$DATE_DUE_DATE/2" $DEST_FILE
    rm $DEST_FILE.bak
    echo "Data in the file were replaced"
    echo
    vim +:99 $DEST_FILE
    chromium-browser $DEST_FILE
}

# Creates dir and makes cd at the same time.
function mkdircd () { mkdir -p "$@" && eval cd "\"\$$#\""; }
# Search and open a dir in current directory structure
function cdfind () { cd **/*$1*(/om[1]); }
function cdd () { cd $(fasd -dlR | grep $(pwd) | grep -m 1 $1) }
# Search and open a file in current directory structure
function vdd () { vim $(cat ~/.vim-fuf-data/mrufile/items | grep $(pwd) | grep -Po "/[^']+" | grep -m 5 $1) }
# Run command multiple times:
# run 5 echo 'Hello World!
run() {
    number=$1
    shift
    for i in `seq $number`; do
      $@
    done
}

#Fasd - jump around
eval "$(fasd --init auto)"
#Key bingins
#bindkey '^X^A' fasd-complete    # C-x C-a to do fasd-complete (fils and directories)
#bindkey '^X^F' fasd-complete-f  # C-x C-f to do fasd-complete-f (only files)
#bindkey '^X^D' fasd-complete-d  # C-x C-d to do fasd-complete-d (only directories))
#Aliases
alias v='f -e vim'
alias o='a -e xdg-open'
alias zz='fasd_cd -d -t'

#Zaw - better incremental search
#https://github.com/zsh-users/zaw
source ~/.zsh/custom/zaw/zaw.zsh
# Add custom source for zaw
source ~/.zsh/custom/zaw-sources/wfasd.zsh
source ~/.zsh/custom/zaw-sources/wfile.zsh
source ~/.zsh/custom/zaw-sources/wfasd-current-dir.zsh
#bind keys
bindkey '' zaw-history
bindkey '' zaw-wfasd
bindkey '' zaw-wfile
#send it to the command line
bindkey -M filterselect '' accept-search
#bindkey -M filterselect '' zaw-callback-append-to-buffer
bindkey -M filterselect '' send-break
bindkey -M filterselect '' send-break
# bindkey -M filterselect '^[[A' up-line-or-history
# bindkey -M filterselect '^[[B' down-line-or-history
zstyle ':filter-select:highlight' matched fg=green
zstyle ':filter-select' extended-search yes
zstyle ':filter-select' rotate-list yes
zstyle ':filter-select' max-lines 30

#Better less: Lesspipe http://www.youtube.com/watch?v=ZEHxG1OhIFo
LESSOPEN="|~/.zsh/custom/lesspipe/lesspipe.sh %s"
export LESSOPEN

#Global aliases
alias -g A='| ag'
alias -g AWK="| awk '{print \$0}'"
alias -g AMP="> /dev/null 2>&1 &"
alias -g CA="2>&1 | cat -A"
alias -g C='| wc -l'
alias -g DN=/dev/null
alias -g ED="export DISPLAY=:0.0"
alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g ETL='|& tail -20'
alias -g ET='|& tail'
alias -g F='| fmt -'
alias -g G='| grep -i'
alias -g H='| head -n 40'
alias -g HL='|& head -20'
alias -g LL="2>&1 | less"
alias -g L="| less"
alias -g LO="localhost"
alias -g LS='| less -S'
alias -g MH='martin.hoger@gmail.com'
alias -g MM='| most'
alias -g ND='*(/om[1])' # newest directory
alias -g NF='*(.om[1])' # newest file
alias -g NE="2> /dev/null"
alias -g NS='| sort -n'
alias -g NULL="> /dev/null 2>&1"
alias -g P='|'
alias -g R='>'
alias -g RNS='| sort -nr'
alias -g S='| sort'
alias -g SED='| sed -r "s///"'
alias -g TL='| tail -20'
alias -g T='| tail -n 40'
alias -g US='| sort -u'
alias -g VM=/var/log/messages
alias -g X0G='| xargs -0 egrep'
alias -g X0='| xargs -0'
alias -g XG='| xargs egrep'
alias -g X='| xargs -I{}'
alias -g SPR="| curl -F 'sprunge=<-' http://sprunge.us"

#Aliases
alias ag="ag -S"
alias aptget="sudo apt-get"
alias agu="sudo apt-get update; sudo apt-get upgrade"
alias agi="sudo apt-get install"
alias agi-backports="sudo apt-get -t wheezy-backports install"
alias agr="sudo apt-get remove"
alias ags="sudo apt-cache search"
alias afs="sudo apt-file search"
alias crontab="crontab -i"
alias d='dirs -v'
alias doc='docker'
alias docr='docker run -it'
alias doce='docker exec -it'
alias doci='docker images'
alias dicom-store-demo-cz="storescu client.fetview.de 22033"
alias dicom-store-demo-de="storescu client.fetview.de 22022"
alias dicom-store-demo-en="storescu client.fetview.de 22044"
alias dicom-store-local-5600="storescu 127.0.0.1 5600"
alias dr='drush'
alias drws='vim +:WatchdogStatus'
alias drwsphp2='drush ws --type=php --count=90'
alias drwsphp3='drush ws --type=php --count=200'
alias drwsphp='drush ws --type=php --count=30'
alias glg="git log --stat --graph --all --decorate"
alias giu="git submodule init; git submodule update"
alias gw='gwenview . > /dev/null 2>&1 &'
alias ha="hamster-cli"
alias i3conf='vim ~/.i3/config'
alias ll-full='ls -rt -d -1 $PWD/*'
alias l='ll'
alias ll='LC_COLLATE="C" ls -alh --group-directories-first'
alias NI="nice -n 19 ionice -c3"
alias N="nice -n 19"
alias rmf='rm -rf'
alias rr='/home/drain/bin/record-region2gif.sh'
alias rw='/home/drain/bin/record-window.sh'
alias t='tree -d -L 2'
alias wedos-mount='/mnt/wedos-mount; cd /mnt/wedos'
alias zshconf='cd ~/.zsh; vim zshrc; source zshrc; cd ~; echo Config reloaded.'
alias zshreload='source ~/.zshrc; echo Config reloaded.'
alias shutdown='sudo shutdown now'
alias poweroff='sudo shutdown now'
alias suspend='sudo pm-suspend'
alias reboot='sudo reboot'
alias sen='docker run --privileged --rm -v /var/run/docker.sock:/run/docker.sock -ti -e TERM tomastomecek/sen'

#Now pressing return-key after entering foobar.tex starts vim with foobar.tex. Calling a html-file runs browser w3m. www.zsh.org 
alias -s txt=vim
alias -s csv=vim
alias -s html=google-chrome
alias -s org=w3m
alias -s doc=libreoffice
alias -s docx=libreoffice
alias -s odt=libreoffice
alias -s ods=libreoffice
alias -s jpg=gwenview
alias -s JPG=gwenview
alias -s jpeg=gwenview
alias -s png=gwenview
alias -s pdf=evince
alias -s xcf=gimp

#We need to make sure these aliases are not defined,
#since we do not want to expand them but call extra functions.
unalias v
unalias z
unalias zz

#When space is pressed.
space-handler() {
    #Expand alias after space
    if [[ $LBUFFER =~ '^[a-zA-Z0-9]+$' ]]; then
        zle _expand_alias
        zle expand-word
    fi
    #Expand global alias after space
    if [[ $LBUFFER =~ ' [A-Z0-9]+$' ]]; then
        zle _expand_alias
        zle expand-word
    fi
    #Insert the space
    zle self-insert
    #When typing z + space start zaw-wfasd
    if [[ $LBUFFER == 'z ' ]]; then
        LBUFFER=""
        zle zaw-wfasd
    fi
    #When typing zz + space start zaw-wfasd-current-dir
    if [[ $LBUFFER == 'zz ' ]]; then
        LBUFFER=""
        zle zaw-wfasd-current-dir
    fi
    #When typing v + space start zaw-wfile
    if [[ $LBUFFER == 'v ' ]]; then
        LBUFFER=""
        zle zaw-wfile
    fi
}
zle -N space-handler
bindkey " " space-handler
bindkey "^ " magic-space           # control-space to bypass completion
bindkey -M isearch " " magic-space # normal space during searches

#Unfortunatelly didn't work for me
#autoload -Uz copy-earlier-word
    #zle -N copy-earlier-word
#bindkey "m" copy-earlier-word

#Start predictive typing
#autoload -Uz predict-on
#zle -N predict-on
#zle -N predict-off
#bindkey '' predict-on
#bindkey '' predict-off


