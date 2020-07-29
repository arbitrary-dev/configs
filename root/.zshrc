export PS1='%B%F{red}'$PS1

export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"

# Usage: p1 <patchfile
alias p1="patch -p1"

alias regen-manifest="repoman manifest"

alias emrg="emerge -quDN --keep-going @world"
alias emrgc="FEATURES=ccache emrg"
emrg-preserved-rebuild() { emerge ${1:--a} @preserved-rebuild; }
alias ecurr="watch -ctn 30 genlop -c"
alias ehist="genlop -it"
alias ecln="emerge --ask --depclean"
alias eclnd="eclean-dist --deep --fetch-restricted"

esync() {
  ecln || return 1

  local sync_log="/tmp/.emaint.log"

  printf "Syncing... "
  if emaint sync -a > $sync_log; then
    echo "done"
  else
    echo "FAILED $sync_log"
    return 1
  fi

  emerge -avuDN @world
}
