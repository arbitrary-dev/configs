export PS1='%B%F{green}'$PS1
export PATH="\
"~"/projects/scripts:\
"~"/.local/bin:\
$PATH"

alias vr="vim ~/.zshrc"

export PATH=$PATH:~/.jenv/bin
eval "$(jenv init -)"

# Work

export MY_SCRIPTS=~/work/.scripts
export PATH=$PATH:$MY_SCRIPTS
ss() { vim $MY_SCRIPTS/${1:-misc}-source.sh; }

if [[ -d $MY_SCRIPTS ]]; then
  for s in $(ls $MY_SCRIPTS/*-source.sh); do
    source $s
  done
fi

# JIRA

j() { jira show $* | \less -iXFR; }
js() { jira list | less; }
alias jw="jira work"
