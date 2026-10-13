

tl() {
    # Check if tmux is running and has sessions
    if ! tmux ls >/dev/null 2>&1; then
        echo "No tmux sessions active."
        return 1
    fi

    local session
    local sessions
    sessions=$(tmux ls -F '#{session_name}')

    local PS3="Select a tmux session: (also use ctrl-b s in tmux): "
    select session in $sessions; do
        if [ -n "$session" ]; then
            tmux attach-session -t "$session"
            break
        else
            echo "Invalid selection."
        fi
    done
}
export -f tl


sesh() {
    if [ -z "$1" ]; then
        echo "Usage: go_sesh <session name> [num windows] [directory] [lunch combo]"
        return 1
    fi

    local session="$1"
    local num_wins="${2:-1}"
    local dir="${3:-.}"
    local lunch="$4"

    if ! tmux has-session -t "$session" 2>/dev/null; then
        # Create a new detached session and set the working directory natively
        tmux new-session -s "$session" -c "$dir" -d

        for i in $(seq 1 "$num_wins"); do
            # Window 1 is created with the session; only create new ones for 2+
            [ "$i" -gt 1 ] && tmux new-window -t "$session" -c "$dir"

            if [ -n "$lunch" ]; then
                tmux send-keys -t "$session" "source build/envsetup.sh && lunch $lunch" C-m
            fi
            tmux send-keys -t "$session" C-l
        done
    fi

    tmux select-window -t "$session:1"
    tmux attach -t "$session"
}
export -f sesh

export GIT_CONFIG_GLOBAL=~/.gitconfig
export NVM_DIR="$HOME/.nvm"

export LESS=-Ri

alias rg='rg --no-ignore-vcs --no-require-git'
alias e="proj ."
alias l="ls -ltrhFa"
alias ll="ls -lFa | less"
alias lr="ls -ltFar"
alias ltr="ls -ltFar"
alias lld="ls -l /dev/mmc*"
alias g="grep -s -IR -i --exclude-dir='tests/' --exclude-dir='prebuilts/' --exclude-dir='out/' --exclude-dir='.git/' --exclude-dir='.repo/' --exclude-dir='external/' --exclude-dir='app/build/' --exclude-dir='build/'"
alias c="clear"
alias s="source ~/.bash_profile"

alias cd1="cd ../"
alias cd2="cd ../../"
alias cd3="cd ../../../"
alias cd4="cd ../../../../"
alias cd5="cd ../../../../../"
alias cd6="cd ../../../../../../"
alias cd7="cd ../../../../../../../"
alias cd8="cd ../../../../../../../../"
alias cd9="cd ../../../../../../../../../"
alias cd0="cd ../../../../../../../../../../"

alias f="find . -type d \( -path ./out -o -name tests -o -name .git -o -path ./.repo \) -prune -false -o -iname"

git config --global difftool.vimdiff-write.cmd \
  'vimdiff -c "set noro modifiable" -c "wincmd l" "$LOCAL" "$REMOTE"'
git config --global diff.tool vimdiff-write

# the exclude dirs match on the single directory name only. i.e. 'app/build' will not work
alias g="grep -s -IR -i  --exclude-dir='build/' --exclude-dir='tests/' --exclude-dir='prebuilts/' --exclude-dir='out/' --exclude-dir='.git/' --exclude-dir='.repo/' --exclude-dir='external/'"
alias gs="git status"
alias gd="git difftool -y --tool=vimdiff-write"
alias gg="git grep -i"

alias tree="tree -a -I .git"
alias t="tree -a -L 2"

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

export EDITOR=/usr/bin/vim

# no git branch
#PROMPT_COMMAND='RET=$?; PS1="\[\e[32m\]\u@\h\[\e[0m\] \w: "'
 
# with git branch
PROMPT_COMMAND='RET=$?;
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null);
  [ -n "$BRANCH" ] && BRANCH=" ($BRANCH)";
  PS1="\[\e[32m\]\u@\h\[\e[0m\] \w\[\e[33m\]${BRANCH}\[\e[0m\]: "'

# Append the current session's new lines immediately after every command
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"
