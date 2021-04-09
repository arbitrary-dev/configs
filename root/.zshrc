export PS1='%B%F{red}'$PS1

export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"

# Usage: p1 <patchfile
alias p1="patch -p1"

alias regen-manifest="repoman manifest"

alias mc="make menuconfig"
alias mo="make oldconfig"

bkernel() {
  local flags=()
  if read -q "?Rebuild external modules? "; then
    flags+="--rebuild-external-modules"
  fi
  echo

  ccache-enable
  TMPDIR= \
  KERNEL_DIR=/tmp/buildkernel \
  buildkernel "${flags[@]}"
}

emrg() {
  if (( $# )); then
    emerge "${@}"
  else
    emerge -avuDN --keep-going @world
  fi
}

alias emrg-c="FEATURES=ccache emrg"
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
    --binutils '=2.34*' --gcc '=9.3*' --kernel '=5.4*' --libc '=2.32*'
}

alias docker-clean="docker system prune --volumes"

resize-tmp() {
  local size="3.0G"
  [ `df --output=size /tmp | tail -1` != "$size" ] \
  && size=${1:-10g}
  if mount -o remount,size=${size} /tmp; then
    echo "Size of /tmp is set to: $size"
  fi
}

efi-sign() {
  [[ -z ${SECUREBOOTKEY} && -z ${SECUREBOOTCERT} ]] \
  && eval "$(grep ^SECUREBOOT `which buildkernel`)"

  if [[ -z ${SECUREBOOTKEY} || -z ${SECUREBOOTCERT} ]]; then
    echo "Please specify SECUREBOOTKEY and SECUREBOOTCERT env vars."
    return 1
  fi

  local in="$1"
  local out="$in.signed"

  if sbsign --key "${SECUREBOOTKEY}" --cert "${SECUREBOOTCERT}" \
            --output "$out" \
            "$in"; then
    echo "Signed: $out"
  fi
}
