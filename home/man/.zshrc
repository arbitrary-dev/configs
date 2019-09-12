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

# Scala Metals

build-metals() {
  local version="$1"
  [ -z "$version" ] && echo "No version specified!" && return 1
  read -k1 -s "a?Build metals-vim v$version (previous will be removed)? "
  echo
  rm -f ~/.local/bin/metals-vim*
  coursier bootstrap \
    --java-opt -Xss4m \
    --java-opt -Xms100m \
    --java-opt -Dmetals.client=coc.nvim \
    org.scalameta:metals_2.12:$version \
    -r bintray:scalacenter/releases \
    -r sonatype:snapshots \
    -o ~/.local/bin/metals-vim-$version -f \
  && ln -s ~/.local/bin/metals-vim{-$version,}
}
