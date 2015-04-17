zmodload zsh/parameter

function zaw-src-wfasd-current-dir() {
    candidates=($(fasd -dlR | grep $(pwd)))
    actions=("zaw-callback-execute" "zaw-callback-append-to-buffer" "zaw-callback-replace-buffer")
    act_descriptions=("execute" "append to edit buffer" "replace edit buffer")
}

zaw-register-src -n wfasd-current-dir zaw-src-wfasd-current-dir

