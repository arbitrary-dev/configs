export PS1='%B%F{green}'$PS1
export PATH="\
"~"/projects/scripts:\
"~"/.local/bin:\
$PATH"

export MY_DOCS=~/docs

alias vr="vim ~/.zshrc"

export PATH=$PATH:~/.jenv/bin
eval "$(jenv init -)"

# Phone

alias mount-phone="go-mtpfs /mnt/phone &"
alias umount-phone="fusermount -u /mnt/phone"

# Work

jnote() {
  docker run -v "$PWD":/home/jovyan/work -p 8888:8888 jupyter/scipy-notebook
}

setup-ssh-terminal() {
  ssh $1 mkdir -p .terminfo/r
  scp /usr/share/terminfo/r/rxvt-unicode-256color $1:.terminfo/r
}

source ~/work/_issues/source-me.sh

export MY_SCRIPTS=~/work/_scripts
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
  if [ -z "$version" ]; then
    echo -e "No version specified!\nTry: https://scalameta.org/metals/docs/editors/vim.html#generating-metals-binary"
    return 1
  fi
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
