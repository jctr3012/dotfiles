# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jc/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/jc/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/home/jc/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/home/jc/.fzf/shell/key-bindings.zsh"
