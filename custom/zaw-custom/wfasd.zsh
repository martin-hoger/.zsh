zmodload zsh/parameter

function zaw-src-wfasd() {
    candidates=($(fasd -dlR))
    actions=("zaw-callback-wfasd-execute" "zaw-callback-execute" "zaw-callback-append-to-buffer" "zaw-callback-replace-buffer")
    act_descriptions=("execute" "append to edit buffer" "replace edit buffer")
}

zaw-register-src -n wfasd zaw-src-wfasd

function zaw-callback-wfasd-execute() {
    if [[ "$BUFFER" == "" ]]; then
        #If commandline is empty, just open the dir.
        BUFFER="cd $1"
        zle accept-line
    else
        #Add the to commandline if there is already something.
        BUFFER="$BUFFER$1"
        zle end-of-line
    fi

}

