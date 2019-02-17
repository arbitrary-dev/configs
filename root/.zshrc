#[[ $PATH != *distcc* ]] && export PATH="/usr/lib/distcc/bin:${PATH}"
export PS1=$'%{\e[0;30m\e[41m%} %n %{\e[0m\e[0;31m%} %1d %{\e[0m%}'
export PATH=$PATH:/home/semyon/scripts

# aliases

alias sws="swapon --show=name,size,used"
alias eclean-dist="eclean-dist --deep --fetch-restricted"
alias bt="for s in bluetooth bluealsa; do rc-service \$s start; done"

# utilities

upd-time() {
  echo "Before: " $(date) && \
  rc-service ntp-client start && \
  echo "After: " $(date)
}

sync() {
  local emerge

  printf "Sync portage... "
  emerge -q --sync &> /dev/null

  if [[ $? = 0 ]]; then
    emerge=1
    echo "done."
  else
    echo "failed!"
  fi

  printf "Sync overlays... "
  layman -qS &> /dev/null

  if [[ $? = 0 ]]; then
    emerge=1
    echo "done."
  else
    echo "failed!"
  fi

  if [[ -n $emerge ]]; then
    echo "Emerging..."
    emerge -qauDN --keep-going @world
  fi
}

alias emrg="emerge -quDN --keep-going @world"

backup() {
  local user=/home/semyon
  local files="
    $user/.config/awesome/rc.lua
    $user/.config/fontconfig/fonts.conf
    $user/.config/awesome/themes/default/theme.lua
    $user/.config/luakit/theme.lua
    $user/.local/share/luakit/styles
    $user/.sxiv/exec/image-info
    $user/.mpd/mpd.conf
    $user/.mpdscribble/mpdscribble.conf
    $user/.ncmpcpp/config
    $user/.vimrc
    $user/.vim/colors
    $user/.bashrc
    $user/.xinitrc
    $user/.Xresources
    $user/scripts

    /root/.vimrc
    /root/.bashrc

    /usr/src/linux/.config

    /etc/acpi/events
    /etc/distcc/hosts
    /etc/udev/rules.d
    /etc/fstab
    /etc/default/grub
    /etc/local.d/01-intel.start
    /etc/wpa_supplicant/wpa_supplicant.conf
    /etc/ntp.conf
    /etc/X11/xorg.conf.d

    /etc/conf.d/distccd
    /etc/conf.d/net

    /etc/portage/make.conf
    /etc/portage/package.*
    /etc/portage/savedconfig
  "

  local tar="tar --ignore-failed-read -cvJf"
  local archive=backup_`date +%d-%m-%Y`.tar.xz

  $tar $archive $files

  echo "Backup archive '$archive' was created!"
}

_press_space() {
  read -sk1 ?"Press [space] to continue... "
  printf "\e[80D\e[K"
}

grub-upd() {
  mount /boot &> /dev/null
  grub-mkconfig -o /boot/grub/grub.cfg
}

bkrn() {
  local wd=$(pwd)
  local src=/usr/src/linux
  local name=`stat $src | head -n1 | sed "s/.+'(.+)'/\1/"`

  echo "Build kernel for $name"
  echo
  _press_space

  # prepare to build in /tmp

  local cfg=$src/.config
  local bdir=/tmp/kernel-build

  mkdir -p $bdir

  if [[ ! -f $bdir/.config && -f $cfg ]]; then
    echo "Copying $cfg to $bdir ..."
    cp $cfg $bdir &> /dev/null
  fi
  cfg=$bdir/${cfg##*/}

  cd $src
  make mrproper

  # .config

  if [[ ! -f $cfg ]]; then
    echo "Enter path to previous ${cfg##*/} (/root/backup/.config-*):"

    local prev
    vared prev
    printf "\e[1A\e[K\e[1A\e[K"

    if [[ -f $prev ]]; then
      cp $prev $cfg
      echo "$prev has been copied to $cfg"
    elif [[ -n $prev ]]; then
      echo "$prev is not found!"
      echo
      _press_space
    fi
  fi

  # make silentoldconfig

  local wo_distcc=${PATH//\/usr\/lib\/distcc\/bin:/}
  if [[ -f $cfg ]]; then
    echo "Update previous ${cfg##*/}"
    PATH=$wo_distcc make O=$bdir silentoldconfig
  fi

  # make menuconfig

  local r=y
  echo
  if [[ -f $cfg ]]; then
    read -q r?"Make menuconfig? "
    echo
  fi
  [[ $r = y ]] && PATH=$wo_distcc make O=$bdir menuconfig

  PATH=$wo_distcc make O=$bdir modules_prepare

  # make

  echo
  if [[ -f $cfg ]]; then
    read -q r?"Build kernel? "
    echo
  fi
  # [[ $r = y ]] && time pump make O=$bdir -j21 -l4
  [[ $r = y ]] && time make O=$bdir -j4
  [[ $? != 0 ]] && return

  # initramfs

  local susp_conf=/etc/suspend.conf
  local susp_resume=/usr/lib/suspend/resume

  if [[ -f $susp_conf && -f $susp_resume ]]; then
    # enable resume from hibernate

    local ovr=/var/lib/genkernel/overlay
    local lrc=/usr/share/genkernel/defaults/linuxrc

    cp $lrc{,.uswsusp}
    cat $lrc | awk '!n  { print "swsusp_resume() {\n\t/sbin/resume\n}\n"; --n } /^$/ { --n } 1' n=2 > $lrc.uswsusp

    mkdir -p $ovr/etc $ovr/sbin
    cp $susp_conf $ovr/etc
    cp $susp_resume $ovr/sbin

    genkernel --kerneldir=$bdir --kernel-config=$cfg --linuxrc=$lrc.uswsusp --initramfs-overlay=$ovr initramfs
  else
    genkernel --kerneldir=$bdir --kernel-config=$cfg initramfs
  fi

  # make @module-rebuild

  read -q ?"Rebuild modules? "
  if [[ $? = 0 ]]; then
    echo
    emerge -q @module-rebuild
  fi

  mount /boot &> /dev/null
  make O=$bdir modules_install
  make O=$bdir install

  # upd /boot

  echo
  local old=/boot/old
  mkdir -p $old
  mv /boot/*.old $old
  grub-upd
  echo

  # backup

  local bak_dir=~/backup
  local bak_file=.config-${name#*-}

  mkdir -p $bak_dir
  cp $cfg $src/${cfg##*/}
  cp $cfg $bak_dir/$bak_file

  [[ $? = 0 ]] && echo "${cfg##*/} backup was made at $bak_dir/$bak_file"
  echo "Done!"

  cd $wd
}

_log() { printf "$1... "; }
_done() {
  local res=$?
  (( $res )) && echo "fail!" || echo "done."
  return $res
}

_count() {
  local t=$1
  local c=$2

  if (( $c == 0 )); then
    printf "no ${t}s"
  else
    printf "$c $t"
    (( $c > 1 )) && printf s
  fi

  echo
}

_mount_device() {
  local err

  _log "Mounting device"
  err=$(mount -t auto /dev/sdb1 /mnt/usb 2>&1 >/dev/null)
  _done

  if [[ -n $err ]]; then
    echo $err
    return 1
  fi
}

_umount_device() {
  _log "Unmounting device"
  umount /mnt/usb
  _done
}

get-photos() {
  echo "Get photos into $(pwd)"
  _press_space

  _mount_device

  (( $? )) && return 1

  if [[ ! -d /mnt/usb/DCIM ]]; then
    echo "No DCIM directory on device!"
    _umount_device
    return 1
  fi

  local fs
  local pc=0
  local vc=0

  _log "Scanning device"

  for f in $(find /mnt/usb/DCIM -iname '*JPG'); do
    [[ -n $fs ]] && fs+=" "
    fs+=$f
    pc=$(($pc+1))
  done

  for f in $(find /mnt/usb/DCIM -iname '*MP4'); do
    [[ -n $fs ]] && fs+=" "
    fs+=$f
    vc=$(($vc+1))
  done

  _done

  echo "Found: $(_count photo $pc) and $(_count video $vc)"

  if (( $pc == 0 && $vc == 0 )); then
    _umount_device
    return
  fi

  local action
  local r
  setopt -s nocasematch

  read r?"[move], copy or abort? "

  if [[ $r =~ "^(q|quit|a|abort)$" ]]; then
    _umount_device
    return
  elif [[ $r =~ "^(|m|move)$" ]]; then
    action=mv
    _log "Moving to $(pwd)"
  elif [[ $r =~ "^(c|copy)$" ]]; then
    action=cp
    _log "Copying to $(pwd)"
  fi

  printf $fs | xargs -d\  -I% $action % ./
  _done

  _log "Changing rights"
  chown -R semyon:semyon .
  _done

  _umount_device
}
