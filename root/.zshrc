#[[ $PATH != *distcc* ]] && export PATH="/usr/lib/distcc/bin:${PATH}"
export PS1=$'%{\e[0;30m\e[41m%} %n %{\e[0m\e[0;31m%} %1d %{\e[0m%}'
export PATH=$PATH:/home/semyon/scripts

# aliases

alias mnt="mount -ouser,utf8"
alias sws="swapon --show=name,size,used"
alias bt="for s in bluetooth bluealsa; do rc-service \$s start; done"
alias ecurr="watch -ctn 30 genlop -c"
alias ehist="genlop -it"

# utilities

eclean() {
  emerge --ask --depclean \
  && eclean-dist --deep --fetch-restricted \
  && rm -rf /var/tmp/portage
}

upd-time() {
  echo "Before: " $(date) && \
  rc-service ntp-client start && \
  echo "After: " $(date)
}

esync() {
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
