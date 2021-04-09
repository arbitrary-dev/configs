if [ $USER ]; then
  export TMPDIR="/tmp/$USER"
  # To spare SSD
  export XDG_CACHE_HOME="$TMPDIR/.cache"
  # Exclude sbt-coursier plugin
  export COURSIER_CACHE="/home/$USER/.coursier/cache/v1"
fi

mkdir /tmp/var 2> /dev/null \
&& rm -rf /var/tmp \
&& ln -s /tmp/var /var/tmp

mkdir /tmp/docker 2> /dev/null \
&& chmod 0700 /tmp/docker \
&& rm -rf /opt/docker/tmp \
&& ln -s /tmp/docker /opt/docker/tmp
