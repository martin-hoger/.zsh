zmodload zsh/parameter

function zaw-src-wfile() {
    candidates=($(cat ~/.cache/ctrlp/mru/cache.txt))
    actions=("zaw-callback-wfile-vim" "zaw-callback-execute" "zaw-callback-append-to-buffer" "zaw-callback-replace-buffer")
    act_descriptions=("open in vim" "execute" "append to edit buffer" "replace edit buffer")
}

zaw-register-src -n wfile zaw-src-wfile

function zaw-callback-wfile-vim() {
    if [[ "$BUFFER" == "" ]]; then
        #If commandline is empty, just open vim.
        BUFFER="vim $1"
        zle accept-line
    else
        #Add the to commandline if there is already something.
        BUFFER="$BUFFER$1"
        zle end-of-line
    fi
}

