git_venv_prompt() {
    # Define the colors that will be used
    # color palette -> https://robotmoon.com/256-colors/
    local blue="\[$(tput setaf 39)\]"
    local orange="\[$(tput setaf 208)\]"
    local green="\[$(tput setaf 25)\]"
    local yellow="\[$(tput setaf 220)\]"
    local red="\[$(tput setaf 196)\]"
    local cyan="\[$(tput setaf 46)\]"
    local magenta="\[$(tput setaf 15)\]"
    local violet="\[$(tput setaf 66)\]"
    local white="\[$(tput setaf 225)\]"
    local tab_magenta="\[$(tput setab 53)\]"
    local tab_ps="\[$(tput setab 234)\]"
    local tab_git="\[$(tput setab 234)\]"
    local reset="\[$(tput sgr0)\]"

    local status=""

    # Add <user>@<host>:<current directory> information
    PS1="$tab_ps$green \u@\h:$reset$tab_ps$blue\W/$reset"

    # Check that we're in a directory managed by git
    if $(git rev-parse &> /dev/null); then
        # Check for any changes
        git update-index --really-refresh -q &> /dev/null

        # Save current directory and move to the top directory of the git repo
        pushd . &> /dev/null
        cd "$(git rev-parse --show-toplevel)"

        PS1+="$tab_git$yellow ($reset$tab_git$cyan"

        # Try to get the current branch name
        PS1+=$(git symbolic-ref --quiet --short HEAD 2> /dev/null) \
            || PS1+=$(git rev-parse --short HEAD 2> /dev/null) \
            || PS1+="unknown branch"

        # Check that we're not in a subdirectory of .git
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]
        then
            # Check for uncomitted changes
            if ! $(git diff --staged --quiet); then
                status+="$tab_git$green+"
                status+=$(git diff --staged --numstat | wc -l | sed 's/ //g')
            fi

            # Check for unstaged changes
            if ! $(git diff-files --quiet); then
                status+="$tab_git$yellow!"
                status+=$(git diff-files | wc -l | sed 's/ //g')
            fi

            # Check for untracked files
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                status+="$tab_git$red?"
                status+=$(git ls-files --others --exclude-standard \
                    | wc -l | sed 's/ //g')
            fi

            if [ -n "$status" ]; then
                status=" $status"
            fi
        fi
        PS1+="$status$reset$tab_git$yellow) $reset"

        # Return to the current directory
        popd &> /dev/null
    fi

    # Handling of Python virtual environments
    # https://stackoverflow.com/a/20026992/1917160
    if [ -n "$VIRTUAL_ENV" ]; then
        # Strip out the path and just leave the env name
        venv="${VIRTUAL_ENV##*/}"
    else
        # In case you don't have one activated
        venv=''
    fi
    if [ -n "$venv" ]; then
        PS1="$tab_magenta$white($venv)$reset$PS1"
    fi

    # \$ is the bash prompt
    PS1+="${reset}$tab_git$reset\$ "

    export PS1
}

# Run the git_bash_prompt function at every prompt
PROMPT_COMMAND=git_venv_prompt

export VIRTUAL_ENV_DISABLE_PROMPT=1
