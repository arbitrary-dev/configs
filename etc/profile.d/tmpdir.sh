if [ $USER ]; then
  export TMPDIR="/tmp/$USER"
  # To spare SSD
  export XDG_CACHE_HOME="$TMPDIR/.cache"
  # Exclude sbt-coursier plugin
  export COURSIER_CACHE="/home/$USER/.coursier/cache/v1"
fi
