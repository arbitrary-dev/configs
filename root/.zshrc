sync() {
  log 'Sync portage' emerge -q --sync
  log 'Sync overlays' layman -qS

  printf '\nEmerging...\n'
  emerge -qauDN --keep-going @world
}

