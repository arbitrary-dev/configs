[[ -f /etc/.profile ]] && source /etc/.profile

export M2_HOME=~/work/apache-maven-3.2.5
export MAVEN_OPTS="-Xmx1g"

alias sf=screenfetch
alias nc=ncmpcpp

alias todo="vim ~/Documents/_misc/todo"
alias notes="vim ~/Documents/_misc/notes"
alias vr="vim ~/.zshrc"
alias sr="source ~/.zshrc"

export MY_ISSUES=~/Documents/issue
issue() { vim $MY_ISSUES/$1; }
issue-del() { rm $MY_ISSUES/$1; }
issue-show() { [[ $1 =~ "^[A-Z]+-[0-9]+$" ]] && { printf "$1 "; head -1 $MY_ISSUES/$1; } || echo $1; }
issues() {
  ls $MY_ISSUES | \
  xargs -n1 -I% \
  zsh -c "$(declare -f issue-show); issue-show %;"
}

export MY_DOCS=~/Documents
doc() {
  local str=$MY_DOCS
  for i in $@; do str+=/**/*$i*; done

  local files=($(eval "ls $str 2> /dev/null"))

  if (( $#files > 1 )); then
    echo "Which one?"
    for f in $files; do echo $f; done
    return 1
  elif (( !$#files )); then
    echo "No such document!"
    return 1
  fi

  if [[ $files = *.pdf ]]; then
    mupdf $files &
    disown
  else
    vim $files
  fi
}
docs() { ls $MY_DOCS | sed s/.pdf//; }

export MY_SCRIPTS=~/work/.scripts
ss() { vim $MY_SCRIPTS/$1; }

if [[ -d $MY_SCRIPTS ]]; then
  for s in $(ls $MY_SCRIPTS/*-source.sh); do
    source $s
  done
fi

post-json() { curl -k -X POST -H "Content-Type: application/json" -d $2 $1; }
sbt-to() { sbt "testOnly *$1* ${2:+-- -z \"$2\"}"; }

export PATH="\
$MY_SCRIPTS:\
$M2_HOME/bin:\
$PATH"
