export PS1='%B%F{red}'$PS1

export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"

# Usage: p1 <patchfile
alias p1="patch -p1"

alias regen-manifest="repoman manifest"

alias bkernel="KERNEL_DIR=/tmp/buildkernel buildkernel --rebuild-external-modules"

emrg() {
  if (( $# )); then
    emerge "${@}"
  else
    emerge -quDN --keep-going @world
  fi
}

alias emrgc="FEATURES=ccache emrg"
emrg-preserved-rebuild() { emerge ${1:--a} @preserved-rebuild; }
alias ecurr="watch -ctn 30 genlop -c"
alias ehist="genlop -it"
alias ecln="emerge --ask --depclean"
alias eclnd="eclean-dist --deep --fetch-restricted"
alias eadd="emerge --noreplace"
alias emask="qlist -IC"

esync() {
  ecln || return 1

  local sync_log="/tmp/.emaint.log"

  printf "\nSyncing... "
  if emaint sync -a > $sync_log; then
    echo "done"
  else
    echo "FAILED $sync_log"
    return 1
  fi

  emerge -avuDN @world
}

crossdev-netbook() {
  crossdev --target i686-pc-linux-gnu \
    --binutils '=2.33*' --gcc '=9.2*' --kernel '=5.4*' --libc '=2.30*'
}

alias docker-clean="docker system prune --volumes"
