export PS1='%B%F{red}'$PS1

export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"

alias esync="emaint sync -a"
alias ecurr="watch -ctn 30 genlop -c"
alias ehist="genlop -it"
alias ecln="emerge --ask --depclean"
alias eclnd="eclean-dist --deep --fetch-restricted"
